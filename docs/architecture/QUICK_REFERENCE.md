# vTeam Architecture Quick Reference

> Single-page reference for developers working with vTeam platform

## Visual Diagram Index

| Diagram | Purpose | When to Use |
|---------|---------|-------------|
| [System Context](../../architecture/diagrams/structurizr-SystemContext.png) | Big picture: users, vTeam, external systems | Understanding stakeholders and boundaries |
| [Containers](../../architecture/diagrams/structurizr-Containers.png) | Technical building blocks and communication | Architecture decisions, deployment planning |
| [Frontend Components](../../architecture/diagrams/structurizr-FrontendComponents.png) | UI component structure | Frontend development, UI refactoring |
| [Backend Components](../../architecture/diagrams/structurizr-BackendComponents.png) | API component structure | Backend development, API design |
| [Operator Components](../../architecture/diagrams/structurizr-OperatorComponents.png) | Operator reconciliation components | Operator development, CR management |
| [Runner Components](../../architecture/diagrams/structurizr-RunnerComponents.png) | AI execution component structure | Runner development, agent integration |
| [Deployment](../../architecture/diagrams/structurizr-Deployment.png) | OpenShift deployment topology | Infrastructure planning, SRE operations |
| [Session Creation Flow](../../architecture/diagrams/structurizr-SessionCreationFlow.png) | Runtime interaction sequence | Debugging, integration testing |

## Container-to-Technology Mapping

| Container | Technology Stack | Repository Path | Deployment |
|-----------|-----------------|-----------------|------------|
| **Frontend** | NextJS 14, TypeScript, Shadcn UI | `components/frontend/` | Kubernetes Pod + Route |
| **Backend** | Go, Gin, client-go | `components/backend/` | Kubernetes Pod + ClusterIP Service |
| **Operator** | Go, Kubebuilder, controller-runtime | `components/operator/` | Kubernetes Deployment |
| **Runner** | Python, Claude Code CLI, Anthropic SDK | `components/runners/claude-code-runner/` | Kubernetes Job (ephemeral) |

## Component Relationship Matrix

### Frontend → Backend

| Frontend Component | Calls | Backend Component | Protocol |
|-------------------|-------|-------------------|----------|
| Session Management UI | → | Sessions API | HTTPS REST |
| Project Management UI | → | Projects API | HTTPS REST |
| Settings & Secrets UI | → | Secrets API | HTTPS REST |
| Authentication Handler | → | RBAC Middleware | HTTPS REST |

### Backend → Kubernetes

| Backend Component | Interacts With | Kubernetes Resource | Operation |
|------------------|----------------|---------------------|-----------|
| Projects API | → | Project CR | Create, Read, Update, Delete |
| Sessions API | → | AgenticSession CR | Create, Read, Update, Delete |
| Secrets API | → | Kubernetes Secrets | Create, Read, Update, Delete |
| Kubernetes Client | → | Custom Resources | All CRUD operations |

### Operator → Kubernetes

| Operator Component | Watches/Creates | Kubernetes Resource | Action |
|-------------------|-----------------|---------------------|--------|
| Project Controller | → | Project CR | Watch, Reconcile |
| Session Controller | → | AgenticSession CR | Watch, Reconcile |
| Session Controller | → | Kubernetes Job | Create (for Runner) |
| Resource Manager | → | Namespace, Quota, RBAC | Create, Manage |
| Job Orchestrator | → | Kubernetes Job | Create, Monitor |

### Runner → External

| Runner Component | Calls | External System | Protocol |
|-----------------|-------|-----------------|----------|
| Claude API Client | → | Anthropic API | HTTPS REST |
| Session Executor | → | AgenticSession CR | Kubernetes API (status updates) |
| Agent Loader | → | Session Executor | Internal (in-process) |
| MCP Integration | → | Session Executor | Internal (in-process) |

## API Endpoints Reference

### Backend API (Go/Gin)

**Base URL**: `http://backend-service:8080` (internal) or via Frontend proxy

