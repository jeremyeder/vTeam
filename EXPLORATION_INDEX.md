# vTeam Codebase Exploration - Complete Reference Index

This document serves as a navigational index for the comprehensive exploration of vTeam's context engineering, architecture, and GPU compute management.

## Generated Documents

1. **VTEAM_CONTEXT_ANALYSIS.md** (15KB)
   - Comprehensive analysis of vTeam's purpose, architecture, and context management
   - 8 detailed sections covering all aspects of the system
   - Specific file locations and code references throughout
   - Includes context engineering gaps and improvement opportunities

2. **VTEAM_CONTEXT_SUMMARY.txt** (12KB)
   - Executive summary format with 10 key sections
   - Quick reference guide for developers
   - Token management strategies and security patterns
   - Environment variables reference
   - Actionable recommendations for improvements

## Quick Navigation

### Understanding vTeam

- **What is vTeam?** → See VTEAM_CONTEXT_ANALYSIS.md Section 1
- **Architecture Overview** → See VTEAM_CONTEXT_ANALYSIS.md Section 4
- **Component Details** → See VTEAM_CONTEXT_SUMMARY.txt Section 5

### Context Management

- **Five Types of Context** → See VTEAM_CONTEXT_SUMMARY.txt Section 2
- **Context Flow Through System** → See VTEAM_CONTEXT_ANALYSIS.md Section 2.B
- **Current Limitations** → See VTEAM_CONTEXT_ANALYSIS.md Section 2.D
- **Existing Features** → See VTEAM_CONTEXT_ANALYSIS.md Section 5

### Token Management

- **Three-Tier Token Strategy** → See VTEAM_CONTEXT_SUMMARY.txt Section 3
- **Token Provisioning Code** → `/components/backend/handlers/sessions.go:provisionRunnerTokenForSession()`
- **GitHub Token Workflow** → `/components/runners/claude-code-runner/wrapper.py:_fetch_github_token()`
- **Security Patterns** → See VTEAM_CONTEXT_SUMMARY.txt Section 7

### GPU & Compute Resources

- **Current GPU Support** → See VTEAM_CONTEXT_SUMMARY.txt Section 4
- **Resource Definitions** → `/components/backend/types/common.go:ResourceOverrides`
- **What's Missing** → See VTEAM_CONTEXT_ANALYSIS.md Section 3.B
- **Improvement Opportunities** → See VTEAM_CONTEXT_ANALYSIS.md Section 7

### Key Source Files

**Backend (Go)**
- Main session handler: `/components/backend/handlers/sessions.go` (1724 lines)
  - CRUD operations, token provisioning, CR lifecycle
- Types: `/components/backend/types/session.go`, `/components/backend/types/common.go`
- Middleware: `/components/backend/handlers/middleware.go`

**Operator (Go)**
- Watch and reconciliation: `/components/operator/internal/handlers/sessions.go` (550+ lines)
- Services: `/components/operator/internal/services/infrastructure.go`
- Types: `/components/operator/internal/types/resources.go`

**Runner (Python)**
- Main wrapper: `/components/runners/claude-code-runner/wrapper.py` (1206 lines)
  - Context loading, SDK execution, Git operations, result streaming
- Context: `/components/runners/runner-shell/runner_shell/core/context.py`
- Protocol: `/components/runners/runner-shell/runner_shell/core/protocol.py`

**Kubernetes Resources**
- CRD definition: `/components/manifests/crds/agenticsessions-crd.yaml`
- Operator deployment: `/components/manifests/operator-deployment.yaml`
- RBAC: `/components/manifests/rbac/`

### Documentation

- **Project Overview**: `/README.md` (421 lines)
- **Development Guide**: `/CLAUDE.md` (1077 lines) - Security patterns, standards
- **Runner Architecture**: `/docs/CLAUDE_CODE_RUNNER.md` - Agent personas, prompts
- **Deployment**: `/docs/OPENSHIFT_DEPLOY.md`
- **OAuth Setup**: `/docs/OPENSHIFT_OAUTH.md`

## Key Findings Summary

### 1. Context Types Managed
- User context (OAuth/SSO)
- Session context (workspace, environment, metadata)
- LLM settings (model, temperature, tokens)
- Multi-repo context (Git repositories)
- Agent/MCP context (personas, tools, servers)

### 2. Token Architecture
- **Tier 1**: User tokens (OpenShift OAuth) for API authentication
- **Tier 2**: Bot tokens (Kubernetes) for runner operations
- **Tier 3**: GitHub tokens (on-demand) for Git operations
All with strong security patterns and redaction

### 3. GPU/Compute Status
- NO GPU support currently implemented
- ResourceOverrides struct for CPU/Memory only
- PVC storage fixed at 5Gi
- No resource requests/limits in runner pods
- Significant opportunity for improvement

### 4. Architecture Pattern
```
User → Frontend (NextJS) → Backend (Go) → Kubernetes Operator (Go)
                                              ↓
                                         Job + Containers
                                              ↓
                                         Runner (Python) → Claude SDK
                                              ↓
                                         WebSocket ← Results
```

### 5. Context Flow Pipeline
Frontend → Backend (parse) → Operator (inject) → Runner (load) → SDK (execute) → Status update

## Improvement Recommendations

### Short-term (Quick Wins)
1. Add GPU fields to ResourceOverrides
2. Implement token accounting in LLMSettings
3. Add context size metrics to CR status

### Medium-term (1-2 sprints)
1. Context relevance scoring module
2. Token budget warnings and enforcement
3. Multi-turn context cache
4. GPU-aware token limits

### Long-term (Strategic)
1. Adaptive context compression
2. Context optimization engine
3. Cost-aware model selection
4. Monitoring/debugging dashboard

## Security & Standards

**Critical Requirements** (from CLAUDE.md):
- User token authentication REQUIRED
- NO panic() in production code
- Token redaction in logs
- Type-safe data access patterns
- OwnerReferences for cleanup
- RBAC enforcement

## Environment Variables Reference

**Backend → Runner** (30+ variables injected):
- Session: SESSION_ID, WORKSPACE_PATH
- Execution: PROMPT, INTERACTIVE, TIMEOUT
- LLM: LLM_MODEL, LLM_TEMPERATURE, LLM_MAX_TOKENS
- Auth: ANTHROPIC_API_KEY, BOT_TOKEN
- Git: REPOS_JSON, INPUT_REPO_URL, OUTPUT_REPO_URL, etc.

See VTEAM_CONTEXT_SUMMARY.txt Section 10 for complete list.

## How to Use These Documents

1. **Start with VTEAM_CONTEXT_SUMMARY.txt** for quick overview
2. **Reference VTEAM_CONTEXT_ANALYSIS.md** for deep dives
3. **Use file paths** to navigate actual source code
4. **Review security patterns** before implementing changes
5. **Check CLAUDE.md** for development standards

## Next Steps for Context Engineering Improvements

1. Review ResourceOverrides implementation in types/common.go
2. Study provisionRunnerTokenForSession() in backend/handlers/sessions.go
3. Examine wrapper.py context initialization logic
4. Design context relevance scoring module
5. Prototype token budget enforcement
6. Plan GPU-aware context adaptation

## Contact Points for Questions

- Architecture: See CLAUDE.md (development guide)
- Security: See CLAUDE.md (security requirements section)
- Context: See wrapper.py (ClaudeCodeAdapter class)
- Tokens: See handlers/sessions.go (provisionRunnerTokenForSession)
- Resources: See types/common.go (ResourceOverrides)

---

**Generated**: October 29, 2025
**Exploration Level**: Very Thorough
**Scope**: Context engineering, architecture, GPU compute, token management
