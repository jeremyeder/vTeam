# UI Terminology & Definitions

Quick reference guide for vTeam Ambient Agentic Runner platform terminology.

> **Source**: vTeam Platform - https://github.com/ambient-code/vTeam

---

## Core Platform Concepts

**Agentic Session**: AI-powered task executed by Claude Code CLI. Created via web UI, processed by specialized agents, returns structured results. (Source: vTeam README.md)

**Project**: User workspace containing sessions, settings, and API keys. Maps to a Kubernetes namespace for resource isolation. Access via web UI at `/projects`. (Source: components/README.md)

**Agent**: Specialized AI persona with defined expertise (e.g., Parker/PM, Archie/Architect, Stella/Staff Engineer). Built into platform, not customizable via UI currently. (Source: rhoai-ux-agents-vTeam.md)

**Multi-Agent / Council**: Workflow where multiple specialized agents review the same input, each providing their domain perspective. Example: 7-agent council for RFE review. (Source: rhoai-ux-agents-vTeam.md)

**Runner**: Kubernetes pod executing Claude Code CLI for AI task processing. Contains necessary tools and MCP capabilities. (Source: components/README.md)

**Runner Secrets / API Keys**: Encrypted credentials for AI service providers (Anthropic, OpenAI, etc.). Configured in Settings → Runner Secrets. Stored as Kubernetes Secrets. (Source: vTeam README.md)

**RFE (Request for Enhancement)**: Feature specification workflow using multi-agent council to refine requirements. Produces implementation-ready documentation. (Source: docs/labs/basic/lab-1-first-rfe.md)

**Prompt**: Task description provided to initiate an agentic session. Supports natural language, context, and agent selection. (Source: vTeam README.md)

---

## Session Management

**Session States**:
- **Pending**: Created but not yet started
- **Running**: Currently executing AI tasks
- **Completed**: Successfully finished
- **Failed**: Encountered errors during execution

**Timeout**: Maximum execution duration (default: 300 seconds). Configurable in session creation form. (Source: vTeam README.md)

**Model Selection**: Choose AI model based on task complexity:
- **Claude Sonnet**: Balanced performance and cost (default)
- **Claude Haiku**: Faster, lower cost
- **Claude Opus**: Most capable, higher cost

**Interactive Mode**: Unlimited chat-based sessions. Checkbox option in advanced settings when creating session.

---

## Navigation & UI

**Web Interface**: NextJS frontend at route URL or `localhost:3000` (port-forward). Main access point for all platform features. (Source: components/README.md)

**Projects Page** (`/projects`): View and manage all accessible projects. Create new projects, search existing ones.

**Sessions Page** (`/projects/[name]/sessions`): List all agentic sessions within a project. Filter by status, create new sessions.

**New Session Page** (`/projects/[name]/sessions/new`): Form to create agentic session with prompt, model selection, and settings.

**Session Detail** (`/projects/[name]/sessions/[id]`): View session results with tabs:
- **Output**: AI-generated analysis (markdown rendered)
- **Logs**: Real-time execution logs
- **Files**: Created/modified files (downloadable)
- **Thinking**: AI reasoning process

**Settings Page** (`/projects/[name]/settings`): Configure project information and runner secrets (API keys).

---

## Technical Terms

**Custom Resource (CR)**: Kubernetes API extension representing sessions and projects. Managed by operator. (Source: components/README.md)

**Namespace**: Kubernetes resource isolation boundary. Maps 1:1 with user-facing Project concept.

**Operator**: Kubernetes controller watching Custom Resources and creating Jobs. Written in Go. (Source: components/README.md)

**Job**: Kubernetes workload executing the agentic session. Ephemeral pod created per session.

**Route**: OpenShift resource exposing frontend service via public URL. Format: `https://vteam-frontend-[namespace].apps.[cluster]`

---

## Built-In Agents

(Source: rhoai-ux-agents-vTeam.md - View complete details on GitHub)

**Core Team:**
- **Parker** (Product Manager): Business value, prioritization, stakeholder communication
- **Archie** (Architect): Technical design, architecture decisions, system patterns
- **Stella** (Staff Engineer): Implementation complexity, quality assessment, technical review
- **Olivia** (Product Owner): Acceptance criteria, user stories, backlog refinement
- **Lee** (Team Lead): Team coordination, sprint planning, execution planning
- **Taylor** (Team Member): Pragmatic implementation, hands-on perspective
- **Derek** (Delivery Owner): Sprint tickets, timelines, delivery coordination

**Specialized:**
- **Emma** (Engineering Manager): Team health, capacity planning, delivery coordination
- **Ryan** (UX Researcher): User insights, data analysis, research planning
- **Phoenix** (PXE Specialist): Customer impact, lifecycle management, field experience
- **Terry** (Technical Writer): Documentation, procedures, technical communication

---

## Common Workflows

**Create Agentic Session**:
1. Navigate to Projects → Select project → New Session
2. Enter prompt describing task
3. Select model and configure settings
4. Click "Create Session"
5. Monitor real-time progress
6. Review results in Output/Logs/Files tabs

**Add API Key**:
1. Navigate to Projects → Select project → Settings
2. Click "Runner Secrets"
3. Select provider (Anthropic, OpenAI, etc.)
4. Enter API key (masked input)
5. Optional: Validate key
6. Save (encrypted in Kubernetes Secret)

**Clone Session**:
1. Open completed session detail page
2. Click "Clone" button
3. Modify prompt or settings
4. Create new session based on original

---

## Important Notes

**Agent Customization**: Agents are built into platform code. No UI for creating custom agents currently. Customization requires code changes. UI support planned for future. (Source: User feedback 2025-10-07)

**Agent Accuracy**: Agents work from data you provide. More context yields better results. Always validate factual claims and apply domain expertise.

**Resource Limits**: Sessions have default timeout of 300 seconds. Adjust in advanced settings for longer tasks or increase globally via platform configuration.

**Security**: All runner secrets encrypted as Kubernetes Secrets. RBAC controls project access. OpenShift OAuth integration available. (Source: components/manifests/rbac/)

---

## Troubleshooting

**"Session stuck in Pending"**: Operator may not be processing CRs. Check operator pod logs and RBAC permissions.

**"API key validation failed"**: Key format incorrect or expired. Generate new key from provider console.

**"Cannot load projects"**: Backend API unreachable. Verify backend pod status and route configuration.

**"Session timed out"**: Task exceeded timeout limit. Increase timeout in session settings or simplify prompt.

---

## Additional Resources

**Platform Documentation**: https://github.com/ambient-code/vTeam
**Agent Framework**: https://github.com/ambient-code/vTeam/blob/main/rhoai-ux-agents-vTeam.md
**Deployment Guide**: docs/OPENSHIFT_DEPLOY.md
**Training Plan**: docs/labs/director-training/TRAINING-REVISION-PLAN.md
