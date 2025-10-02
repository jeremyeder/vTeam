# AgenticSession Examples

This directory contains example AgenticSession manifests for testing and development.

## Available Examples

### 1. Basic Test Session (`agenticsession-test.yaml`)

A simple session that runs a basic command and exits. Useful for:
- Verifying the operator is working
- Testing Job creation
- Quick smoke tests

```bash
kubectl apply -f agenticsession-test.yaml
kubectl get agenticsession test-session-basic -n vteam-dev -w
```

### 2. Session with Git Configuration (`agenticsession-with-git.yaml`)

Demonstrates how to configure git repositories for cloning. Useful for:
- Testing git authentication
- Verifying workspace setup
- Repository-based tasks

```bash
# Edit the manifest to configure your repository
kubectl apply -f agenticsession-with-git.yaml
kubectl get agenticsession test-session-with-git -n vteam-dev -w
```

### 3. Interactive Session (`agenticsession-interactive.yaml`)

An interactive chat-based session. Useful for:
- Chat-based AI interaction
- Long-running tasks
- Interactive debugging

```bash
kubectl apply -f agenticsession-interactive.yaml

# Send messages to the session
echo '{"message": "List files in workspace"}' >> /path/to/inbox.jsonl
```

## Quick Test Workflow

### 1. Create a Test Session

```bash
# Create the basic test session
kubectl apply -f agenticsession-test.yaml
```

### 2. Monitor the Session

```bash
# Watch the AgenticSession status
kubectl get agenticsession test-session-basic -n vteam-dev -w

# Check the created Job
kubectl get jobs -n vteam-dev | grep test-session-basic

# View Pod logs
kubectl logs -n vteam-dev -l job-name=test-session-basic-job -f
```

### 3. Check Results

```bash
# Get session status
kubectl get agenticsession test-session-basic -n vteam-dev -o yaml

# View phase and completion details
kubectl get agenticsession test-session-basic -n vteam-dev -o jsonpath='{.status.phase}'

# Check for errors
kubectl get agenticsession test-session-basic -n vteam-dev -o jsonpath='{.status.message}'
```

### 4. Cleanup

```bash
# Delete the session (Job and Pod are cleaned up automatically)
kubectl delete agenticsession test-session-basic -n vteam-dev
```

## Validating Integration Tests

Use these examples to manually validate the integration test requirements:

### ✅ AgenticSession Creation
```bash
kubectl apply -f agenticsession-test.yaml
kubectl get agenticsession test-session-basic -n vteam-dev
```

### ✅ Job Starts
```bash
# Wait a few seconds after creating the session
kubectl get jobs -n vteam-dev | grep test-session-basic-job
```

### ✅ PVC Storage Class
```bash
# Check workspace PVC
kubectl get pvc ambient-workspace -n vteam-dev
kubectl get pvc ambient-workspace -n vteam-dev -o jsonpath='{.spec.storageClassName}'
```

### ✅ RBAC Permissions
```bash
# Verify operator can create resources
kubectl auth can-i create jobs \
  --as=system:serviceaccount:vteam-dev:agentic-operator \
  -n vteam-dev

kubectl auth can-i update agenticsessions/status \
  --as=system:serviceaccount:vteam-dev:agentic-operator \
  -n vteam-dev
```

## Debugging Tips

### View Operator Logs
```bash
kubectl logs deployment/vteam-operator -n vteam-dev --tail=100 -f
```

### Check Session Events
```bash
kubectl describe agenticsession test-session-basic -n vteam-dev
```

### View Job Details
```bash
kubectl describe job test-session-basic-job -n vteam-dev
```

### Access Pod Shell (if still running)
```bash
POD_NAME=$(kubectl get pods -n vteam-dev -l job-name=test-session-basic-job -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD_NAME -n vteam-dev -- /bin/bash
```

### Check PVC Contents
```bash
# Create a debug pod to inspect PVC
kubectl run -it --rm debug --image=busybox --restart=Never -n vteam-dev -- sh

# Inside the pod, mount the PVC and explore:
# ls -la /workspace
```

## Common Errors and Solutions

### Error: ImagePullBackOff
**Cause**: Runner image not available or registry authentication failed

**Solution**:
```bash
# Check image pull secrets
kubectl get secrets -n vteam-dev

# Check pod events
kubectl describe pod -n vteam-dev | grep -A 5 Events
```

### Error: Job Not Created
**Cause**: Operator not running or RBAC permissions missing

**Solution**:
```bash
# Check operator status
kubectl get deployment vteam-operator -n vteam-dev

# Check operator logs
kubectl logs deployment/vteam-operator -n vteam-dev

# Verify RBAC
kubectl auth can-i create jobs --as=system:serviceaccount:vteam-dev:agentic-operator -n vteam-dev
```

### Error: PVC Pending
**Cause**: No storage class available or insufficient resources

**Solution**:
```bash
# List storage classes
kubectl get storageclass

# Check PVC events
kubectl describe pvc ambient-workspace -n vteam-dev

# Check node resources
kubectl describe nodes
```

## Next Steps

After verifying these examples work correctly:

1. Run the full integration test suite:
   ```bash
   ../integration-test-dev.sh
   ```

2. Review the test output and ensure all tests pass

3. Document any issues or failures in the GitHub issue

4. Proceed with Phase 4 completion when all tests pass

## Related Documentation

- [Integration Testing Guide](../INTEGRATION_TESTING.md)
- [AgenticSession CRD Specification](../../manifests/crds/agenticsessions-crd.yaml)
- [Operator Documentation](../../operator/README.md)
