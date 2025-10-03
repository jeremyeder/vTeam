# MPP Staging Environment Deployment Guide

This guide provides instructions for deploying vTeam to the MPP staging environment (`vteam--test1` namespace).

## Quick Start

### Option 1: Automated Deployment (Recommended)

Use the deployment script for automated setup:

```bash
# From project root
./vteam-mpp-deployment/scripts/deploy-staging.sh
```

The script will:
- ✅ Create the `vteam--test1` namespace
- ✅ Apply required labels for vTeam operator management
- ✅ Deploy RBAC roles (admin, edit, view)
- ✅ Create default ProjectSettings
- ✅ Verify vTeam platform components

### Option 2: GitHub Actions Workflow

Trigger the automated deployment workflow:

1. Go to **Actions** → **Deploy to MPP Staging (vteam--test1)**
2. Click **Run workflow**
3. Configure options:
   - **namespace**: Target namespace (default: `vteam--test1`)
   - **verify_only**: Set to `true` to only run verification checks
4. Click **Run workflow**

**Prerequisites**: The workflow requires these repository secrets:
- `MPP_STAGING_SERVER`: OpenShift cluster API URL
- `MPP_STAGING_TOKEN`: Service account token with cluster access

### Option 3: Manual Deployment

Follow the steps in [../vteam-mpp-deployment/00-README.md](./00-README.md) for detailed manual deployment.

## Prerequisites

### Required Components

1. **vTeam Platform**: Must be deployed to `ambient-code` namespace first
   ```bash
   make deploy
   ```

2. **Cluster Access**:
   - OpenShift cluster with admin permissions
   - `oc` CLI configured and authenticated
   - `kustomize` installed

3. **API Keys**:
   - Anthropic API key for Claude Code runner

### Verification

Check that prerequisites are met:

```bash
# Verify cluster access
oc whoami

# Check vTeam platform is running
oc get pods -n ambient-code

# Check CRDs are installed
oc get crd | grep vteam.ambient-code
```

Expected output:
```
agenticsessions.vteam.ambient-code
projectsettings.vteam.ambient-code
rfeworkflows.vteam.ambient-code
```

## Deployment Steps

### Step 1: Deploy to Staging

Run the deployment script:

```bash
# Use default namespace (vteam--test1)
./vteam-mpp-deployment/scripts/deploy-staging.sh

# Or specify custom namespace
NAMESPACE=vteam--custom ./vteam-mpp-deployment/scripts/deploy-staging.sh
```

The script will output progress and final status.

### Step 2: Configure Runner Secrets

**Option A - Via CLI** (requires admin role):

```bash
# Create Anthropic API key secret
oc create secret generic anthropic-api-key \
  -n vteam--test1 \
  --from-literal=ANTHROPIC_API_KEY=sk-ant-your-actual-key-here

# Update ProjectSettings to reference the secret
oc patch projectsettings default -n vteam--test1 --type=merge -p '
{
  "spec": {
    "runnerSecretsConfig": {
      "secretRefs": [
        {
          "name": "anthropic-api-key",
          "keys": ["ANTHROPIC_API_KEY"]
        }
      ]
    }
  }
}'
```

**Option B - Via Web UI**:

1. Access vTeam frontend (get URL from route)
2. Switch to project: `vteam--test1`
3. Navigate to **Settings** → **Runner Secrets**
4. Add new secret:
   - **Name**: `anthropic-api-key`
   - **Key**: `ANTHROPIC_API_KEY`
   - **Value**: `sk-ant-your-key`

### Step 3: Grant User Access (Optional)

Grant access to team members:

```bash
# Grant edit access (can create/manage sessions)
oc create rolebinding alice-edit \
  -n vteam--test1 \
  --role=ambient-project-edit \
  --user=alice@example.com

# Grant admin access (full project management)
oc create rolebinding bob-admin \
  -n vteam--test1 \
  --role=ambient-project-admin \
  --user=bob@example.com

# Grant view access (read-only monitoring)
oc create rolebinding stakeholders-view \
  -n vteam--test1 \
  --role=ambient-project-view \
  --group=stakeholder-team
```

### Step 4: Verify Deployment

Run the verification script:

```bash
./vteam-mpp-deployment/scripts/verify-deployment.sh
```

Expected output:
```
✅ All checks passed!
```

### Step 5: Test End-to-End

Create a test agentic session:

```bash
./vteam-mpp-deployment/scripts/test-session.sh
```

This will:
- Create a test AgenticSession
- Monitor job creation and execution
- Stream pod logs in real-time
- Display final session status

