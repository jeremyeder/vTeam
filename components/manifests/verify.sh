#!/bin/bash

# verify.sh - vTeam Ambient Agentic Runner Verification Script
# Validates RBAC configuration and pod health after deployment

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="${NAMESPACE:-ambient-code}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Counters for test results
PASSED=0
FAILED=0
WARNINGS=0

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED++))
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARNINGS++))
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED++))
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect if we're on OpenShift or vanilla Kubernetes
is_openshift() {
    kubectl get clusterversion >/dev/null 2>&1 || kubectl api-resources | grep -q route.openshift.io
}

print_info "=== vTeam Ambient Agentic Runner Verification ==="
print_info "Namespace: $NAMESPACE"
echo ""

# Check prerequisites
print_info "Checking prerequisites..."
if ! command_exists kubectl; then
    print_error "kubectl is not installed"
    exit 1
fi

if ! kubectl cluster-info >/dev/null 2>&1; then
    print_error "Cannot connect to Kubernetes cluster"
    exit 1
fi

print_success "Prerequisites check passed"
echo ""

# Check if namespace exists
print_info "=== Namespace Validation ==="
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    print_error "Namespace $NAMESPACE does not exist"
    exit 1
fi

# Check namespace status
NAMESPACE_PHASE=$(kubectl get namespace "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")
if [ "$NAMESPACE_PHASE" = "Active" ]; then
    print_success "Namespace $NAMESPACE is Active"
else
    print_error "Namespace $NAMESPACE is not Active (phase: $NAMESPACE_PHASE)"
fi
echo ""

# Validate CRDs
print_info "=== Custom Resource Definition Validation ==="
CRDS=(
    "agenticsessions.vteam.ambient-code"
    "rfeworkflows.vteam.ambient-code"
    "projectsettings.vteam.ambient-code"
)

for crd in "${CRDS[@]}"; do
    if kubectl get crd "$crd" >/dev/null 2>&1; then
        # Check if CRD is established
        CRD_CONDITION=$(kubectl get crd "$crd" -o jsonpath='{.status.conditions[?(@.type=="Established")].status}' 2>/dev/null || echo "False")
        if [ "$CRD_CONDITION" = "True" ]; then
            print_success "CRD $crd is installed and established"
        else
            print_error "CRD $crd exists but is not established"
        fi
    else
        print_error "CRD $crd is not installed"
    fi
done
echo ""

# Validate RBAC - Service Accounts
print_info "=== RBAC Validation: Service Accounts ==="
SERVICE_ACCOUNTS=("backend-api" "agentic-operator")

for sa in "${SERVICE_ACCOUNTS[@]}"; do
    if kubectl get serviceaccount "$sa" -n "$NAMESPACE" >/dev/null 2>&1; then
        print_success "ServiceAccount $sa exists"
    else
        print_error "ServiceAccount $sa is missing"
    fi
done
echo ""

# Validate RBAC - Roles
print_info "=== RBAC Validation: Roles ==="
ROLES=("backend-api")

for role in "${ROLES[@]}"; do
    if kubectl get role "$role" -n "$NAMESPACE" >/dev/null 2>&1; then
        print_success "Role $role exists"
    else
        print_error "Role $role is missing"
    fi
done
echo ""

# Validate RBAC - RoleBindings
print_info "=== RBAC Validation: RoleBindings ==="
ROLEBINDINGS=("backend-api")

for rb in "${ROLEBINDINGS[@]}"; do
    if kubectl get rolebinding "$rb" -n "$NAMESPACE" >/dev/null 2>&1; then
        print_success "RoleBinding $rb exists"

        # Verify the rolebinding is correctly configured
        EXPECTED_SA="backend-api"
        BOUND_SA=$(kubectl get rolebinding "$rb" -n "$NAMESPACE" -o jsonpath='{.subjects[0].name}' 2>/dev/null || echo "")
        if [ "$BOUND_SA" = "$EXPECTED_SA" ]; then
            print_success "RoleBinding $rb is bound to ServiceAccount $EXPECTED_SA"
        else
            print_warning "RoleBinding $rb is bound to $BOUND_SA (expected $EXPECTED_SA)"
        fi
    else
        print_error "RoleBinding $rb is missing"
    fi
