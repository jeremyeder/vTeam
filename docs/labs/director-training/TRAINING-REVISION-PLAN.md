# Director Training - Comprehensive Revision Plan

**Created**: 2025-10-07
**Status**: Ready for Implementation
**Purpose**: Complete reference for revising director training materials to match platform reality and incorporate enterprise best practices

---

## Table of Contents

1. [Critical User Feedback](#critical-user-feedback)
2. [Platform Reality Check](#platform-reality-check)
3. [External Resources & Lessons](#external-resources--lessons)
4. [Specific Corrections Required](#specific-corrections-required)
5. [Revised Training Approach](#revised-training-approach)
6. [Implementation Checklist](#implementation-checklist)
7. [Source Materials & Citations](#source-materials--citations)

---

## Critical User Feedback

### Key Correction: No Agent Library UI

**Issue Identified**: Line 47 in `02-my-first-agent/README.md`
```markdown
# INCORRECT
1. Navigate to Settings → Agent Templates
2. Select "Parker (Product Manager)" to view
```

**Reality**:
- There is NO "Agent Library" UI component
- Agents ARE baked into the platform currently
- Cannot upload custom agents via UI
- Agent details viewable on vTeam GitHub, not in UI

**Source**: Direct user feedback, 2025-10-07

### Workflow Augmentation Philosophy

User provided clear approach (verbatim):

> Augment your A priority
> Write down what you do to get something done
> Highlight the automateable steps
> Make agents for them
> Next time you do this thing, use the agents as your sounding board.
> Improve the agent as you go.
> Defer more and more to the agent as you improve it.
> Move on to the next…

**Implication**: Training should focus on augmenting REAL work, not theoretical exercises.

### Citation Requirements

**User Requirement**: "I need you to ALWAYS cite sources near to where the text was included."

**Action Required**:
- Every feature claim must cite source
- Every setup step must reference documentation
- Links to actual repos, docs, platform behavior
- No assumptions about features without verification

### Lab Complexity Issue

**User Feedback**: "The first lab needs to be very simple... it is using features that aren't in the actual codebase."

**Problem**:
- Lab 1 was 60 minutes but too complex
- Referenced non-existent UI features
- Created custom agents that can't be uploaded
- Not achievable in time allotted

**Solution**: Radical simplification focusing on using existing agents, not creating new ones.

---

## Platform Reality Check

### What EXISTS in the Platform

✅ **Built-in Agents** (Source: vTeam GitHub - https://github.com/ambient-code/vTeam)
- Parker (Product Manager)
- Archie (Architect)
- Stella (Staff Engineer)
- Olivia (Product Owner)
- Lee (Team Lead)
- Taylor (Team Member)
- Derek (Delivery Owner)
- Plus UX, Content, and SRE agents (see rhoai-ux-agents-vTeam.md)

✅ **Agentic Sessions** (Source: vTeam README.md)
- Web UI for creating sessions
- Multi-agent workflow execution
- Real-time status updates
- Result storage in Custom Resources

✅ **Kubernetes-Native Architecture** (Source: components/README.md)
- Frontend: NextJS web interface
- Backend: Go API service
- Operator: Kubernetes operator
- Runners: Claude Code CLI with agents

### What DOES NOT EXIST (Yet)

❌ **Agent Library UI Component**
- No browsing of agent templates in UI
- No "Settings → Agent Templates" menu
- No visual agent configuration editor

❌ **Custom Agent Upload**
- Cannot upload YAML agent definitions via UI
- No "Create Custom Agent" button
- No agent validation interface

❌ **Agent Customization UI**
- No web-based agent editor
- No persona configuration forms
- No system prompt customization UI

### How to Actually Work with Agents

**Current Reality**:
1. Agents defined in codebase (see `agents/` directory or rhoai-ux-agents-vTeam.md)
2. View agent details on GitHub: https://github.com/ambient-code/vTeam
3. Use existing agents via agentic sessions
4. Agent behavior improvements require code changes (future: UI support)

---

## External Resources & Lessons

### 1. IBM MCP Guide

**Source**: `/tmp/ibm-guide-to-architecting-secure-enterprise-ai-agents-with-mcp-techxchange-2025.pdf`
**Author**: Mihai Criveti, IBM
**Title**: "A Guide to Architecting Secure Enterprise AI Agents with MCP Servers - Verified by Anthropic"
**Pages**: 22
**Date**: 2025-10-04

#### Key Concepts to Incorporate

**Security SOLUTION Framework** (Section 4)
- **S**ecure by design
- **O**bservability and monitoring
- **L**east privilege access
- **U**ser authentication and authorization
- **T**esting and validation
- **I**ncident response
- **O**perational excellence
- **N**etwork segmentation

**MCP Gateway Pattern** (Section 5)
- Centralized request handling
- Approval workflows for sensitive operations
- Authentication and authorization layer
- Request logging and audit trails

**Architecture and Deployment** (Section 5.2)
- MCP Gateway Pattern for enterprise
- Request flow with approvals
- Security foundations

**Agent Observability** (Section 6)
- Why observability changes for agents
- Building blocks: tracing, metrics, logs
- Evals in production and development
- Root-cause analysis and remediation

**DevSecOps Lifecycle** (Section 3)
- PLAN → CODE → BUILD → TEST → OPTIMIZE → RELEASE → DEPLOY → OPERATE → MONITOR
- Continuous loop with runtime optimization

**Enterprise Requirements** (Section 7)
- Reference architecture
- Scalability considerations
- Compliance and governance

### 2. dgutride/weekly-update-agent

**Source**: https://github.com/dgutride/weekly-update-agent

#### Key Patterns

- **Problem-focused**: Automates weekly reporting/updates
- **Modular approach**: Uses `.claude/` directory for configuration
- **Multi-agent plan**: References `weekly-report-subagents-plan.md`
- **Google Workspace integration**: Shows real-world tool integration
- **Incremental development**: Work-in-progress, evolving approach

#### Applicable Lessons

- Start with ONE specific workflow (weekly updates)
- Break down into subagents for different parts
- Use MCP for external integrations (Google Workspace)
- Iterate and improve over time

### 3. jeremyeder/dotagents

**Source**: https://github.com/jeremyeder/dotagents

#### Key Patterns

**Agent Structure**:
- Agents defined in markdown files in `prompts/` directory
- Installed to `~/.claude/agents/`
- Automatic discovery by Claude Code
- No custom UI needed

**Agent Design**:
- **Modular**: Each agent is independent
- **Specialized**: Domain-specific (governance, technical risk, market analysis)
- **Decision support**: Research-backed recommendations
- **Standardized output**: Consistent executive summary format

**Example: PyTorch TAC Voting Advisor**:
- Analyzes GitHub projects for governance decisions
- 7-day voting window → quick, thorough evaluation
- Generates console tables + markdown summaries
- Strategic and risk assessments

#### Applicable Lessons

- Agents live in filesystem (`~/.claude/agents/`), not UI
- Markdown-based agent definitions work well
- Focus on specific decision-making workflows
- Standardized output formats improve usability

### Synthesis: Unified Approach

All three resources point to same pattern:

1. **Identify specific workflow** (weekly updates, voting decisions, etc.)
2. **Define agents for that workflow** (filesystem-based, not UI)
3. **Integrate with real tools** (MCP for GitHub, Google, etc.)
4. **Start simple, iterate** (don't build everything at once)
5. **Enterprise considerations** (security, observability, deployment)

---

## Specific Corrections Required

### 1. Pre-Work Guide (`00-prework.md`)

**Issues**:
- No incorrect features currently (just created)
- Needs citations added
- Should reference IBM security considerations

**Actions**:
- ✅ Keep existing structure
- ✅ Add citations for all external links
- ✅ Add security checklist from IBM guide
- ✅ Verify all setup steps against actual platform

### 2. Presentation Materials (`01-presentation/`)

**Issues in `slides.md`**:
- Line 47 (approx): References "Agent Library" that doesn't exist
- Missing citations for claims
- Needs MCP architecture context

**Actions**:
- ❌ Remove: "Navigate to Settings → Agent Templates"
- ✅ Replace with: "View agent details on vTeam GitHub"
- ✅ Add: MCP Gateway Pattern slide (from IBM guide)
- ✅ Add: Enterprise security considerations
- ✅ Add citations for all technical claims

**Issues in `demo-script.md`**:
- May reference UI features that don't exist
- Needs validation against actual platform

**Actions**:
- ✅ Review all steps against actual platform
- ✅ Update to use only existing features
- ✅ Add fallback plan if features unavailable

**Issues in `speaker-notes.md`**:
- References may be incorrect
- Needs alignment with corrected slides

**Actions**:
- ✅ Update to match corrected slides
- ✅ Add notes on platform limitations
- ✅ Prepare responses for "can I customize agents?" question

### 3. Lab 1 (`02-my-first-agent/`)

**MAJOR ISSUES** - Complete Rewrite Required:

**Current Problems**:
```markdown
# These sections reference non-existent features:

Step 3.1: Create Agent in Ambient Platform
- "Navigate to Settings → Agent Templates" ❌
- "Click Create Custom Agent" ❌
- "Paste your completed YAML" ❌
- "The platform will validate the structure" ❌

Step 3.2: Configure Agent Behavior
- "Agent Behavior Settings" UI ❌
- "Collaboration Mode" options ❌
- "Defer Triggers" configuration ❌
```

**New Approach** - Rename to `02-workflow-augmentation/`:

**Lab 1: Workflow Augmentation (60 minutes)**

**Part 1: Identify Your Priority** (10 min)
- What's your A priority task this week?
- Examples: Weekly status reports, architecture review, sprint planning
- Document current manual process
- Use provided workflow template

**Part 2: Document Current Workflow** (15 min)
- Step-by-step breakdown of manual process
- Identify repetitive steps
- Highlight automateable parts
- Mark decision points

**Part 3: Augment with Existing Agents** (25 min)
- Create agentic session in web UI
- Select relevant built-in agents (Parker, Archie, Stella, etc.)
- Describe your workflow/task
- Observe multi-agent analysis
- NO custom agent creation - use what exists

**Part 4: Iterate and Improve** (10 min)
- What worked? What didn't?
- How would you adjust for next time?
- Document learnings in template
- Plan next workflow to augment

**Key Principles**:
- Use REAL work, not theoretical exercises
- Use EXISTING agents, don't create new ones
- Focus on IMMEDIATE value
- ITERATE and improve over time

### 4. Lab 2 (`03-dev-deploy/`)

**Current Issues**:
- Name suggests "development" but should focus on deployment
- Missing enterprise considerations
- No security or monitoring content

**New Approach** - Rename to `03-agent-deployment/`:

**Lab 2: Agent Deployment with Enterprise Patterns (60 minutes)**

**Part 1: Security Foundations** (15 min)
- IBM SOLUTION Framework overview
- Authentication setup
- Authorization and RBAC
- Based on IBM guide Section 4

**Part 2: Deploy Agent-Augmented Workflow** (30 min)
- Take Lab 1 workflow
- Deploy as automated agentic session
- Use MCP Gateway pattern (IBM guide)
- Configure for production use
- Monitor via platform UI

**Part 3: Observability Setup** (15 min)
- Basic monitoring (IBM guide Section 6)
- Track agent performance metrics
- Set up alerts for failures
- Review logs and traces

**Content to Add**:
- `security-checklist.md` - from IBM SOLUTION framework
- `monitoring-setup.md` - from IBM observability section
- Real deployment examples

### 5. Sample Agent Files (`02-my-first-agent/sample-agents/`)

**Current Issues**:
- These YAML files suggest they can be uploaded via UI
- They're detailed but can't actually be used as shown
- Misleading for participants

**Options**:
1. **Delete entirely** - since they can't be uploaded
2. **Move to reference section** - "future capability" or "for developers"
3. **Repurpose** - show agent structure for understanding, not creation

**Recommendation**: Option 3
- Keep as educational reference
- Add prominent disclaimer: "For understanding agent structure only. Custom agents currently require code changes. UI support coming soon."
- Link to vTeam GitHub for actual agent code

### 6. Participant Package (`participant-package/`)

**Issues**:
- Doesn't exist yet
- Needs accurate information only
- Must include all citations

**Actions**:
- ✅ Create `README.md` - complete guide with citations
- ✅ Create `quick-reference.md` - actual commands that work
- ✅ Create `resources.md` - links to real documentation
- ✅ All content verified against platform

### 7. Instructor Resources (`instructor/`)

**Issues**:
- Doesn't exist yet
- Needs validation script for REAL platform
- Troubleshooting for ACTUAL issues

**Actions**:
- ✅ Create `facilitator-guide.md` - teaching guide
- ✅ Create `validation-script.sh` - tests actual platform features
- ✅ Create `troubleshooting.md` - common real issues (not theoretical)

---

## Revised Training Approach

### Core Principles

1. **Reality-Based**: Only teach features that exist
2. **Workflow-Focused**: Augment real work, not theoretical examples
3. **Iterative**: Start simple, improve over time
4. **Enterprise-Ready**: Include security, monitoring, deployment
5. **Cited**: Every claim has a source

### Training Flow

**Pre-Work** (30-45 min before session)
- Setup: API keys, cluster access
- Validation: Run script to verify environment
- Security: Review enterprise considerations

**Presentation** (30 min)
- What is Ambient Code? (with citations)
- Multi-agent collaboration (show real agents)
- Live demo (using actual features only)
- Enterprise patterns (IBM guide)

**Break** (5 min)
- Environment check
- Questions

**Lab 1: Workflow Augmentation** (60 min)
- Identify real priority task
- Document current manual process
- Use existing agents to augment
- Iterate and improve

**Break** (30 min)
- Lunch or extended break

**Lab 2: Agent Deployment** (60 min)
- Security setup (IBM SOLUTION framework)
- Deploy augmented workflow
- Monitoring and observability

**Wrap-Up** (15 min)
- Key learnings
- Next steps
- Resources for continued learning

### Success Metrics

**Participants leave able to**:
- ✅ Augment one real workflow using existing agents
- ✅ Deploy agent-augmented solution with security
- ✅ Monitor agent performance
- ✅ Know where to find documentation
- ✅ Iterate and improve on their own

**Participants understand**:
- ✅ Which features exist vs. coming soon
- ✅ How to work within current platform capabilities
- ✅ Enterprise security and deployment patterns
- ✅ Where to get help and resources

---

## Implementation Checklist

### Phase 1: Document Creation
- [x] Create TRAINING-REVISION-PLAN.md (this file)
- [ ] Update 00-prework.md with citations
- [ ] Fix 01-presentation/slides.md (line ~47 and add citations)
- [ ] Update 01-presentation/demo-script.md for accuracy
- [ ] Update 01-presentation/speaker-notes.md for alignment

### Phase 2: Lab Rewrite
- [ ] Rename 02-my-first-agent/ to 02-workflow-augmentation/
- [ ] Completely rewrite 02-workflow-augmentation/README.md
- [ ] Create 02-workflow-augmentation/workflow-template.md
- [ ] Create 02-workflow-augmentation/examples/ with real workflows
- [ ] Update 02-my-first-agent/sample-agents/ with disclaimer
- [ ] Rename 03-dev-deploy/ to 03-agent-deployment/
- [ ] Rewrite 03-agent-deployment/README.md with security/monitoring
- [ ] Create 03-agent-deployment/security-checklist.md (from IBM guide)
- [ ] Create 03-agent-deployment/monitoring-setup.md (from IBM guide)

### Phase 3: Supporting Materials
- [ ] Create participant-package/README.md with citations
- [ ] Create participant-package/quick-reference.md (verified commands)
- [ ] Create participant-package/resources.md (real links)
- [ ] Create instructor/facilitator-guide.md
- [ ] Create instructor/validation-script.sh (tests real features)
- [ ] Create instructor/troubleshooting.md (actual issues)

### Phase 4: Quality Assurance
- [ ] Review ALL materials for non-existent features
- [ ] Add citations to EVERY claim
- [ ] Test validation script against actual platform
- [ ] Dry run with test participant
- [ ] Get user approval

### Phase 5: Finalization
- [ ] Update main labs index (docs/labs/index.md)
- [ ] Create git commit with changes
- [ ] Document what's different from original
- [ ] Prepare for delivery

---

## Source Materials & Citations

### Platform Documentation

**vTeam GitHub Repository**
- URL: https://github.com/ambient-code/vTeam
- Key Files:
  - README.md - Platform overview, quick start
  - components/README.md - Architecture details
  - rhoai-ux-agents-vTeam.md - Complete agent framework
  - docs/labs/index.md - Lab structure

**Anthropic Documentation**
- Console: https://console.anthropic.com/
- API Docs: https://docs.anthropic.com/
- Claude Code: https://docs.claude.com/en/docs/claude-code/

**OpenShift Documentation**
- OpenShift Local: https://developers.redhat.com/products/openshift-local/overview
- OpenShift Container Platform: https://docs.openshift.com/

### External Resources

**IBM MCP Guide**
- File: `/tmp/ibm-guide-to-architecting-secure-enterprise-ai-agents-with-mcp-techxchange-2025.pdf`
- Author: Mihai Criveti, IBM
- Date: 2025-10-04
- Key Sections:
  - Section 4: Security SOLUTION Framework
  - Section 5: MCP Gateway Pattern
  - Section 6: Agent Observability
  - Section 7: Reference Architecture

**Example Repositories**
- dgutride/weekly-update-agent: https://github.com/dgutride/weekly-update-agent
- jeremyeder/dotagents: https://github.com/jeremyeder/dotagents

### Citation Format

When adding citations, use this format:

**Inline**: (Source: [Document/URL])
**Footnote**: [^1] at end of section

Examples:
```markdown
Agents are baked into the platform. (Source: vTeam GitHub README.md)

The MCP Gateway Pattern provides centralized request handling.[^1]

[^1]: IBM Guide to Architecting Secure Enterprise AI Agents, Section 5.2
```

---

## Notes for Resumption

### Current State
- Original content created (with errors)
- User feedback received
- IBM guide analyzed
- Example repos reviewed
- This plan created

### Next Steps
1. Start with Phase 1: Fix presentation materials (highest visibility)
2. Then Phase 2: Rewrite labs (core content)
3. Then Phase 3: Supporting materials
4. Then Phase 4: QA
5. Finally Phase 5: Finalization

### Key Reminders
- **Every** feature claim needs citation
- **No** references to non-existent UI features
- **Focus** on workflow augmentation with existing agents
- **Include** enterprise patterns from IBM guide
- **Verify** everything against actual platform

### Questions to Resolve
1. Should we keep sample agent YAML files at all?
2. What validation checks should the script include?
3. Do we need printed materials or all digital?
4. Timeline for delivery?

---

**End of Plan Document**

This document contains complete context for revising director training materials. All feedback, corrections, and implementation steps are captured here for future resumption.
