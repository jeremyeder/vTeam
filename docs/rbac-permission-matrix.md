# RBAC Permission Matrix

## Overview

This document provides a comprehensive audit of Kubernetes API permissions used by the vTeam Ambient Agentic Runner platform. It maps all Kubernetes API calls to their required permissions and verifies that RBAC configurations grant appropriate access.

**Audit Date**: 2025-10-03
**Components Audited**: Backend API Service, Operator
**Epic**: #1, Phase: 4

## Executive Summary

### Backend API Service
- **ClusterRole**: `backend-api`
- **ServiceAccount**: `backend-sa` (namespace: ambient-code)
- **Permission Model**: User token impersonation with minimal backend SA permissions
- **Security Model**: All user-facing operations use caller's token; backend SA only for telemetry

### Operator
- **ClusterRole**: `agentic-operator`
- **ServiceAccount**: `operator-sa` (namespace: ambient-code)
- **Permission Model**: Namespace-scoped resource management with cluster-wide watching
- **Security Model**: Creates and manages per-namespace resources with strict ownership

## Backend API Service (`backend-api`)

### Current ClusterRole Definition

Location: `components/manifests/rbac/backend-clusterrole.yaml`

```yaml
rules:
# ServiceAccounts (only for updating last-used annotations on access keys)
- apiGroups: [""]
  resources: ["serviceaccounts"]
  verbs: ["get", "patch"]

# RFEWorkflow custom resources (full CRUD + status updates)
- apiGroups: ["vteam.ambient-code"]
  resources: ["rfeworkflows"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["vteam.ambient-code"]
  resources: ["rfeworkflows/status"]
  verbs: ["get", "update", "patch"]
```

### API Call Audit

#### File: `internal/middleware/auth.go`

| API Call | Resource | Verb | Permission | Status | Notes |
|----------|----------|------|------------|--------|-------|
| `CoreV1().ServiceAccounts(ns).Get()` | serviceaccounts | get | ✅ Granted | Required | Used to verify access key label before updating last-used annotation |
| `CoreV1().ServiceAccounts(ns).Patch()` | serviceaccounts | patch | ✅ Granted | Required | Updates `ambient-code.io/last-used-at` annotation for access key telemetry |
| `AuthorizationV1().SelfSubjectAccessReviews().Create()` | selfsubjectaccessreviews | create | ⚠️ Missing | Required | Permission check for project access validation |

**Finding**: Backend needs `selfsubjectaccessreviews` create permission for the ValidateProjectContext middleware (line 230).

#### File: `internal/handlers/workflows.go`

All RFEWorkflow operations use **user token impersonation** via `GetK8sClientsForRequest()`. These permissions are checked against the user's token, NOT the backend SA:

| API Call | Resource | Verb | Permission | Notes |
|----------|----------|------|------------|-------|
| `Resource(gvr).Namespace(project).List()` | rfeworkflows | list | User token | Line 35 - List workflows |
| `Resource(gvr).Namespace(project).Get()` | rfeworkflows | get | User token | Line 132 - Get workflow |
| `Resource(gvr).Namespace(project).Delete()` | rfeworkflows | delete | User token | Line 161 - Delete workflow |
| `Resource(gvr).Namespace(project).List()` | agenticsessions | list | User token | Line 189 - List workflow sessions |
| `Resource(gvr).Namespace(project).Get()` | agenticsessions | get | User token | Line 227 - Get session |
| `Resource(gvr).Namespace(project).Update()` | agenticsessions | update | User token | Line 300 - Link session to workflow |
| `Resource(gvr).Namespace(project).Update()` | agenticsessions | update | User token | Line 344 - Unlink session |

#### File: `internal/handlers/keys.go`

All operations use **user token impersonation**:

