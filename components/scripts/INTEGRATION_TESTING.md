# Phase 4 Integration Testing - Dev Namespace

This document describes the integration testing process for the vTeam Ambient Agentic Runner in a development namespace.

## Overview

The Phase 4 integration tests validate the complete deployment and functionality of the system in a dev cluster environment. These tests ensure that all components work together correctly before promoting to production.

## Test Coverage

The integration test suite covers:

1. **Deployment Validation**
   - All required deployments exist (backend, frontend, operator)
   - Deployments are ready with correct replica counts
   - Pods are running and healthy

2. **Custom Resource Definitions (CRDs)**
   - AgenticSessions CRD installed and established
   - ProjectSettings CRD installed and established
   - RFEWorkflows CRD installed and established

3. **RBAC Permissions**
   - Service accounts exist (backend-api, agentic-operator)
   - ClusterRoles are configured correctly
   - Operator has permissions to:
     - Create and manage AgenticSessions
     - Update AgenticSession status
     - Create Jobs
     - Manage PVCs

4. **Storage Validation**
   - PVC storage class is available
   - Workspace PVC is created and bound
   - StorageClass exists and is accessible

5. **AgenticSession Lifecycle**
   - AgenticSession can be created
   - Operator detects and processes AgenticSession
   - Kubernetes Job is created from AgenticSession
   - Pod is created from Job
   - AgenticSession status is updated
   - Resources are cleaned up after test

6. **Operator Health**
   - Operator pod is running
   - No critical errors in operator logs
   - ProjectSettings CR is created

## Prerequisites

Before running integration tests:

1. **Cluster Access**
   - kubectl configured and connected to target cluster
   - Appropriate permissions to create resources in test namespace

2. **Namespace Setup**
   - Dev namespace exists (default: `vteam-dev`)
   - All deployments are installed and running

3. **Dependencies**
   - Issue #10 (prerequisite for Phase 4) is completed
   - All manifests are deployed to the cluster

## Running the Tests

### Quick Start

```bash
# Run with default settings (vteam-dev namespace)
./components/scripts/integration-test-dev.sh

# Run in custom namespace
NAMESPACE=my-dev-namespace ./components/scripts/integration-test-dev.sh

# Run with custom timeout (default: 300s)
TIMEOUT=600 ./components/scripts/integration-test-dev.sh

# Disable cleanup (keep test resources)
CLEANUP_ON_EXIT=false ./components/scripts/integration-test-dev.sh
```

### Configuration Options

Environment variables:

- `NAMESPACE`: Target namespace for testing (default: `vteam-dev`)
- `TIMEOUT`: Maximum wait time for resources in seconds (default: `300`)
- `CLEANUP_ON_EXIT`: Whether to cleanup test resources (default: `true`)

### Expected Output

Successful test run:
```
=========================================
Phase 4 Integration Testing
Namespace: vteam-dev
Timeout: 300s
=========================================

=== Checking Prerequisites ===
[PASS] kubectl is installed
[PASS] Connected to Kubernetes cluster
[PASS] Namespace vteam-dev exists

[INFO] Running test: Deployments exist
[PASS] Deployments exist

[INFO] Running test: Deployments are ready
[PASS] Deployments are ready

... (additional tests)

=========================================
Test Summary
=========================================
Passed: 10
Failed: 0
Total:  10
=========================================

[PASS] All integration tests passed!
```

## Test Details

### 1. Deployment Validation

Verifies that all core components are deployed:
- `vteam-backend`: Backend API service
- `vteam-frontend`: Frontend web interface
- `vteam-operator`: Kubernetes operator managing AgenticSessions

### 2. CRD Validation

Ensures Custom Resource Definitions are properly installed:
- `agenticsessions.vteam.ambient-code`
- `projectsettings.vteam.ambient-code`
- `rfeworkflows.vteam.ambient-code`

Each CRD must be in "Established" state.

### 3. RBAC Validation

Tests service account permissions:
- Operator can create/update AgenticSessions
- Operator can create Jobs
- Operator can manage workspace resources

### 4. Storage Validation

Validates persistent storage configuration:
- Default storage class is available
- Workspace PVC can be created and bound
- Storage class supports ReadWriteMany or ReadWriteOnce

### 5. AgenticSession E2E Test

Creates a real AgenticSession and validates the complete workflow:

```yaml
apiVersion: vteam.ambient-code/v1alpha1
kind: AgenticSession
metadata:
  name: integration-test-{timestamp}
spec:
  prompt: "echo 'Integration test session' && sleep 10"
  timeout: 120
  interactive: false
  llmSettings:
    model: "claude-sonnet-4-20250514"
    temperature: 0.7
    maxTokens: 4096
```

Validates:
1. AgenticSession is created successfully
2. Operator creates a Job within 60 seconds
3. Job creates a Pod
4. Pod reaches Running/Pending/Succeeded state
5. AgenticSession status is updated
6. Resources are cleaned up automatically

### 6. Operator Health

Checks operator stability:
- Pod is running
- No critical errors in recent logs
- Able to watch and process AgenticSessions

## Troubleshooting

### Common Issues

#### 1. Deployments Not Ready

