# Sample Agent Definitions - Reference Only

## ⚠️ Important Disclaimer

**These YAML files are for EDUCATIONAL REFERENCE ONLY.**

### Current Platform Reality

- **Agents are built into the platform code** (Source: vTeam GitHub - rhoai-ux-agents-vTeam.md)
- **No UI for uploading custom agents** currently exists
- **Custom agent creation requires code changes** to the platform
- **UI support for custom agents** is planned for future releases

### What These Files ARE

✅ **Learning Resources**: Understand agent structure and configuration format
✅ **Design Examples**: See how different director roles would be modeled
✅ **Planning Tools**: Draft your ideal agent for when UI support arrives

### What These Files ARE NOT

❌ **Not Uploadable**: Cannot be uploaded via the Ambient web UI
❌ **Not Immediately Usable**: Will not work with current platform version
❌ **Not Lab Requirements**: Lab 1 focuses on using EXISTING built-in agents

---

## How to Actually Use Agents Today

### Option 1: Use Built-In Agents (Recommended)

The platform includes production-ready agents you can use immediately:

**Core Team Agents:**
- Parker (Product Manager)
- Archie (Architect)
- Stella (Staff Engineer)
- Olivia (Product Owner)
- Lee (Team Lead)
- Taylor (Team Member)
- Derek (Delivery Owner)

**Specialized Agents:**
- Emma (Engineering Manager)
- Ryan (UX Researcher)
- Phoenix (PXE Specialist)
- Terry (Technical Writer)

View complete agent details:
<https://github.com/ambient-code/vTeam/blob/main/rhoai-ux-agents-vTeam.md>

### Option 2: Customize Through Prompts

Since you can't modify agents, customize your PROMPTS instead:

**Example - Making Parker act like YOUR PM:**

```text
Context: I'm a Director at a SaaS company focused on developer tools.
Our PM philosophy emphasizes user research, rapid prototyping, and
data-driven decisions. We use RICE scoring (Reach, Impact, Confidence,
Effort) weighted 40% impact, 30% reach, 30% effort/confidence.

Task: Analyze this feature request using OUR prioritization framework...
```

This approach works TODAY and produces customized results.

### Option 3: Contribute to Platform (Advanced)

If you need truly custom agents:

1. **Fork vTeam repository**: <https://github.com/ambient-code/vTeam>
2. **Add agent definition**: See `rhoai-ux-agents-vTeam.md` for structure
3. **Submit pull request**: Contribute your agent back to the platform
4. **Deploy your fork**: Use your modified version

This requires:
- Git/GitHub knowledge
- Markdown editing
- Understanding of agent framework
- Ability to deploy modified platform

---

## Sample Agent Files in This Directory

### director-of-engineering.yaml

**Purpose**: Example of how a Director of Engineering role would be modeled

**Key Features**:
- Technical vision and architecture oversight
- Cross-team coordination patterns
- Engineering excellence standards
- Strategic technical decision frameworks

**Use Case**: Reference when crafting prompts for technical leadership decisions

---

### director-of-product.yaml

**Purpose**: Example of how a Director of Product role would be modeled

**Key Features**:
- Product strategy and roadmap planning
- Customer-centric prioritization
- Go-to-market considerations
- Feature value assessment frameworks

**Use Case**: Reference when crafting prompts for product decisions

---

### director-of-sre.yaml

**Purpose**: Example of how a Director of SRE role would be modeled

**Key Features**:
- Reliability and operational excellence
- SLA/SLI design and monitoring
- Incident response protocols
- Capacity and performance planning

**Use Case**: Reference when crafting prompts for operational decisions

---

## When Will Custom Agents Be Supported?

**Current Status**: Custom agents via UI is on the product roadmap but no
committed timeline yet.

**What's Being Planned**:
- Web-based agent configuration UI
- Agent validation and testing tools
- Personal and team-level agent libraries
- Import/export of agent definitions

**Stay Updated**: Watch the vTeam GitHub repository for announcements

---

## Learning from These Examples

### Agent Structure Pattern

All agents follow this structure:

```yaml
name: [Agent Name]
role: [Job Title]
seniority: [Director-level / Senior / Staff]

expertise:
  - [Specific domain knowledge 1]
  - [Specific domain knowledge 2]
  - [Specific domain knowledge 3]

persona:
  communication_style: |
    [How this agent communicates]

  decision_framework: |
    [How this agent makes decisions]

  key_questions:
    - "[Question this agent always asks]"
    - "[Another critical question]"

knowledge_domains:
  - [Technology/methodology 1]
  - [Technology/methodology 2]

constraints:
  - Defers to [ROLE] for [TOPIC]
  - Focuses on [SCOPE], not [OUT OF SCOPE]

output_format:
  style: [Structured / Narrative / etc.]
  includes:
    - [Output element 1]
    - [Output element 2]
```

### Key Design Principles

**1. Specificity Over Generality**
- ❌ "Software development expertise"
- ✅ "Kubernetes operator development and CRD design"

**2. Realistic Constraints**
- ❌ "I can help with anything technical"
- ✅ "I focus on platform architecture; I defer to security team for compliance"

**3. Authentic Voice**
- ❌ "I analyze requirements professionally"
- ✅ "I ask direct questions and push back on unclear scope"

**4. Clear Decision Framework**
- ❌ "I prioritize important things"
- ✅ "I use RICE scoring weighted 40% user impact, 30% business value, 30% effort"

---

## Using These as Templates

When UI support arrives, these files can serve as starting templates:

1. **Copy a sample** that matches your role
2. **Customize the fields** with YOUR expertise and frameworks
3. **Adjust constraints** to match YOUR organization
4. **Refine communication style** to match YOUR voice
5. **Upload via UI** (when available)

Until then, use the patterns to craft better prompts.

---

## Questions?

**Q: Can I use these files now?**
A: Not directly. Use them to understand agent design, then apply those principles
to your prompts when working with built-in agents.

**Q: When will custom agents be available?**
A: No committed timeline. Watch vTeam GitHub for updates.

**Q: Can I request a custom agent be added?**
A: Yes! File a GitHub issue with your agent specification. The team may add it
to the built-in agent roster.

**Q: How do I contribute to the agent framework?**
A: See CONTRIBUTING.md in the vTeam repository for guidelines.

---

## Additional Resources

**Agent Framework Documentation**:
<https://github.com/ambient-code/vTeam/blob/main/rhoai-ux-agents-vTeam.md>

**Example Agent Implementations**:
<https://github.com/jeremyeder/dotagents>

**Workflow Augmentation Guide**:
See Lab 1 README.md in parent directory

---

**Last Updated**: 2025-10-08
**Platform Version**: vTeam 0.1.x (pre-custom-agent-UI)