| API Call | Resource | Verb | Permission | Notes |
|----------|----------|------|------------|-------|
| `CoreV1().Secrets(project).List()` | secrets | list | User token | Line 34 - List access keys with label selector |
| `CoreV1().Secrets(project).Create()` | secrets | create | User token | Line 124 - Create access key |
| `CoreV1().Secrets(project).Get()` | secrets | get | User token | Line 155 - Get access key |
| `CoreV1().Secrets(project).Delete()` | secrets | delete | User token | Line 173 - Delete access key |

#### File: `internal/handlers/secrets.go`

All operations use **user token impersonation**:

| API Call | Resource | Verb | Permission | Notes |
|----------|----------|------|------------|-------|
| `CoreV1().Secrets(projectName).List()` | secrets | list | User token | Line 23 - List runner secrets |
| `Resource(gvr).Namespace(projectName).Get()` | projectsettings | get | User token | Line 60, 97, 132, 184 - Get project settings |
| `Resource(gvr).Namespace(projectName).Update()` | projectsettings | update | User token | Line 116 - Update runner secrets config |
| `CoreV1().Secrets(projectName).Get()` | secrets | get | User token | Line 151, 205 - Get runner secret |
| `CoreV1().Secrets(projectName).Create()` | secrets | create | User token | Line 220 - Create runner secret |
| `CoreV1().Secrets(projectName).Update()` | secrets | update | User token | Line 236 - Update runner secret |

#### File: `internal/handlers/sessions.go`

All operations use **user token impersonation**:

| API Call | Resource | Verb | Permission | Notes |
|----------|----------|------|------------|-------|
| `Resource(gvr).Namespace(project).List()` | agenticsessions | list | User token | Line 34 - List sessions |
| `Resource(gvr).Namespace(project).Create()` | agenticsessions | create | User token | Line 213 - Create session |

### Backend Findings

1. ✅ **Correct**: Backend SA permissions are minimal and only used for telemetry (ServiceAccount get/patch)
2. ✅ **Correct**: All user-facing operations properly use caller's token for authorization
3. ⚠️ **Missing**: Backend needs `selfsubjectaccessreviews` create permission for ValidateProjectContext middleware
4. ✅ **Correct**: RFEWorkflow permissions in ClusterRole are declared but not used by backend SA (user tokens handle this)
5. ⚠️ **Cleanup Opportunity**: RFEWorkflow permissions could be removed from backend ClusterRole since all operations use user tokens

## Operator (`agentic-operator`)

### Current ClusterRole Definition

Location: `components/manifests/rbac/operator-clusterrole.yaml`

```yaml
rules:
# AgenticSession custom resources (read-only + status updates)
- apiGroups: ["vteam.ambient-code"]
  resources: ["agenticsessions"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["vteam.ambient-code"]
  resources: ["agenticsessions/status"]
  verbs: ["update"]

# ProjectSettings custom resources (create + read + status updates)
- apiGroups: ["vteam.ambient-code"]
  resources: ["projectsettings"]
  verbs: ["get", "list", "watch", "create"]
- apiGroups: ["vteam.ambient-code"]
  resources: ["projectsettings/status"]
  verbs: ["update"]

# Namespaces (read-only for managed namespace detection)
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get", "list", "watch"]

# Jobs (create and monitor for session execution)
- apiGroups: ["batch"]
  resources: ["jobs"]
  verbs: ["get", "create"]

# Pods (for getting logs from failed jobs)
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]

# PersistentVolumeClaims (create workspace PVCs)
- apiGroups: [""]
  resources: ["persistentvolumeclaims"]
  verbs: ["get", "create"]

# Services (create per-namespace content services)
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "create"]

# Deployments (create per-namespace content services)
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["create"]

# RoleBindings (create group access bindings)
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["rolebindings"]
  verbs: ["get", "create"]
```

### API Call Audit

#### File: `operator/main.go`