**Symptom**: `Deployments are ready` test fails

**Solutions**:
```bash
# Check deployment status
kubectl get deployments -n vteam-dev

# Check pod logs
kubectl logs deployment/vteam-operator -n vteam-dev
kubectl logs deployment/vteam-backend -n vteam-dev

# Check pod events
kubectl describe pod -n vteam-dev
```

#### 2. RBAC Permissions Failures

**Symptom**: `RBAC permissions configured` test fails

**Solutions**:
```bash
# Verify ClusterRoleBindings
kubectl get clusterrolebinding | grep agentic-operator

# Check service account
kubectl get serviceaccount agentic-operator -n vteam-dev

# Manually test permissions
kubectl auth can-i create agenticsessions \
  --as=system:serviceaccount:vteam-dev:agentic-operator \
  -n vteam-dev
```

#### 3. Job Not Created

**Symptom**: `AgenticSession creation and Job startup` test fails at Job creation

**Solutions**:
```bash
# Check operator logs
kubectl logs deployment/vteam-operator -n vteam-dev --tail=100

# Check AgenticSession status
kubectl get agenticsession -n vteam-dev
kubectl describe agenticsession integration-test-* -n vteam-dev

# Verify operator is watching
kubectl logs deployment/vteam-operator -n vteam-dev | grep "Watching"
```

#### 4. PVC Storage Issues

**Symptom**: `PVC storage class validation` test fails

**Solutions**:
```bash
# List available storage classes
kubectl get storageclass

# Check PVC status
kubectl get pvc -n vteam-dev
kubectl describe pvc ambient-workspace -n vteam-dev

# Check if default storage class exists
kubectl get storageclass -o yaml | grep "is-default-class"
```

### Viewing Test Resources

If tests fail, you may want to inspect created resources:

```bash
# Disable cleanup
CLEANUP_ON_EXIT=false ./components/scripts/integration-test-dev.sh

# List created AgenticSessions
kubectl get agenticsessions -n vteam-dev | grep integration-test

# View AgenticSession details
kubectl describe agenticsession integration-test-* -n vteam-dev

# Check created Jobs
kubectl get jobs -n vteam-dev | grep integration-test

# View Pod logs
kubectl logs -n vteam-dev -l job-name=integration-test-*-job
```

### Manual Cleanup

If automatic cleanup fails:

```bash
# Delete all test AgenticSessions
kubectl delete agenticsessions -n vteam-dev -l app=integration-test

# Delete all test Jobs
kubectl delete jobs -n vteam-dev | grep integration-test | awk '{print $1}' | xargs kubectl delete job -n vteam-dev

# Delete test Pods
kubectl delete pods -n vteam-dev -l job-name | grep integration-test
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Integration Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  integration-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up kubectl
        uses: azure/setup-kubectl@v3

      - name: Configure cluster access
        run: |
          echo "${{ secrets.KUBECONFIG }}" | base64 -d > /tmp/kubeconfig
          export KUBECONFIG=/tmp/kubeconfig

      - name: Run integration tests
        run: |
          chmod +x components/scripts/integration-test-dev.sh
          NAMESPACE=vteam-ci ./components/scripts/integration-test-dev.sh

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: integration-test-results
          path: test-results/
```

### Makefile Integration

Add to your project Makefile:

```makefile
.PHONY: integration-test
integration-test:
	@echo "Running Phase 4 integration tests..."
	./components/scripts/integration-test-dev.sh

.PHONY: integration-test-dev
integration-test-dev:
	@echo "Running integration tests in vteam-dev namespace..."
	NAMESPACE=vteam-dev ./components/scripts/integration-test-dev.sh

.PHONY: integration-test-ci
integration-test-ci:
	@echo "Running integration tests in CI environment..."
	NAMESPACE=vteam-ci CLEANUP_ON_EXIT=true ./components/scripts/integration-test-dev.sh
```

## Success Criteria

All tests must pass for Phase 4 to be considered complete:

- ✅ All deployments exist and are ready
- ✅ All CRDs are installed and established
- ✅ RBAC permissions are correctly configured
- ✅ PVC storage class is validated
- ✅ AgenticSession can be created
- ✅ Operator creates Job from AgenticSession
- ✅ Job creates Pod successfully
- ✅ AgenticSession status is updated
- ✅ Operator logs show no critical errors
- ✅ Resources are cleaned up automatically

## Related Documentation

- [Components README](../README.md) - Main component documentation
- [Local Development Guide](./local-dev/README.md) - CRC-based development setup
- [Deployment Guide](../manifests/deploy.sh) - Production deployment
- [Verification Script](../manifests/verify.sh) - Post-deployment verification

## Issue Tracking

- **Epic**: #1 (vTeam Ambient Agentic Runner)
- **Phase**: 4 (Integration Testing)
- **Dependencies**: #10 (must be completed first)
- **Estimate**: 6 hours

## Changelog

- **2025-10-02**: Initial Phase 4 integration test suite created
  - Comprehensive test coverage for dev namespace deployment
  - AgenticSession lifecycle validation
  - RBAC and storage validation
  - Operator health checks
  - Automated cleanup and error handling
