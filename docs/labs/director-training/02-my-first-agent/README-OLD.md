# Lab 1: My First Agent - Building Your Digital Twin

## Objective 🎯

Create a personalized AI agent that embodies your expertise, domain knowledge, and decision-making style - a "digital twin" that can assist with tasks in your area of expertise.

**By the end of this lab, you will:**
- Understand agent persona structure and configuration
- Create a custom agent based on your professional expertise
- Test your agent with realistic scenarios
- Have a working agent you can use beyond this training

## Prerequisites 📋

- [ ] Pre-work completed (environment validated)
- [ ] Anthropic API key ready
- [ ] Access to Ambient platform (web UI)
- [ ] Presentation session completed

## Estimated Time ⏱️

**60 minutes**
- Part 1: Understanding Agents (15 min)
- Part 2: Designing Your Agent (20 min)
- Part 3: Implementing Your Agent (15 min)
- Part 4: Testing & Validation (10 min)

## Lab Scenario

You're going to create an AI agent that thinks like you do in your professional domain. This agent will:
- Understand your area of expertise
- Apply your decision-making framework
- Use terminology and concepts from your field
- Provide analysis from your perspective

**Example Use Cases:**
- **Director of Engineering**: Agent that reviews architecture proposals with your team's standards
- **Product Director**: Agent that evaluates feature requests using your prioritization criteria
- **Director of SRE**: Agent that assesses operational risks with your reliability principles

---

## Part 1: Understanding Agents (15 minutes)

### Step 1.1: Review Existing Agent Examples

The Ambient platform includes several pre-built agents. Let's examine one to understand the structure.

**Access the Agent Library:**

1. Open the Ambient web UI
2. Navigate to **Settings → Agent Templates**
3. Select **"Parker (Product Manager)"** to view

**Agent Structure Overview:**

Every agent has four key components:

```yaml
name: Parker
role: Product Manager
seniority: Director-level
expertise:
  - Business strategy and roadmap planning
  - Stakeholder communication and alignment
  - Feature prioritization frameworks
  - User value assessment and ROI analysis

persona:
  communication_style: Strategic and business-focused
  decision_framework: Data-driven with user impact focus
  key_questions:
    - "What problem does this solve for users?"
    - "How does this align with business goals?"
    - "What's the ROI and opportunity cost?"

knowledge_domains:
  - Agile product management
  - OKR frameworks
  - Market analysis
  - Competitive intelligence

constraints:
  - Defers to architects on technical feasibility
  - Consults engineers for implementation estimates
  - Focuses on "what" and "why", not "how"
```

**Key Insights:**

✅ **Specificity Matters**: "Business strategy" is vague; "OKR frameworks for prioritization" is specific

✅ **Realistic Constraints**: Good agents know what they don't know and defer appropriately

✅ **Authentic Voice**: Communication style should match how you actually think/speak

**✅ Checkpoint**: Can you identify Parker's main expertise, decision framework, and constraints?

---

### Step 1.2: Explore Agent Interaction Patterns

Let's see how agents work together in practice.

**View a Completed Session:**

1. Navigate to **Projects → Examples → "Dark Mode Feature RFE"**
2. Click on the completed agentic session
3. Review the agent outputs

**Observe:**

**Parker's Output** (Product Manager):
```markdown
Business Value Assessment: 8/10

Rationale:
- High user demand (accessibility and user preference)
- Low implementation risk
- Competitive parity feature
- Estimated 60-70% user adoption within 3 months

Recommendation: PRIORITIZE
This aligns with our Q4 UX improvement goals and has strong user value.
```

**Archie's Output** (Architect):
```markdown
Technical Feasibility: HIGH

Architecture Considerations:
- Requires CSS variable system for theme switching
- localStorage for persistence (< 1KB storage)
- React Context for state management
- Minimal performance impact

Integration Points:
- Existing component library (must support both themes)
- User preferences service (API extension needed)

Risks: LOW
Primary risk is comprehensive testing across all components in both themes.
```

**Notice the Differences:**
- Parker focuses on **business value and user impact**
- Archie focuses on **technical approach and architecture**
- Each agent stays in their lane while providing complete analysis from their perspective

**✅ Checkpoint**: Can you see how different perspectives create comprehensive analysis?

---

### Step 1.3: Agent Design Principles

Before creating your agent, understand what makes an effective agent:

#### 1. **Domain Expertise Depth**

❌ **Weak**: "I know about software development"
✅ **Strong**: "Expert in microservices architecture, Kubernetes deployments, and OpenShift platform engineering"

#### 2. **Clear Decision Framework**

