# Lab 2: Transform PatternFly with Dark Mode

**Time: 60 minutes**  
**Outcome: Complete production-ready RFE with all 7 agents collaborating**

## Objective

Transform a simple one-line request ("Add dark mode to PatternFly") into a comprehensive, production-ready RFE using the full power of the 7-agent council. You'll see how agents work together to create requirements that are immediately actionable.

## Prerequisites

- Lab 1 completed
- vTeam platform running
- PatternFly React seed cloned

## The Challenge

Your PM just said: "We need dark mode in the PatternFly app."

That's all you have. In the traditional process, this would trigger:

- 2-hour refinement meeting
- 1-hour follow-up for clarifications
- Multiple back-and-forth emails
- Still missing critical details when development starts

Today, we'll get production-ready requirements in 5 minutes.

## Step-by-Step Instructions

### 1. Start the Platform (5 minutes)

Open two terminal windows:

**Terminal 1 - API Server:**

```bash
cd ~/acp-training/vTeam/demos/rfe-builder
uv run -m llama_deploy.apiserver
```

Wait for: "Uvicorn running on <http://0.0.0.0:4501>"

**Terminal 2 - Deploy Workflow:**

```bash
cd ~/acp-training/vTeam/demos/rfe-builder
# Wait 5 seconds after server starts
uv run llamactl deploy deployment.yml
```

Wait for: "Deployment successful: rhoai-ai-feature-sizing"

**Browser:**

```bash
open http://localhost:4501/deployments/rhoai-ai-feature-sizing/ui
```

### 2. Input Your RFE (5 minutes)

In the chat interface, type:

```text
I need to add dark mode to the PatternFly React seed application.

Context:
- This is a React application using PatternFly design system
- Users work in different lighting conditions and time zones
- We need to support user preference and system settings
- The theme choice should persist across sessions
- Must maintain PatternFly design standards
- Accessibility is critical for our enterprise customers

Please provide a comprehensive analysis with all agents.
```

Click Send or press Enter.

### 3. Watch the Agent Analysis (10 minutes)

You'll see each agent activate in sequence:

#### Phase 1: Business Analysis (Parker)

- Business value calculation
- User impact assessment
- Priority recommendation
- Market comparison

#### Phase 2: Technical Review (Archie & Stella)

- Architecture design
- Technical approach
- Implementation complexity
- Resource requirements

#### Phase 3: Requirements (Olivia & Taylor)

- Acceptance criteria
- Test scenarios
- Edge cases
- Definition of done

#### Phase 4: Delivery Planning (Derek & Phoenix)

- Sprint breakdown
- Story points
- Dependencies
- Customer impact

### 4. Review the Generated Artifacts (10 minutes)

The system will generate:

**Epic Structure:**

- Title and description
- Business justification
- Success metrics
- Acceptance criteria

**User Stories (5 total):**

1. Theme Context Setup (3 points)
2. Color System Implementation (5 points)
3. Toggle Component (2 points)
4. Persistence Layer (2 points)
5. Testing & Documentation (1 point)

**Technical Artifacts:**

- Architecture diagram
- Implementation guide
- Test plan
- Migration strategy

### 5. Compare to Manual Process (5 minutes)

Create a quick comparison:

| Aspect | Manual Process | ACP Result |
|--------|---------------|------------|
| Time | 2-3 hours | 5 minutes |
| Completeness | 40% | 95% |
| Acceptance Criteria | 3-4 vague | 12 specific |
| Test Cases | Often forgotten | 12 identified |
| Dependencies | Found during sprint | All identified upfront |
| Customer Impact | Rarely considered | Full analysis provided |

Calculate your time savings:

- Manual: 2 hrs × 10 people = 20 person-hours
- ACP: 5 min generation + 10 min review = 15 minutes
- **Saved: 19.75 hours per feature**

### 6. Export and Customize (10 minutes)

#### Option A: Copy to Your System

1. Select the generated epic and stories
2. Copy to your clipboard
3. Paste into Jira/Azure DevOps/GitHub

#### Option B: Run Export Script

```bash
cd ~/acp-training/vTeam/demos/rfe-builder
./labs/lab2-patternfly-rfe/run-analysis.sh --export
```

#### Option C: Customize for Your Team

Edit the agent prompts to include your specific requirements:

```yaml
teamStandards:
  - "All UI changes need design review"
  - "Dark mode must support our brand colors"
  - "Include mobile Safari testing"
```

### 7. Discuss Application to Your Work (15 minutes)

With your partner or group:

1. **Identify a current RFE** from your backlog
2. **Run it through ACP** (5 minutes)
3. **Compare** to your manual refinement
4. **Calculate** time saved
5. **Share** insights with the group

## Key Observations

### What Makes This Different

The agents don't just template responses - they:

- Consider interdependencies
- Apply domain expertise
- Think about edge cases
- Plan for customer impact
- Coordinate technical decisions

### Agent Collaboration Patterns

Notice how agents build on each other:

- Parker defines value → Archie designs for that value
- Archie sets architecture → Stella plans implementation
- Stella identifies complexity → Taylor finds edge cases
- Olivia creates criteria → Derek plans sprints
- Phoenix ensures customer success throughout

### Quality Indicators

Your RFE is production-ready when:

- ✅ Every story has clear acceptance criteria
- ✅ Dependencies are identified and addressed
- ✅ Test scenarios cover edge cases
- ✅ Customer impact is understood
- ✅ Technical approach is validated

## Common Issues

### Agents Taking Too Long

- Check API rate limits
- Reduce input complexity
- Try during off-peak hours

### Incomplete Analysis

- Provide more context in your input
- Be specific about requirements
- Include constraints and standards

### Export Issues

- Verify Jira credentials in .env
- Check network connectivity
- Use manual copy as fallback

## Lab Complete

You've now:

- ✅ Transformed vague request to production-ready RFE
- ✅ Seen 7 agents collaborate effectively
- ✅ Generated sprint-ready artifacts
- ✅ Calculated real time savings

## Taking It Forward

### This Week

1. Run 3 RFEs through ACP
2. Track time saved
3. Compare quality to manual process

### Next Week

1. Share results with your team
2. Customize agents for your process
3. Begin regular usage

### In One Month

1. Measure velocity improvement
2. Survey team satisfaction
3. Expand to other teams

## Resources

- Sample RFE: `sample-rfe.json`
- Analysis script: `run-analysis.sh`
- Export templates: `export-templates/`

---

**Remember**: This isn't about replacing human judgment - it's about eliminating the grunt work so your team can focus on building great software.
