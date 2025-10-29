# vTeam Codebase Exploration Report

## 1. What is vTeam and Its Purpose?

**vTeam** is a **Kubernetes-native AI automation platform** that orchestrates intelligent agentic sessions with multi-agent collaboration capabilities. It bridges Claude Code CLI with containerized microservices to enable enterprise-scale AI-powered workflows.

### Core Purpose:
- Automate intelligent analysis, research, development, and content creation tasks via AI agents
- Provide a modern web interface for managing agentic sessions
- Enable multi-agent collaboration with specialized AI personas (16 different roles)
- Support spec-driven development workflows with spec-kit integration
- Deploy as production-ready Kubernetes workloads with proper RBAC and isolation

### Architecture Overview:
```
User → Frontend (NextJS) → Backend API (Go) → Kubernetes Operator (Go)
                                                     ↓
                                            Creates Jobs with Runners (Python)
                                                     ↓
                                            Claude Code SDK Execution
```

---

## 2. Current Context Management & Context Engineering

vTeam has a **sophisticated context management system** but limited explicit "context engineering":

### A. Context Types Being Managed:

1. **User Context** (captured at session creation):
   - `userID`: Stable identifier from SSO
   - `displayName`: Human-readable name
   - `groups`: Group memberships for RBAC

2. **Session Context** (RunnerContext):
   - `session_id`: Unique session identifier
   - `workspace_path`: Shared workspace for repositories and files
   - `environment`: Dictionary of environment variables
   - `metadata`: Arbitrary key-value storage

3. **LLM Context Settings**:
   - `model`: Selected Claude model (default: claude-3-7-sonnet-latest)
   - `temperature`: Sampling temperature (0.0-1.0, default: 0.7)
   - `maxTokens`: Token limit per request (default: 4000)

4. **Multi-Repo Context**:
   - Multiple repositories with input/output mappings
   - `mainRepoIndex`: Specifies which repo is Claude's working directory
   - Per-repo status tracking: pushed vs abandoned

5. **Agent Context** (via wrapper.py):
   - MCP server configurations loaded from `.mcp.json`
   - 16 specialized AI agent personas with domain expertise
   - Agent system prompts and analysis templates
   - Permission modes for tool access

### B. How Context Flows Through the System:

```
1. Frontend: User creates session with context (prompt, repos, LLM settings, timeout)
   ↓
2. Backend: Parses context, creates AgenticSession CR with spec fields
   ↓
3. Backend: Derives UserContext from authenticated caller
   ↓
4. Backend: Provisions runner token secret with K8s RBAC context
   ↓
5. Operator: Extracts context from CR and injects as environment variables to Job
   ↓
6. Runner: LoadsRunnerContext, merges environment and metadata
   ↓
7. Claude SDK: Executes with context-aware prompts and tools
   ↓
8. Runner: Updates CR status with execution results (cost, tokens, turns)
```

### C. Token Management:

**Three-tier token strategy:**

1. **User Tokens**:
   - OpenShift OAuth tokens passed via Authorization header
   - Used for all backend API calls with RBAC enforcement
   - Never logged (security critical)

2. **Runner Bot Tokens**:
   - Short-lived Kubernetes tokens minted by backend
   - Stored in per-session Secrets
   - Used by runner to update CR status and fetch GitHub tokens
   - Injected via `BOT_TOKEN` environment variable

3. **GitHub Tokens**:
   - Fetched on-demand from backend via POST to `/github/token`
   - Used for repository cloning and push operations
   - Short-lived, minimal scope
   - Redacted from logs

**Key Code References:**
- Backend: `components/backend/handlers/sessions.go:provisionRunnerTokenForSession()` - Creates per-session ServiceAccount and tokens
- Runner: `components/runners/claude-code-runner/wrapper.py:_fetch_github_token()` - Fetches GitHub tokens on-demand
- Security: `components/backend/server/server.go` - Custom token redaction formatter

### D. Current Context Engineering Limitations:

**What's Missing:**
1. **No explicit context windowing** - All context injected, no optimization for token efficiency
2. **No context summarization** - No automatic compression of context for long runs
3. **No multi-turn context preservation** - Each turn starts fresh (though this is mitigated by MCP servers)
4. **No context relevance scoring** - No automatic filtering of irrelevant context
5. **No token accounting** - While usage is tracked, there's no predictive context budgeting
6. **No hierarchical context** - All context at same priority level
7. **No cross-session context sharing** - Each session is isolated
8. **GPU-specific context** - No GPU resource awareness or optimization

---

## 3. GPU Compute Resources & Management

vTeam has **minimal GPU support**:

### A. Current State:

1. **Resource Specifications** (types/common.go):
```go
type ResourceOverrides struct {
    CPU           string  // e.g., "500m", "2"
    Memory        string  // e.g., "512Mi", "2Gi"
    StorageClass  string  // e.g., "standard", "ssd"
    PriorityClass string  // Pod priority for scheduling
}
```

2. **Job Resources** (operator/sessions.go line 392):
```go
Resources: corev1.ResourceRequirements{} // Empty! No requests/limits set
```

