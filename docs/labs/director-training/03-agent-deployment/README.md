# Lab 2: Enterprise Agent Deployment

## Objective 🎯

Deploy your AI-augmented workflow to production with enterprise security,
monitoring, and operational excellence patterns.

**By the end of this lab, you will:**

- Implement IBM SOLUTION security framework for AI agents
- Deploy workflow automation with proper RBAC and secrets management
- Set up monitoring and observability for agent operations
- Understand production deployment best practices

## Prerequisites 📋

- [ ] Lab 1 completed (workflow augmentation working)
- [ ] OpenShift cluster access (CRC or shared cluster)
- [ ] Anthropic API key ready
- [ ] Basic understanding of Kubernetes/OpenShift

## Estimated Time ⏱️

**60 minutes**

- Part 1: Security Foundations (20 min)
- Part 2: Production Deployment (25 min)
- Part 3: Monitoring & Observability (15 min)

## Core Principles

Enterprise AI deployment requires:

1. **Security by Design** - Not bolted on after
2. **Operational Excellence** - Reliable, maintainable, observable
3. **Least Privilege** - Minimum necessary access
4. **Defense in Depth** - Multiple security layers

(Source: IBM Guide to Architecting Secure Enterprise AI Agents with MCP)

---

## Part 1: Security Foundations (20 minutes)

### Step 1.1: Understand the SOLUTION Framework

IBM's security framework for enterprise AI agents:

**S**ecure by design
**O**bservability and monitoring
**L**east privilege access
**U**ser authentication and authorization
**T**esting and validation
**I**ncident response
**O**perational excellence
**N**etwork segmentation

We'll implement each principle in this lab.

(Source: IBM MCP Guide, Section 4)

### Step 1.2: Security Checklist Review

Before deploying, verify:

```markdown
## Pre-Deployment Security Checklist

### Data Classification
- [ ] Identified data sensitivity levels in your workflow
- [ ] Reviewed what data will be sent to AI APIs
- [ ] Confirmed no PII/PHI/PCI data in prompts (unless approved)
- [ ] Understood data retention policies

### Access Control
- [ ] RBAC roles defined (Admin, Edit, View)
- [ ] Team members assigned appropriate roles
- [ ] Service accounts created with minimal permissions
- [ ] No shared credentials

### Secrets Management
- [ ] API keys stored in Kubernetes Secrets (not ConfigMaps)
- [ ] Secrets encrypted at rest
- [ ] No secrets in git repository
- [ ] Key rotation policy defined

### Network Security
- [ ] Understood pod network policies
- [ ] Confirmed TLS for all external connections
- [ ] API endpoints authenticated
- [ ] No unencrypted traffic
```

**✅ Checkpoint**: Security checklist reviewed and understood

---

### Step 1.3: Implement Secrets Management

Secure API key storage following Kubernetes best practices.

**Steps:**

1. **Verify Current Namespace**

   ```bash
   # Check current project/namespace
   oc project

   # Or switch to your training project
   oc project vteam-training-$(whoami)
   ```

   (Source: OpenShift CLI documentation)

2. **Create Secret for Anthropic API Key**

   ```bash
   # Create secret (replace with your actual key)
   oc create secret generic anthropic-api-key \
     --from-literal=ANTHROPIC_API_KEY=sk-ant-your-key-here \
     -n $(oc project -q)

   # Verify secret created
   oc get secret anthropic-api-key
   ```

3. **Validate Secret Contents (Keys Only)**

   ```bash
   # View secret metadata (DOES NOT show actual key)
   oc describe secret anthropic-api-key

   # Should show:
   # Data
   # ====
   # ANTHROPIC_API_KEY:  XX bytes
   ```

4. **Set Secret Encryption at Rest** (if not already enabled)

   OpenShift encrypts secrets by default. Verify:

   ```bash
   # Check encryption status
   oc get apiservers cluster -o yaml | grep -A 5 encryption
   ```

**Security Best Practices Applied:**

- ✅ **Secret stored in Kubernetes Secret** (not ConfigMap or env file)
- ✅ **Encrypted at rest** by OpenShift
- ✅ **Accessed via volume mount** (not environment variable)
- ✅ **RBAC controls access** to secret

**✅ Checkpoint**: API key securely stored as Kubernetes Secret

