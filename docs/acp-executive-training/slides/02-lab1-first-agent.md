# Lab 1: Build Your First Agent - 30 Minutes

## Slide 1: Your Personal AI Assistant

### What We're Building

In the next 30 minutes, you'll create an AI agent that:

- **Solves YOUR specific bottleneck**
- **Works with your team's workflow**
- **Starts saving time tomorrow**

Choose your path:

1. **Use a template** (5 minutes to value)
2. **Build custom** (10 minutes to value)
3. **Pair up** (recommended - more fun)

---

## Slide 2: Three Starter Templates

### Option A: The Dependency Detective 🔍

```yaml
name: "Dependency Detective"
role: "Cross-team dependency analyzer"
problem_solved: "Hidden dependencies that blow up sprints"
```

**Perfect for you if:**

- Your features touch multiple teams
- You're tired of surprise blockers
- Integration issues kill your velocity

**Sample Output:**

```
Dependencies Found:
- Platform Team: API versioning change required
- Security: New auth flow needs review (2 days)
- Database: Schema migration affects 3 services
- Customer Success: Training materials needed
Risk: HIGH - coordinate with 4 teams before starting
```

---

### Option B: The Performance Prophet 🚀

```yaml
name: "Performance Prophet"
role: "Scaling and performance predictor"
problem_solved: "Features that work in dev but die in production"
```

**Perfect for you if:**

- You've been burned by scaling issues
- Performance is a constant concern
- You need to predict infrastructure costs

**Sample Output:**

```
Performance Analysis:
- At 1K users: 200ms response, 2GB memory
- At 10K users: 2s response, 20GB memory (!)
- At 100K users: System fails at database layer
Bottleneck: Connection pooling
Fix: Implement caching layer before production
Cost Impact: $2K/month at scale
```

---

### Option C: The API Guardian 🛡️

```yaml
name: "API Guardian"
role: "API compatibility and contract enforcer"
problem_solved: "Breaking changes that anger customers"
```

**Perfect for you if:**

- You maintain APIs other teams consume
- Backward compatibility keeps you up at night
- You need better contract testing

**Sample Output:**

```
API Impact Assessment:
- Breaking Changes: 2 endpoints modified
- Affected Consumers: 7 services, 3 external
- Migration Required: Yes (deprecation period)
- Contract Tests Needed: 5 new scenarios
- SDK Updates: Python, Go, Java
Compatibility Score: 6/10 - requires migration guide
```

---

## Slide 3: Anatomy of an Agent

### What Makes a Great Agent

```yaml
name: "Your Agent Name"
persona: "UNIQUE_ID"
role: "What problem does it solve"

# The brain - your specific instructions
prompt: |
  You are an expert at [specific domain].
  
  For every feature/RFE, analyze:
  1. [First thing to check]
  2. [Second thing to check]
  3. [Third thing to check]
  
  Always output:
  - [Specific metric or assessment]
  - [Risk level or score]
  - [Recommended actions]
  
  Focus on [what matters to your team].
  Flag any [specific concerns].

# Knowledge sources (optional)
dataSources:
  - type: local
    path: ./docs/architecture
  - type: github
    repo: your-team/repo
```

---

## Slide 4: Build Your Agent - Live

### Step 1: Choose Your Fighter

**Pair up with someone!** (Or work solo if you prefer)

Discuss:

- What wastes the most time for your team?
- What questions always come up in refinement?
- What gets missed until it's too late?

### Step 2: Create Your Agent

**Option A: Claude Code Workflow (Recommended)**

```bash
cd ~/acp-training/vTeam/demos/rfe-builder
mkdir -p src/agents

# Create your agent
cat > src/agents/my_agent.yaml << 'EOF'
name: "[Your Agent Name]"
persona: "[YOUR_INITIALS]_AGENT"
role: "[Problem it solves]"
seniority: "senior"

prompt: |
  [Your instructions here]
EOF
```

**Option B: Use the UI**

1. Navigate to Agent Builder
2. Fill in the template
3. Test immediately

---

## Slide 5: Real Examples from Your Peers

### Successful Agents from Other Teams

**"Migration Monitor"** (Platform Team)

```yaml
prompt: |
  Assess migration impact for any feature:
  - Database schema changes required
  - Backward compatibility breaks
  - Customer communication needed
  - Rollback strategy complexity
  
  Rate migration risk: LOW/MEDIUM/HIGH/EXTREME
```

**"Security Scanner"** (Security Team)

```yaml
prompt: |
  Review for security implications:
  - Auth/authz changes
  - Data exposure risks
  - Compliance impacts (SOC2, HIPAA)
  - Encryption requirements
  
  Output security checklist and review timeline
```

**"Customer Impact Assessor"** (Customer Success)

```yaml
prompt: |
  Evaluate customer impact:
  - Training required (hours)
  - Documentation updates
  - Breaking workflow changes
  - Support ticket predictions
  
  Recommend communication strategy
```

---

## Slide 6: Testing Your Agent

### Make It Real

Test with an actual RFE from your backlog:

```bash
# Command line test
uv run test-agent my_agent "Add SSO integration with Okta"

# Or use the UI
# Paste your RFE text and watch it work
```

