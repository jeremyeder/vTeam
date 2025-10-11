# ACP Executive Training - Maintenance Guide

## Overview

This training package teaches engineering executives how to use the Ambient Code Platform (vTeam) to solve RFE refinement and team velocity issues.

## Repository Structure

```
acp-executive-training/
├── README.md                    # Main training overview
├── setup-acp-training.sh        # Environment setup script
├── CLAUDE.md                    # This file - maintenance guide
├── pre-work/                   # Pre-training preparation
├── slides/                     # Training presentation materials
├── labs/                       # Hands-on exercises
├── visuals/                    # Mermaid diagrams
└── handouts/                   # Reference materials
```

## Key Components

### Training Flow

1. **Platform Introduction** (30 min) - Demonstrate value proposition
2. **Lab 1: First Agent** (30 min) - Create custom AI assistant
3. **Break** (30 min)
4. **Lab 2: PatternFly RFE** (60 min) - Real-world RFE transformation

### Critical Files

- `setup-acp-training.sh` - Must work on both macOS and Linux
- `labs/lab1-agent-creation/agent-templates.yaml` - Keep templates current
- `visuals/*.mmd` - Mermaid diagrams showing value metrics

## Maintenance Schedule

### Quarterly Tasks

- [ ] Update agent templates with new patterns from production
- [ ] Refresh performance metrics and ROI calculations
- [ ] Review and update API version requirements
- [ ] Test setup script on latest OS versions

### Annual Tasks

- [ ] Update PatternFly React Seed to latest version
- [ ] Review all dependencies for major version changes
- [ ] Refresh training content based on feedback
- [ ] Update vTeam repository references

### Before Each Training Session

1. Run full setup test:

   ```bash
   ./setup-acp-training.sh
   ./pre-work/verify-setup.sh
   ```

2. Verify API endpoints:

   ```bash
   curl -H "Authorization: Bearer $ANTHROPIC_API_KEY" https://api.anthropic.com/v1/messages
   curl -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models
   ```

3. Test lab exercises end-to-end

4. Update dates and attendee information in README.md

## Common Issues and Solutions

### Setup Script Failures

| Issue | Solution |
|-------|----------|
| `uv: command not found` | Re-run installer: `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Python version error | Install Python 3.11+: `brew install python@3.11` (macOS) |
| Git clone fails | Check network/firewall, use HTTPS instead of SSH |
| Permission denied | Ensure scripts have execute permission: `chmod +x *.sh` |

### API Key Issues

| Issue | Solution |
|-------|----------|
| Authentication failed | Verify key format: `sk-ant-api03-...` for Anthropic |
| Rate limits | Use different keys for each attendee or stagger usage |
| Key not found | Check `.env` file location and format |

### Platform Issues

| Issue | Solution |
|-------|----------|
| Port 4501 in use | Kill existing process: `pkill -f llama_deploy` |
| Slow response | Check API status pages, try off-peak hours |
| Import errors | Re-sync environment: `cd demos/rfe-builder && uv sync` |

## Testing Checklist

### Pre-Training (1 week before)

- [ ] Run setup script on clean macOS machine
- [ ] Run setup script on clean Fedora machine
- [ ] Verify all agent templates work
- [ ] Test both lab exercises completely
- [ ] Generate sample outputs for comparison
- [ ] Update slide deck with current metrics

### Day Before Training

- [ ] Send reminder email with pre-work instructions
- [ ] Verify API keys have sufficient credits
- [ ] Test network connectivity at training location
- [ ] Prepare backup demo videos (in case of failures)

### Day of Training

- [ ] Arrive 30 minutes early for setup
- [ ] Test projector/screen sharing
- [ ] Verify attendee machines are ready
- [ ] Have backup API keys available

## Update Procedures

### Updating Agent Templates

```bash
# Edit templates
vi labs/lab1-agent-creation/agent-templates.yaml

# Test each template
uv run test-agent dependency_detective "Sample RFE text"
uv run test-agent performance_prophet "Sample RFE text"
uv run test-agent api_guardian "Sample RFE text"

# Commit changes
git add -A
git commit -m "Update agent templates for Q1 2025"
git push
```

### Updating Metrics

1. Gather latest data from production deployments
2. Update README.md with new statistics
3. Regenerate visualization diagrams
4. Update slides with new numbers

### Updating Dependencies

```bash
# Update vTeam
cd ~/acp-training/vTeam
git pull
cd demos/rfe-builder
uv sync

# Update PatternFly
cd ~/acp-training/patternfly-react-seed
git pull
npm install

# Test everything still works
./pre-work/verify-setup.sh
```

## Contact Information

**Primary Maintainer**: Jeremy Eder  
**Email**: <jeder@redhat.com>  
**Slack**: @jeder  
**Backup**: [Your backup contact]

## Success Metrics Tracking

Track these after each training:

- Number of agents created by attendees
- Time to complete each lab
- Questions asked (document for FAQ)
- Follow-up adoption rate (check 2 weeks later)
- Velocity improvements reported (check 1 month later)

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0.0 | 2024-12-XX | Initial training materials | Jeremy Eder |

## Git Workflow

Following Jeremy's preferences:

```bash
# Always work in feature branches
git checkout -b update-training-materials

# Make changes
# ...

# Commit with clear messages
git add -A
git commit -m "feat: Update agent templates for Q1 2025"

# Push and create PR
git push origin update-training-materials

# After review, squash and merge
```

## Links and Resources

- **vTeam Repository**: <https://github.com/ambient-code/vTeam>
- **PatternFly Seed**: <https://github.com/patternfly/patternfly-react-seed>
- **Anthropic Console**: <https://console.anthropic.com/>
- **OpenAI Platform**: <https://platform.openai.com/>
- **Training Feedback Form**: [Add your form link]

## Notes

- Keep Jeremy's voice: pragmatic, direct, slightly irreverent
- No AI hype or marketing speak
- Focus on concrete time savings and velocity improvements
- Always test on both macOS and Linux before training
- Maintain low cognitive load - one concept at a time

---

*Last updated: [Date]*  
*Next review: [Quarterly review date]*