done
echo ""

# Validate RBAC - ClusterRoles
print_info "=== RBAC Validation: ClusterRoles ==="
CLUSTERROLES=(
    "backend-api"
    "agentic-operator"
    "ambient-project-admin"
    "ambient-project-edit"
    "ambient-project-view"
)

for cr in "${CLUSTERROLES[@]}"; do
    if kubectl get clusterrole "$cr" >/dev/null 2>&1; then
        print_success "ClusterRole $cr exists"
    else
        print_warning "ClusterRole $cr is missing"
    fi
done
echo ""

# Validate RBAC - ClusterRoleBindings
print_info "=== RBAC Validation: ClusterRoleBindings ==="
CLUSTERROLEBINDINGS=("backend-api" "agentic-operator")

for crb in "${CLUSTERROLEBINDINGS[@]}"; do
    if kubectl get clusterrolebinding "$crb" >/dev/null 2>&1; then
        print_success "ClusterRoleBinding $crb exists"
    else
        print_warning "ClusterRoleBinding $crb is missing"
    fi
done
echo ""

# Validate ConfigMaps
print_info "=== ConfigMap Validation ==="
CONFIGMAPS=("git-config")

for cm in "${CONFIGMAPS[@]}"; do
    if kubectl get configmap "$cm" -n "$NAMESPACE" >/dev/null 2>&1; then
        print_success "ConfigMap $cm exists"
    else
        print_warning "ConfigMap $cm is missing (may be optional)"
    fi
done
echo ""

# Validate Deployments
print_info "=== Deployment Validation ==="
DEPLOYMENTS=("backend-api" "frontend" "agentic-operator")