❌ **Weak**: "I prioritize important things"
✅ **Strong**: "I use RICE scoring (Reach, Impact, Confidence, Effort) weighted 40% user impact, 30% business value, 30% effort"

#### 3. **Realistic Boundaries**

❌ **Weak**: "I can help with anything technical"
✅ **Strong**: "I focus on platform architecture; I defer to security team for compliance review and to data team for ML pipeline design"

#### 4. **Authentic Voice**

❌ **Weak**: "I analyze requirements professionally"
✅ **Strong**: "I ask direct questions, push back on unclear scope, and insist on measurable success criteria before proceeding"

**✅ Checkpoint**: Understand the principles? Ready to design your agent!

---

## Part 2: Designing Your Agent (20 minutes)

### Step 2.1: Define Your Expertise Domain

Complete this worksheet to map your professional expertise:

**My Expertise Worksheet:**

```markdown
1. PRIMARY ROLE & FUNCTION
   What is your core responsibility?
   Example: "Director of Platform Engineering - responsible for Kubernetes
   infrastructure supporting 200+ microservices"

   YOUR ANSWER:
   _______________________________________________________________


2. TOP 3 EXPERTISE AREAS
   What are you considered an expert in?
   Example:
   - Kubernetes and OpenShift architecture
   - Platform reliability and SRE practices
   - Multi-tenant infrastructure design

   YOUR ANSWERS:
   a) ____________________________________________________________
   b) ____________________________________________________________
   c) ____________________________________________________________


3. DECISION FRAMEWORKS YOU USE
   How do you make decisions in your domain?
   Example: "For platform changes, I assess: blast radius, rollback plan,
   observability coverage, and impact on tenant SLAs"

   YOUR ANSWER:
   _______________________________________________________________
   _______________________________________________________________


4. KEY QUESTIONS YOU ALWAYS ASK
   What questions do you consistently ask when reviewing work?
   Example:
   - "How do we roll this back if it fails?"
   - "What's the impact on tenant workloads?"
   - "Do we have monitoring for this?"

   YOUR ANSWERS:
   a) ____________________________________________________________
   b) ____________________________________________________________
   c) ____________________________________________________________


5. KNOWLEDGE BOUNDARIES
   What do you NOT handle (and who does)?
   Example: "I don't handle: application-level security (defers to SecOps),
   data compliance (defers to Legal), budget/pricing (defers to Finance)"

   YOUR ANSWER:
   _______________________________________________________________
   _______________________________________________________________
```

**Time**: 10 minutes to complete this worksheet

**✅ Checkpoint**: Worksheet complete? You now have the foundation for your agent.

---

### Step 2.2: Define Your Agent's Persona

Now translate your worksheet into agent configuration format.

**Agent Persona Template:**

Copy this template and fill in based on your worksheet:

```yaml
name: [YOUR NAME or ROLE NAME]
role: [YOUR TITLE]
seniority: [Director-level / Senior / Staff]

expertise:
  # From worksheet question 2
  - [Expertise area 1]
  - [Expertise area 2]
  - [Expertise area 3]

persona:
  communication_style: |
    [Describe how you communicate - direct? consultative? data-driven?]

  decision_framework: |
    [From worksheet question 3 - your decision-making approach]

  key_questions:
    # From worksheet question 4
    - "[Question 1]"
    - "[Question 2]"
    - "[Question 3]"

knowledge_domains:
  # Specific technologies, frameworks, methodologies you know
  - [Domain 1]
  - [Domain 2]
  - [Domain 3]

constraints:
  # From worksheet question 5 - what you don't handle
  - Defers to [ROLE] for [TOPIC]
  - Consults [ROLE] when [SITUATION]
  - Focuses on [SCOPE], not [OUT OF SCOPE]

output_format:
  # How you like to present analysis
  style: [Structured | Narrative | Bullet points | etc.]
  includes:
    - [Element 1: e.g., Risk assessment]
    - [Element 2: e.g., Recommendations]
    - [Element 3: e.g., Next steps]
```

**Example - Completed Director of SRE Agent:**

