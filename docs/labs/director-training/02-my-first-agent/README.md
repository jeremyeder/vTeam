# Lab 1: Workflow Augmentation with AI Agents

## Objective 🎯

Learn to augment your real work using the platform's built-in AI agents. Transform
a manual workflow into an AI-assisted process that you can use beyond this training.

**By the end of this lab, you will:**

- Identify a high-priority workflow to augment
- Document your current manual process
- Use built-in agents to assist with real work
- Understand how to iterate and improve over time

## Prerequisites 📋

- [ ] Pre-work completed (environment validated)
- [ ] Anthropic API key configured
- [ ] Access to Ambient platform (web UI)
- [ ] Presentation session completed

## Estimated Time ⏱️

**60 minutes**

- Part 1: Identify Your Priority Workflow (10 min)
- Part 2: Document Current Process (15 min)
- Part 3: Augment with AI Agents (25 min)
- Part 4: Iterate and Improve (10 min)

## Core Philosophy

> "Augment your A priority. Write down what you do to get something done.
> Highlight the automateable steps. Make agents for them. Next time you do this
> thing, use the agents as your sounding board. Improve the agent as you go.
> Defer more and more to the agent as you improve it."

(Source: Training feedback - workflow augmentation approach)

---

## Part 1: Identify Your Priority Workflow (10 minutes)

### Step 1.1: Choose Your A Priority

What is the **one thing** that would make the biggest impact on your work if it
were faster, easier, or more consistent?

**Examples by Role:**

**Director of Engineering:**

- Architecture decision records (ADRs)
- Weekly status reports to leadership
- Cross-team technical alignment
- Technical debt prioritization

**Director of Product:**

- Feature prioritization frameworks
- Stakeholder communication summaries
- Competitive analysis briefs
- Roadmap alignment reviews

**Director of SRE:**

- Incident postmortem analysis
- Capacity planning reports
- Runbook creation and updates
- Service reliability reviews

### Step 1.2: Complete Priority Worksheet

Use this template to identify your workflow:

```markdown
## My Priority Workflow

**Workflow Name**: _______________________________________________

**How Often**: (Daily / Weekly / Monthly / Quarterly)

**Current Time Investment**: _______ hours per occurrence

**Pain Points**:

1. _________________________________________________________
2. _________________________________________________________
3. _________________________________________________________

**Ideal Outcome**:
_________________________________________________________________
_________________________________________________________________

**Success Metrics**:

- Time saved: ____________________
- Quality improvement: ____________________
- Consistency: ____________________
```

**✅ Checkpoint**: You have identified one specific workflow to augment

---

## Part 2: Document Current Process (15 minutes)

### Step 2.1: Map Your Workflow Steps

Break down EXACTLY what you do now, step by step.

**Template:**

```markdown
## Current Workflow: [Name]

### Step 1: [First Action]

**What I do**: _____________________________________________________
**Tools used**: ____________________________________________________
**Time**: _______ minutes
**Automateable?**: Yes / No / Partially

### Step 2: [Second Action]

**What I do**: _____________________________________________________
**Tools used**: ____________________________________________________
**Time**: _______ minutes
**Automateable?**: Yes / No / Partially

### Step 3: [Continue...]

[Repeat for each step]

---

**Total Steps**: _______
**Total Time**: _______ minutes/hours
**Automateable Steps**: _______ out of _______
```

### Step 2.2: Example - Weekly Status Report

Here's a real example to guide you:

```markdown
## Current Workflow: Weekly Executive Status Report

### Step 1: Gather Updates from Teams

**What I do**: Review Jira, Slack channels, team standups, email threads
**Tools used**: Jira, Slack, Gmail, meeting notes
**Time**: 45 minutes
**Automateable?**: Partially (data gathering)

### Step 2: Identify Key Themes

**What I do**: Read through 20-30 updates, identify patterns and priorities
**Tools used**: Notepad, mental synthesis
**Time**: 30 minutes
**Automateable?**: Yes (pattern recognition)

### Step 3: Assess Progress vs Goals

**What I do**: Compare updates against quarterly OKRs
**Tools used**: OKR spreadsheet, mental comparison
**Time**: 20 minutes
**Automateable?**: Yes (comparison and analysis)

### Step 4: Draft Status Report

**What I do**: Write 3-4 paragraph summary with bullets
**Tools used**: Google Docs
**Time**: 40 minutes
**Automateable?**: Yes (writing with guidance)

### Step 5: Review and Refine

**What I do**: Read through, adjust tone, add context
**Tools used**: Mental review
**Time**: 15 minutes
**Automateable?**: Partially (structure yes, tone judgment no)

---

**Total Steps**: 5
**Total Time**: 2.5 hours
**Automateable Steps**: 3.5 out of 5
```

**✅ Checkpoint**: Your current workflow is documented with time estimates

---

## Part 3: Augment with AI Agents (25 minutes)

### Step 3.1: Understand Built-In Agents

The platform includes specialized agents you can use immediately:

(Source: vTeam GitHub - rhoai-ux-agents-vTeam.md)

**Agent Roster:**

1. **Parker (Product Manager)** - Business value, prioritization, stakeholder
   communication
2. **Archie (Architect)** - Technical design, architecture decisions, system
   patterns
3. **Stella (Staff Engineer)** - Implementation complexity, quality assessment,
   technical review
4. **Olivia (Product Owner)** - Acceptance criteria, user stories, backlog
   refinement
5. **Lee (Team Lead)** - Team coordination, sprint planning, execution planning
6. **Taylor (Team Member)** - Pragmatic implementation, hands-on perspective
7. **Derek (Delivery Owner)** - Sprint tickets, timelines, delivery coordination

**Plus specialized agents:**

- **Emma (Engineering Manager)** - Team wellbeing, capacity planning, delivery
  coordination
- **Ryan (UX Researcher)** - User insights, data analysis, research planning
- **Phoenix (PXE Specialist)** - Customer impact, lifecycle management, field
  experience
- **Terry (Technical Writer)** - Documentation, procedures, technical
  communication

View complete agent details:
<https://github.com/ambient-code/vTeam/blob/main/rhoai-ux-agents-vTeam.md>

### Step 3.2: Select Relevant Agents

Based on your workflow, which agents would be helpful?

**Matching Guide:**

| Workflow Type | Recommended Agents |
|---------------|-------------------|
| Status reports / Updates | Parker, Lee, Emma |
| Technical decisions | Archie, Stella |
| Feature prioritization | Parker, Olivia, Archie |
| Documentation | Terry, Stella, Felix |
| Incident analysis | Phoenix, Stella, Archie |
| Capacity planning | Emma, Lee, Jack |

**Your Selection:**

```markdown
**Agents I'll use**:

1. ________________ - Because: _________________________________
2. ________________ - Because: _________________________________
3. ________________ - Because: _________________________________
```

### Step 3.3: Create Agentic Session

Now use the Ambient platform to augment your workflow.

**Steps:**

1. **Navigate to Ambient Web UI**

   (Source: vTeam README.md - Quick Start section)

   ```bash
   # Get your platform URL
   oc get route frontend-route -n ambient-code
   ```

2. **Create New Session**

   - Click "Projects" → Select your project → "New Session"
   - Session Name: `[Your Workflow Name] - AI Assisted`

3. **Describe Your Workflow Task**

   In the prompt field, provide:

   ```text
   I need help with [WORKFLOW NAME].

   **Context**:
   [Paste relevant context - data, goals, constraints]

   **What I normally do**:
   [Paste steps 1-3 from Part 2.1]

   **What I need**:
   [Describe the output you want - report format, decision framework, etc.]

   **Agents**: Please involve [list your selected agents]
   ```

4. **Configure Settings**

   - Model: Claude Sonnet (recommended for balanced performance)
   - Timeout: 300 seconds (default)
   - Click "Create Session"

