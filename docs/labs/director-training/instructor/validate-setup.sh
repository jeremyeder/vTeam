#!/bin/bash
#
# Pre-Training Validation Script
#
# Purpose: Verify participant environment is ready for Director Training
# Usage: curl -sSL https://raw.githubusercontent.com/ambient-code/vTeam/main/docs/labs/director-training/instructor/validate-setup.sh | bash
#
# Checks:
# - Git installation and version
# - OpenShift/Kubernetes CLI tools
# - Container runtime (Docker or Podman)
# - Node.js version
# - Python version
# - Network connectivity
# - OpenShift cluster access (if configured)
#
# Exit codes:
# 0 - All checks passed
# 1 - One or more checks failed
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status tracking
FAILURES=0
WARNINGS=0

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Director Training - Setup Validation${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_failure() {
    echo -e "${RED}❌ $1${NC}"
    FAILURES=$((FAILURES + 1))
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_command() {
    local cmd=$1
    local friendly_name=$2
    local min_version=$3

    if command -v "$cmd" &> /dev/null; then
        local version
        version=$("$cmd" --version 2>&1 | head -n 1)
        print_success "$friendly_name: $version"
        return 0
    else
        print_failure "$friendly_name: Not found (expected $min_version or later)"
        return 1
    fi
}

check_git() {
    if command -v git &> /dev/null; then
        local git_version
        git_version=$(git --version | awk '{print $3}')
        local major_version
        major_version=$(echo "$git_version" | cut -d. -f1)
        local minor_version
        minor_version=$(echo "$git_version" | cut -d. -f2)

        if [ "$major_version" -ge 2 ] && [ "$minor_version" -ge 30 ]; then
            print_success "Git: v$git_version"
        else
            print_warning "Git: v$git_version (2.30+ recommended)"
        fi
    else
        print_failure "Git: Not found (required 2.30+)"
    fi
}

check_oc_kubectl() {
    local has_oc=false
    local has_kubectl=false

    if command -v oc &> /dev/null; then
        local oc_version
        oc_version=$(oc version --client 2>&1 | grep -i "client version" | head -n 1 || echo "unknown")
        print_success "oc CLI: $oc_version"
        has_oc=true
    else
        print_info "oc CLI: Not found (OpenShift CLI)"
    fi

    if command -v kubectl &> /dev/null; then
        local kubectl_version
        kubectl_version=$(kubectl version --client 2>&1 | grep -i "client version" | head -n 1 || kubectl version --client 2>&1 | head -n 1)
        print_success "kubectl: $kubectl_version"
        has_kubectl=true
    else
        print_info "kubectl: Not found (Kubernetes CLI)"
    fi

    if [ "$has_oc" = false ] && [ "$has_kubectl" = false ]; then
        print_failure "Neither oc nor kubectl found (at least one required)"
    fi
}

check_container_runtime() {
    local has_runtime=false

    if command -v docker &> /dev/null; then
        local docker_version
        docker_version=$(docker --version 2>&1)
        print_success "Docker: $docker_version"
        has_runtime=true
    fi

    if command -v podman &> /dev/null; then
        local podman_version
        podman_version=$(podman --version 2>&1)
        print_success "Podman: $podman_version"
        has_runtime=true
    fi

    if [ "$has_runtime" = false ]; then
        print_failure "Container runtime: Neither Docker nor Podman found"
    fi
}

check_node() {
    if command -v node &> /dev/null; then
        local node_version
        node_version=$(node --version | sed 's/v//')
        local major_version
        major_version=$(echo "$node_version" | cut -d. -f1)

        if [ "$major_version" -ge 20 ]; then
            print_success "Node.js: v$node_version"
        else
            print_warning "Node.js: v$node_version (20+ recommended)"
        fi
    else
        print_failure "Node.js: Not found (required 20+)"
    fi
}

check_python() {
    local python_cmd=""

    # Try python3 first
    if command -v python3 &> /dev/null; then
        python_cmd="python3"
    elif command -v python &> /dev/null; then
        python_cmd="python"
    fi

    if [ -n "$python_cmd" ]; then
        local python_version
        python_version=$($python_cmd --version 2>&1 | awk '{print $2}')
        local major_version
        major_version=$(echo "$python_version" | cut -d. -f1)
        local minor_version
        minor_version=$(echo "$python_version" | cut -d. -f2)

        if [ "$major_version" -eq 3 ] && [ "$minor_version" -ge 11 ]; then
            print_success "Python: v$python_version"
        else
            print_warning "Python: v$python_version (3.11+ recommended)"
        fi
    else
        print_failure "Python: Not found (required 3.11+)"
    fi
}

check_network() {
    print_info "Testing network connectivity..."

    # Test general internet connectivity
    if curl -sSf -m 5 https://www.google.com > /dev/null 2>&1; then
        print_success "Network: Internet connectivity verified"
    else
        print_failure "Network: Cannot reach internet"
        return
    fi

    # Note: Anthropic endpoint checks removed - Cloudflare protection blocks curl
    # HEAD requests. API connectivity will be verified during actual training usage.
}

check_cluster_access() {
    print_info "Testing OpenShift/Kubernetes cluster access..."

    # Try oc first
    if command -v oc &> /dev/null; then
        if oc whoami &> /dev/null; then
            local current_user
            current_user=$(oc whoami)
            local cluster_url
            cluster_url=$(oc whoami --show-server 2>&1 || echo "unknown")
            print_success "Cluster Access: Authenticated as $current_user"
            print_info "Cluster URL: $cluster_url"

            # Check if can create resources in a namespace
            if oc auth can-i create pods &> /dev/null; then
                print_success "Cluster Permissions: Can create pods"
            else
                print_warning "Cluster Permissions: Cannot create pods (may need namespace access)"
            fi
        else
            print_info "Cluster Access: Not logged in (will use shared training cluster)"
        fi
    elif command -v kubectl &> /dev/null; then
        if kubectl cluster-info &> /dev/null; then
            print_success "Cluster Access: Connected to Kubernetes cluster"

            if kubectl auth can-i create pods &> /dev/null; then
                print_success "Cluster Permissions: Can create pods"
            else
                print_warning "Cluster Permissions: Cannot create pods (may need namespace access)"
            fi
        else
            print_info "Cluster Access: Not connected (will use shared training cluster)"
        fi
    else
        print_info "Cluster Access: No CLI tool available (will configure during training)"
    fi
}

check_disk_space() {
    print_info "Checking disk space..."

    # Get available space in home directory (in GB)
    local available_gb
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        available_gb=$(df -g ~ | awk 'NR==2 {print $4}')
    else
        # Linux
        available_gb=$(df -BG ~ | awk 'NR==2 {print $4}' | sed 's/G//')
    fi

    if [ "$available_gb" -ge 20 ]; then
        print_success "Disk Space: ${available_gb}GB available (20GB+ required)"
    else
        print_warning "Disk Space: ${available_gb}GB available (20GB recommended)"
    fi
}

check_api_key() {
    print_info "Checking for Anthropic API key..."

    if [ -n "$ANTHROPIC_API_KEY" ]; then
        print_success "ANTHROPIC_API_KEY: Environment variable is set"

        # Optional: Validate the key format (should start with sk-)
        if [[ $ANTHROPIC_API_KEY == sk-* ]]; then
            print_success "ANTHROPIC_API_KEY: Format looks correct"
        else
            print_warning "ANTHROPIC_API_KEY: Format may be incorrect (should start with 'sk-')"
        fi
    else
        print_info "ANTHROPIC_API_KEY: Not set (you'll configure this during training)"
        print_info "Get your key at: https://console.anthropic.com/"
    fi
}

print_summary() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Validation Summary${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    if [ $FAILURES -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        print_success "All prerequisites met! You're ready for training."
        echo ""
        print_info "Next steps:"
        echo "  1. Save your Anthropic API key (https://console.anthropic.com/)"
        echo "  2. Review pre-work at: docs/labs/director-training/00-prework.md"
        echo "  3. Bring your laptop (fully charged) on training day"
        echo ""
        return 0
    elif [ $FAILURES -eq 0 ] && [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $WARNINGS warning(s) found - review above${NC}"
        echo ""
        print_info "You can proceed with training, but consider addressing warnings."
        echo ""
        return 0
    else
        echo -e "${RED}❌ $FAILURES critical issue(s) found${NC}"
        if [ $WARNINGS -gt 0 ]; then
            echo -e "${YELLOW}⚠️  $WARNINGS warning(s) found${NC}"
        fi
        echo ""
        print_info "Please address critical issues before training day."
        print_info "Refer to: docs/labs/director-training/00-prework.md"
        echo ""
        print_info "Need help? Contact your training coordinator."
        echo ""
        return 1
    fi
}

# Main execution
main() {
    print_header

    print_info "Validating your environment for Director Training..."
    echo ""

    # Run all checks
    check_git
    check_oc_kubectl
    check_container_runtime
    check_node
    check_python
    check_disk_space
    check_network
    check_cluster_access
    check_api_key

    # Print summary and exit
    print_summary
    exit $?
}

# Run main function
main
