# UI Terminology & Definitions

Platform terminology based on actual code implementation.

---

## Core Concepts

**Agentic Session**: AI-powered task execution using Claude Code CLI. Represented as Custom Resource `agenticsessions.vteam.ambient-code`. (Source: `components/manifests/crds/agenticsessions-crd.yaml`)

**Project**: Namespace-scoped workspace for organizing sessions and settings. Represented as Custom Resource `AmbientProject`. (Source: `components/frontend/src/types/project.ts`, `components/manifests/crds/projectsettings-crd.yaml`)

**Agent**: YAML-defined AI persona loaded from filesystem at runtime. Examples: "Product Manager", "Staff Engineer", "Team Lead". (Source: `components/backend/internal/handlers/agents.go`, `components/runners/claude-code-runner/agents/*.yaml`)

**RFE Workflow**: Multi-phase feature refinement process with agent collaboration. Represented as Custom Resource `rfeworkflows.vteam.ambient-code`. (Source: `components/frontend/src/types/agentic-session.ts` lines 164-240, `components/manifests/crds/rfeworkflows-crd.yaml`)

**Runner**: Container executing Claude Code CLI for session processing. Lives in `components/runners/claude-code-runner/`. (Source: `components/runners/claude-code-runner/CLAUDE.md`)

**Interactive Mode**: Chat-based session using inbox/outbox JSONL files for continuous interaction. Enabled via `spec.interactive: true` in AgenticSession. (Source: `components/manifests/crds/agenticsessions-crd.yaml` line 22-24)

---

## Session States

Session phases defined in TypeScript and CRD:

**AgenticSessionPhase** (Source: `components/frontend/src/types/agentic-session.ts` line 1):
- `Pending`: Session created, awaiting execution
- `Creating`: Operator creating Kubernetes Job
- `Running`: Job actively processing
- `Completed`: Successfully finished
- `Failed`: Error during execution
- `Stopped`: Manually stopped by user
- `Error`: System error

---

## Data Structures

### AgenticSessionSpec

Source: `components/frontend/src/types/agentic-session.ts` lines 31-42

```typescript
{
  prompt: string;                    // Required: Task description
  llmSettings: {
    model: string;                   // Default: "claude-3-7-sonnet-latest"
    temperature: number;             // Default: 0.7
    maxTokens: number;               // Default: 4000
  };
  timeout: number;                   // Default: 300 seconds
  displayName?: string;              // Optional: Human-readable name
  gitConfig?: GitConfig;             // Optional: Git repository configuration
  project?: string;                  // Project association
  interactive?: boolean;             // Enable chat mode
  paths?: {
    workspace?: string;              // PVC workspace path
  }
}
```

### Project Types

Source: `components/frontend/src/types/project.ts` lines 111-119

```typescript
{
  name: string;                      // Project identifier
  displayName?: string;              // Human-readable name
  description?: string;              // Project description
  labels?: Record<string, string>;   // Kubernetes labels
  annotations?: Record<string, string>; // Kubernetes annotations
  creationTimestamp?: string;        // ISO timestamp
  status?: string;                   // "Pending" | "Active" | "Error" | "Terminating"
}
```

### Permission Roles

Source: `components/frontend/src/types/project.ts` lines 19-30

```typescript
type PermissionRole = "view" | "edit" | "admin";

{
  subjectType: "user" | "group";
  subjectName: string;
  role: PermissionRole;
  permissions?: string[];            // Optional: Granular permissions
  memberCount?: number;              // For groups
  grantedAt?: string;
  grantedBy?: string;
}
```

---

## Message Types

Source: `components/frontend/src/types/agentic-session.ts` lines 45-112

**ContentBlock Types**:
- `text_block`: Plain text content
- `thinking_block`: AI reasoning process with signature
- `tool_use_block`: Tool invocation with id, name, input
- `tool_result_block`: Tool execution result

**Message Types**:
- `user_message`: User input
- `assistant_message`: AI response with model info
- `system_message`: Platform notifications
- `result_message`: Session completion summary with cost/usage
- `tool_use_messages`: Paired tool use and result

---

## Built-In Agents

Source: `components/runners/claude-code-runner/agents/*.yaml`

Agents are YAML files with this structure:
```yaml
name: "Product Manager"           # Display name
persona: "PRODUCT_MANAGER"        # Identifier
role: "Product Management and Business Strategy"
isRootAgent: false
expertise: [list of skills]
systemMessage: |
  Agent instructions and personality
analysisPrompt:
  template: |
    Structured analysis template
tools: []                         # Available Claude Code tools
```