5. **Observe Multi-Agent Processing**

   Watch as agents activate sequentially:
   - Each agent provides their specialized perspective
   - Agents reference and build on each other's analysis
   - Real-time streaming shows reasoning

**Example Prompt - Weekly Status Report:**

```text
I need help with my weekly executive status report.

**Context**:
- 3 engineering teams (Platform, AI, Data)
- Quarterly goals: Ship AI-assisted dev tools, improve platform reliability
- This week's focus: Dark mode feature, API gateway upgrade, incident reduction

**Team Updates** (from Jira/Slack):
- Platform team: API gateway upgrade 60% complete, testing phase
- AI team: Dark mode RFE completed, ready for sprint planning
- Data team: Pipeline optimization reduced incident count by 40%

**What I normally do**:
1. Read through all updates (45 min)
2. Identify key themes (30 min)
3. Assess progress vs quarterly goals (20 min)
4. Draft 3-4 paragraph summary with bullets (40 min)
5. Review and refine (15 min)

**What I need**:
- Executive summary (3-4 paragraphs)
- Progress against quarterly goals
- Key risks or blockers identified
- Recommended focus for next week
- Format: Professional, concise, data-driven

**Agents**: Please involve Parker (for business context), Emma (for team
health), and Lee (for execution status)
```

### Step 3.4: Review Agent Outputs

When the session completes, examine each agent's contribution:

**Parker's Output** (Product Manager):

- Business value assessment
- Alignment with strategic goals
- Stakeholder communication recommendations

**Emma's Output** (Engineering Manager):

- Team health indicators
- Capacity concerns
- Resource allocation suggestions

**Lee's Output** (Team Lead):

- Execution status summary
- Risk identification
- Next sprint recommendations

### Step 3.5: Use the Results

The agents have provided multi-perspective analysis. Now:

1. **Copy useful sections** directly into your deliverable
2. **Refine for context** - add your judgment and tone
3. **Validate facts** - agents work from the data you provided
4. **Note what worked** for next time

**Time Savings Calculation:**

```markdown
**Original Time**: _______ hours
**AI-Assisted Time**: _______ hours
**Savings**: _______ hours (____%)

**Quality Improvement**:
- More comprehensive? Yes / No
- Better structured? Yes / No
- Included perspectives I missed? Yes / No
```

**✅ Checkpoint**: You've completed one workflow instance with AI assistance

---

## Part 4: Iterate and Improve (10 minutes)

### Step 4.1: Reflection Worksheet

Document your experience:

```markdown
## Workflow Augmentation - Iteration 1

**Date**: ______________
**Workflow**: ______________

### What Worked Well

1. _____________________________________________________________
2. _____________________________________________________________
3. _____________________________________________________________

### What Didn't Work

1. _____________________________________________________________
2. _____________________________________________________________

### Surprises (Good or Bad)

1. _____________________________________________________________
2. _____________________________________________________________

### Adjustments for Next Time

**Agent Selection**:
- Keep: ___________________________________________________________
- Remove: _________________________________________________________
- Add: ____________________________________________________________

**Prompt Improvements**:
- More context needed on: _________________________________________
- Less detail needed on: __________________________________________
- Different format: _______________________________________________

**Process Changes**:
- Do earlier: _____________________________________________________
- Skip entirely: __________________________________________________
- Automate differently: ___________________________________________
```

### Step 4.2: Plan Your Next Iteration

The power of workflow augmentation comes from **repeated use and refinement**.

**Commitment:**

```markdown
**Next Time I Do This Workflow**:
- Date: ______________
- I will use agents: _______________________________________________
- I will improve the prompt by: ___________________________________
- Success will look like: _________________________________________

**One Month From Now**:
- I expect to have run this _______ times
- I expect to have refined my approach _______ times
- My target time savings: _______% per instance
```

### Step 4.3: Identify Next Workflow

You've augmented ONE workflow. What's next on your priority list?

**Future Workflows to Augment:**