3. **PVC Storage** (operator/services/infrastructure.go):
- Fixed 5Gi storage per session PVC
- No configurable storage size
- No storage optimization

### B. What's NOT Implemented:

1. **No GPU support** - No nvidia.com/gpu resource requests
2. **No VRAM awareness** - Can't select GPU models
3. **No memory optimization** - Fixed 4000 token max regardless of available memory
4. **No compute scheduling** - No affinity/anti-affinity rules
5. **No resource monitoring** - No metrics collection for resource usage
6. **No dynamic scaling** - Fixed container resources
7. **No cost optimization** - No attempt to minimize compute or API costs

### C. Resource Limits in Place:

- **Operator**: 50m CPU / 64Mi memory (requests), 200m / 256Mi (limits)
- **Runner Pod**: No explicit limits (inherits defaults from cluster)
- **Session Timeout**: 300 seconds default, max 14400 seconds (4 hours) in Job spec
- **Token Limit**: 4000 tokens default per LLM settings

---

## 4. Main Components & Architecture

### A. Component Breakdown:

| Component | Technology | Responsibility |
|-----------|-----------|-----------------|
| **Frontend** | NextJS + Shadcn UI | Session UI, real-time monitoring |
| **Backend API** | Go + Gin + Kubernetes client | Session CRUD, RBAC, token provisioning, WebSocket |
| **Operator** | Go + K8s Reconciliation | Watches AgenticSessions → creates Jobs |
| **Claude Runner** | Python + Claude SDK | Executes AI with tools, Git operations, MCP servers |
| **Runner Shell** | Python asyncio | Protocol layer for runner-backend communication |

### B. CRD Hierarchy:

```
AgenticSession (vteam.ambient-code/v1alpha1)
├── Spec: prompt, repos, interactive mode, LLM settings, timeouts, resource overrides
├── Status: phase, messages, results, token usage, cost
└── Metadata: user context, runner token secret annotation

ProjectSettings (per-namespace config)
├── API keys (Anthropic, GitHub)
├── Default models and timeouts
└── Runner secrets name

RFEWorkflow (Request for Enhancement - 7-step agent council)
├── Multi-agent refinement process
└── Structured engineering analysis
```

### C. Data Flow - Session Lifecycle:

```
CREATE SESSION:
  User → Frontend → Backend API → Backend creates CR → Operator watches
  
  Operator detects AgenticSession in Pending state
  ↓
  Operator creates per-session PVC (5Gi)
  Operator provisions Job with:
    - Container: ambient-content (serves workspace via HTTP)
    - Container: ambient-code-runner (executes Claude SDK)
  
EXECUTION:
  Runner initializes context from environment
  Runner loads MCP servers from .mcp.json (if present)
  Runner executes Claude SDK with:
    - Prompt injected from environment
    - Tools: Read, Write, Bash, Glob, Grep, Edit, WebSearch, WebFetch, MCP-provided
    - Permission mode: acceptEdits (auto-apply changes)
  
  Runner streams output via WebSocket back to backend
  Backend relays via WebSocket to frontend
  
CLEANUP:
  Job completes → Runner updates CR status (Completed/Failed)
  Runner pushes changes to output repo if AUTO_PUSH_ON_COMPLETE
  Operator detects terminal state, creates Service for workspace access
  TTL controller eventually cleans up Job after 600 seconds
  OwnerReferences cascade deletion of PVC when AgenticSession deleted
```

---

## 5. Existing Context & Token Management Features

### A. Context Handling in Runner:

**Location**: `components/runners/claude-code-runner/wrapper.py`

1. **ClaudeCodeAdapter class**:
   - Manages session initialization and orchestration
   - Maintains WebSocket connection to backend
   - Handles message streaming

2. **Context Initialization** (lines 34-41):
```python
async def initialize(self, context: RunnerContext):
    self.context = context
    await self._prepare_workspace()  # Clone repos into workspace
    await self._validate_prerequisites()  # Check for required files
```

3. **Multi-Repo Context** (lines 161-187):
   - Reads REPOS_JSON environment variable
   - Determines main working directory via MAIN_REPO_INDEX or MAIN_REPO_NAME
   - Sets additional repos as read-only context directories

4. **MCP Server Context** (lines 1101-1159):
   - Loads MCP servers from `.mcp.json` file
   - Searches in: explicit MCP_CONFIG_PATH, cwd, workspace root
   - Passes to Claude SDK via `options.mcp_servers`

5. **LLM Context Injection** (lines 203-243):
   - Model from LLM_MODEL environment
   - Temperature from LLM_TEMPERATURE
   - Max tokens from LLM_MAX_TOKENS or MAX_TOKENS

### B. Token Management Features:

1. **Token Provisioning** (backend/handlers/sessions.go):
   - Creates per-session ServiceAccount (deterministic name)
   - Grants minimal RBAC Role for CR updates only
   - Mints short-lived token via TokenRequest API
   - Stores in Secret: `ambient-runner-token-{sessionName}`
   - Annotates CR with secret name: `ambient-code.io/runner-token-secret`