---

### Step 1.4: Configure RBAC

Set up role-based access control for your project.

(Source: vTeam RBAC documentation - docs/rbac-permission-matrix.md)

**Available Roles:**

1. **view** - Read-only access to sessions and results
2. **edit** - Create sessions, modify non-security settings
3. **admin** - Full control including secrets and permissions

**Grant Access to Team Member:**

```bash
# Add user with 'edit' role
oc policy add-role-to-user edit teammate-username -n $(oc project -q)

# Add user with 'view' role (read-only)
oc policy add-role-to-user view auditor-username -n $(oc project -q)

# Verify role bindings
oc get rolebindings -n $(oc project -q)
```

**Create Service Account for Automation:**

```bash
# Create service account with minimal permissions
oc create sa workflow-automation -n $(oc project -q)

# Grant only necessary permissions
oc policy add-role-to-user edit \
  system:serviceaccount:$(oc project -q):workflow-automation \
  -n $(oc project -q)

# Get service account token (for CI/CD)
oc sa get-token workflow-automation -n $(oc project -q)
```

**Principle Applied: Least Privilege**

- ✅ Users get minimum necessary permissions
- ✅ Service accounts isolated per purpose
- ✅ Read-only accounts for auditing
- ✅ No admin access unless required

**✅ Checkpoint**: RBAC configured with least privilege principle

---

## Part 2: Production Deployment (25 minutes)

### Step 2.1: Deploy vTeam Platform

Deploy the platform with production-ready configuration.

(Source: vTeam README.md - Quick Start section)

**Option A: Deploy from Official Images (Recommended)**

```bash
# Clone vTeam repository
git clone https://github.com/ambient-code/vTeam.git
cd vTeam

# Deploy to your namespace
make deploy NAMESPACE=$(oc project -q)

# Wait for pods to be ready
oc get pods -n $(oc project -q) -w
```

**Option B: Deploy from Manifests Directly**

```bash
# Navigate to manifests
cd components/manifests

# Apply Custom Resource Definitions
oc apply -f crds/

# Apply RBAC
oc apply -f rbac/ -n $(oc project -q)

# Deploy services
oc apply -f deployments/ -n $(oc project -q)
oc apply -f services/ -n $(oc project -q)

# Create route for frontend
oc create route edge frontend-route \
  --service=frontend-service \
  --port=3000 \
  -n $(oc project -q)
```

**Verify Deployment:**

```bash
# Check all pods are running
oc get pods -n $(oc project -q)

# Expected output:
# NAME                        READY   STATUS    RESTARTS   AGE
# backend-...                 1/1     Running   0          2m
# frontend-...                1/1     Running   0          2m
# operator-...                1/1     Running   0          2m

# Get frontend URL
oc get route frontend-route -n $(oc project -q) \
  -o jsonpath='{.spec.host}'
```

**✅ Checkpoint**: Platform deployed and accessible

---

### Step 2.2: Configure Project Settings

Set up your project for workflow automation.

**Steps:**

1. **Access Web Interface**

   ```bash
   # Get URL and open in browser
   echo "https://$(oc get route frontend-route -n $(oc project -q) \
     -o jsonpath='{.spec.host}')"
   ```

2. **Create Project** (if not exists)

   - Click "New Project"
   - Name: `workflow-automation`
   - Description: "Director workflow augmentation - Production"
   - Click "Create"

3. **Configure Runner Secrets via UI**

   - Navigate to: Projects → workflow-automation → Settings
   - Click "Runner Secrets"
   - Add Secret:
     - Provider: Anthropic
     - Key: Reference your `anthropic-api-key` secret
   - Save

4. **Verify Secret Configuration**

   ```bash
   # Check ProjectSettings custom resource
   oc get projectsettings workflow-automation \
     -n $(oc project -q) -o yaml

   # Should show runnerSecrets configuration
   ```

**✅ Checkpoint**: Project configured with API keys

---

### Step 2.3: Deploy Your Workflow Automation

Turn your Lab 1 workflow into an automated recurring job.

**Example: Weekly Status Report Automation**

Create an automated session that runs weekly:

