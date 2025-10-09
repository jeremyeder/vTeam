# Facilitator Guide: Director Training - Ambient Agentic Development

**Training Duration**: 3 hours
**Format**: 30-min presentation + 2 hands-on labs (60 min each) + 30-min break
**Target Audience**: Directors and senior technical leaders

---

## Table of Contents

- [Pre-Training Preparation](#pre-training-preparation)
- [Session Timeline](#session-timeline)
- [Presentation Delivery (30 min)](#presentation-delivery-30-min)
- [Lab 1: Workflow Augmentation (60 min)](#lab-1-workflow-augmentation-60-min)
- [Lab 2: Enterprise Deployment (60 min)](#lab-2-enterprise-deployment-60-min)
- [Common Issues & Troubleshooting](#common-issues--troubleshooting)
- [Success Metrics](#success-metrics)
- [Post-Training Follow-Up](#post-training-follow-up)

---

## Pre-Training Preparation

### 24 Hours Before Training

**Participant Readiness**:

- [ ] Confirm all participants completed pre-work (00-prework.md)
- [ ] Send reminder with validation script
- [ ] Verify at least 80% completion rate of pre-work checklist
- [ ] Send final logistics (room location, WiFi credentials, start time)

**Cluster Access**:

- [ ] Validate shared training cluster is accessible
- [ ] Create namespaces for each participant (if using shared cluster)
- [ ] Test deployment from fresh namespace
- [ ] Prepare cluster credentials package
- [ ] Verify `oc whoami` works from your machine

**Materials Preparation**:

- [ ] Load presentation slides and test display
- [ ] Print lab guides (backup if WiFi issues)
- [ ] Prepare example workflows for demos
- [ ] Test all demo scripts end-to-end
- [ ] Have backup Anthropic API key ready

**Room Setup**:

- [ ] Verify projector/screen resolution (1920x1080 minimum)
- [ ] Test audio if presenting hybrid/virtual
- [ ] Arrange seating for pair programming option
- [ ] Set up instructor station with two monitors
- [ ] Print name tents if needed

### 1 Hour Before Training

**Final Checks**:

- [ ] Run through presentation slides (timing check)
- [ ] Start validation script on own machine
- [ ] Verify example agentic session is accessible
- [ ] Test cluster connectivity
- [ ] Have troubleshooting doc open in browser tab
- [ ] Prepare Q&A reference sheet

**Participant Arrival**:

- Welcome each participant personally
- Direct them to run validation script
- Troubleshoot any setup issues immediately
- Encourage early arrivals to help late arrivals

---

## Session Timeline

### Ideal Schedule (3 hours)

| Time | Duration | Activity | Notes |
|------|----------|----------|-------|
| 0:00 | 5 min | Welcome & Introductions | Set expectations, verify setup |
| 0:05 | 25 min | Presentation | Core concepts, demo, value prop |
| 0:30 | 5 min | Break | Setup validation, questions |
| 0:35 | 60 min | Lab 1: Workflow Augmentation | Hands-on with existing agents |
| 1:35 | 10 min | Break | Share learnings, reset for Lab 2 |
| 1:45 | 60 min | Lab 2: Enterprise Deployment | Deploy with security patterns |
| 2:45 | 10 min | Wrap-Up & Next Steps | Collect feedback, share resources |
| 2:55 | 5 min | Q&A & Networking | Optional extended discussion |

### Timing Flexibility

**Running Behind** (common scenarios):

- **5 min behind**: Skip optional demo sections, tighten Q&A
- **10 min behind**: Reduce first break to 3 minutes
- **15 min behind**: Skip Lab 1 deployment step (focus on workflow design)
- **20+ min behind**: Pause and reassess - may need to compress Lab 2

**Running Ahead** (rare but possible):

- **5 min ahead**: Take longer break, answer more questions
- **10 min ahead**: Deep-dive into advanced Lab 2 topics (observability, HA)
- **15+ min ahead**: Introduce Lab 3 concepts (if available) or extended Q&A

---

## Presentation Delivery (30 min)

### Opening (5 min)

**Script**:

> "Good [morning/afternoon]. I'm [NAME], and in the next 3 hours, you'll learn
> to augment your workflows with AI agents and deploy them to production. This
> isn't theoretical - you'll leave with working examples you can use Monday."

**Set Expectations**:

- Hands-on, practical focus
- Questions encouraged throughout
- Pair programming welcome in labs
- No "dumb questions" - if confused, ask

**Verify Setup** (quick poll):

- "Who ran the validation script successfully?"
- "Who has their Anthropic API key ready?"
- "Who has OpenShift access?"

Address any "no" responses immediately or assign help during break.

### Core Content (20 min)

**Key Messages** (in order):

1. **The Problem**: RFE refinement takes hours, results vary by who does it
2. **The Solution**: Multi-agent AI system provides consistent, comprehensive analysis
3. **The Value**: Hours → minutes, with director-level insights
4. **The Reality**: Built-in agents, no UI for custom agents (yet)
5. **The Approach**: Augment workflows, not replace engineers

**Presentation Flow**:

- **Slides 1-4** (5 min): Problem statement and business impact
- **Slides 5-8** (7 min): Architecture and agent framework
- **Slides 9-12** (5 min): Demo and value proposition
- **Slides 13-15** (3 min): Lab preview and logistics

**Demo Tips** (Slide 10):

- Have pre-created agentic session open
- Show 2-3 messages maximum (don't scroll through entire session)
- Highlight agent names in conversation
- Point out multi-perspective analysis
- **Do NOT live-create an agent** (no UI for this - common confusion point)

### Q&A Handling (5 min)

**Common Questions & Responses**:

**Q: "Can we create custom agents?"**
A: "Not via UI today. Agents are built into the platform code. You'll learn to
augment workflows with existing agents in Lab 1. Custom agent UI is on the
roadmap but no committed timeline."

**Q: "What if I don't finish the labs?"**
A: "All materials stay with you. We have checkpoints to catch up. Focus on
understanding concepts; you can finish implementation later."

**Q: "Is this secure for production?"**
A: "Yes. Lab 2 covers IBM's SOLUTION framework for enterprise AI security -
encryption, RBAC, audit logs, network policies. We'll implement all of it."

**Q: "What's the learning curve for my team?"**
A: "For basic workflow augmentation? They'll learn in 30-60 minutes. For
advanced customization? A couple weeks. But you get value from day one."

---

## Lab 1: Workflow Augmentation (60 min)

### Learning Objectives

By the end of Lab 1, participants should:

1. Identify their A priority task suitable for AI augmentation
2. Break down the task into automateable vs. human-judgment steps
3. Create an agentic session that automates 2-3 steps
4. Document their workflow for team replication
5. Understand built-in agent capabilities and limitations

### Facilitator Responsibilities

**During Setup (0-5 min)**:

- Ensure all participants have lab guide open (02-my-first-agent/README.md)
- Verify everyone is logged into OpenShift cluster
- Confirm Anthropic API keys are accessible
- Start timer for 60-minute session

**During Exercise 1 (5-20 min)**: *Identify Your A Priority*

- Circulate and observe participant progress
- **Common issues**:
  - Choosing too complex a task → Guide to simpler starting point
  - Choosing too simple a task → Encourage more ambitious goal
  - Can't think of a task → Suggest: "What took you 3+ hours this week?"

**During Exercise 2 (20-35 min)**: *Map the Workflow*

- Watch for participants struggling with step breakdown
- **Intervention points**:
  - "Which steps require human judgment?" (help identify AI boundaries)
  - "Which steps are repetitive?" (prime automation candidates)
  - "Which steps depend on previous outputs?" (sequencing check)

**During Exercise 3 (35-55 min)**: *Create Agentic Session*

- This is where most participants will struggle initially
- **Key teaching moments**:
  - Show how to provide context in prompts
  - Demonstrate agent selection (when to use Parker vs. Archie vs. Stella)
  - Explain how to validate agent outputs
- **Common mistakes**:
  - Using agent like ChatGPT (no context, vague prompts)
  - Expecting agents to "just know" domain-specific details
  - Not reviewing outputs before using them

**During Documentation (55-60 min)**: *Document the Workflow*

- Emphasize this is for team replication
- Template: "What I do → What agent does → How I validate"

### Checkpoints & Interventions

**15-Minute Checkpoint**:

- Quick poll: "Who has identified their A priority task?"
- Expected: 80%+ should raise hands
- If <60%: Pause and do 5-minute group brainstorm

**30-Minute Checkpoint**:

- Quick poll: "Who has completed their workflow map?"
- Expected: 70%+ should raise hands
- If <50%: Extend Exercise 2 by 5 minutes, compress Exercise 3

**45-Minute Checkpoint**:

- Quick poll: "Who has created an agentic session?"
- Expected: 60%+ should raise hands
- If <40%: Offer to demo session creation on projector

### Troubleshooting Common Issues

**Issue: "I don't know what task to choose"**
**Solution**: Ask: "What's on your calendar for next week that you're not
looking forward to?" Use that as the starting point.

**Issue: "My task requires data I can't share with AI"**
**Solution**: Use synthetic/example data for training. In production, they'll
use real data with appropriate security controls (covered in Lab 2).

**Issue: "The agent gave me wrong information"**
**Solution**: Perfect teaching moment! "That's why we validate. What was wrong?
How could you rephrase the prompt to get better output?"

**Issue: "I want to use [specific agent] but don't see it"**
**Solution**: Check rhoai-ux-agents-vTeam.md for full agent list. May need to
guide them to appropriate agent for their use case.

### Success Indicators

**Minimum Success** (all participants should achieve):

- Identified 1 task suitable for AI augmentation
- Created basic workflow map with 3-5 steps
- Executed at least 1 agentic session with observable output

**Target Success** (80%+ should achieve):

- Identified task that saves 1+ hour per week
- Workflow map with clear automation boundaries
- Agentic session that automates 2-3 steps successfully
- Documented workflow ready for team sharing

**Stretch Success** (top 20% may achieve):

- Multiple workflow variations explored
- Advanced prompt engineering for better results
- Integration points identified for existing tools
- Already planning team rollout

---

## Lab 2: Enterprise Deployment (60 min)

### Lab 2 Learning Objectives

By the end of Lab 2, participants should:

1. Understand IBM SOLUTION security framework for enterprise AI
2. Deploy agentic workflow with production-grade security
3. Implement RBAC, encryption, and audit logging
4. Monitor and observe agentic session execution
5. Know how to scale deployment across their organization

### Lab 2 Facilitator Responsibilities

**During Setup (0-5 min)**:

- Verify all participants have completed Lab 1 (or identified workflow)
- Ensure cluster access is working
- Confirm everyone has lab guide open (03-agent-deployment/README.md)
- Start timer for 60-minute session

**During Exercise 1 (5-15 min)**: *Security Planning*

- Participants review SOLUTION framework
- **Teaching moment**: Connect security principles to their organization's
  requirements
- **Common questions**:
  - "Do we really need all this?" → Yes, for production. Explain why.
  - "Can we skip [X] for internal use?" → Discuss risk vs. convenience

**During Exercise 2 (15-35 min)**: *Deploy with Security*

- Most technically complex part of training
- **Watch for**:
  - Kubernetes Secret creation errors (common typo: namespace name)
  - RBAC permission issues (wrong service account)
  - Pod not starting (check API key validity)
- **Intervention strategy**:
  - First error: Guide them to debug themselves
  - Second error: Offer to pair-debug
  - Third+ error: Consider cluster-level issue

**During Exercise 3 (35-50 min)**: *Observability Setup*

- Easier than Exercise 2, should go smoothly
- **Highlight**: How monitoring helps with production issues
- **Show**: Where to find logs, how to interpret them

**During Exercise 4 (50-60 min)**: *Scale Planning*

- Mostly discussion and documentation
- **Facilitate**: How would this work for their team/org?
- **Address**: Common organizational barriers

### Lab 2 Checkpoints & Interventions

**15-Minute Checkpoint**:

- Quick poll: "Who has completed security planning?"
- Expected: 90%+ should raise hands (this is mostly reading)
- If <70%: Assign reading for homework, move to deployment

**30-Minute Checkpoint**:

- Quick poll: "Who has agent deployed successfully?"
- Expected: 50%+ should raise hands
- If <30%: **PAUSE** - likely a cluster or lab guide issue

**45-Minute Checkpoint**:

- Quick poll: "Who has observability working?"
- Expected: 60%+ should raise hands
- If <40%: Compress Exercise 4, focus on deployment success

### Lab 2 Troubleshooting

**Issue: "oc create secret generic fails"**
**Solution**: Check namespace exists, verify base64 encoding of API key, ensure
no trailing whitespace in secret value.

**Issue: "Pod is in ImagePullBackOff"**
**Solution**: Check image name spelling, verify image registry is accessible,
confirm imagePullSecrets are configured.

**Issue: "Agent session starts but times out"**
**Solution**: Check API key validity, verify network policies allow egress to
api.anthropic.com, review pod logs for error messages.

**Issue: "I don't have permissions to create RBAC resources"**
**Solution**: Pre-created roles should be available. If not, instructor needs
cluster-admin access to create them.

**Issue: "How do I know if it's working?"**
**Solution**: Guide them through: `oc get pods`, `oc logs <pod-name>`, check
for successful session creation in logs.

### Lab 2 Success Indicators

**Minimum Success** (all participants should achieve):

- Understand SOLUTION framework principles
- Successfully deploy agent to OpenShift (even if with help)
- Retrieve logs from deployed agent
- Know where to find documentation for production deployment

**Target Success** (80%+ should achieve):

- Deploy agent with all SOLUTION components implemented
- Configure RBAC and verify least-privilege access
- Set up observability and interpret logs
- Document deployment process for their team

**Stretch Success** (top 20% may achieve):

- Customize deployment for their specific environment
- Identify and implement additional security controls
- Plan multi-environment deployment strategy (dev/staging/prod)
- Already scheduling pilot with their team

---

## Common Issues & Troubleshooting

### Technical Issues

#### Cluster Access Problems

**Symptoms**: Can't run `oc` commands, authentication errors
**Diagnosis**:

```bash
oc whoami  # Should return username
oc cluster-info  # Should return cluster URL
```

**Solutions**:

1. Re-run `oc login <cluster-url>` with credentials
2. Check VPN/network connectivity if using remote cluster
3. Verify token hasn't expired (tokens last 24 hours typically)
4. Fall back to shared training cluster if local OpenShift Local fails

#### Anthropic API Issues

**Symptoms**: "Authentication error", "Rate limit exceeded", "Insufficient credits"
**Diagnosis**:

```bash
curl -H "x-api-key: $ANTHROPIC_API_KEY" \
     -H "anthropic-version: 2023-06-01" \
     https://api.anthropic.com/v1/messages
```

**Solutions**:

1. Verify API key was copied correctly (no spaces, full key)
2. Check account credits at console.anthropic.com
3. Confirm key hasn't been deleted/rotated
4. Use instructor backup key as last resort

#### Python/Environment Issues

**Symptoms**: "Module not found", "Permission denied", version conflicts
**Diagnosis**:

```bash
python --version  # Should be 3.11+
which python      # Should be in venv or user space
pip list          # Check for required packages
```

**Solutions**:

1. Create fresh virtual environment: `python -m venv venv && source venv/bin/activate`
2. Install requirements: `pip install -r requirements.txt`
3. If system Python issues: Use Docker/Podman container instead
4. Check CLAUDE.md for project-specific setup

### Conceptual Issues

#### "I don't understand the difference between agents"

**Response**: Use the sports team analogy:

- **Parker (PM)**: Team captain - decides what's worth doing
- **Archie (Architect)**: Coach - ensures strategy makes sense
- **Stella (Staff Engineer)**: Veteran player - knows what's realistic
- **Olivia (PO)**: Referee - defines what "done" looks like

Each has different expertise, all work together.

#### "Why can't I create custom agents?"

**Response**: "Great question - this is a common confusion point. Agents are
built into the platform code, similar to how kubectl has built-in commands. The
UI for custom agents is planned but not yet available. Today, you'll learn to
augment workflows with existing agents, which is what 90% of use cases need.
For truly custom needs, you can fork the platform and contribute agents back."

#### "This seems like it's replacing engineers"

**Response**: "I get that concern - let me reframe it. This is like code review
or pair programming. Would you skip code review because it's 'replacing' your
judgment? No - multiple perspectives improve quality. Same here. Agents help
engineers work faster and catch things they might miss. You're still making all
the decisions."

### Logistical Issues

#### Participant Running Very Behind

**Triage**:

1. **Assess**: Are they confused (need help) or slow (need time)?
2. **Intervene**: If confused, pair them with participant who's ahead
3. **Adjust**: If slow, give them lab materials to finish later
4. **Decide**: Is whole group behind, or just this person?

**Communication**:

> "I notice you're working through [STEP]. That's a tricky part. Would you like
> to pair with [PARTICIPANT] who just completed it, or would you prefer to
> finish this part after the session? Either way, you'll get the full value."

#### Participant Very Advanced, Bored

**Triage**:

1. **Recognize**: Acknowledge their skill level publicly
2. **Challenge**: Give them stretch goals (see Stretch Success criteria)
3. **Leverage**: Ask them to help others (benefits everyone)

**Communication**:

> "[NAME], I can see you're ahead of the curve. Two options: First, I have some
> advanced challenges if you want to dive deeper [share stretch goals]. Second,
> if you're willing to help others, that would be incredibly valuable. Your choice."

#### Time Management Crisis (>20 min behind)

**Decision Tree**:

- **Cause: Complex technical issues** → Pause, fix issues, compress later content
- **Cause: Slow group pace** → Skip optional content, focus on core exercises
- **Cause: Lots of great questions** → Continue Q&A, assign labs as homework

**Communication**:

> "We're running behind schedule because [REASON]. Here's what I propose:
> [PLAN]. This means you'll still get [CORE VALUE], and you can finish
> [OPTIONAL CONTENT] afterward. Sound good?"

---

## Success Metrics

### Immediate Metrics (End of Session)

**Participation**:

- [ ] 90%+ participants completed Lab 1
- [ ] 80%+ participants completed Lab 2
- [ ] 100% participants can articulate workflow augmentation concept
- [ ] 75%+ participants have working deployed agent

**Feedback Scores** (1-5 scale, target >4.0):

- [ ] Content relevance: ___
- [ ] Hands-on value: ___
- [ ] Instructor effectiveness: ___
- [ ] Material quality: ___
- [ ] Likelihood to recommend: ___

**Qualitative Indicators**:

- [ ] Participants stayed engaged (not on laptops during presentation)
- [ ] Questions were substantive (not "where do I click")
- [ ] Lab discussions showed understanding of concepts
- [ ] Participants shared use cases with each other

### Follow-Up Metrics (1 Week Post-Training)

**Adoption**:

- [ ] X% of participants have used agents for real work
- [ ] X% have shared workflows with their teams
- [ ] X% have scheduled team training/demo

**Business Impact**:

- [ ] Time saved: ___% reduction in [specific workflow]
- [ ] Quality improvement: ___ (fewer revisions, better outcomes)
- [ ] Team interest: ___ people requesting access

### Long-Term Metrics (1 Month Post-Training)

**Organizational Change**:

- [ ] X teams have adopted AI-augmented workflows
- [ ] X production deployments running
- [ ] X% reduction in refinement cycle time
- [ ] X new workflows identified for augmentation

---

## Post-Training Follow-Up

### Immediately After Session (Day 0)

**Participant Communication**:

- [ ] Send thank-you email with:
  - Lab materials (if not already distributed)
  - Link to vTeam GitHub repository
  - Feedback survey (if not collected in-session)
  - Instructor contact for questions
  - Slack channel or discussion forum link

**Internal Debrief**:

- [ ] Document what worked well
- [ ] Note what needs improvement
- [ ] Identify common participant questions (add to FAQ)
- [ ] Update lab guides with fixes for discovered issues
- [ ] Estimate overall success rating (subjective)

### 1 Week Follow-Up

**Check-In Email Template**:

```text
Subject: How's it going with AI-augmented workflows?

Hi [NAME],

It's been a week since the Ambient Agentic Development training. I wanted to
check in:

1. Have you had a chance to use what you learned?
2. What's working well?
3. Where are you stuck or confused?
4. What would help you get more value?

I'm here to help. Reply to this email or schedule a 15-min call: [LINK]

Best,
[YOUR NAME]
```

**Office Hours** (Optional):

- Schedule 1-hour open office hours for Q&A
- Invite all participants
- Record session for those who can't attend
- Use time to debug real-world issues

### 1 Month Follow-Up

**Success Story Collection**:

- Request participants share what they've built
- Highlight wins in team meetings or newsletters
- Create case studies for future trainings
- Recognize and reward innovative applications

**Iteration Planning**:

- Review all feedback collected
- Update training materials based on lessons learned
- Identify content gaps (what questions couldn't you answer?)
- Plan for next training iteration

---

## Appendix: Quick Reference

### Essential Commands

**OpenShift/Kubernetes**:

```bash
# Check cluster access
oc whoami
oc cluster-info

# List pods in namespace
oc get pods -n <namespace>

# View pod logs
oc logs <pod-name> -n <namespace>

# Describe pod (debugging)
oc describe pod <pod-name> -n <namespace>

# Create secret
oc create secret generic anthropic-api-key \
  --from-literal=api-key=<KEY> \
  -n <namespace>

# Apply manifest
oc apply -f <manifest.yaml>
```

**Python/Environment**:

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt

# Run validation
python validate-setup.py
```

### Key File Locations

```text
vTeam/
├── docs/labs/director-training/
│   ├── 00-prework.md              # Participant pre-work
│   ├── 01-presentation/
│   │   ├── slides.md              # Presentation content
│   │   ├── speaker-notes.md       # Detailed delivery guide
│   │   └── demo-script.md         # Demo walkthrough
│   ├── 02-my-first-agent/
│   │   ├── README.md              # Lab 1 guide
│   │   └── sample-agents/         # Reference YAML files
│   ├── 03-agent-deployment/
│   │   └── README.md              # Lab 2 guide
│   └── instructor/
│       ├── FACILITATOR-GUIDE.md   # This file
│       └── validate-setup.sh      # Pre-training validation
```

### Emergency Contacts

**Technical Issues**:

- Platform support: [CONTACT INFO]
- Cluster admin: [CONTACT INFO]
- API key emergency backup: [LOCATION/PERSON]

**Logistical Issues**:

- Training coordinator: [CONTACT INFO]
- Facility support: [CONTACT INFO]
- IT helpdesk: [CONTACT INFO]

---

**Last Updated**: 2025-10-09
**Version**: 1.0.0
**Maintainer**: vTeam Training Team

**Feedback**: File issues or suggestions at
<https://github.com/ambient-code/vTeam/issues>
