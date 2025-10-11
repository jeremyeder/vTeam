#!/bin/bash
# Test script for custom agents
# Usage: ./test-agent.sh <agent_name> "<rfe_description>"

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo "Usage: $0 <agent_name> \"<rfe_description>\""
    echo "Example: $0 dependency_detective \"Add model versioning to RHOAI\""
    exit 1
fi

AGENT_NAME=$1
RFE_DESCRIPTION=$2
AGENT_FILE="src/agents/${AGENT_NAME}.yaml"

echo -e "${BLUE}🤖 Testing Agent: ${AGENT_NAME}${NC}"
echo "======================================"
echo ""

# Check if agent file exists
if [ ! -f "$AGENT_FILE" ]; then
    echo -e "${RED}✗ Agent file not found: $AGENT_FILE${NC}"
    echo ""
    echo "Available agents:"
    ls -1 src/agents/*.yaml 2>/dev/null || echo "No agents found in src/agents/"
    exit 1
fi

echo -e "${GREEN}✓${NC} Agent file found: $AGENT_FILE"
echo ""

# Validate YAML syntax
echo "Validating agent configuration..."
python3 -c "
import yaml
import sys
try:
    with open('$AGENT_FILE', 'r') as f:
        config = yaml.safe_load(f)
    print('✓ YAML syntax valid')
    print(f'  Name: {config.get(\"name\", \"Unknown\")}')
    print(f'  Role: {config.get(\"role\", \"Unknown\")}')
except Exception as e:
    print(f'✗ YAML error: {e}')
    sys.exit(1)
" || exit 1

echo ""

# Create test script
cat > /tmp/test_agent.py << 'EOF'
import sys
import yaml
import time
from datetime import datetime

def load_agent(agent_file):
    """Load agent configuration from YAML file"""
    with open(agent_file, 'r') as f:
        return yaml.safe_load(f)

def analyze_rfe(agent, rfe_description):
    """Simulate agent analysis of RFE"""
    print(f"Starting analysis at {datetime.now().strftime('%H:%M:%S')}")
    print("-" * 50)
    
    # Simulate processing
    print(f"\n📋 Analyzing RFE: {rfe_description[:100]}...")
    time.sleep(1)
    
    print(f"\n🤖 Agent: {agent['name']}")
    print(f"📌 Role: {agent['role']}")
    print(f"🎯 Specialty: {agent.get('description', 'General analysis')}")
    
    # Show what the agent would analyze
    prompt_template = agent.get('analysisPrompt', {}).get('template', '')
    if prompt_template:
        print("\n🔍 Analysis Focus Areas:")
        # Extract numbered sections from prompt
        import re
        sections = re.findall(r'\d+\.\s+([A-Z\s]+)', prompt_template)
        for i, section in enumerate(sections, 1):
            print(f"   {i}. {section.strip()}")
    
    # Simulate output based on schema
    output_schema = agent.get('outputSchema', {})
    if output_schema:
        print("\n📊 Expected Outputs:")
        for key, value_type in output_schema.items():
            print(f"   • {key}: {value_type}")
    
    # Simulate analysis results
    print("\n💡 Sample Analysis Results:")
    
    if 'dependency' in agent['name'].lower():
        print("   - Technical Dependencies: 8 components identified")
        print("   - Team Dependencies: 4 teams required")
        print("   - Risk Level: MEDIUM")
        print("   - Critical Path: 3 blocking items")
        
    elif 'performance' in agent['name'].lower():
        print("   - Performance Impact: HIGH at 10K+ users")
        print("   - Resource Requirements: 2x current capacity")
        print("   - Bottlenecks: Database writes, API gateway")
        print("   - Cost Projection: $50K/year at scale")
        
    elif 'api' in agent['name'].lower():
        print("   - Breaking Changes: 2 endpoints affected")
        print("   - Version Strategy: Minor version bump (v1.3)")
        print("   - Contract Tests Needed: 5 new tests")
        print("   - Migration Effort: LOW (1 sprint)")
    
    else:
        print("   - Analysis Complete: Key insights generated")
        print("   - Risk Assessment: MEDIUM")
        print("   - Recommendations: 3 action items")
        print("   - Next Steps: Review with team")
    
    print("\n" + "-" * 50)
    print(f"Analysis completed at {datetime.now().strftime('%H:%M:%S')}")
    
    return True

# Main execution
if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python test_agent.py <agent_file> <rfe_description>")
        sys.exit(1)
    
    agent_file = sys.argv[1]
    rfe_description = sys.argv[2]
    
    try:
        agent = load_agent(agent_file)
        analyze_rfe(agent, rfe_description)
        print("\n✅ Agent test successful!")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)
EOF

# Run the test
echo "Running agent analysis..."
echo "========================="
python3 /tmp/test_agent.py "$AGENT_FILE" "$RFE_DESCRIPTION"

echo ""
echo -e "${GREEN}✅ Agent test complete!${NC}"
echo ""
echo "Next steps:"
echo "-----------"
echo "1. Review the analysis output above"
echo "2. Adjust your agent's prompt if needed"
echo "3. Test with more RFE examples"
echo "4. Use in production with the vTeam platform"
echo ""
echo "To use this agent with the full platform:"
echo "  cd ~/acp-training/vTeam/demos/rfe-builder"
echo "  uv run -m llama_deploy.apiserver"
echo ""

# Cleanup
rm -f /tmp/test_agent.py