| Line | API Call | Resource | Verb | Permission | Status | Notes |
|------|----------|----------|------|------------|--------|-------|
| 173 | `Resource(gvr).Namespace(ns).Watch()` | agenticsessions | watch | ✅ Granted | Required | Watch sessions in single namespace mode |
| 175 | `Resource(gvr).Watch()` | agenticsessions | watch | ✅ Granted | Required | Watch sessions cluster-wide |
| 201 | `CoreV1().Namespaces().Get()` | namespaces | get | ✅ Granted | Required | Check namespace labels for managed status |
| 245 | `Resource(gvr).Namespace(ns).Get()` | agenticsessions | get | ✅ Granted | Required | Verify session exists before processing |
| 286 | `BatchV1().Jobs(ns).Get()` | jobs | get | ✅ Granted | Required | Check if job exists |
| 326 | `Resource(gvr).Namespace(ns).Get()` | projectsettings | get | ✅ Granted | Required | Read runner secrets config |
| 539 | `BatchV1().Jobs(ns).Create()` | jobs | create | ✅ Granted | Required | Create job for session |
| 573 | `CoreV1().PersistentVolumeClaims(ns).Get()` | persistentvolumeclaims | get | ✅ Granted | Required | Check PVC exists |
| 595 | `CoreV1().PersistentVolumeClaims(ns).Create()` | persistentvolumeclaims | create | ✅ Granted | Required | Create workspace PVC |
| 607 | `CoreV1().Services(ns).Get()` | services | get | ✅ Granted | Required | Check service exists |
| 656 | `AppsV1().Deployments(ns).Create()` | deployments | create | ✅ Granted | Required | Create content service deployment |
| 673 | `CoreV1().Services(ns).Create()` | services | create | ✅ Granted | Required | Create content service |
| 700 | `BatchV1().Jobs(ns).Get()` | jobs | get | ✅ Granted | Required | Monitor job status |
| 715 | `CoreV1().Pods(ns).List()` | pods | list | ✅ Granted | Required | List pods for failed job |
| 720 | `CoreV1().Pods(ns).GetLogs()` | pods/log | get | ✅ Granted | Required | Get logs from failed pod |
| 744 | `Resource(gvr).Namespace(ns).Get()` | agenticsessions | get | ✅ Granted | Required | Get session for status update |
| 764 | `Resource(gvr).Namespace(ns).UpdateStatus()` | agenticsessions/status | update | ✅ Granted | Required | Update session status |
| 778 | `CoreV1().Namespaces().Watch()` | namespaces | watch | ✅ Granted | Required | Watch for new managed namespaces |
| 827 | `Resource(gvr).Namespace(ns).Watch()` | projectsettings | watch | ✅ Granted | Required | Watch ProjectSettings in single namespace |
| 829 | `Resource(gvr).Watch()` | projectsettings | watch | ✅ Granted | Required | Watch ProjectSettings cluster-wide |
| 876 | `Resource(gvr).Namespace(ns).Get()` | projectsettings | get | ✅ Granted | Required | Check ProjectSettings exists |
| 902 | `Resource(gvr).Namespace(ns).Create()` | projectsettings | create | ✅ Granted | Required | Create default ProjectSettings |
| 917 | `Resource(gvr).Namespace(ns).Get()` | projectsettings | get | ✅ Granted | Required | Verify ProjectSettings exists |
| 969 | `RbacV1().RoleBindings(ns).Get()` | rolebindings | get | ✅ Granted | Required | Check RoleBinding exists |
| 1002 | `RbacV1().RoleBindings(ns).Create()` | rolebindings | create | ✅ Granted | Required | Create group access RoleBinding |
| 1028 | `Resource(gvr).Namespace(ns).Get()` | projectsettings | get | ✅ Granted | Required | Get ProjectSettings for status update |
| 1048 | `Resource(gvr).Namespace(ns).UpdateStatus()` | projectsettings/status | update | ✅ Granted | Required | Update ProjectSettings status |

### Operator Findings

