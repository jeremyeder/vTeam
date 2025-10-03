# vTeam Multi-Project Platform (MPP) Deployment Guide

## Overview

This directory contains Kubernetes RBAC role definitions for deploying vTeam in a multi-project platform (MPP) configuration. These roles enable project-level access control for the vTeam Ambient Agentic Runner platform, allowing teams to manage AI-powered agentic sessions with appropriate permissions.

## Table of Contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [RBAC Roles](#rbac-roles)
- [Deployment Guide](#deployment-guide)
- [RBAC Permission Matrix](#rbac-permission-matrix)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)

## Architecture

The vTeam MPP deployment uses a three-tier RBAC model that aligns with typical software team roles:

```
┌─────────────────────────────────────────────────────────────┐
│                   vTeam Platform Components                  │
├─────────────────────────────────────────────────────────────┤
│  Frontend (NextJS) │ Backend API (Go) │ Operator (Go)       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Project Namespaces                        │
│  (e.g., vteam--project1, vteam--project2)                   │
├─────────────────────────────────────────────────────────────┤
│  • AgenticSessions (CRD)                                     │
│  • ProjectSettings (CRD)                                     │
│  • RFEWorkflows (CRD)                                        │
│  • Secrets (Runner API keys, Git credentials)               │
│  • Jobs (Session execution)                                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     RBAC Roles (MPP)                         │
├─────────────────────────────────────────────────────────────┤
│  Admin    │ Full project management + RBAC                  │
│  Edit     │ Session/workflow management                     │
│  View     │ Read-only monitoring                            │
└─────────────────────────────────────────────────────────────┘
```

### Component Overview

| Component | Technology | Description |
|-----------|------------|-------------|
| **Frontend** | NextJS + Shadcn UI | User interface for managing agentic sessions and workflows |
| **Backend API** | Go + Gin | REST API for managing Kubernetes Custom Resources with multi-tenant support |
| **Operator** | Go | Kubernetes operator that watches Custom Resources and creates execution Jobs |
| **Claude Code Runner** | Python + Claude CLI | Pod that executes AI tasks with multi-agent collaboration |

### Custom Resource Definitions (CRDs)

- **AgenticSession**: Represents an AI-powered task execution session
- **ProjectSettings**: Project-level configuration (runner secrets, Git settings)
- **RFEWorkflow**: Multi-step workflow for Request for Enhancement (RFE) management

## Prerequisites

### Required Components

Before deploying these RBAC roles, ensure the vTeam platform is installed:

1. **vTeam Platform Deployment**: Deploy core vTeam components first
   ```bash
   # Deploy from project root
   make deploy

   # Or deploy to custom namespace
   make deploy NAMESPACE=ambient-code
   ```

2. **OpenShift/Kubernetes Cluster**
   - OpenShift 4.12+ or Kubernetes 1.28+
   - Cluster admin access (for creating ClusterRoles and namespaces)
   - `oc` or `kubectl` CLI configured

3. **Custom Resource Definitions**: Ensure vTeam CRDs are installed
   - AgenticSession CRD
   - ProjectSettings CRD
   - RFEWorkflow CRD

### Verification

Verify the platform is ready:

```bash
# Check CRDs are installed
oc get crd | grep vteam.ambient-code

# Expected output:
# agenticsessions.vteam.ambient-code
# projectsettings.vteam.ambient-code
# rfeworkflows.vteam.ambient-code

# Check platform components are running
oc get pods -n ambient-code

# Expected pods:
# backend-api-...         (Running)
# agentic-operator-...    (Running)
# frontend-...            (Running)
```

## RBAC Roles

### Role Hierarchy

| Role | Use Case | Typical Users | Permission Level |
|------|----------|---------------|------------------|
| **ambient-project-admin** | Project owners, team leads | Senior engineers, managers | Full control + user management |
| **ambient-project-edit** | Active developers | Engineers, data scientists | Session/workflow management |
| **ambient-project-view** | Observers, auditors | Stakeholders, security teams | Read-only monitoring |

### Role Definitions

#### 1. ambient-project-admin

**File**: `roles/ambient-project-admin.yaml`

Full project management including RBAC administration.

**Key Permissions**:
- ✅ Full CRUD on AgenticSessions, ProjectSettings, RFEWorkflows
- ✅ Manage Secrets and ConfigMaps (API keys, Git credentials)
- ✅ Manage ServiceAccounts (runner access keys)
- ✅ Create/delete Roles and RoleBindings (user management)
- ✅ Job deletion (cleanup failed sessions)
- ✅ Pod and log monitoring
- ✅ Namespace/Project management (OpenShift)

**Use Cases**:
- Initialize new projects
- Grant access to team members
- Manage runner API keys and secrets
- Configure Git integration
- Clean up failed sessions

**Security Note**: This role can grant permissions to other users. Only assign to trusted team leads.

#### 2. ambient-project-edit

**File**: `roles/ambient-project-edit.yaml`

Session and workflow management for active development.

**Key Permissions**:
- ✅ Full CRUD on AgenticSessions and RFEWorkflows
- ✅ Read ProjectSettings (access runner configuration)
- ✅ Create Secrets (provision runner tokens during session creation)
- ✅ Read ConfigMaps (access Git configuration)
- ✅ Delete Jobs (stop running sessions)
- ✅ Pod and log monitoring
- ✅ Create/manage ServiceAccounts and Roles (for session provisioning)
- ✅ Create ServiceAccount tokens (for runner authentication)

**Use Cases**:
- Create and manage agentic sessions
- Create and manage RFE workflows
- Stop running sessions
- Monitor session execution and logs
- Provision runner access keys

**Restrictions**:
- Cannot modify ProjectSettings (read-only)
- Cannot delete RBAC resources (can create for sessions, not delete)

#### 3. ambient-project-view

**File**: `roles/ambient-project-view.yaml`

Read-only access for monitoring and auditing.

**Key Permissions**:
- ✅ Read AgenticSessions, ProjectSettings, RFEWorkflows
- ✅ View Jobs (session execution status)
- ✅ View Pods and logs (monitor session progress)

**Use Cases**:
- Monitor team activity
- Audit session execution
- Review workflow progress
- Troubleshoot issues (read-only)

**Restrictions**:
- Cannot create, modify, or delete any resources
- Cannot access Secrets or ConfigMaps

## Deployment Guide

### Step 1: Create Project Namespace

Create a dedicated namespace for your project:

```bash
# Replace 'project-name' with your project identifier
export PROJECT_NAME="vteam--project1"

# Create namespace
oc create namespace $PROJECT_NAME

# Label as vTeam-managed (required for operator)
oc label namespace $PROJECT_NAME \
  ambient-code.io/managed=true \
  ambient-code.io/project=$PROJECT_NAME
```

### Step 2: Deploy RBAC Roles

Deploy the three RBAC roles to your project namespace:

```bash
# Update namespace in role manifests
for role in roles/*.yaml; do
  sed "s/namespace: vteam--test1/namespace: $PROJECT_NAME/g" $role | oc apply -f -
done

# Verify roles are created
oc get roles -n $PROJECT_NAME
```

Expected output:
```
NAME                      CREATED AT
ambient-project-admin     2025-10-03T...
ambient-project-edit      2025-10-03T...
ambient-project-view      2025-10-03T...
```

### Step 3: Grant Access to Users

Create RoleBindings to grant users access:

```bash
# Grant admin access to project owner
oc create rolebinding project-admin-binding \
  -n $PROJECT_NAME \
  --role=ambient-project-admin \
  --user=alice@example.com

# Grant edit access to developers
oc create rolebinding project-edit-binding \
  -n $PROJECT_NAME \
  --role=ambient-project-edit \
  --group=engineering-team

# Grant view access to stakeholders
oc create rolebinding project-view-binding \
  -n $PROJECT_NAME \
  --role=ambient-project-view \
  --group=stakeholders
```

### Step 4: Initialize Project Settings

The operator will automatically create a default ProjectSettings resource when it detects the new namespace. Verify:

```bash
# Check ProjectSettings was created
oc get projectsettings -n $PROJECT_NAME

# View default settings
oc get projectsettings default -n $PROJECT_NAME -o yaml
```

### Step 5: Configure Runner Secrets

Project admins should configure runner secrets via the web UI:

1. Access vTeam web interface: `https://vteam-frontend.apps.cluster.example.com`
2. Switch to your project namespace
3. Navigate to **Settings → Runner Secrets**
4. Add Anthropic API key:
   - Secret Name: `anthropic-api-key`
   - Key: `ANTHROPIC_API_KEY`
   - Value: `sk-ant-...`

Alternatively, configure via CLI (admin only):

```bash
# Create runner secret for Anthropic API
oc create secret generic anthropic-api-key \
  -n $PROJECT_NAME \
  --from-literal=ANTHROPIC_API_KEY=sk-ant-your-key-here

# Update ProjectSettings to reference the secret
oc patch projectsettings default -n $PROJECT_NAME --type=merge -p '
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

### Step 6: Verify Deployment

Test the deployment with a sample agentic session:

```bash
# Create a test session (requires 'edit' or 'admin' role)
cat <<EOF | oc apply -f -
apiVersion: vteam.ambient-code/v1
kind: AgenticSession
metadata:
  name: test-session
  namespace: $PROJECT_NAME
spec:
  prompt: "List the files in the current directory and explain the project structure"
  model: "claude-sonnet-4"
  timeout: 300
EOF

# Monitor session status
oc get agenticsessions -n $PROJECT_NAME -w

# View session logs (after job starts)
oc logs -f job/test-session-job -n $PROJECT_NAME
```

## RBAC Permission Matrix

### Complete Permission Comparison

| Resource Type | Admin | Edit | View | Notes |
|--------------|-------|------|------|-------|
| **Custom Resources** |
| AgenticSessions | Full CRUD + Status | Full CRUD + Status | Read-only | Sessions and their status |
| ProjectSettings | Full CRUD + Status | Read-only | Read-only | Project configuration |
| RFEWorkflows | Full CRUD + Status | Full CRUD + Status | Read-only | Workflow definitions |
| **Core Resources** |
| Secrets | Full CRUD | Create only | None | API keys, credentials |
| ConfigMaps | Full CRUD | Get only | None | Git configuration |
| ServiceAccounts | Full CRUD + Token | Create, Update, Patch, Get, List + Token | None | Runner authentication |
| **Workload Resources** |
| Jobs | Get, List, Watch, Delete | Get, List, Watch, Delete | Get, List, Watch | Session execution |
| Pods | Get, List, Watch | Get, List, Watch | Get, List, Watch | Session monitoring |
| Pods/log | Get | Get | Get | Session logs |
| **RBAC Resources** |
| Roles | Full CRUD | Create, Update, Patch, Delete | None | Permission management |
| RoleBindings | Full CRUD | Create, Update, Patch, Delete | None | User access grants |
| **Namespace Resources** |
| Namespaces | Full CRUD | None | None | Project creation (OpenShift) |
| Projects (OpenShift) | Full CRUD | None | None | Project management |

### Permission Details by Operation

#### AgenticSessions

| Operation | Admin | Edit | View | API Endpoint |
|-----------|-------|------|------|-------------|
| List sessions | ✅ | ✅ | ✅ | `GET /api/projects/:project/sessions` |
| Get session | ✅ | ✅ | ✅ | `GET /api/projects/:project/sessions/:id` |
| Create session | ✅ | ✅ | ❌ | `POST /api/projects/:project/sessions` |
| Update session | ✅ | ✅ | ❌ | `PATCH /api/projects/:project/sessions/:id` |
| Delete session | ✅ | ✅ | ❌ | `DELETE /api/projects/:project/sessions/:id` |
| Update status | ✅ | ✅ | ❌ | Operator only |

#### ProjectSettings

| Operation | Admin | Edit | View | API Endpoint |
|-----------|-------|------|------|-------------|
| Get settings | ✅ | ✅ | ✅ | `GET /api/projects/:project/settings` |
| Update settings | ✅ | ❌ | ❌ | `PUT /api/projects/:project/settings` |
| Manage runner secrets | ✅ | ❌ | ❌ | `POST /api/projects/:project/settings/runner-secrets` |

#### RFEWorkflows

| Operation | Admin | Edit | View | API Endpoint |
|-----------|-------|------|------|-------------|
| List workflows | ✅ | ✅ | ✅ | `GET /api/projects/:project/workflows` |
| Get workflow | ✅ | ✅ | ✅ | `GET /api/projects/:project/workflows/:id` |
| Create workflow | ✅ | ✅ | ❌ | `POST /api/projects/:project/workflows` |
| Delete workflow | ✅ | ✅ | ❌ | `DELETE /api/projects/:project/workflows/:id` |
| Link session to workflow | ✅ | ✅ | ❌ | `POST /api/projects/:project/workflows/:id/sessions` |

## Troubleshooting

### Common Issues

#### 1. Permission Denied Errors

**Symptom**: `Error: User 'alice@example.com' cannot create resource 'agenticsessions' in namespace 'vteam--project1'`

**Diagnosis**:
```bash
# Check user's permissions
oc auth can-i create agenticsessions -n vteam--project1 --as=alice@example.com

# List user's role bindings
oc get rolebindings -n vteam--project1 -o yaml | grep -A 10 alice@example.com
```

**Solutions**:
1. Verify RoleBinding exists and references correct user/group:
   ```bash
   oc get rolebindings -n vteam--project1
   ```
2. Check RoleBinding subject matches user identity:
   ```bash
   oc describe rolebinding project-edit-binding -n vteam--project1
   ```
3. Grant appropriate role:
   ```bash
   oc create rolebinding alice-edit \
     -n vteam--project1 \
     --role=ambient-project-edit \
     --user=alice@example.com
   ```

#### 2. Sessions Not Starting

**Symptom**: AgenticSession created but Job never starts

**Diagnosis**:
```bash
# Check session status
oc get agenticsessions -n vteam--project1

# Check operator logs
oc logs -f deployment/agentic-operator -n ambient-code

# Check for events
oc get events -n vteam--project1 --sort-by='.lastTimestamp'
```

**Common Causes**:
1. **Missing runner secrets**:
   ```bash
   # Check ProjectSettings references secrets
   oc get projectsettings default -n vteam--project1 -o yaml

   # Verify secrets exist
   oc get secrets -n vteam--project1
   ```

   **Solution**: Create runner secret (see Step 5 in Deployment Guide)

2. **Namespace not labeled**:
   ```bash
   # Check namespace labels
   oc get namespace vteam--project1 --show-labels
   ```

   **Solution**: Add required labels:
   ```bash
   oc label namespace vteam--project1 \
     ambient-code.io/managed=true \
     ambient-code.io/project=vteam--project1
   ```

3. **Operator not watching namespace**:
   ```bash
   # Check operator is running
   oc get pods -n ambient-code | grep operator

   # Check operator environment
   oc get deployment agentic-operator -n ambient-code -o yaml | grep -A 5 env
   ```

#### 3. Job Fails Immediately

**Symptom**: Job pod fails with error status

**Diagnosis**:
```bash
# List failed jobs
oc get jobs -n vteam--project1

# Get job details
oc describe job <job-name> -n vteam--project1

# Check pod logs
oc logs <pod-name> -n vteam--project1
```

**Common Causes**:
1. **Invalid API key**:
   ```
   Error: anthropic.AuthenticationError: Invalid API key
   ```

   **Solution**: Update API key in secret:
   ```bash
   oc delete secret anthropic-api-key -n vteam--project1
   oc create secret generic anthropic-api-key \
     -n vteam--project1 \
     --from-literal=ANTHROPIC_API_KEY=sk-ant-valid-key
   ```

2. **Missing image**:
   ```
   Failed to pull image "quay.io/ambient_code/vteam_claude_runner:latest": ImagePullBackOff
   ```

   **Solution**: Check operator configuration:
   ```bash
   oc get deployment agentic-operator -n ambient-code -o yaml | grep AMBIENT_CODE_RUNNER_IMAGE
   ```

3. **Insufficient resources**:
   ```
   0/3 nodes are available: 3 Insufficient memory
   ```

   **Solution**: Adjust resource requests in operator configuration or provision more cluster capacity

#### 4. Cannot Access Web UI

**Symptom**: Web interface not accessible or shows authentication errors

**Diagnosis**:
```bash
# Check frontend pod status
oc get pods -n ambient-code | grep frontend

# Check frontend logs
oc logs -f deployment/frontend -n ambient-code

# Check route configuration
oc get route frontend-route -n ambient-code
```

**Solutions**:
1. **Route not created**:
   ```bash
   # Create route manually
   oc create route edge frontend-route \
     --service=frontend-service \
     --port=3000 \
     -n ambient-code
   ```

2. **OAuth not configured** (OpenShift):
   ```bash
   # Run OAuth setup
   cd components/manifests
   ./deploy.sh secrets
   ```

3. **Port forwarding fallback**:
   ```bash
   oc port-forward svc/frontend-service 3000:3000 -n ambient-code
   # Access via http://localhost:3000
   ```

#### 5. ProjectSettings Not Created

**Symptom**: `Error: projectsettings.vteam.ambient-code "default" not found`

**Diagnosis**:
```bash
# Check if namespace is managed
oc get namespace vteam--project1 --show-labels

# Check operator logs for errors
oc logs deployment/agentic-operator -n ambient-code | grep project1
```

**Solution**:
```bash
# Manually create ProjectSettings
cat <<EOF | oc apply -f -
apiVersion: vteam.ambient-code/v1
kind: ProjectSettings
metadata:
  name: default
  namespace: vteam--project1
spec:
  runnerSecretsConfig:
    secretRefs: []
EOF
```

### Verification Commands

```bash
# 1. Check all RBAC roles are deployed
oc get roles -n $PROJECT_NAME | grep ambient-project

# Expected output:
# ambient-project-admin
# ambient-project-edit
# ambient-project-view

# 2. Verify user permissions
oc auth can-i create agenticsessions -n $PROJECT_NAME --as=user@example.com

# 3. Check Custom Resources
oc get agenticsessions,projectsettings,rfeworkflows -n $PROJECT_NAME

# 4. Monitor operator activity
oc logs -f deployment/agentic-operator -n ambient-code

# 5. Check recent events
oc get events -n $PROJECT_NAME --sort-by='.lastTimestamp' | tail -20

# 6. Verify runner secrets are configured
oc get projectsettings default -n $PROJECT_NAME -o jsonpath='{.spec.runnerSecretsConfig.secretRefs[*].name}'

# 7. Test end-to-end session creation
cat <<EOF | oc apply -f -
apiVersion: vteam.ambient-code/v1
kind: AgenticSession
metadata:
  name: health-check
  namespace: $PROJECT_NAME
spec:
  prompt: "Echo 'Hello from vTeam'"
  model: "claude-sonnet-4"
  timeout: 60
EOF

# Watch session progress
oc get agenticsessions health-check -n $PROJECT_NAME -w
```

## Security Considerations

### Principle of Least Privilege

1. **Role Assignment**:
   - Only grant `ambient-project-admin` to trusted team leads
   - Most developers should have `ambient-project-edit`
   - Use `ambient-project-view` for stakeholders and auditors

2. **Secret Management**:
   - Admin role is required to create/update runner secrets
   - Edit role can create secrets during session provisioning (scoped)
   - Never commit secrets to Git repositories

3. **Namespace Isolation**:
   - Each project should have dedicated namespace
   - RBAC roles are namespace-scoped (not cluster-wide)
   - Projects cannot access each other's resources

### API Key Security

**Best Practices**:
1. Rotate API keys regularly
2. Use separate API keys per project (cost tracking and security isolation)
3. Store keys in Kubernetes Secrets (encrypted at rest)
4. Monitor API usage via Anthropic dashboard
5. Revoke keys immediately if compromised

**Key Rotation Procedure**:
```bash
# 1. Create new secret with rotated key
oc create secret generic anthropic-api-key-new \
  -n $PROJECT_NAME \
  --from-literal=ANTHROPIC_API_KEY=sk-ant-new-key

# 2. Update ProjectSettings to reference new secret
oc patch projectsettings default -n $PROJECT_NAME --type=merge -p '
{
  "spec": {
    "runnerSecretsConfig": {
      "secretRefs": [
        {
          "name": "anthropic-api-key-new",
          "keys": ["ANTHROPIC_API_KEY"]
        }
      ]
    }
  }
}'

# 3. Delete old secret after verification
oc delete secret anthropic-api-key -n $PROJECT_NAME
```

### Service Account Tokens

The `ambient-project-edit` role can create ServiceAccount tokens for runner authentication. This is necessary for session provisioning but should be monitored:

```bash
# Audit ServiceAccounts in project
oc get serviceaccounts -n $PROJECT_NAME

# Check for unexpected ServiceAccounts
oc get serviceaccounts -n $PROJECT_NAME -o json | \
  jq '.items[] | select(.metadata.labels."ambient-code.io/access-key" != "true")'
```

### Network Policies (Recommended)

For additional security, implement network policies to restrict pod-to-pod communication:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-runner-egress
  namespace: vteam--project1
spec:
  podSelector:
    matchLabels:
      app: ambient-code-runner
  policyTypes:
  - Egress
  egress:
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          name: openshift-dns
    ports:
    - protocol: UDP
      port: 53
  # Allow Anthropic API
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443
```

### Audit Logging

Enable audit logging to track RBAC changes and session creation:

```bash
# View recent RBAC changes
oc get events -n $PROJECT_NAME --field-selector reason=RoleBindingCreated

# Track AgenticSession creation
oc get events -n $PROJECT_NAME --field-selector involvedObject.kind=AgenticSession

# Monitor secret access (requires cluster audit logs)
# Contact your cluster administrator for audit log access
```

## Related Documentation

- **Main README**: [../README.md](../README.md) - vTeam platform overview
- **Deployment Guide**: [../docs/OPENSHIFT_DEPLOY.md](../docs/OPENSHIFT_DEPLOY.md) - Platform deployment
- **RBAC Audit**: [../docs/rbac-permission-matrix.md](../docs/rbac-permission-matrix.md) - Complete permission matrix
- **OAuth Setup**: [../docs/OPENSHIFT_OAUTH.md](../docs/OPENSHIFT_OAUTH.md) - Authentication configuration
- **Operator Documentation**: [../components/operator/](../components/operator/) - Operator internals

## Support

For issues and questions:
- **GitHub Issues**: [vTeam Issues](https://github.com/jeremyeder/vTeam/issues)
- **Platform Logs**: `oc logs deployment/agentic-operator -n ambient-code`
- **API Logs**: `oc logs deployment/backend-api -n ambient-code`

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.
