# ACP Quick Reference Guide

## Essential Commands

### Starting the Platform

```bash
# Navigate to vTeam
cd ~/acp-training/vTeam/demos/rfe-builder

# Start API server (Terminal 1)
uv run -m llama_deploy.apiserver

# Deploy workflow (Terminal 2, wait 5 seconds after starting server)
uv run llamactl deploy deployment.yml

# Access UI
open http://localhost:4501/deployments/rhoai-ai-feature-sizing/ui
```

### Testing Your Agent

```bash
# Test from command line
uv run test-agent [agent_name] "[RFE text]"

# Example
uv run test-agent dependency_detective "Add SSO integration with Okta for enterprise customers"
```

### Troubleshooting

```bash
# Kill stuck processes
pkill -f llama_deploy

# Check API keys
cat ~/acp-training/vTeam/demos/rfe-builder/src/.env

# Verify setup
~/acp-training/verify-setup.sh

# Update environment
cd ~/acp-training/vTeam/demos/rfe-builder && uv sync
```

## Agent Creation Template

```yaml
name: "[Your Agent Name]"
persona: "[UNIQUE_ID]"
role: "[Problem it solves]"
seniority: "senior"

prompt: |
  You are an expert at [domain].
  
  For every RFE, analyze:
  1. [Critical check 1]
  2. [Critical check 2]
  3. [Critical check 3]
  
  Output:
  ## Risk Level
  [HIGH/MEDIUM/LOW]
  
  ## Key Issues
  - [Bullet points]
  
  ## Recommendations
  - [Actions to take]
```

## The 7 Agent Council

| Agent | Role | What They Catch |
|-------|------|-----------------|
| **Parker** | Product Manager | Business value, ROI, market impact |
| **Archie** | Architect | Technical design, scaling, architecture |
| **Stella** | Staff Engineer | Implementation complexity, technical debt |
| **Taylor** | Team Member | Edge cases, testing, development details |
| **Olivia** | Product Owner | Acceptance criteria, scope, sprint fit |
| **Uma** | UX Lead | Design consistency, accessibility |
| **Derek** | Delivery Owner | Dependencies, timeline, cross-team impact |

## Key Metrics

### Before ACP

- 2 hours per RFE refinement
- 40% sprint velocity lost
- 3-4 vague acceptance criteria
- Issues found during development

### After ACP  

- 5 minutes per RFE
- 25% velocity improvement
- 10-12 specific criteria
- Issues found before sprint starts

## API Integration

### Environment Variables

```bash
# Required in .env file
ANTHROPIC_API_KEY=sk-ant-api03-...
OPENAI_API_KEY=sk-...

# Optional
VERTEX_PROJECT_ID=your-project
VERTEX_LOCATION=us-central1
```

### Cost Estimates

- Average RFE analysis: $0.50
- Time saved value: $300 (2 hours @ $150/hour)
- ROI: 600x

## Git Workflow

```bash
# Create feature branch
git checkout -b feature-[description]

# Add and commit
git add -A
git commit -m "feat: Add [what you added]"

# Push to remote
git push origin feature-[description]

# Create PR for review
```

## Common Issues

| Problem | Solution |
|---------|----------|
| Port 4501 in use | `pkill -f llama_deploy` |
| Import errors | `cd rfe-builder && uv sync` |
| API key errors | Check format in `.env` |
| Slow response | Check API service status |
| Agent not found | Ensure YAML in `src/agents/` |

## Success Checklist

### After Training

- [ ] Platform runs locally
- [ ] Created custom agent
- [ ] Tested on real RFE
- [ ] Saved agent file
- [ ] Know deployment steps

### First Week

- [ ] Run 5 RFEs through ACP
- [ ] Share results with team
- [ ] Measure time saved
- [ ] Iterate on agent
- [ ] Report metrics

## Support

**Jeremy Eder**  
Slack: @jeder  
Email: <jeder@redhat.com>  
GitHub: <https://github.com/ambient-code/vTeam>

---

*Remember: The goal isn't perfect requirements. It's better requirements in 96% less time.*