1. **Create Session Configuration YAML**

   ```yaml
   # weekly-report-session.yaml
   apiVersion: vteam.ambient-code/v1alpha1
   kind: AgenticSession
   metadata:
     name: weekly-status-report
     namespace: vteam-training-yourname
   spec:
     displayName: "Weekly Executive Status Report"
     prompt: |
       I need to create my weekly executive status report.

       **Context**:
       - 3 engineering teams (Platform, AI, Data)
       - Quarterly goals: Ship AI-assisted dev tools, improve reliability

       **Team Updates** (from Jira/Slack):
       [This would be dynamically populated in production]
       - Platform team: API gateway upgrade 60% complete
       - AI team: Dark mode RFE completed
       - Data team: Pipeline optimization reduced incidents 40%

       **What I need**:
       - Executive summary (3-4 paragraphs)
       - Progress against quarterly goals
       - Key risks or blockers
       - Recommended focus for next week
       - Format: Professional, concise, data-driven

       **Agents**: Parker (business context), Emma (team health),
       Lee (execution status)

     llmSettings:
       model: "claude-3-7-sonnet-latest"
       temperature: 0.7
       maxTokens: 4000

     timeout: 600
     project: workflow-automation
   ```

2. **Deploy the Session**

   ```bash
   # Apply session configuration
   oc apply -f weekly-report-session.yaml

   # Watch session execute
   oc get agenticsessions -n $(oc project -q) -w
   ```

3. **Retrieve Results**

   ```bash
   # Get session status
   oc get agenticsession weekly-status-report \
     -n $(oc project -q) -o yaml

   # View results (when completed)
   oc get agenticsession weekly-status-report \
     -n $(oc project -q) \
     -o jsonpath='{.status.result}' | jq .
   ```

**For Production: Schedule with CronJob**

```yaml
# weekly-report-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: weekly-status-report
  namespace: vteam-training-yourname
spec:
  schedule: "0 9 * * 1"  # Every Monday at 9 AM
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: workflow-automation
          containers:
          - name: trigger-session
            image: quay.io/openshift/origin-cli:latest
            command:
            - /bin/bash
            - -c
            - |
              oc apply -f /config/weekly-report-session.yaml
          restartPolicy: OnFailure
          volumes:
          - name: config
            configMap:
              name: session-config
```

**✅ Checkpoint**: Workflow deployed and automated

---

## Part 3: Monitoring & Observability (15 minutes)

### Step 3.1: Agent Observability Foundations

Understand what to monitor for AI agent operations.

(Source: IBM MCP Guide, Section 6 - Agent Observability)

**Key Monitoring Areas:**

1. **Session Metrics**
   - Success rate (completed vs failed)
   - Execution duration
   - Token usage and cost
   - Error rates by type

2. **Agent Performance**
   - Which agents are used most
   - Agent response quality patterns
   - Processing time per agent

3. **Resource Utilization**
   - Pod CPU/memory usage
   - Job queue depth
   - Storage consumption

4. **Business Metrics**
   - Time saved per workflow
   - User adoption rate
   - Workflow automation coverage

---

### Step 3.2: Set Up Basic Monitoring

Implement monitoring using OpenShift's built-in capabilities.

**View Session Metrics:**

```bash
# List all sessions with status
oc get agenticsessions -n $(oc project -q) \
  -o custom-columns=NAME:.metadata.name,\
STATUS:.status.phase,DURATION:.status.duration,\
TOKENS:.status.usage.totalTokens

# Get session logs
oc logs -l app=claude-code-runner -n $(oc project -q) --tail=100

# Watch for errors
oc get events -n $(oc project -q) --sort-by='.lastTimestamp' | \
  grep -i error
```

**Monitor Resource Usage:**

```bash
# Pod resource consumption
oc adm top pods -n $(oc project -q)

# Check for resource constraints
oc describe pod -l app=claude-code-runner -n $(oc project -q) | \
  grep -A 5 "Limits\|Requests"
```

**Set Up Alerts (OpenShift Monitoring):**

```yaml
# session-failure-alert.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: agentic-session-alerts
  namespace: vteam-training-yourname
spec:
  groups:
  - name: agentic-sessions
    interval: 30s
    rules:
    - alert: HighSessionFailureRate
      expr: |
        rate(agenticsession_failures_total[5m]) > 0.1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High failure rate for agentic sessions"
        description: "More than 10% of sessions failing"

    - alert: SessionTimeoutExceeded
      expr: |
        agenticsession_duration_seconds > 600
      labels:
        severity: warning
      annotations:
        summary: "Session exceeded timeout threshold"
```