## Verification Checklist

Use this checklist to verify successful deployment:

- [ ] Namespace `vteam--test1` exists and is labeled
- [ ] Three RBAC roles deployed (`ambient-project-{admin,edit,view}`)
- [ ] vTeam platform pods running in `ambient-code` namespace
- [ ] vTeam CRDs installed (agenticsessions, projectsettings, rfeworkflows)
- [ ] Default ProjectSettings created in `vteam--test1`
- [ ] Runner secrets configured (Anthropic API key)
- [ ] User access granted (at least one admin)
- [ ] Test session completes successfully

## Monitoring & Troubleshooting

### Check Deployment Status

```bash
# Overall namespace status
oc get all -n vteam--test1

# RBAC roles
oc get roles -n vteam--test1

# Custom resources
oc get agenticsessions,projectsettings,rfeworkflows -n vteam--test1

# Recent events
oc get events -n vteam--test1 --sort-by='.lastTimestamp' | tail -20
```

### Check Platform Health

```bash
# Platform components
oc get pods -n ambient-code

# Operator logs
oc logs -f deployment/agentic-operator -n ambient-code

# Backend API logs
oc logs -f deployment/backend-api -n ambient-code
```

### Common Issues

#### 1. Sessions Not Starting

**Symptom**: AgenticSession created but Job never appears

**Diagnosis**:
```bash
# Check if namespace is labeled for operator
oc get namespace vteam--test1 --show-labels

# Check operator logs for errors
oc logs deployment/agentic-operator -n ambient-code | grep test1

# Check ProjectSettings
oc get projectsettings default -n vteam--test1 -o yaml
```

**Solutions**:
- Ensure namespace has `ambient-code.io/managed=true` label
- Verify ProjectSettings exists with runner secrets configured
- Check operator is running and watching namespaces

#### 2. Job Fails with Authentication Error

**Symptom**: Pod logs show `AuthenticationError: Invalid API key`

**Solution**:
```bash
# Verify secret exists
oc get secret anthropic-api-key -n vteam--test1

# Check secret value (first few characters)
oc get secret anthropic-api-key -n vteam--test1 -o jsonpath='{.data.ANTHROPIC_API_KEY}' | base64 -d | head -c 20

# Recreate secret with correct key
oc delete secret anthropic-api-key -n vteam--test1
oc create secret generic anthropic-api-key \
  -n vteam--test1 \
  --from-literal=ANTHROPIC_API_KEY=sk-ant-correct-key
```

#### 3. Permission Denied

**Symptom**: User cannot create sessions

**Diagnosis**:
```bash
# Check user's permissions
oc auth can-i create agenticsessions -n vteam--test1 --as=user@example.com

# List role bindings
oc get rolebindings -n vteam--test1
```

**Solution**:
```bash
# Grant edit role
oc create rolebinding user-edit \
  -n vteam--test1 \
  --role=ambient-project-edit \
  --user=user@example.com
```

#### 4. Web UI Not Accessible

**Symptom**: Cannot access vTeam frontend

**Solution**:
```bash
# Check frontend route
oc get route -n ambient-code

# Use port forwarding as fallback
oc port-forward svc/frontend-service 3000:3000 -n ambient-code
# Access via http://localhost:3000
```

## Cleanup

To remove the staging deployment:

```bash
# Delete all resources in namespace
oc delete agenticsessions,projectsettings,rfeworkflows --all -n vteam--test1

# Delete namespace
oc delete namespace vteam--test1
```

## Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `deploy-staging.sh` | Automated deployment | `./deploy-staging.sh` |
| `verify-deployment.sh` | Health checks | `./verify-deployment.sh` |
| `test-session.sh` | End-to-end test | `./test-session.sh` |

## Related Documentation

- **MPP Deployment Guide**: [00-README.md](./00-README.md) - Complete MPP deployment documentation
- **RBAC Roles**: [roles/](./roles/) - Role definitions for admin/edit/view access
- **Main README**: [../README.md](../README.md) - vTeam platform overview
- **OpenShift Deployment**: [../docs/OPENSHIFT_DEPLOY.md](../docs/OPENSHIFT_DEPLOY.md) - Platform deployment

## Support

For issues:
1. Run verification script: `./vteam-mpp-deployment/scripts/verify-deployment.sh`
2. Check operator logs: `oc logs deployment/agentic-operator -n ambient-code`
3. Review troubleshooting guide: [00-README.md#troubleshooting](./00-README.md#troubleshooting)
4. Create GitHub issue with verification output and logs
