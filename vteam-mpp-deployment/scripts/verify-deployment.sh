#!/bin/bash
# Verify vTeam MPP deployment health and configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="${NAMESPACE:-vteam--test1}"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  vTeam MPP Deployment Verification${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "Namespace: ${GREEN}$NAMESPACE${NC}"
echo ""

# Track overall status
ERRORS=0
WARNINGS=0

# Check 1: Namespace exists and is labeled
echo -e "${YELLOW}[1/8] Checking namespace...${NC}"
if ! oc get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo -e "${RED}❌ Namespace $NAMESPACE does not exist${NC}"
    ERRORS=$((ERRORS + 1))
else
    LABELS=$(oc get namespace "$NAMESPACE" --show-labels | grep ambient-code.io/managed || echo "")
    if [ -z "$LABELS" ]; then
        echo -e "${YELLOW}⚠️ Namespace is not labeled for vTeam management${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}✅ Namespace exists and is properly labeled${NC}"
    fi
fi
echo ""

# Check 2: RBAC roles
echo -e "${YELLOW}[2/8] Checking RBAC roles...${NC}"
ROLE_COUNT=$(oc get roles -n "$NAMESPACE" 2>/dev/null | grep -c ambient-project || echo "0")
if [ "$ROLE_COUNT" -lt 3 ]; then
    echo -e "${YELLOW}⚠️ Expected 3 RBAC roles, found: $ROLE_COUNT${NC}"
    echo "Expected roles:"
    echo "  - ambient-project-admin"
    echo "  - ambient-project-edit"
    echo "  - ambient-project-view"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ All 3 RBAC roles present${NC}"
    oc get roles -n "$NAMESPACE" | grep ambient-project
fi
echo ""

# Check 3: vTeam platform
echo -e "${YELLOW}[3/8] Checking vTeam platform (ambient-code)...${NC}"
if ! oc get namespace ambient-code >/dev/null 2>&1; then
    echo -e "${RED}❌ vTeam platform namespace not found${NC}"
    ERRORS=$((ERRORS + 1))
else
    BACKEND_READY=$(oc get deployment backend-api -n ambient-code -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    OPERATOR_READY=$(oc get deployment agentic-operator -n ambient-code -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    FRONTEND_READY=$(oc get deployment frontend -n ambient-code -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")

    if [ "$BACKEND_READY" -gt 0 ] && [ "$OPERATOR_READY" -gt 0 ] && [ "$FRONTEND_READY" -gt 0 ]; then
        echo -e "${GREEN}✅ vTeam platform components running${NC}"
        echo "  Backend: $BACKEND_READY ready"
        echo "  Operator: $OPERATOR_READY ready"
        echo "  Frontend: $FRONTEND_READY ready"
    else
        echo -e "${YELLOW}⚠️ Some platform components not ready${NC}"
        echo "  Backend: $BACKEND_READY ready"
        echo "  Operator: $OPERATOR_READY ready"
        echo "  Frontend: $FRONTEND_READY ready"
        WARNINGS=$((WARNINGS + 1))
    fi
fi
echo ""

# Check 4: CRDs
echo -e "${YELLOW}[4/8] Checking Custom Resource Definitions...${NC}"
CRD_COUNT=$(oc get crd 2>/dev/null | grep -c vteam.ambient-code || echo "0")
if [ "$CRD_COUNT" -lt 3 ]; then
    echo -e "${RED}❌ Expected 3 vTeam CRDs, found: $CRD_COUNT${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✅ All vTeam CRDs installed${NC}"
    oc get crd | grep vteam.ambient-code
fi
echo ""

# Check 5: ProjectSettings
echo -e "${YELLOW}[5/8] Checking ProjectSettings...${NC}"
if ! oc get projectsettings default -n "$NAMESPACE" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️ Default ProjectSettings not found${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ ProjectSettings exists${NC}"

    # Check if secrets are configured
    SECRET_REFS=$(oc get projectsettings default -n "$NAMESPACE" -o jsonpath='{.spec.runnerSecretsConfig.secretRefs[*].name}' 2>/dev/null || echo "")
    if [ -z "$SECRET_REFS" ]; then
        echo -e "${YELLOW}⚠️ No runner secrets configured${NC}"
        echo "Configure via: oc create secret generic anthropic-api-key -n $NAMESPACE --from-literal=ANTHROPIC_API_KEY=..."
        WARNINGS=$((WARNINGS + 1))
    else
        echo "  Configured secrets: $SECRET_REFS"
    fi
fi
echo ""

# Check 6: Secrets
echo -e "${YELLOW}[6/8] Checking runner secrets...${NC}"
if ! oc get secret anthropic-api-key -n "$NAMESPACE" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️ Anthropic API key secret not found${NC}"
    echo "Sessions will fail without API key"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ Anthropic API key secret exists${NC}"
fi
echo ""

# Check 7: Permissions
echo -e "${YELLOW}[7/8] Checking your permissions...${NC}"
CURRENT_USER=$(oc whoami)
echo "Current user: $CURRENT_USER"

CAN_CREATE=$(oc auth can-i create agenticsessions -n "$NAMESPACE" 2>/dev/null && echo "yes" || echo "no")
CAN_VIEW=$(oc auth can-i get agenticsessions -n "$NAMESPACE" 2>/dev/null && echo "yes" || echo "no")

if [ "$CAN_CREATE" = "yes" ]; then
    echo -e "${GREEN}✅ You can create sessions (edit or admin role)${NC}"
elif [ "$CAN_VIEW" = "yes" ]; then
    echo -e "${BLUE}ℹ️ You have view-only access${NC}"
else
    echo -e "${YELLOW}⚠️ You don't have access to this namespace${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Check 8: Recent activity
echo -e "${YELLOW}[8/8] Checking recent activity...${NC}"
SESSION_COUNT=$(oc get agenticsessions -n "$NAMESPACE" 2>/dev/null | wc -l || echo "0")
if [ "$SESSION_COUNT" -gt 1 ]; then
    echo -e "${BLUE}Found $((SESSION_COUNT - 1)) agentic session(s)${NC}"
    oc get agenticsessions -n "$NAMESPACE"
else
    echo "No agentic sessions yet"
fi
echo ""

# Summary
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Verification Summary${NC}"
echo -e "${BLUE}=========================================${NC}"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    echo ""
    echo "Ready to create agentic sessions:"
    echo "  vteam-mpp-deployment/scripts/test-session.sh"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️ Deployment functional with $WARNINGS warning(s)${NC}"
    echo ""
    echo "You can proceed with testing, but review warnings above"
else
    echo -e "${RED}❌ Found $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    echo ""
    echo "Fix errors before proceeding"
fi
echo ""

echo -e "${BLUE}Documentation:${NC}"
echo "  vteam-mpp-deployment/00-README.md"
echo ""

exit $ERRORS
