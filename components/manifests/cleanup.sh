#!/bin/bash

# cleanup.sh - vTeam Ambient Agentic Runner Cleanup Script
# Removes all vTeam resources from a Kubernetes/OpenShift cluster

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
FORCE="${FORCE:-false}"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect if we're on OpenShift or vanilla Kubernetes
is_openshift() {
    kubectl get clusterversion >/dev/null 2>&1 || kubectl api-resources | grep -q route.openshift.io
}

print_info "=== vTeam Ambient Agentic Runner Cleanup ==="
print_info "Namespace: $NAMESPACE"
echo ""

# Check prerequisites
print_info "Checking prerequisites..."
if ! command_exists kubectl; then
    print_error "kubectl is not installed. Please install it before proceeding."
    exit 1
fi

if ! command_exists kustomize; then
    print_error "kustomize is not installed. Please install it before proceeding."
    exit 1
fi

if ! kubectl cluster-info >/dev/null 2>&1; then
    print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

print_success "Prerequisites check passed"
echo ""

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    print_warning "Namespace $NAMESPACE does not exist. Nothing to clean up."
    exit 0
fi

# Display what will be deleted
print_warning "=== Resources to be deleted ==="
echo "The following resources will be removed:"
echo ""
echo "  Namespace: $NAMESPACE"
echo "    - All Deployments (backend-api, frontend, agentic-operator)"
echo "    - All Services"
echo "    - All ConfigMaps"
echo "    - All Secrets"
echo "    - All ServiceAccounts"
echo "    - All Roles and RoleBindings"
echo "    - All Custom Resources (AgenticSessions, RFEWorkflows, ProjectSettings)"

if is_openshift; then
    echo "    - All Routes (OpenShift)"
fi

echo ""
echo "  Cluster-scoped resources:"
echo "    - ClusterRoles (backend-api, agentic-operator, ambient-project-*)"
echo "    - ClusterRoleBindings (backend-api, agentic-operator)"
echo "    - CustomResourceDefinitions (agenticsessions, rfeworkflows, projectsettings)"

if is_openshift; then
    echo "    - OAuthClient (ambient-frontend)"
fi

echo ""

# Confirmation prompt (unless FORCE=true)
if [ "$FORCE" != "true" ]; then
    print_warning "This action cannot be undone!"
    read -p "Are you sure you want to delete all vTeam resources from namespace $NAMESPACE? (yes/no) " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "Cleanup cancelled by user."
        exit 0
    fi

    # Double confirmation for cluster-scoped resources
    read -p "This will also delete cluster-scoped resources (CRDs, ClusterRoles, etc.). Continue? (yes/no) " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "Cleanup cancelled by user."
        exit 0
    fi
fi

# Start cleanup
print_info "Starting cleanup process..."
echo ""

# Delete custom resources first (before CRDs are removed)
print_info "=== Deleting Custom Resources ==="

if kubectl get agenticsessions.vteam.ambient-code -n "$NAMESPACE" >/dev/null 2>&1; then
    print_info "Deleting AgenticSessions..."
    kubectl delete agenticsessions.vteam.ambient-code --all -n "$NAMESPACE" --timeout=60s || print_warning "Some AgenticSessions could not be deleted"
else
    print_info "No AgenticSessions to delete"
fi

if kubectl get rfeworkflows.vteam.ambient-code -n "$NAMESPACE" >/dev/null 2>&1; then
    print_info "Deleting RFEWorkflows..."
    kubectl delete rfeworkflows.vteam.ambient-code --all -n "$NAMESPACE" --timeout=60s || print_warning "Some RFEWorkflows could not be deleted"
else
    print_info "No RFEWorkflows to delete"
fi

if kubectl get projectsettings.vteam.ambient-code -n "$NAMESPACE" >/dev/null 2>&1; then
    print_info "Deleting ProjectSettings..."
    kubectl delete projectsettings.vteam.ambient-code --all -n "$NAMESPACE" --timeout=60s || print_warning "Some ProjectSettings could not be deleted"
else
    print_info "No ProjectSettings to delete"
fi

print_success "Custom resources deleted"
echo ""

# Delete namespace-scoped resources using kustomize
print_info "=== Deleting Namespace Resources ==="

cd "$SCRIPT_DIR"

# Adjust namespace in kustomization if needed
ORIGINAL_NAMESPACE=$(grep "^namespace:" kustomization.yaml | awk '{print $2}')
if [ "$NAMESPACE" != "$ORIGINAL_NAMESPACE" ]; then
    print_info "Temporarily updating kustomization namespace to $NAMESPACE..."
    kustomize edit set namespace "$NAMESPACE"
fi

# Delete all resources via kustomize
print_info "Deleting resources via kustomize..."
kustomize build . | kubectl delete -f - --ignore-not-found=true --timeout=120s || print_warning "Some resources could not be deleted via kustomize"