2. **Token Security** (wrapper.py):
   - `_redact_secrets()`: Removes GitHub tokens from logs (ghs_, ghp_ patterns)
   - `_url_with_token()`: Injects tokens into HTTPS URLs for auth
   - Token never logged directly (only logged token length)

3. **GitHub Token Workflow** (wrapper.py lines 956-1015):
   - Tries GITHUB_TOKEN env var first (cached)
   - Falls back to POST /github/token endpoint
   - Backend mints token from GitHub App installation
   - Token used for clone, fetch, push operations

### C. Context Transmission:

**Backend → Runner (environment variables)**:
```
SESSION_ID, WORKSPACE_PATH
PROMPT, INTERACTIVE, TIMEOUT
LLM_MODEL, LLM_TEMPERATURE, LLM_MAX_TOKENS
ANTHROPIC_API_KEY, BOT_TOKEN
REPOS_JSON, MAIN_REPO_INDEX, MAIN_REPO_NAME
INPUT_REPO_URL, INPUT_BRANCH, OUTPUT_REPO_URL, OUTPUT_BRANCH
AUTO_PUSH_ON_COMPLETE, CREATE_PR, PR_TARGET_BRANCH
```

**Runner → Backend (WebSocket messages)**:
- AGENT_RUNNING: Execution started
- AGENT_MESSAGE: Text output, tool calls, tool results
- SYSTEM_MESSAGE: Logs and status
- MESSAGE_PARTIAL: Streamed output fragments
- status updates via HTTP PUT to CR status endpoint

---

## 6. Documentation & Goals

### A. Documentation Structure:

Located in `/docs/`:
- **OPENSHIFT_DEPLOY.md**: Deployment guide with resource examples
- **CLAUDE_CODE_RUNNER.md**: Runner architecture, prompts, agent personas
- **GITHUB_APP_SETUP.md**: Token provisioning and GitHub integration
- **Developer Guide**: Architecture patterns, API design, security standards
- **User Guide**: Getting started, session creation
- **Labs**: Hands-on exercises for spec-kit workflows

### B. Project Goals (from README & CLAUDE.md):

1. **Kubernetes-native AI automation**: Proper CRDs, operators, RBAC
2. **Multi-tenant isolation**: Namespace-scoped projects with RBAC
3. **Enterprise deployment**: OAuth integration, production hardening
4. **Spec-driven development**: Workflow support for spec.md → plan.md → tasks.md
5. **Real-time collaboration**: WebSocket updates, interactive sessions
6. **Multi-agent workflows**: 16 specialized personas for engineering refinement
7. **Production readiness**: Health checks, monitoring, structured logging

### C. Security & Standards:

**Critical Rules (from CLAUDE.md)**:
1. User token authentication REQUIRED for API operations
2. NO panic() in production code - explicit error handling
3. Token redaction in logs (never log full tokens)
4. Type-safe unstructured access patterns
5. OwnerReferences for resource cleanup
6. RBAC checks before all resource access

---

## 7. Key Improvement Opportunities for Context Engineering

### Gap Analysis:

1. **Context Window Optimization**:
   - Current: Full context always injected, no filtering
   - Opportunity: Implement context relevance scoring and compression

2. **Multi-turn Memory**:
   - Current: Session is stateless between LLM calls
   - Opportunity: Implement persistent context cache with summarization

3. **Resource Awareness**:
   - Current: No GPU support, fixed resources
   - Opportunity: Add GPU/VRAM awareness to context and token budgeting

4. **Token Accounting**:
   - Current: Usage tracked but not predictive
   - Opportunity: Implement token budgeting and adaptive context sizing

5. **Context Lifecycle Management**:
   - Current: Context set once at session start
   - Opportunity: Dynamic context updates based on execution phase

6. **Cost Optimization**:
   - Current: No cost awareness in context management
   - Opportunity: Implement cost-aware context selection and model switching

---

## 8. File Locations for Reference

### Core Components:
- Backend: `/components/backend/` (Go)
- Operator: `/components/operator/` (Go)
- Runner: `/components/runners/claude-code-runner/` (Python wrapper.py)
- Frontend: `/components/frontend/` (NextJS)

### Types & Structures:
- Session types: `/components/backend/types/session.go`
- Common types: `/components/backend/types/common.go`
- Runner context: `/components/runners/runner-shell/runner_shell/core/context.py`

### Key Handlers:
- Session CRUD: `/components/backend/handlers/sessions.go` (1724 lines)
- Operator watch: `/components/operator/internal/handlers/sessions.go` (550+ lines)
- Token provisioning: `/components/backend/handlers/sessions.go:provisionRunnerTokenForSession()`

### Kubernetes Resources:
- CRD: `/components/manifests/crds/agenticsessions-crd.yaml`
- Operator deployment: `/components/manifests/operator-deployment.yaml`

### Documentation:
- Runner docs: `/docs/CLAUDE_CODE_RUNNER.md`
- Security standards: `/CLAUDE.md` (920+ lines of development guidelines)