```markdown
1. ____________________________________ (Next month)
2. ____________________________________ (Quarter 2)
3. ____________________________________ (Quarter 3)
```

**✅ Checkpoint**: You have a plan to continue workflow augmentation beyond
this training

---

## Key Learnings 📚

After completing this lab, you should understand:

1. **Workflow Augmentation Philosophy**: Start with real work, use existing
   agents, iterate
2. **Agent Capabilities**: What each built-in agent specializes in
3. **Practical Application**: How to use the platform for YOUR actual work
4. **Iteration Mindset**: First time is learning, improvement comes with
   repetition
5. **Realistic Expectations**: Agents assist and augment, you still apply
   judgment

---

## Important Notes ⚠️

### About Custom Agents

**Current Reality:**

- Agents are **built into the platform** (Source: vTeam GitHub)
- **No UI for creating custom agents** currently
- Agent behavior improvements require code changes
- UI support for custom agents is on the roadmap

**What This Means:**

- Focus on using existing agents effectively
- Customize your **prompts** to get relevant output
- Select agent combinations that match your needs
- Provide context to get better results

### About Agent Accuracy

**Agents work from the data you provide:**

- Garbage in = garbage out
- More context = better analysis
- Validate factual claims
- Apply your domain expertise and judgment

**Agents are assistants, not replacements** for your expertise.

---

## Troubleshooting 🛠️

### Issue: Agents Didn't Address My Workflow

**Symptoms**:

- Generic output
- Missing key aspects
- Wrong focus

**Solutions**:

1. **Add more context** - agents need specifics
2. **Be explicit** - state exactly what you want
3. **Try different agents** - maybe you need different specializations
4. **Refine and rerun** - iteration is expected

### Issue: Session Timed Out

**Symptoms**:

- Session stopped before completion
- Incomplete agent outputs

**Solutions**:

1. **Increase timeout** - Settings → Timeout → 600 seconds
2. **Simplify prompt** - break complex workflows into parts
3. **Select fewer agents** - 2-3 agents is often sufficient

### Issue: Output Too Generic

**Symptoms**:

- Could apply to anyone
- Lacks domain-specific insight

**Solutions**:

1. **Add domain context** - industry, technology stack, constraints
2. **Provide examples** - show what good looks like
3. **Include your standards** - coding guidelines, writing style, etc.

---

## Next Steps 🔍

**Immediate:**

- Use your augmented workflow for real work this week
- Document results and iterate
- Share with team members

**Advanced:**

- Combine multiple agents for complex workflows
- Build prompt templates for repeated tasks
- Track time savings and quality improvements

**Ready for Lab 2?**

Continue to [Lab 2: Enterprise Deployment](../03-agent-deployment/README.md)
where you'll learn security, monitoring, and production deployment patterns.

---

## Success Criteria ✅

You've successfully completed Lab 1 when:

- [ ] Identified one priority workflow to augment
- [ ] Documented current manual process
- [ ] Created agentic session using built-in agents
- [ ] Reviewed and used agent outputs for real work
- [ ] Completed reflection and iteration plan
- [ ] Understand realistic capabilities and limitations

**Congratulations!** You've learned workflow augmentation. Now let's deploy it
with enterprise patterns in Lab 2!

---

## Additional Resources

**Platform Documentation:**

- vTeam GitHub: <https://github.com/ambient-code/vTeam>
- Agent Framework: <https://github.com/ambient-code/vTeam/blob/main/rhoai-ux-agents-vTeam.md>
- Deployment Guide: docs/OPENSHIFT_DEPLOY.md

**Workflow Augmentation Examples:**

- Weekly reporting: <https://github.com/dgutride/weekly-update-agent>
- Decision support: <https://github.com/jeremyeder/dotagents>

**Enterprise AI Patterns:**

- IBM MCP Guide: See instructor for PDF
- Security SOLUTION Framework (covered in Lab 2)
- Agent observability patterns (covered in Lab 2)