1. ✅ **All permissions properly granted**: Every API call has corresponding RBAC permission
2. ✅ **Principle of least privilege**: No excessive permissions granted
3. ✅ **Namespace isolation**: All resource creation is namespace-scoped
4. ✅ **Proper status subresource usage**: Status updates use dedicated UpdateStatus() calls
5. ✅ **Secure defaults**: Uses OwnerReferences for automatic cleanup

## Security Analysis

### Backend Security Model

**Strengths:**
- ✅ All user-facing operations use caller's token (proper impersonation)
- ✅ Backend SA has minimal permissions (only ServiceAccount get/patch)
- ✅ No privilege escalation possible
- ✅ Users can only access resources they have permissions for

**Weaknesses:**
- ⚠️ Missing `selfsubjectaccessreviews` create permission for ValidateProjectContext
- ⚠️ Unused RFEWorkflow permissions in backend ClusterRole could be removed

### Operator Security Model

**Strengths:**
- ✅ All permissions are necessary and actively used
- ✅ Namespace-scoped resource creation prevents cross-namespace privilege escalation
- ✅ Status subresources used correctly
- ✅ OwnerReferences ensure proper cleanup

**No issues identified**

## Recommendations

### High Priority

1. **Add missing backend permission** (auth.go:230):
   ```yaml
   - apiGroups: ["authorization.k8s.io"]
     resources: ["selfsubjectaccessreviews"]
     verbs: ["create"]
   ```

### Low Priority

2. **Clean up unused backend permissions**:
   - Remove RFEWorkflow permissions from backend ClusterRole since all operations use user tokens
   - Keep only ServiceAccount permissions and add selfsubjectaccessreviews

### Documentation

3. **Add inline comments** to RBAC manifests explaining permission usage
4. **Document user token impersonation model** in backend README

## Permission Matrix Summary

### Backend API Service
| Resource | Get | List | Watch | Create | Update | Patch | Delete | Status Update |
|----------|-----|------|-------|--------|--------|-------|--------|---------------|
| serviceaccounts | ✅ | - | - | - | - | ✅ | - | - |
| selfsubjectaccessreviews | - | - | - | ⚠️ MISSING | - | - | - | - |
| rfeworkflows | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| rfeworkflows/status | ✅ | - | - | - | ✅ | ✅ | - | - |

**Note**: RFEWorkflow permissions are currently unused by backend SA (operations use user tokens)

### Operator
| Resource | Get | List | Watch | Create | Update | Patch | Delete | Status Update |
|----------|-----|------|-------|--------|--------|-------|--------|---------------|
| agenticsessions | ✅ | ✅ | ✅ | - | - | - | - | ✅ |
| projectsettings | ✅ | ✅ | ✅ | ✅ | - | - | - | ✅ |
| namespaces | ✅ | ✅ | ✅ | - | - | - | - | - |
| jobs | ✅ | - | - | ✅ | - | - | - | - |
| pods | - | ✅ | - | - | - | - | - | - |
| pods/log | ✅ | - | - | - | - | - | - | - |
| persistentvolumeclaims | ✅ | - | - | ✅ | - | - | - | - |
| services | ✅ | - | - | ✅ | - | - | - | - |
| deployments | - | - | - | ✅ | - | - | - | - |
| rolebindings | ✅ | - | - | ✅ | - | - | - | - |

## Implementation Status

- ✅ Backend RBAC: Mostly correct, 1 permission missing
- ✅ Operator RBAC: Complete and correct
- ⚠️ Backend cleanup: Remove unused RFEWorkflow permissions (optional)
- ⚠️ Backend fix: Add selfsubjectaccessreviews create permission (required)

## Conclusion

The RBAC configuration is generally well-designed with proper separation of concerns:

1. **Backend** uses user token impersonation for all user-facing operations (security best practice)
2. **Operator** has appropriate cluster-scoped permissions for resource management
3. **One missing permission** identified in backend for ValidateProjectContext middleware
4. **One cleanup opportunity** to remove unused RFEWorkflow permissions from backend

**Overall Assessment**: ✅ RBAC is secure and follows Kubernetes best practices with minor improvements needed.
