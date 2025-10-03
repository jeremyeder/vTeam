#!/bin/bash
# Deploy vTeam to MPP Staging Environment (vteam--test1)
# This script automates the deployment steps from the MPP deployment guide

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="${NAMESPACE:-vteam--test1}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  vTeam MPP Staging Deployment${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "Target namespace: ${GREEN}$NAMESPACE${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v oc >/dev/null 2>&1; then
    echo -e "${RED}❌ OpenShift CLI (oc) not found${NC}"
    echo "Install from: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/"
    exit 1
fi

if ! command -v kustomize >/dev/null 2>&1; then
    echo -e "${RED}❌ Kustomize not found${NC}"
    echo "Install from: https://kubectl.docs.kubernetes.io/installation/kustomize/"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"
echo ""

# Check cluster authentication
echo -e "${YELLOW}Checking OpenShift authentication...${NC}"
if ! oc whoami >/dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to OpenShift${NC}"
    echo "Please run: oc login <cluster-url>"
    exit 1
fi

CURRENT_USER=$(oc whoami)
echo -e "${GREEN}✅ Authenticated as: $CURRENT_USER${NC}"
echo ""

# Step 1: Create namespace
echo -e "${YELLOW}Step 1: Creating namespace...${NC}"
if ! oc get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "Creating namespace: $NAMESPACE"
    oc create namespace "$NAMESPACE"

    # Label namespace for vTeam operator
    oc label namespace "$NAMESPACE" \
        ambient-code.io/managed=true \
        ambient-code.io/project="$NAMESPACE"

    echo -e "${GREEN}✅ Namespace created and labeled${NC}"
else
    echo -e "${BLUE}Namespace $NAMESPACE already exists${NC}"

    # Ensure labels are set
    oc label namespace "$NAMESPACE" \
        ambient-code.io/managed=true \
        ambient-code.io/project="$NAMESPACE" \
        --overwrite
fi
echo ""

# Step 2: Deploy RBAC roles
echo -e "${YELLOW}Step 2: Deploying RBAC roles...${NC}"
cd "$PROJECT_ROOT/vteam-mpp-deployment"

for role in roles/*.yaml; do
    echo "Applying $(basename $role)..."
    sed "s/namespace: vteam--test1/namespace: $NAMESPACE/g" "$role" | oc apply -f -
done

echo -e "${GREEN}✅ RBAC roles deployed${NC}"
echo ""

# Step 3: Verify vTeam platform is running
echo -e "${YELLOW}Step 3: Verifying vTeam platform components...${NC}"

if ! oc get namespace ambient-code >/dev/null 2>&1; then
    echo -e "${RED}❌ vTeam platform (ambient-code namespace) not found${NC}"
    echo "Deploy the vTeam platform first:"
    echo "  cd $PROJECT_ROOT"
    echo "  make deploy"
    exit 1
fi

# Check CRDs
echo "Checking CRDs..."
if ! oc get crd agenticsessions.vteam.ambient-code >/dev/null 2>&1; then
    echo -e "${RED}❌ vTeam CRDs not found${NC}"
    echo "Deploy the vTeam platform first: make deploy"
    exit 1
fi

# Check platform pods
echo "Checking platform pods..."
POD_STATUS=$(oc get pods -n ambient-code --no-headers 2>/dev/null || echo "")
if [ -z "$POD_STATUS" ]; then
    echo -e "${YELLOW}⚠️ No pods found in ambient-code namespace${NC}"
else
    echo "$POD_STATUS"
fi

echo -e "${GREEN}✅ vTeam platform verified${NC}"
echo ""

# Step 4: Create ProjectSettings
echo -e "${YELLOW}Step 4: Creating ProjectSettings...${NC}"

if ! oc get projectsettings default -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "Creating default ProjectSettings..."
    cat <<EOF | oc apply -f -
apiVersion: vteam.ambient-code/v1
kind: ProjectSettings
metadata:
  name: default
  namespace: $NAMESPACE
spec:
  runnerSecretsConfig:
    secretRefs: []
EOF
    echo -e "${GREEN}✅ ProjectSettings created${NC}"
else
    echo -e "${BLUE}ProjectSettings already exists${NC}"
fi
echo ""

# Step 5: Deployment summary
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Deployment Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

echo -e "${BLUE}Namespace Status:${NC}"
oc get namespace "$NAMESPACE" --show-labels
echo ""

echo -e "${BLUE}RBAC Roles:${NC}"
oc get roles -n "$NAMESPACE"
echo ""

echo -e "${BLUE}Custom Resources:${NC}"
oc get projectsettings,agenticsessions,rfeworkflows -n "$NAMESPACE" 2>/dev/null || echo "  (none yet)"
echo ""

# Next steps
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo -e "${BLUE}1. Configure runner secrets:${NC}"
echo "   Option A - Via CLI (requires admin role):"
echo "   oc create secret generic anthropic-api-key \\"
echo "     -n $NAMESPACE \\"
echo "     --from-literal=ANTHROPIC_API_KEY=sk-ant-your-key"
echo ""
echo "   Option B - Via Web UI:"
echo "   - Access vTeam frontend"
echo "   - Switch to project: $NAMESPACE"
echo "   - Settings → Runner Secrets"
echo "   - Add Anthropic API key"
echo ""

echo -e "${BLUE}2. Grant user access (optional):${NC}"
echo "   # Grant edit access to a user"
echo "   oc create rolebinding user-edit \\"
echo "     -n $NAMESPACE \\"
echo "     --role=ambient-project-edit \\"
echo "     --user=alice@example.com"
echo ""

echo -e "${BLUE}3. Test deployment:${NC}"
echo "   Run the test script:"
echo "   $SCRIPT_DIR/test-session.sh"
echo ""

echo -e "${BLUE}4. Monitor deployment:${NC}"
echo "   oc get pods,jobs -n $NAMESPACE -w"
echo ""

echo -e "${GREEN}Deployment guide: vteam-mpp-deployment/00-README.md${NC}"