| Endpoint | Method | Component | Purpose |
|----------|--------|-----------|---------|
| `/api/projects` | GET, POST | Projects API | List/create projects |
| `/api/projects/{id}` | GET, PUT, DELETE | Projects API | Manage specific project |
| `/api/sessions` | GET, POST | Sessions API | List/create sessions |
| `/api/sessions/{id}` | GET, PUT, DELETE | Sessions API | Manage specific session |
| `/api/secrets` | GET, POST | Secrets API | List/create runner secrets |
| `/api/secrets/{id}` | GET, PUT, DELETE | Secrets API | Manage specific secret |
| `/health` | GET | - | Health check |
| `/metrics` | GET | - | Prometheus metrics |

## Custom Resource Definitions

### AgenticSession CR

```yaml
apiVersion: ambient.vteam.io/v1alpha1
kind: AgenticSession
metadata:
  name: session-example
  namespace: project-namespace
spec:
  prompt: "Analyze this codebase"
  model: "claude-3-sonnet-20240320"
  timeout: 300
  projectRef:
    name: my-project
status:
  phase: "Running"  # Pending, Running, Completed, Failed
  startTime: "2025-09-30T14:00:00Z"
  completionTime: "2025-09-30T14:05:00Z"
  results:
    outputData: "Analysis complete..."
    metrics:
      tokensUsed: 1500
      executionTime: "5m0s"
```

### Project CR

```yaml
apiVersion: ambient.vteam.io/v1alpha1
kind: Project
metadata:
  name: my-project
spec:
  displayName: "My Engineering Project"
  namespace: my-project-ns
  resourceQuotas:
    cpu: "4"
    memory: "8Gi"
    storage: "20Gi"
status:
  phase: "Active"  # Pending, Active, Terminating
  namespaceReady: true
  conditions:
    - type: "Ready"
      status: "True"
      reason: "ProjectProvisioned"
```

## Deployment Checklist

### Prerequisites
- [ ] OpenShift cluster with admin access
- [ ] Container registry access (quay.io)
- [ ] Anthropic API key

### Deployment Steps
- [ ] Deploy Custom Resource Definitions
- [ ] Deploy Operator (creates CRDs)
- [ ] Deploy Backend API service
- [ ] Deploy Frontend application
- [ ] Create Route for Frontend access
- [ ] Configure runner secrets via UI

### Verification
- [ ] All pods running: `oc get pods -n ambient-code`
- [ ] Services accessible: `oc get services,routes -n ambient-code`
- [ ] CRDs installed: `oc get crd | grep ambient.vteam.io`
- [ ] Frontend route working: `curl -I $(oc get route frontend-route -o jsonpath='{.spec.host}')`

## Development Workflow

### Working on Frontend
1. Make changes in `components/frontend/`
2. Test locally: `npm run dev`
3. Build: `npm run build`
4. Container build: `make build-frontend`
5. Deploy: `make deploy-frontend`
6. Verify UI components respect Container diagram boundaries

### Working on Backend
1. Make changes in `components/backend/`
2. Run locally: `go run cmd/server/main.go`
3. Test API: `curl http://localhost:8080/api/sessions`
4. Container build: `make build-backend`
5. Deploy: `make deploy-backend`
6. Verify components call only designated Kubernetes resources

### Working on Operator
1. Make changes in `components/operator/`
2. Run locally: `make run` (against dev cluster)
3. Test reconciliation: Create test CR
4. Container build: `make build-operator`
5. Deploy: `make deploy-operator`
6. Verify controllers reconcile correct CR types

### Working on Runner
1. Make changes in `components/runners/claude-code-runner/`
2. Test locally: `python -m runner.main`
3. Test agent loading: Verify 17 agents load correctly
4. Container build: `make build-runner`
5. Deploy: Operator creates Jobs automatically
6. Verify components interact as shown in Component diagram

## Common Architectural Patterns

### Pattern: Custom Resource Lifecycle

```
User → Frontend → Backend → AgenticSession CR (Create)
                                ↓
                           Operator watches CR
                                ↓
                      Operator creates Job (Runner pod)
                                ↓
                      Runner executes AI tasks
                                ↓
                      Runner updates CR status
                                ↓
                      Frontend polls → Backend → CR (Read status)
```

### Pattern: Multi-Tenant Isolation

```
Project CR created
    ↓
Project Controller reconciles
    ↓
Creates Namespace (tenant-specific)
    ↓
Applies ResourceQuotas
    ↓
Applies RBAC policies
    ↓
Applies NetworkPolicies
    ↓
Tenant isolated and ready
```

### Pattern: Ephemeral Job Execution

