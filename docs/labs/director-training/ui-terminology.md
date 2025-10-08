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

## Permissions

Project access control using role-based permissions. (Source: `components/frontend/src/types/project.ts`)

**Roles**:
- **view**: Read-only access to view sessions and results
- **edit**: Can create sessions, modify non-security settings
- **admin**: Full control including deletion, permissions management, and API keys

**Subjects**: Permissions granted to individual users or groups

---

## Built-In Agents

Agents are YAML-defined AI personas loaded from filesystem at runtime. (Source: `components/runners/claude-code-runner/agents/*.yaml`)

**Available Agents**:
- [product_manager.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/product_manager.yaml) - Product Manager
- [staff_engineer.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/staff_engineer.yaml) - Staff Engineer
- [engineering_manager.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/engineering_manager.yaml) - Engineering Manager
- [team_lead.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/team_lead.yaml) - Team Lead
- [team_member.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/team_member.yaml) - Team Member
- [delivery_owner.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/delivery_owner.yaml) - Delivery Owner
- [scrum_master.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/scrum_master.yaml) - Scrum Master
- [technical_writer.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/technical_writer.yaml) - Technical Writer
- [technical_writing_manager.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/technical_writing_manager.yaml) - Technical Writing Manager
- [documentation_program_manager.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/documentation_program_manager.yaml) - Documentation Program Manager
- [content_strategist.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/content_strategist.yaml) - Content Strategist
- [ux_architect.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/ux_architect.yaml) - UX Architect
- [ux_team_lead.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/ux_team_lead.yaml) - UX Team Lead
- [ux_feature_lead.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/ux_feature_lead.yaml) - UX Feature Lead
- [ux_researcher.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/ux_researcher.yaml) - UX Researcher
- [pxe.yaml](https://github.com/jeremyeder/vTeam/blob/main/components/runners/claude-code-runner/agents/pxe.yaml) - PXE (Product Experience Engineering)

---

## RFE Workflow Phases

Multi-phase feature refinement process where agents collaborate sequentially. (Source: `components/frontend/src/types/agentic-session.ts`)

**pre**: Initial preparation phase where requirements are gathered and context is established. Agents analyze the problem space, identify stakeholders, and collect necessary background information to ensure the team has a shared understanding of the feature request before proceeding to ideation.

**ideate**: Creative exploration phase where agents brainstorm potential solutions and approaches. Multiple agents contribute different perspectives—product management considers business value, architects evaluate technical feasibility, and engineers assess implementation complexity. This divergent thinking phase generates a wide range of possibilities.

**specify**: Detailed specification phase where requirements are formalized into structured documentation. Product owners define acceptance criteria, user stories are written, and functional requirements are documented. The specification serves as the authoritative reference for what the feature should accomplish.

**plan**: Technical planning phase where architecture and implementation approach are defined. Architects design system components, staff engineers identify technical risks, and the team agrees on technology choices, data models, and integration points. The plan bridges requirements and implementation.

**tasks**: Task breakdown phase where high-level plans are decomposed into actionable development work items. Delivery owners create sprint tickets, estimate effort, identify dependencies, and sequence work. The result is a prioritized backlog ready for team execution.

**review**: Final validation phase where all artifacts are reviewed for completeness and consistency. The entire workflow output—specifications, plans, and tasks—is examined to ensure alignment, catch gaps, and verify that the feature is ready for development to begin.

**completed**: Terminal state indicating the RFE workflow has finished successfully. All phases have been executed, artifacts generated, and the feature definition is complete.

---

## Git Configuration

Sessions can clone Git repositories with authentication. Configure user name/email for commits, and provide SSH key or token via Kubernetes Secrets. Multiple repositories can be cloned to the session workspace. (Source: `components/manifests/crds/agenticsessions-crd.yaml`)

---

## Storage Paths

Sessions use PVC-backed persistent storage with structured paths for workspace files, conversation messages, and interactive mode inbox/outbox JSONL files. (Source: `components/manifests/crds/agenticsessions-crd.yaml`)

---

## API Keys

AI agents require API credentials stored as Kubernetes Secrets and loaded into runner pods as environment variables. (Source: `components/runners/claude-code-runner/main.py`, `components/manifests/env.example`)

**Required**:
- **ANTHROPIC_API_KEY**: Anthropic Claude API key for AI processing

**Optional**:
- **GIT_SSH_KEY_SECRET**: SSH private key for Git repository access
- **GIT_TOKEN_SECRET**: Personal access token for HTTPS Git authentication

Secrets are created in the project namespace and referenced in session configurations. See [Appendix A: API Key Setup](#appendix-a-api-key-setup) for detailed instructions.

---

## Custom Resource Definitions

Actual CRDs in cluster (Source: `components/manifests/crds/`):

1. **agenticsessions.vteam.ambient-code** - AI task execution sessions
2. **rfeworkflows.vteam.ambient-code** - Multi-phase RFE refinement workflows
3. **projectsettings.vteam.ambient-code** - Project configuration

---

## Additional Resources

- Frontend code: `components/frontend/src/`
- Backend code: `components/backend/internal/`
- CRD definitions: `components/manifests/crds/`
- Agent definitions: `components/runners/claude-code-runner/agents/`

---

# Appendix A: API Key Setup

## Anthropic API Key

**Required for all AI agent sessions**

### Getting Your API Key

1. Visit [console.anthropic.com](https://console.anthropic.com/)
2. Create an account or sign in
3. Navigate to **Settings → API Keys**
4. Click **Create Key**
5. Copy the key (starts with `sk-ant-`)
6. Verify you have at least $5 in credits

### Loading into OpenShift

```bash
# Create secret in your project namespace
oc create secret generic anthropic-api-key \
  --from-literal=ANTHROPIC_API_KEY=sk-ant-your-key-here \
  -n your-project-name
```

### Verifying the Secret

```bash
# Check secret exists
oc get secret anthropic-api-key -n your-project-name

# View secret keys (not values)
oc describe secret anthropic-api-key -n your-project-name
```

---

## Git SSH Key (Optional)

**For private repository access via SSH**

### Generating SSH Key

```bash
# Generate new key
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/vteam_key

# Copy public key
cat ~/.ssh/vteam_key.pub
```

### Adding to GitHub

1. Go to **GitHub → Settings → SSH and GPG keys**
2. Click **New SSH key**
3. Paste your public key
4. Save

### Loading into OpenShift

```bash
# Create secret from private key file
oc create secret generic git-ssh-key \
  --from-file=ssh-privatekey=~/.ssh/vteam_key \
  -n your-project-name
```

---

## Git Personal Access Token (Optional)

**For private repository access via HTTPS**

### Creating GitHub Token

1. Go to **GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)**
2. Click **Generate new token (classic)**
3. Select scopes: **repo** (full control of private repositories)
4. Click **Generate token**
5. Copy token (starts with `ghp_`)

### Loading into OpenShift

```bash
# Create secret from token
oc create secret generic git-token \
  --from-literal=token=ghp_your_token_here \
  -n your-project-name
```

---

## Updating API Keys

To rotate or update credentials:

```bash
# Delete existing secret
oc delete secret anthropic-api-key -n your-project-name

# Create new secret with updated key
oc create secret generic anthropic-api-key \
  --from-literal=ANTHROPIC_API_KEY=sk-ant-new-key-here \
  -n your-project-name
```

---

## Security Best Practices

- **Never commit API keys** to version control
- **Use password managers** to store keys securely
- **Rotate keys regularly** (quarterly recommended)
- **Use separate keys** for development and production
- **Monitor usage** via Anthropic console
- **Revoke compromised keys** immediately