**What to Look For:**

- ✅ Catches issues you've seen before
- ✅ Provides specific, actionable feedback
- ✅ Outputs in useful format
- ✅ Takes < 30 seconds

**Iterate Quickly:**

- Too vague? Add specific instructions
- Missing something? Add to the prompt
- Too verbose? Add output constraints

---

## Slide 7: Advanced Agent Features

### Level Up Your Agent (If Time Permits)

**Add Knowledge Sources:**

```yaml
dataSources:
  - type: local
    source: ./docs/api-specs
    description: "OpenAPI specifications"
  
  - type: github
    source: "redhat/openshift-ai"
    description: "Current codebase"
```

**Add Output Formatting:**

```yaml
prompt: |
  ...
  Format output as:
  ## Risk Assessment
  [LOW/MEDIUM/HIGH]
  
  ## Required Actions
  - [ ] Action item 1
  - [ ] Action item 2
  
  ## Timeline Impact
  [Days added to estimate]
```

**Add Scoring:**

```yaml
prompt: |
  ...
  Score each aspect 1-10:
  - Technical Complexity: X/10
  - Business Value: X/10
  - Risk Level: X/10
  
  Only flag for review if any score > 7
```

---

## Slide 8: Pairing Exercise

### Work Together (Recommended)

**Pair Programming Instructions:**

1. **Driver/Navigator Pattern**
   - One person types (Driver)
   - Other person guides (Navigator)
   - Switch after 10 minutes

2. **Choose Complementary Problem**
   - PM + Engineer = Business/Tech analyzer
   - Frontend + Backend = Full stack reviewer
   - Platform + Product = Infrastructure impact

3. **Combine Your Expertise**

   ```yaml
   name: "Full Stack Reviewer"
   prompt: |
     Analyze from both frontend and backend perspective:
     
     Frontend concerns (from Pat):
     - UI component impacts
     - State management changes
     - Browser compatibility
     
     Backend concerns (from Jamie):
     - API changes required
     - Database impacts
     - Scaling considerations
   ```

---

## Slide 9: Share and Compare

### Quick Round-Robin (5 minutes)

Each person/pair:

1. **State the problem** your agent solves (10 seconds)
2. **Show one insight** it provided (20 seconds)
3. **Share surprise** discovery (10 seconds)

**Capture Board:**

| Who | Problem Solved | Key Insight |
|-----|---------------|-------------|
| Team 1 | Dependency detection | Found 7 hidden dependencies |
| Team 2 | Performance prediction | Saved $5K/month in scaling |
| Team 3 | Security review | Caught GDPR issue |

---

## Slide 10: Make It Permanent

### Your Agent in Production

**Save Your Work:**

```bash
# Commit to your fork
cd ~/acp-training/vTeam
git checkout -b my-agent-[yourname]
git add src/agents/my_agent.yaml
git commit -m "Add [Agent Name] for [problem solved]"
git push origin my-agent-[yourname]
```

**Deploy to Your Team:**

1. Share agent file with your team
2. Add to your team's RFE workflow
3. Measure time saved in first sprint
4. Iterate based on feedback

**Success Metrics:**

- Time saved per RFE: _____ minutes
- Issues caught early: _____ per sprint
- Team satisfaction: _____ / 10

---

## Slide 11: Common Patterns

### What Works Best

**DO:**

- ✅ Focus on ONE specific problem
- ✅ Use your domain language
- ✅ Include examples in prompt
- ✅ Add clear output format
- ✅ Test with real data

**DON'T:**

- ❌ Try to solve everything
- ❌ Write vague instructions
- ❌ Forget output format
- ❌ Skip testing
- ❌ Overthink it

**Remember:** Version 1 just needs to be better than nothing. Ship it.

---

## Slide 12: Q&A and Troubleshooting

### Common Issues

**"My agent is too verbose"**
Add constraints:

```yaml
prompt: |
  ...
  Maximum 5 bullet points.
  Be concise. No explanations.
```

**"It's missing important checks"**
Be explicit:

```yaml
prompt: |
  ALWAYS check for:
  1. [Specific thing]
  2. [Other thing]
  Never skip these checks.
```

**"Output format is inconsistent"**
Provide template:

```yaml
prompt: |
  Use this exact format:
  RISK: [LOW/MEDIUM/HIGH]
  BLOCKERS: [list or "none"]
  TIMELINE: [days]
```

---

## Key Takeaways

### You Now Have

1. ✅ **A working AI agent** solving your specific problem
2. ✅ **Understanding** of how to build more
3. ✅ **Clear path** to deploy with your team

### Next Steps

1. Test your agent on 3 real RFEs this week
2. Share with your team in next standup
3. Measure time saved
4. Iterate based on results

### Remember

> "The best agent is the one that ships today and saves time tomorrow."
>
> Not perfect. Just better than manual.

---

## Lab Success Criteria

Before moving on, ensure you have:

- [ ] Created at least one agent
- [ ] Tested it with real RFE text
- [ ] Got useful output
- [ ] Saved your agent file
- [ ] Identified how to use it tomorrow

**Time check:** We should be at minute 25-30.

Ready for break, then Lab 2 where we'll see all 7 agents work together!