for deployment in "${DEPLOYMENTS[@]}"; do
    if kubectl get deployment "$deployment" -n "$NAMESPACE" >/dev/null 2>&1; then
        print_success "Deployment $deployment exists"

        # Check deployment status
        READY=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        DESIRED=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")

        if [ "$READY" = "$DESIRED" ] && [ "$READY" != "0" ]; then
            print_success "Deployment $deployment is ready ($READY/$DESIRED replicas)"
        else
            print_error "Deployment $deployment is not ready ($READY/$DESIRED replicas)"
        fi

        # Check for image pull errors
        PODS=$(kubectl get pods -n "$NAMESPACE" -l "app=$deployment" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")
        for pod in $PODS; do
            if [ -n "$pod" ]; then
                POD_STATUS=$(kubectl get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")
                if [ "$POD_STATUS" != "Running" ] && [ "$POD_STATUS" != "Succeeded" ]; then
                    REASON=$(kubectl get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.status.containerStatuses[0].state.waiting.reason}' 2>/dev/null || echo "Unknown")
                    if [ "$REASON" = "ImagePullBackOff" ] || [ "$REASON" = "ErrImagePull" ]; then
                        print_error "Pod $pod has image pull error: $REASON"
                    else
                        print_warning "Pod $pod is in $POD_STATUS state (reason: $REASON)"
                    fi
                fi
            fi
        done
    else
        print_error "Deployment $deployment is missing"
    fi
done
echo ""

# Validate Services
print_info "=== Service Validation ==="
SERVICES=("backend-service" "frontend-service")

for service in "${SERVICES[@]}"; do
    if kubectl get service "$service" -n "$NAMESPACE" >/dev/null 2>&1; then
        print_success "Service $service exists"

        # Check if service has endpoints
        ENDPOINTS=$(kubectl get endpoints "$service" -n "$NAMESPACE" -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null || echo "")
        if [ -n "$ENDPOINTS" ]; then
            ENDPOINT_COUNT=$(echo "$ENDPOINTS" | wc -w)
            print_success "Service $service has $ENDPOINT_COUNT endpoint(s)"
        else
            print_warning "Service $service has no endpoints (pods may not be ready)"
        fi
    else
        print_error "Service $service is missing"
    fi
done
echo ""

# Validate Routes (OpenShift only)
if is_openshift; then
    print_info "=== Route Validation (OpenShift) ==="
    if kubectl get route -n "$NAMESPACE" >/dev/null 2>&1; then
        ROUTES=$(kubectl get route -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")
        if [ -n "$ROUTES" ]; then
            for route in $ROUTES; do
                HOST=$(kubectl get route "$route" -n "$NAMESPACE" -o jsonpath='{.spec.host}' 2>/dev/null || echo "")
                if [ -n "$HOST" ]; then
                    print_success "Route $route: https://$HOST"
                else
                    print_warning "Route $route has no host configured"
                fi
            done
        else
            print_warning "No routes found (may need to be created manually)"
        fi
    else
        print_warning "Routes are not available (this is normal for non-OpenShift clusters)"
    fi
    echo ""
fi

# Pod Health Checks
print_info "=== Pod Health Validation ==="
ALL_PODS=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")

if [ -n "$ALL_PODS" ]; then
    for pod in $ALL_PODS; do
        POD_STATUS=$(kubectl get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")
        READY_CONTAINERS=$(kubectl get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.status.containerStatuses[*].ready}' 2>/dev/null | grep -o "true" | wc -l || echo "0")
        TOTAL_CONTAINERS=$(kubectl get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w || echo "0")

        if [ "$POD_STATUS" = "Running" ] && [ "$READY_CONTAINERS" = "$TOTAL_CONTAINERS" ]; then
            print_success "Pod $pod is Running ($READY_CONTAINERS/$TOTAL_CONTAINERS containers ready)"
        elif [ "$POD_STATUS" = "Succeeded" ]; then
            print_success "Pod $pod has Succeeded (completed job)"
        else
            print_error "Pod $pod is $POD_STATUS ($READY_CONTAINERS/$TOTAL_CONTAINERS containers ready)"

            # Show container status details
            CONTAINER_STATES=$(kubectl get pod "$pod" -n "$NAMESPACE" -o jsonpath='{range .status.containerStatuses[*]}{.name}: {.state}{"\n"}{end}' 2>/dev/null || echo "")
            if [ -n "$CONTAINER_STATES" ]; then
                echo -e "${YELLOW}  Container states:${NC}"
                echo "$CONTAINER_STATES" | sed 's/^/    /'
            fi
        fi

        # Check restart count
        RESTART_COUNT=$(kubectl get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || echo "0")
        if [ "$RESTART_COUNT" -gt 0 ]; then
            print_warning "Pod $pod has restarted $RESTART_COUNT time(s)"
        fi
    done
else
    print_warning "No pods found in namespace $NAMESPACE"
fi
echo ""

# Resource Quota Check (if exists)
print_info "=== Resource Quota Check ==="
if kubectl get resourcequota -n "$NAMESPACE" >/dev/null 2>&1; then
    QUOTAS=$(kubectl get resourcequota -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")
    if [ -n "$QUOTAS" ]; then
        for quota in $QUOTAS; do
            print_info "ResourceQuota $quota:"
            kubectl get resourcequota "$quota" -n "$NAMESPACE" -o yaml | grep -A 5 "status:" | sed 's/^/  /'
        done
    fi
else
    print_info "No resource quotas configured"
fi
echo ""

# Persistent Volume Claims Check
print_info "=== Persistent Volume Claims Check ==="
PVCS=$(kubectl get pvc -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")
if [ -n "$PVCS" ]; then
    for pvc in $PVCS; do
        PVC_STATUS=$(kubectl get pvc "$pvc" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")
        if [ "$PVC_STATUS" = "Bound" ]; then
            print_success "PVC $pvc is Bound"
        else
            print_error "PVC $pvc is $PVC_STATUS (not Bound)"
        fi
    done
else
    print_info "No PVCs configured (expected for this deployment)"
fi
echo ""

# Summary
print_info "=== Verification Summary ==="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        print_success "All verification checks passed!"
        exit 0
    else
        print_warning "Verification passed with warnings. Review the warnings above."
        exit 0
    fi
else
    print_error "Verification failed. Please review the errors above and fix them."
    exit 1
fi