# Restore original namespace in kustomization
if [ "$NAMESPACE" != "$ORIGINAL_NAMESPACE" ] && [ -n "$ORIGINAL_NAMESPACE" ]; then
    print_info "Restoring kustomization namespace to $ORIGINAL_NAMESPACE..."
    kustomize edit set namespace "$ORIGINAL_NAMESPACE"
fi

print_success "Namespace resources deleted"
echo ""

# Delete cluster-scoped resources manually
print_info "=== Deleting Cluster-Scoped Resources ==="

# Delete ClusterRoleBindings
print_info "Deleting ClusterRoleBindings..."
CLUSTERROLEBINDINGS=("backend-api" "agentic-operator")
for crb in "${CLUSTERROLEBINDINGS[@]}"; do
    if kubectl get clusterrolebinding "$crb" >/dev/null 2>&1; then
        kubectl delete clusterrolebinding "$crb" --ignore-not-found=true
        print_success "Deleted ClusterRoleBinding $crb"
    else
        print_info "ClusterRoleBinding $crb not found (already deleted)"
    fi
done

# Delete ClusterRoles
print_info "Deleting ClusterRoles..."
CLUSTERROLES=(
    "backend-api"
    "agentic-operator"
    "ambient-project-admin"
    "ambient-project-edit"
    "ambient-project-view"
    "aggregate-agenticsessions-admin"
    "aggregate-rfeworkflows-admin"
    "aggregate-projectsettings-admin"
)
for cr in "${CLUSTERROLES[@]}"; do
    if kubectl get clusterrole "$cr" >/dev/null 2>&1; then
        kubectl delete clusterrole "$cr" --ignore-not-found=true
        print_success "Deleted ClusterRole $cr"
    else
        print_info "ClusterRole $cr not found (already deleted)"
    fi
done

# Delete CRDs (this will cascade delete all CR instances)
print_info "Deleting CustomResourceDefinitions..."
CRDS=(
    "agenticsessions.vteam.ambient-code"
    "rfeworkflows.vteam.ambient-code"
    "projectsettings.vteam.ambient-code"
)
for crd in "${CRDS[@]}"; do
    if kubectl get crd "$crd" >/dev/null 2>&1; then
        kubectl delete crd "$crd" --timeout=60s --ignore-not-found=true
        print_success "Deleted CRD $crd"
    else
        print_info "CRD $crd not found (already deleted)"
    fi
done

# Delete OAuthClient (OpenShift only)
if is_openshift; then
    print_info "Deleting OAuthClient (OpenShift)..."
    if kubectl get oauthclient ambient-frontend >/dev/null 2>&1; then
        kubectl delete oauthclient ambient-frontend --ignore-not-found=true
        print_success "Deleted OAuthClient ambient-frontend"
    else
        print_info "OAuthClient ambient-frontend not found (already deleted)"
    fi
fi

print_success "Cluster-scoped resources deleted"
echo ""

# Optionally delete the namespace itself
print_info "=== Namespace Deletion ==="
if [ "$FORCE" = "true" ]; then
    print_info "Deleting namespace $NAMESPACE..."
    kubectl delete namespace "$NAMESPACE" --timeout=120s
    print_success "Namespace $NAMESPACE deleted"
else
    read -p "Do you want to delete the namespace $NAMESPACE itself? (yes/no) " -r
    echo
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "Deleting namespace $NAMESPACE..."
        kubectl delete namespace "$NAMESPACE" --timeout=120s
        print_success "Namespace $NAMESPACE deleted"
    else
        print_info "Namespace $NAMESPACE was not deleted. You can delete it manually with:"
        echo "  kubectl delete namespace $NAMESPACE"
    fi
fi

echo ""
print_success "=== Cleanup Complete ==="
echo ""

# Verify cleanup
print_info "Verifying cleanup..."
REMAINING_PODS=$(kubectl get pods -n "$NAMESPACE" 2>/dev/null | grep -v "NAME" | wc -l || echo "0")
REMAINING_CRDS=$(kubectl get crd | grep "vteam.ambient-code" | wc -l || echo "0")

if [ "$REMAINING_PODS" -eq 0 ] && [ "$REMAINING_CRDS" -eq 0 ]; then
    print_success "All vTeam resources have been successfully removed"
else
    if [ "$REMAINING_PODS" -gt 0 ]; then
        print_warning "$REMAINING_PODS pod(s) still exist in namespace $NAMESPACE (may be terminating)"
    fi
    if [ "$REMAINING_CRDS" -gt 0 ]; then
        print_warning "$REMAINING_CRDS vTeam CRD(s) still exist (may be finalizing)"
    fi
    print_info "It may take a few moments for all resources to be fully removed."
fi

print_info "To redeploy vTeam, run: ./deploy.sh"
