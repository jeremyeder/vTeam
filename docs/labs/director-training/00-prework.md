# Pre-Work: Director Training Setup Guide

## Overview

This guide ensures you're ready for the Ambient Platform RFE Builder training
session. Complete all steps **before the training day** to maximize your
hands-on learning time.

**Estimated Setup Time**: 30-45 minutes

> **Source**: vTeam Platform - <https://github.com/ambient-code/vTeam>

## Training Session Details

- **Duration**: 3 hours
- **Format**: 30-min presentation + 2 hands-on labs (60 min each) + 30-min break
- **Prerequisites**: This pre-work completed
- **Bring**: Laptop with setup validated

## Required Access & Accounts

### 1. Anthropic API Access ✅

You'll need an Anthropic API key to run AI agents.

(Source: Anthropic Console - <https://console.anthropic.com/>)

**Setup Steps:**

1. **Create Account**: Visit [console.anthropic.com](https://console.anthropic.com/)
2. **Get API Key**: Navigate to Settings → API Keys → Create Key
3. **Save Securely**: Store your key - you'll configure it during training
4. **Verify Credits**: Ensure you have at least $5 in credits available

**Cost Estimate**: Training labs will use approximately $2-3 in API credits.

**Security Note**: Never commit API keys to version control. Store in password
manager or encrypted storage.

✅ **Checkpoint**: API key saved and credits verified

### 2. OpenShift/Kubernetes Access

During training, you'll deploy to an OpenShift environment.

(Source: Red Hat OpenShift Local - <https://developers.redhat.com/products/openshift-local>)

**Options:**

**Option A: OpenShift Local (Recommended for Training)**

```bash
# Install CRC (OpenShift Local)
brew install crc

# Setup (requires Red Hat account - free)
crc setup
crc start
```

**Option B: Access to Shared Training Cluster**

- Instructor will provide cluster URL and credentials on training day
- No local installation required

✅ **Checkpoint**: Can access `oc` or `kubectl` commands

## System Requirements

### Minimum Specifications

- **OS**: macOS 10.15+, Linux, or Windows 10+ with WSL2
- **RAM**: 8 GB minimum, 16 GB recommended
- **Disk**: 20 GB free space
- **CPU**: 4 cores recommended
- **Network**: Stable internet connection (for API calls)

### Required Software

| Tool | Version | Installation | Purpose |
|------|---------|--------------|---------|
| **Git** | 2.30+ | `brew install git` | Clone repositories |
| **oc CLI** | Latest | `brew install openshift-cli` | OpenShift management |
| **kubectl** | 1.28+ | `brew install kubectl` | Kubernetes operations (alternative) |
| **Docker/Podman** | Latest | `brew install docker` or `brew install podman` | Container operations |
| **Node.js** | 20+ | `brew install node` | Frontend development |
| **Python** | 3.11+ | `brew install python@3.11` | Backend scripting |

### Verification Script

Run this command to verify your environment:

```bash
# Download and run validation script
curl -sSL https://raw.githubusercontent.com/ambient-code/vTeam/main/docs/labs/director-training/instructor/validate-setup.sh | bash
```

Expected output:
```
✅ Git: v2.40.0
✅ oc CLI: v4.14.0
✅ Docker: v24.0.0
✅ Node.js: v20.11.0
✅ Python: v3.11.7
✅ Network: Connected
✅ Cluster Access: Verified

All prerequisites met! You're ready for training.
```

## Pre-Training Checklist

Complete this checklist 24 hours before training:

- [ ] **Anthropic API key** created and saved securely
- [ ] **API credits** verified ($5+ available)
- [ ] **OpenShift access** confirmed (local or shared cluster)
- [ ] **Required software** installed and verified
- [ ] **Network connectivity** tested (can reach console.anthropic.com)
- [ ] **Laptop fully charged** with power adapter ready
- [ ] **Validation script** run successfully

## Training Day Requirements

### What to Bring

1. **Laptop** with all software installed
2. **Power adapter** (training is 3 hours)
3. **Anthropic API key** (saved in password manager or notes)
4. **Notebook** (optional - for notes)

### What We'll Provide

- Training materials and lab guides
- Sample code and templates
- Access to shared resources
- Support during hands-on exercises

## Troubleshooting Common Issues

### Issue: Can't Install OpenShift Local

**Solution**: Use the shared training cluster instead
- Instructor will provide access details on training day
- No local installation needed

### Issue: Anthropic API Key Not Working

**Symptoms**: Authentication errors when testing
**Solutions**:
1. Verify key was copied completely (no spaces)
2. Check account has available credits
3. Ensure key hasn't been deleted from console
4. Create a new key if needed

### Issue: oc/kubectl Commands Not Found

**macOS**:
```bash
brew install openshift-cli kubectl
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Linux**:
```bash
# Download oc CLI
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz
tar xvf openshift-client-linux.tar.gz
sudo mv oc kubectl /usr/local/bin/
```

### Issue: Not Enough Disk Space

**Required**: 20 GB free
**Check**:
```bash
df -h ~
```

**Solutions**:
- Clear Docker images: `docker system prune -a`
- Remove unused applications
- Move large files to external storage

### Issue: Corporate Proxy/Firewall

If you're behind a corporate proxy:

1. **Test API access**:
   ```bash
   curl -I https://api.anthropic.com
   ```

2. **Configure proxy** (if needed):
   ```bash
   export HTTP_PROXY=http://proxy.company.com:8080
   export HTTPS_PROXY=http://proxy.company.com:8080
   ```

3. **Contact IT**: You may need proxy exceptions for:
   - `api.anthropic.com`
   - `console.anthropic.com`
   - OpenShift cluster URLs

## Getting Help

### Before Training Day

- **Questions?** Post in training Slack channel or email instructor
- **Technical issues?** Share validation script output for diagnosis
- **Can't complete setup?** Contact instructor at least 24 hours before training

### During Training

- **Lab assistance**: Instructors available throughout hands-on exercises
- **Technical issues**: Dedicated troubleshooting support
- **Falling behind?** We have catch-up checkpoints built in

## Enterprise Security Considerations

Before deploying AI agents in your environment, understand these security
principles. We'll implement these in Lab 2.

(Source: IBM Guide to Architecting Secure Enterprise AI Agents with MCP)

### SOLUTION Framework

Enterprise AI security follows the SOLUTION framework:

**S**ecure by design
- AI agents follow least-privilege principles
- Encrypted secrets management (Kubernetes Secrets)
- Secure communication channels (TLS)

**O**bservability and monitoring
- Real-time session tracking
- Audit logs for all AI operations
- Usage and cost monitoring

**L**east privilege access
- RBAC for project and session access
- Namespace isolation per project
- Limited agent capabilities

**U**ser authentication and authorization
- OpenShift OAuth integration available
- Project-level access control
- API key rotation policies

**T**esting and validation
- Pre-deployment agent testing
- Prompt injection prevention
- Output validation

**I**ncident response
- Session termination capabilities
- Audit trail for investigations
- Error handling and recovery

**O**perational excellence
- High availability deployment
- Backup and disaster recovery
- Performance monitoring

**N**etwork segmentation
- Pod network policies
- Service mesh integration (optional)
- API gateway patterns

### Security Checklist for Training

Before training day, review:

- [ ] Understand API key storage (Kubernetes Secrets)
- [ ] Know your organization's data classification policies
- [ ] Review what data you'll use in training prompts
- [ ] Understand RBAC roles (View, Edit, Admin)
- [ ] Know who has access to your training project

**We'll implement these patterns in Lab 2: Enterprise Deployment**

---

## Optional Pre-Reading

Want to come prepared? Review these resources (optional):

- **Ambient Code Concepts**: [vTeam README](https://github.com/ambient-code/vTeam)
- **Multi-Agent Systems**: [Agent Framework](https://github.com/ambient-code/vTeam/blob/main/rhoai-ux-agents-vTeam.md)
- **Deployment Guide**: docs/OPENSHIFT_DEPLOY.md in vTeam repo

**Time Estimate**: 15-30 minutes of reading

## What's Next?

Once you've completed this pre-work:

1. ✅ **Verify** all checklist items above
2. 📧 **Confirm** attendance with instructor
3. 📅 **Mark calendar** for training day (3 hours + lunch)
4. 🚀 **Get excited** about AI-assisted development!

---

**Questions?** Contact your training coordinator or post in the training Slack channel.

**Ready to go?** See you at the training session!