**✅ Checkpoint**: Basic monitoring configured

---

### Step 3.3: Implement Audit Logging

Track all AI operations for compliance and debugging.

**Enable Session Audit Trail:**

```bash
# View session history
oc get agenticsessions -n $(oc project -q) \
  --sort-by=.metadata.creationTimestamp

# Export session audit log
oc get agenticsessions -n $(oc project -q) -o json | \
  jq '.items[] | {
    name: .metadata.name,
    created: .metadata.creationTimestamp,
    user: .metadata.annotations["openshift.io/requester"],
    prompt: .spec.prompt,
    status: .status.phase,
    tokens: .status.usage.totalTokens,
    cost: .status.cost
  }' > session-audit.json
```

**Track Who Did What:**

```bash
# View RBAC audit trail
oc get events -n $(oc project -q) \
  --field-selector reason=PolicyRule | \
  grep -i "rolebinding\|role"

# Monitor secret access
oc adm policy who-can get secret anthropic-api-key \
  -n $(oc project -q)
```

**Production Audit Logging:**

For production, integrate with centralized logging:

```yaml
# Forward logs to external SIEM
apiVersion: logging.openshift.io/v1
kind: ClusterLogForwarder
metadata:
  name: instance
  namespace: openshift-logging
spec:
  outputs:
  - name: siem
    type: syslog
    url: 'tcp://siem.example.com:514'
  pipelines:
  - name: audit-logs
    inputRefs:
    - audit
    outputRefs:
    - siem
```

**✅ Checkpoint**: Audit logging implemented

---

### Step 3.4: Cost Tracking and Optimization

Monitor and optimize AI API costs.

**Track Token Usage:**

```bash
# Calculate total tokens used
oc get agenticsessions -n $(oc project -q) -o json | \
  jq '[.items[].status.usage.totalTokens // 0] | add'

# Estimate monthly cost
# (Tokens * $0.003 per 1K tokens for Claude Sonnet)
```

**Cost Optimization Strategies:**

1. **Use Appropriate Models**
   - Simple tasks: Claude Haiku (faster, cheaper)
   - Complex analysis: Claude Sonnet (balanced)
   - Critical decisions: Claude Opus (most capable)

2. **Optimize Prompts**
   - Remove unnecessary context
   - Use clear, concise instructions
   - Avoid repetitive preambles

3. **Cache Common Patterns**
   - Reuse workflow templates
   - Cache agent configurations
   - Share results across team

4. **Set Budget Alerts**

   ```yaml
   # budget-alert.yaml
   apiVersion: monitoring.coreos.com/v1
   kind: PrometheusRule
   metadata:
     name: cost-alerts
   spec:
     groups:
     - name: ai-costs
       rules:
       - alert: MonthlyBudgetExceeded
         expr: |
           sum(agenticsession_cost_dollars) > 500
         annotations:
           summary: "Monthly AI budget exceeded $500"
   ```

**✅ Checkpoint**: Cost tracking implemented

---

## Production Deployment Checklist

Before going to production, verify:

### Security ✅

- [ ] All secrets stored in Kubernetes Secrets
- [ ] RBAC configured with least privilege
- [ ] No hardcoded credentials in code
- [ ] TLS enabled for all external connections
- [ ] Network policies defined
- [ ] Audit logging enabled
- [ ] Incident response plan documented

### Reliability ✅

- [ ] Resource limits set on all pods
- [ ] Health checks configured
- [ ] Auto-scaling policies defined
- [ ] Backup and recovery tested
- [ ] Disaster recovery plan documented
- [ ] High availability for critical components

### Observability ✅

- [ ] Metrics collection configured
- [ ] Logging aggregation set up
- [ ] Alerts defined for critical events
- [ ] Dashboards created for operations team
- [ ] On-call rotation established

### Operations ✅

- [ ] Runbook created for common issues
- [ ] Key rotation procedure documented
- [ ] Update/patching process defined
- [ ] Team trained on operations
- [ ] Support escalation paths clear

---

## Troubleshooting Guide

### Issue: Session Fails to Start

**Symptoms:**
- Session stuck in "Pending" state
- No pods created

