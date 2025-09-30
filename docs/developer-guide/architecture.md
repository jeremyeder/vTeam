# Developer Architecture Guide

> Deep-dive technical guide for vTeam platform contributors

## Introduction

This guide provides detailed technical information for developers contributing to the vTeam platform. It complements the [architecture overview](../architecture/README.md) with implementation details, testing strategies, and development workflows.

**Prerequisites**: Familiarity with Kubernetes, Go, React/NextJS, and Python.

## Architecture Overview

vTeam follows a microservices architecture deployed on Kubernetes/OpenShift using the Operator pattern for workflow orchestration. See the [C4 model diagrams](../../architecture/diagrams/) for visual architecture reference.

### Design Philosophy

1. **Kubernetes-Native**: Leverage K8s primitives (CRs, Operators, Jobs) instead of external workflow engines
2. **Declarative**: Users declare desired state (AgenticSession CR), system reconciles to that state
3. **Multi-Tenant**: Project-based namespace isolation with RBAC enforcement
4. **Ephemeral Execution**: Runner pods created on-demand, terminated after completion
5. **Scalable**: Stateless containers, horizontal scaling, resource quotas

## Container Deep Dive

### Frontend Container

**Source**: `components/frontend/`

**Technology**: NextJS 14 (React), TypeScript, Shadcn UI

#### Component Responsibilities

**Session Management UI** (`src/app/sessions/`)
- Create new agentic sessions
- Monitor real-time progress
- Display session results
- Manages session state via React hooks

**Project Management UI** (`src/app/projects/`)
- CRUD operations for multi-tenant projects
- Project selection and navigation
- Project resource quota display

**Settings & Secrets UI** (`src/app/settings/`)
- Runner secret configuration (Anthropic API keys)
- Per-project secret isolation
- Secure credential input (never displayed after creation)

**Authentication Handler** (`src/lib/auth.ts`)
- OpenShift OAuth integration via NextAuth.js
- Session token management
- Role-based UI rendering

#### Development Workflow

```bash
# Run locally (development mode)
cd components/frontend
npm install
npm run dev
# Access http://localhost:3000

# Build for production
npm run build
npm start

# Lint and type-check
npm run lint
npm run type-check

# Container build
docker build -t vteam-frontend:dev .
```

#### Testing Strategy

- **Unit Tests**: Jest + React Testing Library for components
- **Integration Tests**: Playwright for E2E workflows
- **API Mocking**: Mock Backend API calls during tests
- **Accessibility**: Automated a11y checks with axe-core

#### Key Files

- `src/app/layout.tsx` - Root layout with auth provider
- `src/lib/api.ts` - Backend API client
- `src/components/` - Reusable UI components
- `src/hooks/` - Custom React hooks

---

### Backend Container

**Source**: `components/backend/`

**Technology**: Go, Gin framework, client-go

#### Component Responsibilities

**Projects API** (`pkg/api/projects/`)
- `GET /api/projects` - List projects for authenticated user
- `POST /api/projects` - Create new project (creates Project CR)
- `GET /api/projects/{id}` - Get project details
- `PUT /api/projects/{id}` - Update project
- `DELETE /api/projects/{id}` - Delete project (deletes Project CR)

**Sessions API** (`pkg/api/sessions/`)
- `GET /api/sessions` - List sessions for project
- `POST /api/sessions` - Create session (creates AgenticSession CR)
- `GET /api/sessions/{id}` - Get session status
- `PUT /api/sessions/{id}` - Update session
- `DELETE /api/sessions/{id}` - Delete session

**Secrets API** (`pkg/api/secrets/`)
- `GET /api/secrets` - List runner secrets for project
- `POST /api/secrets` - Create secret (creates K8s Secret)
- `DELETE /api/secrets/{id}` - Delete secret

**RBAC Middleware** (`pkg/middleware/rbac.go`)
- Authenticates requests via OAuth token
- Validates user access to project namespace
- Enforces multi-tenancy (users can only access their projects)

**Kubernetes Client** (`pkg/k8s/client.go`)
- Wraps client-go for CR management
- Handles Project and AgenticSession CRs
- Manages Kubernetes Secrets

#### Development Workflow

```bash
# Run locally (requires kubeconfig)
cd components/backend
go run cmd/server/main.go

# Test
go test ./...

# Lint
golangci-lint run

# Container build
docker build -t vteam-backend:dev .
```

#### Testing Strategy

- **Unit Tests**: Table-driven tests for handlers and middleware
- **Integration Tests**: Test against real K8s cluster (kind)
- **Mocking**: Mock Kubernetes client for isolated tests
- **API Tests**: HTTP request/response validation

#### Key Files

- `cmd/server/main.go` - Entry point
- `pkg/api/` - API handlers
- `pkg/middleware/` - HTTP middleware
- `pkg/k8s/` - Kubernetes client wrapper
- `pkg/models/` - Data models

