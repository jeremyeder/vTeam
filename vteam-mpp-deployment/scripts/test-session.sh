#!/bin/bash
# Test vTeam MPP deployment by creating and monitoring a test agentic session

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="${NAMESPACE:-vteam--test1}"
SESSION_NAME="test-session-$(date +%s)"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  vTeam End-to-End Test${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "Namespace: ${GREEN}$NAMESPACE${NC}"
echo -e "Session: ${GREEN}$SESSION_NAME${NC}"
echo ""

# Check prerequisites
if ! command -v oc >/dev/null 2>&1; then
    echo -e "${RED}❌ OpenShift CLI (oc) not found${NC}"
    exit 1
fi

if ! oc whoami >/dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to OpenShift${NC}"
    exit 1
fi

# Verify namespace exists
if ! oc get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo -e "${RED}❌ Namespace $NAMESPACE does not exist${NC}"
    echo "Run deployment script first: vteam-mpp-deployment/scripts/deploy-staging.sh"
    exit 1
fi

# Check permissions
echo -e "${YELLOW}Checking permissions...${NC}"
if ! oc auth can-i create agenticsessions -n "$NAMESPACE" >/dev/null 2>&1; then
    echo -e "${RED}❌ You don't have permission to create AgenticSessions in $NAMESPACE${NC}"
    echo "Ask an admin to grant you access:"
    echo "  oc create rolebinding $(oc whoami | cut -d: -f2)-edit \\"
    echo "    -n $NAMESPACE \\"
    echo "    --role=ambient-project-edit \\"
    echo "    --user=$(oc whoami)"
    exit 1
fi
echo -e "${GREEN}✅ Permissions verified${NC}"
echo ""

# Create test session
echo -e "${YELLOW}Creating test agentic session...${NC}"
cat <<EOF | oc apply -f -
apiVersion: vteam.ambient-code/v1
kind: AgenticSession
metadata:
  name: $SESSION_NAME
  namespace: $NAMESPACE
spec:
  prompt: "List the files in the current directory and provide a brief description of the project structure. This is a test session to verify the vTeam deployment."
  model: "claude-sonnet-4"
  timeout: 300
EOF

echo -e "${GREEN}✅ Session created: $SESSION_NAME${NC}"
echo ""

# Monitor session
echo -e "${YELLOW}Monitoring session status...${NC}"
echo "Press Ctrl+C to stop monitoring"
echo ""

# Wait for job to be created
MAX_WAIT=60
WAIT_COUNT=0
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    JOB_NAME=$(oc get jobs -n "$NAMESPACE" -l agenticsession="$SESSION_NAME" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

    if [ -n "$JOB_NAME" ]; then
        echo -e "${GREEN}Job created: $JOB_NAME${NC}"
        break
    fi

    sleep 2
    WAIT_COUNT=$((WAIT_COUNT + 2))
    echo "Waiting for job creation... ($WAIT_COUNT/$MAX_WAIT seconds)"
done

if [ -z "$JOB_NAME" ]; then
    echo -e "${YELLOW}⚠️ Job not created after $MAX_WAIT seconds${NC}"
    echo "This could indicate:"
    echo "  1. Missing runner secrets (Anthropic API key)"
    echo "  2. Operator not watching this namespace"
    echo "  3. ProjectSettings not configured"
    echo ""
    echo "Check operator logs:"
    echo "  oc logs -f deployment/agentic-operator -n ambient-code"
    echo ""
    echo "Check session status:"
    oc get agenticsession "$SESSION_NAME" -n "$NAMESPACE" -o yaml
    exit 1
fi

# Monitor job status
echo ""
echo -e "${YELLOW}Monitoring job execution...${NC}"
echo "Job: $JOB_NAME"
echo ""

# Wait for pod to start
MAX_WAIT=60
WAIT_COUNT=0
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    POD_NAME=$(oc get pods -n "$NAMESPACE" -l job-name="$JOB_NAME" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

    if [ -n "$POD_NAME" ]; then
        echo -e "${GREEN}Pod started: $POD_NAME${NC}"
        break
    fi

    sleep 2
    WAIT_COUNT=$((WAIT_COUNT + 2))
done

if [ -z "$POD_NAME" ]; then
    echo -e "${YELLOW}⚠️ Pod not started after $MAX_WAIT seconds${NC}"
    echo "Check job details:"
    oc describe job "$JOB_NAME" -n "$NAMESPACE"
    exit 1
fi

# Stream logs
echo ""
echo -e "${YELLOW}Streaming pod logs...${NC}"
echo "----------------------------------------"
oc logs -f "$POD_NAME" -n "$NAMESPACE" 2>&1 || echo "Pod completed or failed"
echo "----------------------------------------"
echo ""

# Get final session status
echo -e "${YELLOW}Final session status:${NC}"
SESSION_STATUS=$(oc get agenticsession "$SESSION_NAME" -n "$NAMESPACE" -o jsonpath='{.status.state}' 2>/dev/null || echo "Unknown")
echo "State: $SESSION_STATUS"

if [ "$SESSION_STATUS" = "Completed" ]; then
    echo -e "${GREEN}✅ Test session completed successfully!${NC}"
    echo ""
    echo "View full session details:"
    echo "  oc get agenticsession $SESSION_NAME -n $NAMESPACE -o yaml"
else
    echo -e "${YELLOW}⚠️ Session did not complete successfully${NC}"
    echo "Check session details:"
    echo "  oc describe agenticsession $SESSION_NAME -n $NAMESPACE"
fi

echo ""
echo -e "${BLUE}Cleanup (optional):${NC}"
echo "  oc delete agenticsession $SESSION_NAME -n $NAMESPACE"