**Diagnosis:**

```bash
# Check operator logs
oc logs -l app=vteam-operator -n $(oc project -q) --tail=50

# Check RBAC permissions
oc auth can-i create jobs -n $(oc project -q)

# Verify CRDs installed
oc get crd agenticsessions.vteam.ambient-code
```

**Solutions:**
1. Verify operator is running: `oc get pods -l app=vteam-operator`
2. Check RBAC: Ensure operator has job creation permissions
3. Review operator logs for specific errors

---

### Issue: API Key Not Found

**Symptoms:**
- Session fails with "API key not found" error
- Runner pod crashes

**Diagnosis:**

```bash
# Verify secret exists
oc get secret anthropic-api-key -n $(oc project -q)

# Check ProjectSettings configuration
oc get projectsettings -n $(oc project -q) -o yaml

# Check runner pod logs
oc logs -l app=claude-code-runner --tail=20
```

**Solutions:**
1. Recreate secret with correct name
2. Update ProjectSettings to reference correct secret
3. Verify secret is in same namespace as session

---

### Issue: High Costs

**Symptoms:**
- Unexpected API bills
- Token usage higher than expected

**Diagnosis:**

```bash
# Identify expensive sessions
oc get agenticsessions -n $(oc project -q) -o json | \
  jq -r '.items[] | "\(.metadata.name): \(.status.usage.totalTokens)"' | \
  sort -t: -k2 -nr | head -10
```

**Solutions:**
1. Review prompts for unnecessary verbosity
2. Use cheaper models for simple tasks (Haiku vs Sonnet)
3. Implement prompt caching
4. Set token limits: `maxTokens: 2000`

---

## Key Learnings 📚

After completing this lab, you should understand:

1. **IBM SOLUTION Framework**: How to apply enterprise security principles
   to AI agents
2. **Secrets Management**: Kubernetes-native secure credential storage
3. **RBAC**: Least privilege access control for teams
4. **Monitoring**: What to observe for AI agent operations
5. **Production Readiness**: Checklist for enterprise deployment

---

## Next Steps 🔍

**Immediate:**
- Run your workflow automation in production for 1 week
- Monitor metrics and gather usage data
- Iterate on prompts based on results
- Share success metrics with stakeholders

**Advanced:**
- Set up scheduled workflows (CronJobs)
- Integrate with existing CI/CD pipelines
- Build custom dashboards for your workflows
- Contribute improvements back to vTeam platform

**Scaling:**
- Expand to additional workflows
- Create team-wide agent libraries
- Implement advanced monitoring (distributed tracing)
- Build self-service platform for your organization

---

## Success Criteria ✅

You've successfully completed Lab 2 when:

- [ ] Platform deployed to OpenShift with proper RBAC
- [ ] API keys securely managed as Kubernetes Secrets
- [ ] Lab 1 workflow running as automated session
- [ ] Basic monitoring and alerting configured
- [ ] Audit logging enabled and tested
- [ ] Production deployment checklist completed
- [ ] Understand IBM SOLUTION security framework

**Congratulations!** You now have enterprise-ready AI workflow automation!

---

## Additional Resources

**IBM Security Framework:**
- IBM Guide to Architecting Secure Enterprise AI Agents with MCP
- Section 4: SOLUTION Framework
- Section 5: MCP Gateway Pattern
- Section 6: Agent Observability

**Platform Documentation:**
- vTeam GitHub: <https://github.com/ambient-code/vTeam>
- Deployment Guide: docs/OPENSHIFT_DEPLOY.md
- RBAC Matrix: docs/rbac-permission-matrix.md
- OAuth Setup: docs/OPENSHIFT_OAUTH.md

**OpenShift Security:**
- Managing Secrets: <https://docs.openshift.com/container-platform/latest/nodes/pods/nodes-pods-secrets.html>
- RBAC: <https://docs.openshift.com/container-platform/latest/authentication/using-rbac.html>
- Network Policies: <https://docs.openshift.com/container-platform/latest/networking/network_policy/about-network-policy.html>

**Monitoring & Observability:**
- OpenShift Monitoring: <https://docs.openshift.com/container-platform/latest/monitoring/monitoring-overview.html>
- Prometheus Alerts: <https://prometheus.io/docs/alerting/latest/overview/>
