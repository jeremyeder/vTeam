# vTeam Platform Architecture

This directory contains the C4 model architecture documentation for the vTeam platform, following the [C4 model](https://c4model.com) approach to software architecture diagrams.

## Quick Start

### View Architecture Diagrams

Architecture diagrams are defined in `workspace.dsl` using [Structurizr DSL](https://github.com/structurizr/dsl) and can be rendered in multiple ways:

**Option 1: Structurizr Lite (Recommended for Editing)**
```bash
docker run -it --rm -p 8080:8080 -v $(pwd):/usr/local/structurizr structurizr/lite
# Open http://localhost:8080 in your browser
```

**Option 2: Structurizr CLI (For CI/CD)**
```bash
# Install CLI (macOS)
brew install structurizr-cli

# Export to PlantUML format
structurizr-cli export -workspace workspace.dsl -format plantuml -output diagrams/

# Render PlantUML diagrams to PNG/SVG
plantuml diagrams/*.puml
```

**Option 3: View Pre-Generated Diagrams**

Pre-generated diagrams are available in the `diagrams/` directory (updated via CI/CD).

### Directory Structure

```
architecture/
├── workspace.dsl          # C4 model definition (source of truth)
├── diagrams/              # Generated diagrams (auto-updated by CI/CD)
│   ├── SystemContext.png
│   ├── Containers.png
│   ├── BackendComponents.png
│   ├── OperatorComponents.png
│   ├── RunnerComponents.png
│   ├── Deployment.png
│   └── SessionCreationFlow.png
└── README.md             # This file
```

## Architecture Overview

### System Context Diagram

**Purpose**: Shows vTeam in the context of users and external systems.

**Key Elements**:
- **Users**: Platform users (engineers) and administrators (SREs)
- **External Systems**: Anthropic API, Kubernetes/OpenShift, GitHub
- **vTeam Platform**: The software system being documented

**When to Reference**: Understanding the big picture, stakeholder communication, requirements gathering.

### Container Diagram

**Purpose**: Shows the major technical building blocks (containers) and their interactions.

**Key Containers**:
1. **Frontend Web Application** (NextJS, TypeScript)
   - User interface for session management
   - Technologies: NextJS 14, Shadcn UI, NextAuth.js

2. **Backend API Service** (Go, Gin)
   - REST API for Custom Resource management
   - Multi-tenant authorization and RBAC
   - Technologies: Go, Gin Framework, client-go

3. **Agentic Operator** (Go, Kubebuilder)
   - Kubernetes operator reconciling Custom Resources
   - Creates Jobs for AI runner pods
   - Technologies: controller-runtime, Kubebuilder

4. **Claude Code Runner** (Python)
   - Ephemeral execution pod running AI tasks
   - Multi-agent orchestration (17 agents)
   - Technologies: Python, Claude Code CLI, MCP SDK

5. **Custom Resources (etcd)** - Kubernetes storage
6. **Kubernetes Secrets** - Encrypted credential storage

**When to Reference**: Architecture decisions, deployment planning, team boundary discussions.

### Component Diagrams

Detailed internal structure of each container:

#### Frontend Components
- Session Management UI
- Project Management UI
- Settings & Secrets UI
- Authentication Handler (OAuth)

#### Backend Components
- Projects API
- Sessions API
- Secrets API
- RBAC Middleware
- Kubernetes Client

#### Operator Components
- Project Controller
- Session Controller
- Resource Manager (quotas, network policies)
- Job Orchestrator

#### Runner Components
- Agent Loader (17 AI agents)
- MCP Integration (browser automation)
- Session Executor
- Claude API Client

**When to Reference**: Detailed implementation planning, code generation, refactoring decisions.

### Deployment Diagram

**Purpose**: Shows how containers are deployed to OpenShift infrastructure.

**Key Elements**:
- OpenShift Cluster deployment topology
- Namespace organization (ambient-code, kube-system)
- Pod distribution and networking
- External service integration

**When to Reference**: Infrastructure planning, SRE operations, deployment automation.

### Dynamic Diagram: Session Creation Flow

**Purpose**: Shows runtime interaction sequence for creating and executing an AI session.

**Flow**:
1. User creates session via Frontend
2. Frontend calls Backend API
3. Backend creates AgenticSession Custom Resource
4. Operator watches CR and creates Kubernetes Job
5. Runner pod executes AI tasks via Anthropic API
6. Runner updates session status in CR
7. Frontend polls and displays results

**When to Reference**: Understanding behavior, debugging issues, integration testing.

## Using C4 with LLMs

### For LLM-Assisted Development

**Include architecture context in prompts**:

```markdown
Reference: vTeam Platform Architecture
- See: architecture/workspace.dsl
- Container Diagram: architecture/diagrams/Containers.png

When generating code for [component name], ensure it:
1. Respects the boundaries shown in the component diagram
2. Uses the specified technologies (e.g., Go + Gin for Backend)
3. Communicates via the defined relationships only
4. Follows the deployment model in the deployment diagram
```

**Example Prompts**:

1. **Generate Code from Architecture**:
   ```
   Read the vTeam architecture in workspace.dsl. Generate the Go code
   for the "Sessions API" component in the Backend container. Include:
   - HTTP handlers for CRUD operations
   - Integration with Kubernetes client component
   - RBAC middleware integration as shown in the component diagram
   ```

2. **Validate Code Against Architecture**:
   ```
   Review this PR against the vTeam architecture (workspace.dsl):
   - Does the new code respect component boundaries?
   - Are there any architectural violations?
   - Do the dependencies match the relationships in the diagram?
   ```

3. **Generate Tests from Architecture**:
   ```
   Based on the relationships in the Container diagram, generate
   integration tests for the Backend → Kubernetes API interaction.
   Test the AgenticSession CR lifecycle shown in the dynamic diagram.
   ```

### For Architecture Evolution

**When architecture changes**:

1. Update `workspace.dsl` first (architecture is code)
2. Regenerate diagrams: `make generate-diagrams`
3. Update implementation to match (or vice versa if brownfield)
4. Commit both DSL and diagrams together

**Example workflow**:
```bash
# Edit architecture
vim workspace.dsl

# Regenerate diagrams
structurizr-cli export -workspace workspace.dsl -format plantuml -output diagrams/
plantuml diagrams/*.puml

# Validate with ArchUnit (future enhancement)
go test ./tests/architecture/...

# Commit changes
git add workspace.dsl diagrams/
git commit -m "arch: add MCP Integration component to Runner"
```

## Architecture Validation

### Manual Validation

Before committing architecture changes, ask:

1. **Completeness**: Are all major components represented?
2. **Clarity**: Can a new team member understand the system?
3. **Accuracy**: Does the architecture match the actual implementation?
4. **Utility**: Will this help developers make better decisions?

### Automated Validation (Future)

Planned CI/CD checks:
- [ ] DSL syntax validation
- [ ] Diagram generation smoke test
- [ ] ArchUnit tests enforcing component boundaries
- [ ] Drift detection (code vs architecture)

## Design Decisions

### Why C4 Model?

**Problem**: vTeam had scattered documentation (Mermaid diagrams, READMEs, tribal knowledge). LLM-assisted development needs deterministic, version-controlled architecture.

**Solution**: C4 model provides:
- **Hierarchical views**: Context → Container → Component → Code
- **Diagrams as code**: Version control, deterministic LLM input
- **Notation independence**: Can use PlantUML, Mermaid, or Structurizr
- **LLM-friendly**: Structured text easier to parse than free-form docs

See: [docs/research/c4-vs-prompting-analysis.md](../docs/research/c4-vs-prompting-analysis.md)

### Why Structurizr DSL?

**Alternatives Considered**:
- PlantUML: Less structured, harder for LLMs to generate/modify
- Mermaid: Limited C4 support, less powerful for complex systems
- Hand-drawn diagrams: Not version-controllable, not LLM-readable

**Decision**: Structurizr DSL
- Text-based, human-readable syntax
- Generates multiple output formats (PlantUML, Mermaid, JSON)
- Strong C4 semantics (enforces relationships, deployment mapping)
- Active community and tooling ecosystem

### Diagram Maintenance Strategy

**Approach**: Diagrams are generated from `workspace.dsl`, not manually drawn.

**Workflow**:
1. Edit `workspace.dsl` (source of truth)
2. Generate diagrams via Structurizr CLI
3. Commit both DSL and diagrams (for GitHub preview)
4. CI/CD validates and regenerates on every commit

**Rationale**: Prevents stale diagrams. Single source of truth enables automation.

## Contributing to Architecture

### When to Update Architecture

**Always update** when:
- Adding a new container (microservice, database, external system)
- Changing deployment topology
- Adding/removing major component boundaries
- Modifying API contracts between containers

**Consider updating** when:
- Refactoring internal component structure
- Adding significant new functionality
- Changing technology choices

**Skip updating** when:
- Minor implementation details change
- Internal function/class refactoring
- Bug fixes that don't affect architecture

### How to Update Architecture

1. **Read existing architecture**: Understand current state
   ```bash
   structurizr-cli export -workspace workspace.dsl -format plantuml
   ```

2. **Edit DSL**: Make changes to `workspace.dsl`
   ```dsl
   # Add new component
   newComponent = component "New Feature" "Description" "Technology"

   # Add relationship
   existingComponent -> newComponent "Calls"
   ```

3. **Validate locally**: Generate diagrams and review
   ```bash
   structurizr-cli export -workspace workspace.dsl -format plantuml -output diagrams/
   plantuml diagrams/*.puml
   open diagrams/Containers.png
   ```

4. **Update documentation**: Update this README if needed

5. **Create PR**: Include both DSL and diagram changes
   ```bash
   git add workspace.dsl diagrams/
   git commit -m "arch: add authentication middleware component"
   ```

### Architecture Review Checklist

Before merging architecture changes:

- [ ] DSL syntax is valid (runs through Structurizr CLI)
- [ ] All containers have clear technology choices
- [ ] Relationships are bidirectional where appropriate
- [ ] Component boundaries align with Team Topologies
- [ ] Deployment diagram updated if infrastructure changes
- [ ] Dynamic diagrams updated if interaction flows change
- [ ] README updated if new diagram types added
- [ ] Diagrams are readable (not too crowded or complex)

## Integration with Existing Documentation

### Relationship to Other Docs

**C4 diagrams complement (not replace)**:
- **Mermaid diagrams** (`diagrams/ux-feature-workflow.md`): Show *behavior* (how agents collaborate)
- **C4 diagrams** (`architecture/workspace.dsl`): Show *structure* (what components exist)

**Example**:
- Mermaid flowchart: "How does a feature flow through the team?"
- C4 component diagram: "What are the components and their relationships?"

Both are valuable for different purposes.

### Linking to Agent Documentation

**Agent definitions** (`agents/*.md`, `rhoai-ux-agents-vTeam.md`):
- Define agent *personalities*, *behaviors*, *competencies*
- Map to Runner components in C4 architecture
- Example: "Agent Loader" component orchestrates the 17 agents

**Integration**:
- C4 diagrams show *where* agents run (Runner container)
- Agent docs show *what* agents do (behaviors, roles)

## Tooling Reference

### Structurizr CLI Commands

```bash
# Validate DSL syntax
structurizr-cli validate -workspace workspace.dsl

# Export to PlantUML
structurizr-cli export -workspace workspace.dsl -format plantuml -output diagrams/

# Export to Mermaid
structurizr-cli export -workspace workspace.dsl -format mermaid -output diagrams/

# Export to JSON (for programmatic access)
structurizr-cli export -workspace workspace.dsl -format json -output workspace.json
```

### PlantUML Commands

```bash
# Render single diagram
plantuml diagrams/Containers.puml

# Render all diagrams
plantuml diagrams/*.puml

# Render to SVG instead of PNG
plantuml -tsvg diagrams/*.puml
```

### Docker-Based Workflow (No Local Install)

```bash
# Structurizr Lite (browser-based editing)
docker run -it --rm -p 8080:8080 -v $(pwd):/usr/local/structurizr structurizr/lite

# PlantUML rendering
docker run -it --rm -v $(pwd)/diagrams:/data plantuml/plantuml -tpng /data/*.puml
```

## FAQ

### Q: Do I need to update diagrams every time I change code?

**A**: Only if the change affects **architecture** (containers, components, relationships). Bug fixes and implementation details don't require diagram updates.

### Q: What if the diagrams don't match the code?

**A**: This is "architecture drift" and should be fixed ASAP. Either:
1. Update code to match diagrams (if architecture is correct)
2. Update diagrams to match code (if implementation is correct)
3. Discuss in architecture review if unclear

Future: CI/CD will detect drift automatically via ArchUnit tests.

### Q: Can I use Mermaid instead of Structurizr?

**A**: Yes! Structurizr can export to Mermaid format. However, Structurizr DSL is more powerful for C4 modeling (enforces relationships, deployment mapping). Use Mermaid for simpler diagrams.

### Q: How do I know if my architecture is "good"?

**A**: Ask these questions:
- Can a new engineer understand the system in 30 minutes by reading diagrams?
- Do component boundaries align with team boundaries (Team Topologies)?
- Can an LLM generate code scaffolding from the architecture?
- Are deployment and operational concerns clear?

If yes, your architecture is probably good enough.

### Q: What about detailed class diagrams?

**A**: C4 stops at the component level intentionally. For internal class design, use code comments, inline documentation, or UML class diagrams if absolutely necessary. Most teams find component-level diagrams sufficient.

## Resources

### C4 Model
- Official site: https://c4model.com
- Core diagrams: https://c4model.com/#coreDiagrams
- Supplementary diagrams: https://c4model.com/#supplementaryDiagrams

### Structurizr
- DSL reference: https://github.com/structurizr/dsl
- CLI documentation: https://github.com/structurizr/cli
- Examples: https://structurizr.com/help/dsl

### vTeam-Specific
- Research analysis: [docs/research/c4-vs-prompting-analysis.md](../docs/research/c4-vs-prompting-analysis.md)
- Multi-tenant architecture: [.specify/memory/orginal/architecture.md](../.specify/memory/orginal/architecture.md)
- Agent framework: [rhoai-ux-agents-vTeam.md](../rhoai-ux-agents-vTeam.md)

---

**Last Updated**: 2025-09-30
**Maintained By**: vTeam Architecture Team
**Questions**: Ask in #vteam-dev Slack channel or file an issue