#### API Contract Example

```go
// POST /api/sessions
type CreateSessionRequest struct {
    Prompt      string `json:"prompt" binding:"required"`
    Model       string `json:"model" binding:"required"`
    Temperature float64 `json:"temperature,omitempty"`
    Timeout     int    `json:"timeout,omitempty"`
    ProjectID   string `json:"projectId" binding:"required"`
}

type CreateSessionResponse struct {
    ID        string `json:"id"`
    Status    string `json:"status"`
    CreatedAt string `json:"createdAt"`
}
```

---

### Operator Container

**Source**: `components/operator/`

**Technology**: Go, Kubebuilder, controller-runtime

#### Component Responsibilities

**Project Controller** (`controllers/project_controller.go`)
- Watches Project CRs
- Reconciliation logic:
  1. Check if Project CR exists
  2. Create namespace (if needed)
  3. Apply ResourceQuotas
  4. Apply RBAC (RoleBindings)
  5. Update Project CR status

**Session Controller** (`controllers/session_controller.go`)
- Watches AgenticSession CRs
- Reconciliation logic:
  1. Check if AgenticSession CR exists
  2. Validate project reference
  3. Create Kubernetes Job (if phase == "Pending")
  4. Monitor Job status
  5. Update AgenticSession CR status based on Job

**Resource Manager** (`pkg/resources/manager.go`)
- Creates ResourceQuotas per project
- Applies NetworkPolicies for tenant isolation
- Manages RBAC policies

**Job Orchestrator** (`pkg/jobs/orchestrator.go`)
- Constructs Job spec for Runner pod
- Injects secrets (Anthropic API key) as env vars
- Sets resource limits
- Configures pod labels and annotations

#### Development Workflow

```bash
# Run locally (watches cluster)
cd components/operator
make install  # Install CRDs
make run      # Run controller locally

# Test
make test

# Container build
make docker-build IMG=vteam-operator:dev

# Deploy to cluster
make deploy IMG=vteam-operator:dev
```

#### Testing Strategy

- **Unit Tests**: Test reconciliation logic in isolation
- **envtest**: Test against simulated K8s API server
- **Integration Tests**: Deploy to kind cluster and verify CRs

#### Reconciliation Pattern

```go
func (r *SessionReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    // Fetch AgenticSession CR
    session := &v1alpha1.AgenticSession{}
    if err := r.Get(ctx, req.NamespacedName, session); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // If session is pending, create Job
    if session.Status.Phase == "Pending" {
        job := r.constructJobForSession(session)
        if err := r.Create(ctx, job); err != nil {
            return ctrl.Result{}, err
        }
        session.Status.Phase = "Running"
        if err := r.Status().Update(ctx, session); err != nil {
            return ctrl.Result{}, err
        }
    }

    // If Job completed, update session status
    job := &batchv1.Job{}
    if err := r.Get(ctx, types.NamespacedName{Name: session.Name, Namespace: session.Namespace}, job); err == nil {
        if job.Status.Succeeded > 0 {
            session.Status.Phase = "Completed"
            r.Status().Update(ctx, session)
        } else if job.Status.Failed > 0 {
            session.Status.Phase = "Failed"
            r.Status().Update(ctx, session)
        }
    }

    return ctrl.Result{RequeueAfter: 10 * time.Second}, nil
}
```

#### Key Files

- `controllers/` - Reconciliation controllers
- `api/v1alpha1/` - CR type definitions
- `config/crd/` - CRD YAML manifests
- `config/rbac/` - RBAC for operator

---

### Runner Container

**Source**: `components/runners/claude-code-runner/`

**Technology**: Python, Claude Code CLI, Anthropic SDK, MCP

#### Component Responsibilities

**Agent Loader** (`src/agents/loader.py`)
- Loads 17 specialized AI agents from YAML definitions
- Provides agent context to Session Executor
- Supports agent chaining and workflows

**MCP Integration** (`src/mcp/integration.py`)
- Model Context Protocol for browser automation
- Enables web scraping and interaction capabilities
- Integrates with Session Executor

**Session Executor** (`src/executor/session.py`)
- Main execution loop for AI tasks
- Coordinates agents and MCP tools
- Writes results to AgenticSession CR status

**Claude API Client** (`src/clients/anthropic_client.py`)
- Wraps Anthropic Python SDK
- Handles API authentication (from K8s Secret)
- Manages streaming responses

#### Development Workflow

```bash
# Run locally (requires ANTHROPIC_API_KEY env var)
cd components/runners/claude-code-runner
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m src.main --session-id test-session

# Test
pytest tests/

# Lint
black src/ tests/
flake8 src/ tests/

# Container build
docker build -t vteam-runner:dev .
```

#### Testing Strategy