```
AgenticSession CR created
    ↓
Session Controller reconciles
    ↓
Job Orchestrator creates Job
    ↓
Kubernetes schedules Runner pod
    ↓
Runner executes (reads Secrets, calls Anthropic API)
    ↓
Runner writes results to CR status
    ↓
Job completes, pod terminates
    ↓
Frontend displays results
```

## Troubleshooting Reference

### Frontend Issues
- **Component**: Session Management UI, Project UI, Settings UI, Auth Handler
- **Logs**: `oc logs deployment/frontend -n ambient-code`
- **Common**: OAuth misconfiguration, Backend API unreachable

### Backend Issues
- **Component**: Projects API, Sessions API, Secrets API, RBAC Middleware, K8s Client
- **Logs**: `oc logs deployment/backend -n ambient-code`
- **Common**: RBAC permissions, CR creation failures

### Operator Issues
- **Component**: Project Controller, Session Controller, Resource Manager, Job Orchestrator
- **Logs**: `oc logs deployment/operator -n ambient-code`
- **Common**: Reconciliation loops, Job creation failures

### Runner Issues
- **Component**: Agent Loader, MCP Integration, Session Executor, Claude API Client
- **Logs**: `oc logs job/runner-job-xyz -n ambient-code`
- **Common**: Anthropic API key invalid, MCP integration errors

## Architecture Decision Log

### ADR-001: Kubernetes Operators for Session Orchestration
- **Date**: 2025-09-30
- **Decision**: Use Kubernetes Operator pattern
- **Rationale**: Declarative CRs, reconciliation loops, native K8s integration
- **Status**: Accepted

### ADR-002: Ephemeral Runner Pods
- **Date**: 2025-09-30
- **Decision**: Create new pod per session (vs persistent runners)
- **Rationale**: Resource efficiency, session isolation, clean state
- **Status**: Accepted

### ADR-003: Go for Backend and Operator
- **Date**: 2025-09-30
- **Decision**: Use Go instead of Python or TypeScript
- **Rationale**: Native K8s libraries, performance, ecosystem alignment
- **Status**: Accepted

### ADR-004: NextJS for Frontend
- **Date**: 2025-09-30
- **Decision**: NextJS 14 with TypeScript
- **Rationale**: React ecosystem, SSR capabilities, TypeScript safety
- **Status**: Accepted

### ADR-005: Python for Runner
- **Date**: 2025-09-30
- **Decision**: Python for AI execution pod
- **Rationale**: Claude Code CLI (Python), Anthropic SDK (Python), AI ecosystem
- **Status**: Accepted

## Key Metrics to Monitor

| Metric | Component | Purpose |
|--------|-----------|---------|
| Session creation rate | Backend | Track platform usage |
| Job creation latency | Operator | Measure orchestration performance |
| Pod scheduling time | Kubernetes | Identify resource constraints |
| Runner execution time | Runner | Optimize AI workflows |
| API response time | Backend | Ensure responsive UI |
| CR reconciliation duration | Operator | Detect controller issues |
| Anthropic API latency | Runner | Track external dependency |

## Resource Limits Reference

### Default Limits (Per Pod)

| Container | CPU Request | CPU Limit | Memory Request | Memory Limit |
|-----------|-------------|-----------|----------------|--------------|
| Frontend | 100m | 500m | 128Mi | 512Mi |
| Backend | 200m | 1000m | 256Mi | 1Gi |
| Operator | 100m | 500m | 128Mi | 512Mi |
| Runner | 500m | 2000m | 512Mi | 4Gi |

### Project Quotas (Per Tenant)

| Resource | Default Quota |
|----------|---------------|
| CPU | 4 cores |
| Memory | 8Gi |
| Storage | 20Gi |
| Pods | 50 |
| Services | 10 |

## External References

- **Full Architecture**: [README.md](README.md)
- **C4 Model Source**: [../../architecture/workspace.dsl](../../architecture/workspace.dsl)
- **C4 Tooling Guide**: [../../architecture/README.md](../../architecture/README.md)
- **Deployment Guide**: [../OPENSHIFT_DEPLOY.md](../OPENSHIFT_DEPLOY.md)

---

**Last Updated**: 2025-09-30
**Purpose**: Developer quick reference (print-friendly)
**Maintained By**: vTeam Architecture Team