```yaml
name: Alex Rivera
role: Director of Site Reliability Engineering
seniority: Director-level

expertise:
  - Production system reliability and incident response
  - SLA/SLI design and monitoring strategy
  - Kubernetes platform operations at scale
  - Chaos engineering and resilience testing

persona:
  communication_style: |
    Direct and operationally-focused. I speak in terms of SLOs, blast radius,
    and recovery time. I'm skeptical of "it should work" and insist on
    observability and tested failure modes.

  decision_framework: |
    For any platform change, I evaluate:
    1. Blast radius (what breaks if this fails?)
    2. Observability (can we detect and diagnose issues?)
    3. Rollback strategy (how do we undo this safely?)
    4. SLA impact (does this affect customer-facing SLOs?)
    Weighted: 40% risk mitigation, 30% observability, 30% recovery capability

  key_questions:
    - "What's the blast radius if this goes wrong?"
    - "How will we know if this is working or failing?"
    - "What's the rollback plan?"
    - "Have we tested this under failure conditions?"

knowledge_domains:
  - OpenShift and Kubernetes platform engineering
  - Prometheus/Grafana monitoring stacks
  - Incident command and response protocols
  - Terraform and GitOps deployment patterns
  - Google SRE principles and error budgets

constraints:
  - Defers to Security team for compliance and vulnerability assessment
  - Consults Architects for cross-platform integration design
  - Focuses on operational excellence, not application business logic
  - Escalates cost optimization beyond infra to FinOps team

output_format:
  style: Structured with clear risk assessment
  includes:
    - Operational risk rating (High/Medium/Low)
    - Observability requirements
    - Rollback and recovery procedures
    - Runbook recommendations
    - SLA impact analysis
```

**Time**: 10 minutes to complete your agent YAML

**✅ Checkpoint**: Agent persona defined in YAML format?

---

## Part 3: Implementing Your Agent (15 minutes)

### Step 3.1: Create Agent in Ambient Platform

Now let's implement your agent in the Ambient platform.

**Steps:**

1. **Navigate to Agent Creation**:
   - Open Ambient web UI
   - Go to **Settings → Agent Templates**
   - Click **"Create Custom Agent"**

2. **Enter Basic Information**:
   ```
   Agent Name: [Your name/role from YAML]
   Display Name: [How it appears in UI]
   Description: [One-sentence summary of agent's purpose]
   ```

3. **Configure Agent Persona**:
   - Paste your completed YAML into the **"Agent Configuration"** field
   - The platform will validate the structure

4. **Set Agent Scope** (optional):
   ```
   Available to:
   ☑ Just me (private agent)
   ☐ My team
   ☐ Organization-wide
   ```

5. **Add System Prompt** (advanced):

   The system prompt provides additional context. Use this template:

   ```markdown
   You are {name}, a {role} with {seniority} experience.

   Your expertise includes:
   {list expertise areas}

   When analyzing requests, you:
   - Apply your decision framework: {decision framework}
   - Ask critical questions: {key questions}
   - Stay within your domain: {knowledge domains}
   - Defer when appropriate: {constraints}

   Your output should be {output format style} and include:
   {output format includes}

   Maintain your authentic voice: {communication style}
   ```

6. **Save Agent**:
   - Click **"Validate Configuration"**
   - Review any warnings or errors
   - Click **"Create Agent"**

**✅ Checkpoint**: Agent created successfully in the platform?

---

### Step 3.2: Configure Agent Behavior

Fine-tune how your agent behaves in multi-agent workflows.

**Agent Behavior Settings:**

1. **Collaboration Mode**:
   ```
   ○ Autonomous (makes decisions independently)
   ● Collaborative (participates in multi-agent review)
   ○ Advisory (provides input but doesn't vote)
   ```

   **Select**: Collaborative (for most use cases)

2. **Defer Triggers**:

   Configure when your agent should defer to others:

   ```yaml
   defer_when:
     - topic: "Security compliance and vulnerability assessment"
       to: "Security Architect role"

     - topic: "Budget and cost beyond infrastructure"
       to: "Finance or FinOps role"

     - topic: "Application-level business logic"
       to: "Product Manager or Architect role"
   ```

3. **Quality Gates**:

   Define what constitutes "insufficient information" for your agent:

   ```yaml
   requires_clarification_when:
     - missing: "Blast radius or failure impact assessment"
     - missing: "Rollback or recovery plan"
     - missing: "Observability and monitoring approach"
   ```

**✅ Checkpoint**: Agent behavior configured?

---

## Part 4: Testing & Validation (10 minutes)

### Step 4.1: Create Test Scenario

Let's test your agent with a realistic scenario from your domain.

**Test Scenario Template:**

Choose a scenario that matches your expertise:

**Option A - Feature Review**:
```markdown
Feature Request: [Describe a typical feature in your domain]

Example (for SRE Director):
"We want to implement auto-scaling for our Kubernetes workloads based on
custom metrics from our application. This should handle traffic spikes
during peak hours without manual intervention."

Expected Agent Analysis:
- [What should your agent focus on?]
- [What questions should it ask?]
- [What risks should it identify?]
```