- **Unit Tests**: Mock Anthropic API calls
- **Integration Tests**: Test against real API (with quotas)
- **Agent Tests**: Validate agent loading and chaining
- **MCP Tests**: Mock browser interactions

#### Execution Flow

```python
# Simplified execution logic
async def execute_session(session_id: str):
    # Load session from CR
    session = await load_session_cr(session_id)

    # Load agents
    agents = AgentLoader().load_agents()

    # Initialize MCP if needed
    mcp = MCPIntegration() if session.spec.mcp_enabled else None

    # Execute with Claude API
    client = AnthropicClient(api_key=os.getenv("ANTHROPIC_API_KEY"))
    result = await client.run_agents(
        prompt=session.spec.prompt,
        agents=agents,
        mcp=mcp,
        model=session.spec.model
    )

    # Write results back to CR
    session.status.phase = "Completed"
    session.status.results.output_data = result.content
    session.status.results.metrics.tokens_used = result.tokens
    await update_session_cr(session)
```

#### Key Files

- `src/main.py` - Entry point
- `src/agents/` - Agent definitions and loading
- `src/mcp/` - MCP integration
- `src/executor/` - Session execution logic
- `src/clients/` - Anthropic API client

---

## Testing Strategies by Component

### Frontend Testing

**Unit Tests** (Jest + React Testing Library)
```typescript
// Example: SessionList.test.tsx
describe('SessionList', () => {
  it('renders session list', () => {
    const sessions = [
      { id: '1', prompt: 'Test', status: 'Running' }
    ];
    render(<SessionList sessions={sessions} />);
    expect(screen.getByText('Test')).toBeInTheDocument();
  });
});
```

**E2E Tests** (Playwright)
```typescript
test('create session workflow', async ({ page }) => {
  await page.goto('/');
  await page.click('button:has-text("New Session")');
  await page.fill('textarea[name="prompt"]', 'Analyze code');
  await page.selectOption('select[name="model"]', 'claude-3-sonnet');
  await page.click('button:has-text("Create")');
  await expect(page.locator('.session-status')).toContainText('Pending');
});
```

### Backend Testing

**Unit Tests** (Go table-driven)
```go
func TestCreateSession(t *testing.T) {
    tests := []struct {
        name       string
        request    CreateSessionRequest
        wantStatus int
        wantError  bool
    }{
        {
            name: "valid session",
            request: CreateSessionRequest{
                Prompt:    "Test",
                Model:     "claude-3-sonnet",
                ProjectID: "proj-1",
            },
            wantStatus: http.StatusCreated,
            wantError:  false,
        },
        {
            name: "missing prompt",
            request: CreateSessionRequest{
                Model:     "claude-3-sonnet",
                ProjectID: "proj-1",
            },
            wantStatus: http.StatusBadRequest,
            wantError:  true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Test logic
        })
    }
}
```

### Operator Testing

**envtest** (Simulated K8s API)
```go
func TestSessionReconciliation(t *testing.T) {
    ctx := context.Background()

    // Create AgenticSession CR
    session := &v1alpha1.AgenticSession{
        ObjectMeta: metav1.ObjectMeta{
            Name:      "test-session",
            Namespace: "default",
        },
        Spec: v1alpha1.AgenticSessionSpec{
            Prompt: "Test prompt",
            Model:  "claude-3-sonnet",
        },
    }

    err := k8sClient.Create(ctx, session)
    require.NoError(t, err)

    // Trigger reconciliation
    req := reconcile.Request{
        NamespacedName: types.NamespacedName{
            Name:      "test-session",
            Namespace: "default",
        },
    }

    _, err = reconciler.Reconcile(ctx, req)
    require.NoError(t, err)

    // Verify Job was created
    job := &batchv1.Job{}
    err = k8sClient.Get(ctx, types.NamespacedName{Name: "test-session", Namespace: "default"}, job)
    require.NoError(t, err)
}
```

### Runner Testing

**Unit Tests** (pytest with mocking)
```python
@pytest.mark.asyncio
async def test_session_execution(mock_anthropic_client):
    session = AgenticSession(
        spec=SessionSpec(
            prompt="Test prompt",
            model="claude-3-sonnet"
        )
    )

    executor = SessionExecutor(client=mock_anthropic_client)
    result = await executor.execute(session)

    assert result.phase == "Completed"
    assert result.results.output_data is not None
    assert result.results.metrics.tokens_used > 0
```

## Development Best Practices

### Component Boundaries

**Rule**: Components should only call other components via defined relationships in the C4 diagram.

**Example Violation**:
```go
// BAD: Frontend directly calling Kubernetes API
k8sClient.Create(ctx, &v1alpha1.AgenticSession{...})
```

**Correct**:
```go
// GOOD: Frontend calls Backend API
response := apiClient.POST("/api/sessions", sessionRequest)
```

### Error Handling