**Available Agents** (found in code):
- `product_manager.yaml` - Product Manager
- `staff_engineer.yaml` - Staff Engineer
- `engineering_manager.yaml` - Engineering Manager
- `team_lead.yaml` - Team Lead
- `team_member.yaml` - Team Member
- `delivery_owner.yaml` - Delivery Owner
- `scrum_master.yaml` - Scrum Master
- `technical_writer.yaml` - Technical Writer
- `technical_writing_manager.yaml` - Technical Writing Manager
- `documentation_program_manager.yaml` - Documentation Program Manager
- `content_strategist.yaml` - Content Strategist
- `ux_architect.yaml` - UX Architect
- `ux_team_lead.yaml` - UX Team Lead
- `ux_feature_lead.yaml` - UX Feature Lead
- `ux_researcher.yaml` - UX Researcher
- `pxe.yaml` - PXE (Product Experience Engineering)

**Agent API Response Format** (Source: `components/backend/internal/handlers/agents.go` lines 20-25):
```json
{
  "persona": "product-manager",
  "name": "Product Manager",
  "role": "Product Management and Business Strategy",
  "description": "Agent description from YAML"
}
```

---

## RFE Workflow Phases

Source: `components/frontend/src/types/agentic-session.ts` line 164

```typescript
type WorkflowPhase = "pre" | "ideate" | "specify" | "plan" | "tasks" | "review" | "completed";
```

---

## Git Configuration

Source: `components/manifests/crds/agenticsessions-crd.yaml` lines 48-87

Sessions can clone Git repositories with authentication:

```yaml
gitConfig:
  user:
    name: "User Name"
    email: "user@example.com"
  authentication:
    sshKeySecret: "git-ssh-key"      # Kubernetes Secret name
    tokenSecret: "git-token"         # Alternative: PAT token
  repositories:
    - url: "https://github.com/org/repo"
      branch: "main"
      clonePath: "repos/myrepo"
```

---

## Storage Paths

Source: `components/manifests/crds/agenticsessions-crd.yaml` lines 88-108

Sessions use PVC-backed storage:

```yaml
paths:
  workspace: "/sessions/{id}/workspace"    # Working directory
  messages: "/sessions/{id}/messages.json" # Conversation log
  inbox: "/sessions/{id}/inbox.jsonl"      # User chat inputs (interactive mode)
  outbox: "/sessions/{id}/outbox.jsonl"    # AI responses (interactive mode)
```

---

## Custom Resource Definitions

Actual CRDs in cluster (Source: `components/manifests/crds/`):

1. **agenticsessions.vteam.ambient-code** - AI task execution sessions
2. **rfeworkflows.vteam.ambient-code** - Multi-phase RFE refinement workflows
3. **projectsettings.vteam.ambient-code** - Project configuration

---

## Important Implementation Details

**Agent Discovery** (Source: `components/backend/internal/handlers/agents.go` lines 27-37):
- Agents loaded from `AGENTS_DIR` environment variable
- Falls back to `/app/agents` in container
- Scans `*.yaml` files excluding `agent-schema.yaml` and `README.yaml`
- Name format: "FirstName Role" → persona: "firstname-role"

**Agent Rendering** (Source: `components/backend/internal/handlers/agents.go` lines 111-156):
- Agents returned as markdown with YAML frontmatter
- Frontmatter includes: name, description, tools
- Tools inferred from description ("WebSearch", "WebFetch", etc.)
- Content field contains full agent prompt

**Model Defaults** (Source: `components/manifests/crds/agenticsessions-crd.yaml` line 36):
- Default model: `claude-3-7-sonnet-latest`
- Default temperature: `0.7`
- Default maxTokens: `4000`
- Default timeout: `300` seconds (5 minutes)

**Permission Roles** (Source: `components/frontend/src/types/project.ts` line 19):
- `view`: Read-only access
- `edit`: Can create sessions, modify non-security settings
- `admin`: Full control including deletion

**Subject Types for RBAC** (Source: `components/frontend/src/types/project.ts` line 21):
- `user`: Individual user account
- `group`: Group of users

---

## No UI for Agent Customization

**Finding**: Despite API endpoints for listing agents (`GET /api/projects/[name]/agents`), there are NO frontend pages for:
- Creating custom agents via UI
- Editing agent YAML files
- Uploading agent definitions

**Agent Management Reality**:
- Agents are read-only from filesystem
- Loaded at runtime from YAML files
- Customization requires editing YAML files and rebuilding runner image
- No "Settings → Agent Templates" page exists in codebase

**Source**: Absence of UI routes in `components/frontend/src/app/` tree; API is read-only (GET endpoint only in `components/frontend/src/app/api/projects/[name]/agents/route.ts`)

---

## Additional Resources

- Frontend code: `components/frontend/src/`
- Backend code: `components/backend/internal/`
- CRD definitions: `components/manifests/crds/`
- Agent definitions: `components/runners/claude-code-runner/agents/`