**Option B - Problem Analysis**:
```markdown
Problem Statement: [Describe a typical problem you analyze]

Example (for Product Director):
"User engagement dropped 15% in the last quarter for our mobile app. We need
to identify root causes and propose features to improve retention."

Expected Agent Analysis:
- [What framework should it apply?]
- [What data should it request?]
- [What solutions should it suggest?]
```

**Your Test Scenario**:
```markdown
Scenario Type: [Feature Review / Problem Analysis / Other]

Description:
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________

Expected Agent Behavior:
1. ___________________________________________________________
2. ___________________________________________________________
3. ___________________________________________________________
```

**✅ Checkpoint**: Test scenario defined?

---

### Step 4.2: Run Agentic Session with Your Agent

Execute a test session using your custom agent.

**Steps:**

1. **Create New Session**:
   - Navigate to **Projects → [Your Project]**
   - Click **"New Agentic Session"**

2. **Configure Session**:
   ```
   Session Name: "Test - [Agent Name]"

   Task Description:
   [Paste your test scenario]

   Agent Selection:
   ☑ [Your Custom Agent]
   ☐ Parker (PM)
   ☐ Archie (Architect)
   ☐ Stella (Staff Engineer)

   Note: Start with ONLY your agent for focused testing
   ```

3. **Run Session**:
   - Click **"Start Session"**
   - Watch your agent analyze the scenario
   - Expected duration: 1-2 minutes

4. **Review Agent Output**:

   Evaluate against these criteria:

   **Quality Checklist:**
   - [ ] Agent applied YOUR decision framework correctly
   - [ ] Agent asked YOUR key questions
   - [ ] Agent identified relevant concerns from YOUR domain
   - [ ] Agent stayed within defined expertise boundaries
   - [ ] Agent output matches YOUR communication style
   - [ ] Agent deferred appropriately when outside scope

**✅ Checkpoint**: First test session completed?

---

### Step 4.3: Refine Your Agent

Based on test results, refine your agent configuration.

**Common Adjustments:**

**Issue 1: Agent Too Generic**
```yaml
# BEFORE (weak)
expertise:
  - Software development
  - Technical leadership

# AFTER (strong)
expertise:
  - Kubernetes operator development and CRD design
  - Go-based microservices architecture
  - OpenShift platform engineering and multi-tenancy
```

**Issue 2: Agent Makes Decisions Outside Scope**
```yaml
# ADD constraints to prevent scope creep
constraints:
  - Does NOT make business prioritization decisions (defers to PM)
  - Does NOT estimate costs beyond infrastructure (defers to Finance)
  - Focuses on technical feasibility and operational excellence only
```

**Issue 3: Agent Output Lacks Structure**
```yaml
# ADD explicit output format
output_format:
  style: Structured with clear sections
  required_sections:
    - Risk Assessment (High/Medium/Low with justification)
    - Technical Approach (architectural overview)
    - Operational Considerations (monitoring, rollback, etc.)
    - Recommendations (prioritized list)
  tone: Direct and actionable, not overly cautious
```

**Refinement Process:**

1. Identify what needs improvement (use checklist above)
2. Navigate to **Settings → Agent Templates → [Your Agent] → Edit**
3. Make targeted changes to YAML configuration
4. **Save and retest** with same scenario
5. Repeat until agent output matches your expectations

**✅ Checkpoint**: Agent refined and performs well on test scenario?

---

### Step 4.4: Multi-Agent Collaboration Test

Now test your agent working WITH other agents.

**Steps:**

1. **Create Multi-Agent Session**:
   ```
   Session Name: "Multi-Agent Test - [Feature/Problem]"

   Task Description:
   [Same test scenario as before]

   Agent Selection:
   ☑ [Your Custom Agent]
   ☑ Parker (Product Manager)
   ☑ Archie (Architect)
   ```

2. **Run and Observe**:
   - Watch how agents interact
   - See if your agent complements others (no redundancy)
   - Check if your agent defers appropriately

3. **Evaluate Collaboration Quality**:

   **Good Signs:**
   - ✅ Each agent covers different aspects (no overlap)
   - ✅ Your agent references others' analysis when relevant
   - ✅ Your agent adds unique value beyond generic analysis

   **Red Flags:**
   - ❌ Your agent repeats what Parker/Archie already said
   - ❌ Your agent tries to cover all perspectives (scope creep)
   - ❌ Your agent's output is too similar to existing agents

**✅ Checkpoint**: Multi-agent collaboration successful?

---

## Validation & Testing

### Comprehensive Agent Quality Check

Run through this final validation:

**Domain Expertise** ✅
- [ ] Agent demonstrates deep knowledge in specified domain
- [ ] Agent uses domain-specific terminology correctly
- [ ] Agent applies recognized frameworks from your field
- [ ] Agent references relevant best practices and standards

**Authentic Voice** ✅
- [ ] Agent's communication style matches your style
- [ ] Agent asks the questions YOU would ask
- [ ] Agent identifies concerns YOU would raise
- [ ] Agent's priorities align with your priorities

**Appropriate Boundaries** ✅
- [ ] Agent stays within defined expertise scope
- [ ] Agent defers to other roles when appropriate
- [ ] Agent acknowledges limitations clearly
- [ ] Agent doesn't overreach into others' domains

**Practical Value** ✅
- [ ] Agent output is actionable and specific
- [ ] Agent analysis would actually be helpful in real work
- [ ] Agent provides insights beyond generic AI responses
- [ ] You would genuinely use this agent in your job

**Collaboration Effectiveness** ✅
- [ ] Agent complements other agents (no redundancy)
- [ ] Agent adds unique perspective to multi-agent analysis
- [ ] Agent references and builds on others' inputs
- [ ] Agent participates constructively in council workflow

---

## Troubleshooting 🛠️

### Issue: Agent Is Too Generic

**Symptoms**:
- Output could apply to any role
- Analysis lacks domain-specific depth
- Indistinguishable from default AI response

**Solutions**:
1. **Add Specific Frameworks**:
   ```yaml
   decision_framework: |
     I use the RICE framework (Reach × Impact × Confidence / Effort)
     weighted 40% user impact, 30% business value, 30% effort
   ```

2. **Include Domain Terminology**:
   ```yaml
   knowledge_domains:
     - Kubernetes HPA and VPA autoscaling
     - Prometheus federation and aggregation
     - Red Hat OpenShift platform engineering
   ```

3. **Add Concrete Examples**:
   ```yaml
   key_questions:
     - "What's the p95 latency impact during peak traffic?"
     - "How does this affect our 99.9% uptime SLA?"
   ```

---

### Issue: Agent Overlaps with Existing Agents

**Symptoms**:
- Agent provides similar analysis to Parker/Archie
- Redundant perspectives in multi-agent sessions
- No unique value-add

**Solutions**:
1. **Narrow Expertise Scope**:
   ```yaml
   expertise:
     # Too broad
     - Software architecture

     # Better - specific niche
     - Event-driven microservices architecture
     - Apache Kafka and stream processing systems
   ```

2. **Add Clear Differentiation**:
   ```yaml
   persona:
     unique_focus: |
       Unlike general architects, I focus specifically on data flow,
       event consistency, and stream processing performance.
   ```

---

### Issue: Agent Output Lacks Structure

**Symptoms**:
- Rambling, unorganized analysis
- Missing key elements you'd include
- Hard to extract actionable insights

**Solutions**:
1. **Define Explicit Output Template**:
   ```yaml
   output_format:
     template: |
       ## Risk Assessment
       [High/Medium/Low with justification]

       ## Technical Approach
       [Recommended architecture/solution]

       ## Operational Checklist
       - [ ] Monitoring setup
       - [ ] Rollback procedure
       - [ ] Runbook updated

       ## Recommendations
       1. [Prioritized actions]
   ```

---

## Key Learnings 📚

After completing this lab, you should understand:

1. **Agent Structure**: How expertise, persona, and constraints define agent behavior
2. **Domain Specificity**: More specific = more valuable and unique
3. **Realistic Boundaries**: Good agents know what they don't know
4. **Collaboration Dynamics**: Agents should complement, not duplicate
5. **Practical Application**: You now have a working agent for real work

---

## Next Steps 🔍

**Immediate:**
- Use your agent for a real work task this week
- Refine based on actual usage patterns
- Share with team members for feedback

**Advanced:**
- Create additional agents for different contexts (e.g., "Architecture Review Me" vs "Quick Triage Me")
- Build team-specific agents with shared knowledge
- Integrate agents into your existing workflows

**Ready for Lab 2?**
Continue to [Lab 2: Dev+Deploy](../03-dev-deploy/README.md) where you'll use your agent to build and deploy an application!

---

## Success Criteria ✅

You've successfully completed Lab 1 when:

- [ ] Created a custom agent with your domain expertise
- [ ] Agent performs well on test scenarios from your field
- [ ] Agent adds unique value in multi-agent collaboration
- [ ] You can articulate your agent's role and boundaries
- [ ] You're ready to use this agent for real work

**Congratulations!** You've created your AI digital twin. Let's put it to work in Lab 2!
