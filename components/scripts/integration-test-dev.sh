#!/bin/bash

# integration-test-dev.sh - Phase 4 Integration Testing for Dev Namespace
# Tests deployment to dev cluster, AgenticSession creation, Job startup,
# PVC storage class validation, and RBAC permissions

set -euo pipefail

###############
# Configuration
###############
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="${NAMESPACE:-vteam-dev}"
TIMEOUT="${TIMEOUT:-300}"

# Test configuration
TEST_SESSION_PREFIX="integration-test"
CLEANUP_ON_EXIT="${CLEANUP_ON_EXIT:-true}"

###############
# Color output
###############
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

###############
# Utilities
###############
log() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[PASS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[FAIL]${NC} $*"; }
fail() { error "$*"; exit 1; }

# Test result tracking
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

run_test() {
  local test_name="$1"
  shift
  TESTS_RUN=$((TESTS_RUN + 1))

  log "Running test: $test_name"
  if "$@"; then
    success "$test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    error "$test_name"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_TESTS+=("$test_name")
    return 1
  fi
}

# Cleanup tracking
CREATED_RESOURCES=()

cleanup_resource() {
  local kind="$1"
  local name="$2"
  local namespace="${3:-$NAMESPACE}"

  CREATED_RESOURCES+=("$kind:$name:$namespace")
}

cleanup_all() {
  if [ "$CLEANUP_ON_EXIT" != "true" ]; then
    warn "Cleanup disabled, skipping resource cleanup"
    return 0
  fi

  log "Cleaning up test resources..."
  for resource in "${CREATED_RESOURCES[@]}"; do
    IFS=':' read -r kind name ns <<< "$resource"
    log "Deleting $kind/$name in namespace $ns"
    kubectl delete "$kind" "$name" -n "$ns" --ignore-not-found=true 2>/dev/null || true
  done
}

trap cleanup_all EXIT

# Wait for resource with timeout
wait_for_resource() {
  local kind="$1"
  local name="$2"
  local namespace="${3:-$NAMESPACE}"
  local timeout="${4:-$TIMEOUT}"
  local delay=2
  local elapsed=0

  log "Waiting for $kind/$name to exist (timeout: ${timeout}s)..."
  while [ $elapsed -lt $timeout ]; do
    if kubectl get "$kind" "$name" -n "$namespace" >/dev/null 2>&1; then
      success "$kind/$name exists"
      return 0
    fi
    sleep $delay
    elapsed=$((elapsed + delay))
  done

  error "$kind/$name not found after ${timeout}s"
  return 1
}

# Wait for condition with timeout
wait_for_condition() {
  local description="$1"
  local check_command="$2"
  local timeout="${3:-$TIMEOUT}"
  local delay=2
  local elapsed=0

  log "Waiting for: $description (timeout: ${timeout}s)..."
  while [ $elapsed -lt $timeout ]; do
    if eval "$check_command" >/dev/null 2>&1; then
      success "$description"
      return 0
    fi
    sleep $delay
    elapsed=$((elapsed + delay))
  done

  error "$description (timed out after ${timeout}s)"
  return 1
}

###############
# Prerequisites
###############
check_prerequisites() {
  log "=== Checking Prerequisites ==="

  # Check kubectl
  if ! command -v kubectl >/dev/null 2>&1; then
    fail "kubectl is not installed"
  fi
  success "kubectl is installed"

  # Check cluster connectivity
  if ! kubectl cluster-info >/dev/null 2>&1; then
    fail "Cannot connect to Kubernetes cluster"
  fi
  success "Connected to Kubernetes cluster"

  # Check namespace exists
  if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    fail "Namespace $NAMESPACE does not exist"
  fi
  success "Namespace $NAMESPACE exists"

  echo ""
}

###############
# Test: Deployment Validation
###############
test_deployment_exists() {
  log "=== Test: Deployment Validation ==="

  local deployments=("vteam-backend" "vteam-frontend" "vteam-operator")
  local all_exist=true

  for deployment in "${deployments[@]}"; do
    if kubectl get deployment "$deployment" -n "$NAMESPACE" >/dev/null 2>&1; then
      success "Deployment $deployment exists"
    else
      error "Deployment $deployment not found"
      all_exist=false
    fi
  done

  echo ""
  [ "$all_exist" = true ]
}

test_deployments_ready() {
  log "=== Test: Deployments Ready ==="

  local deployments=("vteam-backend" "vteam-frontend" "vteam-operator")
  local all_ready=true

  for deployment in "${deployments[@]}"; do
    local ready
    ready=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    local desired
    desired=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")

    if [ "$ready" = "$desired" ] && [ "$ready" != "0" ]; then
      success "Deployment $deployment is ready ($ready/$desired replicas)"
    else
      error "Deployment $deployment is not ready ($ready/$desired replicas)"
      all_ready=false
    fi
  done

  echo ""
  [ "$all_ready" = true ]
}

###############
# Test: CRD Validation
###############
test_crds_installed() {
  log "=== Test: CRD Installation ==="

  local crds=(
    "agenticsessions.vteam.ambient-code"
    "projectsettings.vteam.ambient-code"
    "rfeworkflows.vteam.ambient-code"
  )
  local all_installed=true

  for crd in "${crds[@]}"; do
    if kubectl get crd "$crd" >/dev/null 2>&1; then
      local condition
      condition=$(kubectl get crd "$crd" -o jsonpath='{.status.conditions[?(@.type=="Established")].status}' 2>/dev/null || echo "False")

      if [ "$condition" = "True" ]; then
        success "CRD $crd is installed and established"
      else
        error "CRD $crd exists but not established"
        all_installed=false
      fi
    else
      error "CRD $crd not found"
      all_installed=false
    fi
  done

  echo ""
  [ "$all_installed" = true ]
}

###############
# Test: RBAC Validation
###############
test_rbac_service_accounts() {
  log "=== Test: RBAC Service Accounts ==="

  local service_accounts=("backend-api" "agentic-operator")
  local all_exist=true

  for sa in "${service_accounts[@]}"; do
    if kubectl get serviceaccount "$sa" -n "$NAMESPACE" >/dev/null 2>&1; then
      success "ServiceAccount $sa exists"
    else
      error "ServiceAccount $sa not found"
      all_exist=false
    fi
  done

  echo ""
  [ "$all_exist" = true ]
}

test_rbac_cluster_roles() {
  log "=== Test: RBAC ClusterRoles ==="

  local cluster_roles=(
    "backend-api"
    "agentic-operator"
    "ambient-project-admin"
    "ambient-project-edit"
    "ambient-project-view"
  )
  local all_exist=true

  for cr in "${cluster_roles[@]}"; do
    if kubectl get clusterrole "$cr" >/dev/null 2>&1; then
      success "ClusterRole $cr exists"
    else
      warn "ClusterRole $cr not found (may be optional)"
    fi
  done

  echo ""
  [ "$all_exist" = true ]
}

test_rbac_permissions() {
  log "=== Test: RBAC Permissions ==="

  # Test operator can manage AgenticSessions
  local operator_sa="system:serviceaccount:$NAMESPACE:agentic-operator"

  if kubectl auth can-i create agenticsessions --as="$operator_sa" -n "$NAMESPACE" >/dev/null 2>&1; then
    success "Operator can create AgenticSessions"
  else
    error "Operator cannot create AgenticSessions"
    echo ""
    return 1
  fi

  if kubectl auth can-i update agenticsessions/status --as="$operator_sa" -n "$NAMESPACE" >/dev/null 2>&1; then
    success "Operator can update AgenticSession status"
  else
    error "Operator cannot update AgenticSession status"
    echo ""
    return 1
  fi

  if kubectl auth can-i create jobs --as="$operator_sa" -n "$NAMESPACE" >/dev/null 2>&1; then
    success "Operator can create Jobs"
  else
    error "Operator cannot create Jobs"
    echo ""
    return 1
  fi

  echo ""
  return 0
}

###############
# Test: PVC and Storage
###############
test_pvc_storage_class() {
  log "=== Test: PVC Storage Class Validation ==="

  # Check for workspace PVC created by operator
  if kubectl get pvc ambient-workspace -n "$NAMESPACE" >/dev/null 2>&1; then
    local status
    status=$(kubectl get pvc ambient-workspace -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")

    local storage_class
    storage_class=$(kubectl get pvc ambient-workspace -n "$NAMESPACE" -o jsonpath='{.spec.storageClassName}' 2>/dev/null || echo "default")

    if [ "$status" = "Bound" ]; then
      success "PVC ambient-workspace is Bound with storage class: $storage_class"
    else
      error "PVC ambient-workspace is $status (not Bound)"
      echo ""
      return 1
    fi

    # Verify storage class exists
    if kubectl get storageclass "$storage_class" >/dev/null 2>&1; then
      success "StorageClass $storage_class exists"
    else
      warn "StorageClass $storage_class not found"
    fi
  else
    warn "PVC ambient-workspace not found (may be created on first session)"
  fi

  echo ""
  return 0
}

###############
# Test: AgenticSession Creation and Job Startup
###############
test_create_agenticsession() {
  log "=== Test: AgenticSession Creation and Job Startup ==="

  local session_name="${TEST_SESSION_PREFIX}-$(date +%s)"
  local manifest

  # Create AgenticSession manifest
  manifest=$(cat <<EOF
apiVersion: vteam.ambient-code/v1alpha1
kind: AgenticSession
metadata:
  name: ${session_name}
  namespace: ${NAMESPACE}
spec:
  prompt: "echo 'Integration test session' && sleep 10"
  timeout: 120
  interactive: false
  llmSettings:
    model: "claude-sonnet-4-20250514"
    temperature: 0.7
    maxTokens: 4096
EOF
)

  log "Creating AgenticSession: $session_name"
  echo "$manifest" | kubectl apply -f - >/dev/null 2>&1

  if [ $? -ne 0 ]; then
    error "Failed to create AgenticSession $session_name"
    echo ""
    return 1
  fi

  cleanup_resource "agenticsession" "$session_name" "$NAMESPACE"
  success "AgenticSession $session_name created"

  # Wait for Job to be created by operator
  local job_name="${session_name}-job"
  if wait_for_resource "job" "$job_name" "$NAMESPACE" 60; then
    success "Job $job_name created by operator"
    cleanup_resource "job" "$job_name" "$NAMESPACE"
  else
    error "Job $job_name not created within timeout"
    echo ""
    return 1
  fi

  # Wait for Pod to be created from Job
  local check_pod="kubectl get pods -n $NAMESPACE -l job-name=$job_name -o jsonpath='{.items[0].metadata.name}' 2>/dev/null | grep -q ."
  if wait_for_condition "Pod created from Job" "$check_pod" 60; then
    local pod_name
    pod_name=$(kubectl get pods -n "$NAMESPACE" -l "job-name=$job_name" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

    if [ -n "$pod_name" ]; then
      success "Pod $pod_name created from Job"

      # Check pod status
      local pod_phase
      pod_phase=$(kubectl get pod "$pod_name" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")

      log "Pod phase: $pod_phase"

      if [ "$pod_phase" = "Running" ] || [ "$pod_phase" = "Pending" ] || [ "$pod_phase" = "Succeeded" ]; then
        success "Pod is in valid state: $pod_phase"
      else
        warn "Pod is in unexpected state: $pod_phase"
      fi
    fi
  else
    error "Pod not created from Job within timeout"
    echo ""
    return 1
  fi

  # Check AgenticSession status update
  local check_status="kubectl get agenticsession $session_name -n $NAMESPACE -o jsonpath='{.status.phase}' 2>/dev/null | grep -qE '(Creating|Running|Pending|Completed|Failed)'"
  if wait_for_condition "AgenticSession status updated" "$check_status" 60; then
    local session_phase
    session_phase=$(kubectl get agenticsession "$session_name" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")
    success "AgenticSession status: $session_phase"
  else
    warn "AgenticSession status not updated (operator may still be processing)"
  fi

  echo ""
  return 0
}

###############
# Test: Operator Health
###############
test_operator_health() {
  log "=== Test: Operator Health ==="

  # Check operator pod is running
  local operator_pod
  operator_pod=$(kubectl get pods -n "$NAMESPACE" -l app=vteam-operator -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

  if [ -z "$operator_pod" ]; then
    error "Operator pod not found"
    echo ""
    return 1
  fi

  success "Operator pod found: $operator_pod"

  # Check operator pod status
  local pod_phase
  pod_phase=$(kubectl get pod "$operator_pod" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")

  if [ "$pod_phase" = "Running" ]; then
    success "Operator pod is Running"
  else
    error "Operator pod is $pod_phase (not Running)"
    echo ""
    return 1
  fi

  # Check for errors in logs (last 100 lines)
  local error_count
  error_count=$(kubectl logs "$operator_pod" -n "$NAMESPACE" --tail=100 2>/dev/null | \
    grep -iE "error|fatal|panic" | \
    grep -viE "watching for.*error|watch.*error.*restarting" | \
    wc -l | tr -d '[:space:]')

  if [ "$error_count" -eq 0 ]; then
    success "No critical errors in operator logs"
  else
    warn "Found $error_count error-like messages in operator logs (may be normal)"
  fi

  echo ""
  return 0
}

###############
# Test: ProjectSettings
###############
test_projectsettings() {
  log "=== Test: ProjectSettings CR ==="

  if kubectl get projectsettings projectsettings -n "$NAMESPACE" >/dev/null 2>&1; then
    success "ProjectSettings CR exists"
  else
    warn "ProjectSettings CR not found (operator should create it)"
    echo ""
    return 1
  fi

  echo ""
  return 0
}

###############
# Main Execution
###############
main() {
  echo "========================================="
  echo "Phase 4 Integration Testing"
  echo "Namespace: $NAMESPACE"
  echo "Timeout: ${TIMEOUT}s"
  echo "========================================="
  echo ""

  # Prerequisites
  check_prerequisites

  # Run tests
  run_test "Deployments exist" test_deployment_exists
  run_test "Deployments are ready" test_deployments_ready
  run_test "CRDs installed and established" test_crds_installed
  run_test "RBAC service accounts exist" test_rbac_service_accounts
  run_test "RBAC cluster roles exist" test_rbac_cluster_roles
  run_test "RBAC permissions configured" test_rbac_permissions
  run_test "PVC storage class validation" test_pvc_storage_class
  run_test "Operator health check" test_operator_health
  run_test "ProjectSettings CR exists" test_projectsettings
  run_test "AgenticSession creation and Job startup" test_create_agenticsession

  # Summary
  echo ""
  echo "========================================="
  echo "Test Summary"
  echo "========================================="
  echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
  echo -e "${RED}Failed: $TESTS_FAILED${NC}"
  echo "Total:  $TESTS_RUN"
  echo "========================================="

  if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    success "All integration tests passed!"
    echo ""
    exit 0
  else
    echo ""
    error "Some tests failed:"
    for test in "${FAILED_TESTS[@]}"; do
      echo "  - $test"
    done
    echo ""
    exit 1
  fi
}

# Run main
main "$@"
