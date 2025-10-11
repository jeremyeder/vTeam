# Ambient Code Platform - Executive Training

## The Problem We're Solving Together

Our engineering teams lose **40% of sprint velocity** to RFE refinement, unclear requirements, and PM/Engineering alignment issues. You asked me to fix this. Here's how we do it.

## What is ACP?

The Ambient Code Platform (vTeam) transforms how we create, refine, and implement features - turning 2-hour refinement sessions into 5-minute AI-assisted workflows.

## Training Overview

**Date**: [Training Date]  
**Duration**: 2.5 hours (including break)  
**Attendees**: 10 Engineering Executives  
**Outcome**: Each of you leaves with a working AI agent that solves your team's specific bottleneck

## Schedule

| Time | Section | What We'll Do |
|------|---------|---------------|
| 9:00-9:30 | Platform Introduction | See the velocity problem solved live |
| 9:30-10:00 | Lab 1: Your First Agent | Build an AI assistant for your daily work |
| 10:00-10:30 | Break | Coffee & informal Q&A |
| 10:30-11:30 | Lab 2: PatternFly Dark Mode | Transform a real RFE with 7-agent analysis |
| 11:30-12:00 | Next Steps | Deploy to your teams |

## Success Metrics - What We're Achieving

### Before ACP

- 📊 40% ticket readiness
- ⏱️ 2 hours per RFE refinement
- 🔄 3-4 vague acceptance criteria
- 🐛 Issues found during sprint

### After ACP

- 📊 **90% ticket readiness**
- ⏱️ **5 minutes per RFE**
- 🔄 **10-12 specific acceptance criteria**
- 🐛 **Issues found before sprint starts**

## The Value Equation

```
Time Saved per Sprint: 16 hours (2 days)
Velocity Improvement: 25%
Quality Improvement: 3x
ROI: Immediate
```

## Pre-work Required (15 minutes)

Before the training, please:

1. Run the setup script:

```bash
curl -L https://raw.githubusercontent.com/ambient-code/vTeam/main/training/setup-acp-training.sh | bash
```

2. Get your API keys (links in pre-work email)

3. Verify everything works:

```bash
cd ~/acp-executive-training
./pre-work/verify-setup.sh
```

## What You'll Build

### Lab 1: Your Custom Agent

Choose from templates or create your own:

- **Dependency Detective** - Finds hidden cross-team dependencies
- **Performance Prophet** - Predicts scaling bottlenecks
- **API Guardian** - Ensures backward compatibility

### Lab 2: Real-World RFE

We'll add dark mode to PatternFly React Seed and watch as:

- 7 specialized agents analyze the requirement
- Complete epic and stories are generated
- Test plans materialize
- Documentation requirements appear

## Your Instructors

**Jeremy Eder** - Distinguished Engineer, Red Hat  
Leading the charge on fixing our velocity problems through AI-assisted engineering.

## Key Takeaways

By the end of this training:

1. ✅ You'll have a working AI agent solving your specific pain point
2. ✅ You'll see 96% reduction in RFE refinement time
3. ✅ You'll know how to deploy this to your teams next week
4. ✅ You'll measure ROI within one sprint

## Quick Start Commands

```bash
# Start the platform
uv run -m llama_deploy.apiserver
uv run llamactl deploy deployment.yml

# Access the UI
open http://localhost:4501/deployments/rhoai-ai-feature-sizing/ui

# Test your agent
uv run test-agent [agent_name] "[your RFE]"
```

## Questions?

Slack: @jeder  
Email: <jeder@redhat.com>  
Repo: <https://github.com/ambient-code/vTeam>

---

*Remember: This isn't about AI hype. It's about getting 2 extra days per sprint for actual engineering. That's 20% more features shipped. That's how we win.*