**Backend/Operator** (Go):
```go
// Always wrap errors with context
if err := r.Create(ctx, job); err != nil {
    return ctrl.Result{}, fmt.Errorf("failed to create job for session %s: %w", session.Name, err)
}
```

**Runner** (Python):
```python
# Use structured logging
try:
    result = await client.run_agents(...)
except Exception as e:
    logger.error("Session execution failed",
                 session_id=session.id,
                 error=str(e))
    raise
```

### Logging Standards

**Structured Logging** (All components):
```go
// Backend/Operator
logger.Info("Session created",
    "sessionID", session.Name,
    "namespace", session.Namespace,
    "model", session.Spec.Model)
```

```python
# Runner
logger.info("Agent execution started",
            extra={
                "agent_name": agent.name,
                "session_id": session_id,
                "model": model
            })
```

## Deployment Architecture

### Local Development

```
Developer Machine
    ├── Frontend (localhost:3000)
    │   └── Calls Backend via proxy
    ├── Backend (localhost:8080)
    │   └── Calls dev cluster K8s API
    └── kind cluster
        ├── Operator (watching CRs)
        └── CRDs installed
```

### Production (OpenShift)

```
OpenShift Cluster
    ├── ambient-code namespace
    │   ├── Frontend Pod + Route
    │   ├── Backend Pod + ClusterIP Service
    │   ├── Operator Pod
    │   └── Runner Job Pods (ephemeral)
    ├── kube-system namespace
    │   └── etcd (Custom Resources storage)
    └── External: Anthropic API (HTTPS)
```

## Performance Considerations

### Frontend
- **Code Splitting**: NextJS automatic code splitting per route
- **API Polling**: 5-second interval for session status updates
- **Caching**: React Query for API response caching

### Backend
- **Connection Pooling**: K8s client connection reuse
- **Rate Limiting**: 100 req/min per user (configurable)
- **Response Compression**: Gzip enabled for large payloads

### Operator
- **Reconciliation Rate**: Max 10 reconciliations/second
- **Leader Election**: Single active controller per cluster
- **Watch Filtering**: Only watch CRs in managed namespaces

### Runner
- **Streaming**: Anthropic API responses streamed to reduce latency
- **Timeout**: 5-minute default (configurable per session)
- **Resource Limits**: 2 CPU, 4Gi memory (prevents runaway jobs)

## Security Considerations

### Authentication & Authorization

- **Frontend**: OpenShift OAuth via NextAuth.js
- **Backend**: Validates OAuth tokens, enforces RBAC
- **Operator**: Kubernetes ServiceAccount with minimal RBAC
- **Runner**: Reads secrets from K8s Secret (never logs API keys)

### Secret Management

- **Storage**: Kubernetes Secrets (encrypted at rest)
- **Access**: Project-scoped (Runner can only read secrets in same namespace)
- **Rotation**: Manual rotation via UI (future: automated rotation)

### Network Policies

```yaml
# Example: Isolate runner pods
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: runner-isolation
spec:
  podSelector:
    matchLabels:
      app: vteam-runner
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              name: kube-system  # Allow K8s API access
    - to:
        - podSelector: {}       # Allow pod-to-pod (for DNS)
    - ports:
        - port: 443
          protocol: TCP          # Allow Anthropic API (HTTPS)
```

## Observability

### Metrics (Prometheus)

**Backend**:
- `vteam_api_requests_total{endpoint, method, status}`
- `vteam_api_request_duration_seconds{endpoint}`
- `vteam_session_create_errors_total`

**Operator**:
- `vteam_reconcile_duration_seconds{controller}`
- `vteam_reconcile_errors_total{controller}`
- `vteam_job_creation_total{project}`

**Runner**:
- `vteam_session_execution_duration_seconds`
- `vteam_anthropic_tokens_used_total{model}`
- `vteam_session_failures_total{reason}`

### Logging

**Log Levels**:
- `DEBUG`: Verbose (reconciliation details, API calls)
- `INFO`: Standard (session created, job started)
- `WARN`: Recoverable errors (API rate limit, retry)
- `ERROR`: Non-recoverable errors (job failure, CR invalid)

### Tracing (Future)

- OpenTelemetry integration planned
- Trace session creation → job execution → completion
- Distributed tracing across containers

## Related Documentation

- **Architecture Overview**: [../architecture/README.md](../architecture/README.md)
- **Quick Reference**: [../architecture/QUICK_REFERENCE.md](../architecture/QUICK_REFERENCE.md)
- **C4 Model Source**: [../../architecture/workspace.dsl](../../architecture/workspace.dsl)
- **Deployment Guide**: [../OPENSHIFT_DEPLOY.md](../OPENSHIFT_DEPLOY.md)

---

**Last Updated**: 2025-09-30
**Audience**: Contributors and core developers
**Maintained By**: vTeam Engineering Team
