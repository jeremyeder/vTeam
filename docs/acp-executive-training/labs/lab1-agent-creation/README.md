# Lab 1: Build Your First Agent

**Time: 30 minutes**  
**Outcome: A working AI agent that solves your team's specific bottleneck**

## Objective

Create a custom AI agent that addresses a real pain point in your engineering workflow. You'll leave with a working agent you can use Monday morning.

## Prerequisites

- Completed pre-work setup
- vTeam platform installed
- API keys configured

## Choose Your Path

### Option A: Dependency Detective 🔍

Perfect if your team struggles with:

- Finding integration issues late in development
- Unclear component dependencies
- Surprise infrastructure requirements

### Option B: Performance Prophet ⚡

Ideal if you need to:

- Predict scaling issues before production
- Estimate infrastructure costs
- Identify performance bottlenecks early

### Option C: API Guardian 🛡️

Great for teams that:

- Maintain APIs with many consumers
- Need to ensure backward compatibility
- Want to automate contract testing

### Option D: Custom Agent 🛠️

Build exactly what YOUR team needs.

## Step-by-Step Instructions

### 1. Set Up Your Workspace (2 minutes)

```bash
cd ~/acp-training/vTeam/demos/rfe-builder
mkdir -p src/agents
cd src/agents
```

### 2. Create Your Agent Configuration (10 minutes)

Choose one of the templates from `agent-templates.yaml` or create your own:

```bash
# Copy a template (replace TEMPLATE_NAME with your choice)
cp ../../labs/lab1-agent-creation/agent-templates.yaml ./my_agent.yaml

# Or create from scratch
nano my_agent.yaml
```

### 3. Customize Your Agent (10 minutes)

Edit your agent file to match your needs:

```yaml
name: "Your Agent Name"
persona: "UNIQUE_IDENTIFIER"
role: "What problem does it solve?"

analysisPrompt:
  template: |
    Analyze this RFE for [YOUR SPECIFIC FOCUS]:
    
    {rfe_description}
    
    Identify:
    1. [First thing to analyze]
    2. [Second thing to analyze]
    3. [Third thing to analyze]
    
    Output:
    - [Specific output format]
    - [Another output requirement]
```

### 4. Test Your Agent (5 minutes)

```bash
cd ~/acp-training/vTeam/demos/rfe-builder

# Run the test script
./labs/lab1-agent-creation/test-agent.sh my_agent "Your test RFE description"
```

### 5. Iterate and Improve (3 minutes)

Based on the output:

1. Adjust the prompt for better analysis
2. Add more specific instructions
3. Refine output format

## Pairing Exercise

Find a partner with complementary needs:

1. **Share your pain points** (2 minutes each)
2. **Combine agent capabilities** (5 minutes)
3. **Test on real RFE** (3 minutes)

## Success Criteria

Your agent is ready when it:

- ✅ Analyzes RFEs consistently
- ✅ Provides actionable insights
- ✅ Saves you at least 30 minutes per RFE
- ✅ Catches issues you typically miss

## Common Issues

### Agent Not Loading

```bash
# Check YAML syntax
python -c "import yaml; yaml.safe_load(open('my_agent.yaml'))"
```

### Poor Analysis Quality

- Make prompts more specific
- Add examples in the prompt
- Request structured output

### Slow Response

- Reduce prompt complexity
- Focus on essential analysis

## Taking It Back

### Monday Morning

1. Run your agent on this week's backlog
2. Compare to manual analysis
3. Measure time saved

### Share with Team

1. Demo in standup
2. Get feedback
3. Iterate based on usage

## Lab Complete

You now have:

- A working custom agent
- Experience with agent creation
- A plan to use it immediately

## Resources

- Agent examples: `agent-templates.yaml`
- Test script: `test-agent.sh`
- Full documentation: <https://github.com/ambient-code/vTeam>

---

**Next**: Lab 2 - See all agents work together on a real feature
