#!/bin/bash
# ACP Training Setup Verification
# Ensures everything is ready for executive training

echo "🔍 ACP Training Setup Verification"
echo "=================================="
echo ""

ERRORS=0
WARNINGS=0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check commands
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✅${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}❌${NC} $1 is NOT installed"
        ((ERRORS++))
        return 1
    fi
}

echo "System Prerequisites:"
echo "--------------------"
check_command git
check_command python3
check_command node
check_command uv

# Check Python version
echo ""
echo "Python Version Check:"
echo "--------------------"
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 11 ]; then
    echo -e "${GREEN}✅${NC} Python $PYTHON_VERSION (3.11+ required)"
else
    echo -e "${RED}❌${NC} Python $PYTHON_VERSION is too old (need 3.11+)"
    ((ERRORS++))
fi

# Check directories
echo ""
echo "Repository Structure:"
echo "--------------------"
if [ -d "$HOME/acp-training/vTeam" ]; then
    echo -e "${GREEN}✅${NC} vTeam repository exists"
    
    # Check if it's actually a git repo
    if [ -d "$HOME/acp-training/vTeam/.git" ]; then
        echo -e "${GREEN}✅${NC} vTeam is a valid git repository"
    else
        echo -e "${YELLOW}⚠️${NC}  vTeam directory exists but not a git repo"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}❌${NC} vTeam repository missing"
    ((ERRORS++))
fi

if [ -d "$HOME/acp-training/patternfly-react-seed" ]; then
    echo -e "${GREEN}✅${NC} PatternFly repository exists"
else
    echo -e "${RED}❌${NC} PatternFly repository missing"
    ((ERRORS++))
fi

# Check Python environment
echo ""
echo "Python Environment:"
echo "------------------"
VTEAM_DIR="$HOME/acp-training/vTeam/demos/rfe-builder"
if [ -d "$VTEAM_DIR/.venv" ] || [ -d "$VTEAM_DIR/venv" ]; then
    echo -e "${GREEN}✅${NC} Python virtual environment exists"
    
    # Check if key packages are installed
    if [ -f "$VTEAM_DIR/pyproject.toml" ]; then
        echo -e "${GREEN}✅${NC} Project configuration found"
    else
        echo -e "${YELLOW}⚠️${NC}  pyproject.toml missing"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠️${NC}  Python environment not found - run: cd $VTEAM_DIR && uv sync"
    ((WARNINGS++))
fi

# Check API keys
echo ""
echo "API Configuration:"
echo "-----------------"
ENV_FILE="$HOME/acp-training/vTeam/demos/rfe-builder/src/.env"
if [ -f "$ENV_FILE" ]; then
    echo -e "${GREEN}✅${NC} .env file exists"
    
    # Check for Anthropic key
    if grep -q "ANTHROPIC_API_KEY=sk-ant-api03-" "$ENV_FILE" 2>/dev/null; then
        if grep -q "ANTHROPIC_API_KEY=sk-ant-api03-YOUR" "$ENV_FILE" 2>/dev/null; then
            echo -e "${YELLOW}⚠️${NC}  Anthropic API key is still a placeholder"
            ((WARNINGS++))
        else
            echo -e "${GREEN}✅${NC} Anthropic API key configured"
        fi
    else
        echo -e "${YELLOW}⚠️${NC}  Anthropic API key not configured"
        ((WARNINGS++))
    fi
    
    # Check for OpenAI key
    if grep -q "OPENAI_API_KEY=sk-" "$ENV_FILE" 2>/dev/null; then
        if grep -q "OPENAI_API_KEY=sk-YOUR" "$ENV_FILE" 2>/dev/null; then
            echo -e "${YELLOW}⚠️${NC}  OpenAI API key is still a placeholder"
            ((WARNINGS++))
        else
            echo -e "${GREEN}✅${NC} OpenAI API key configured"
        fi
    else
        echo -e "${YELLOW}⚠️${NC}  OpenAI API key not configured"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}❌${NC} .env file missing at: $ENV_FILE"
    echo "    Create it with:"
    echo "    cp $VTEAM_DIR/src/.env.example $ENV_FILE"
    ((ERRORS++))
fi

# Network connectivity check
echo ""
echo "Network Connectivity:"
echo "--------------------"
if ping -c 1 github.com &> /dev/null; then
    echo -e "${GREEN}✅${NC} Can reach GitHub"
else
    echo -e "${YELLOW}⚠️${NC}  Cannot reach GitHub - check network/proxy"
    ((WARNINGS++))
fi

if ping -c 1 api.anthropic.com &> /dev/null; then
    echo -e "${GREEN}✅${NC} Can reach Anthropic API"
else
    echo -e "${YELLOW}⚠️${NC}  Cannot reach Anthropic API"
    ((WARNINGS++))
fi

# Port availability
echo ""
echo "Port Availability:"
echo "-----------------"
if lsof -Pi :4501 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️${NC}  Port 4501 is in use (needed for LlamaDeploy)"
    echo "    Kill existing process: pkill -f llama_deploy"
    ((WARNINGS++))
else
    echo -e "${GREEN}✅${NC} Port 4501 is available"
fi

# Quick functionality test
echo ""
echo "Quick Functionality Test:"
echo "------------------------"
cd "$VTEAM_DIR" 2>/dev/null
if [ $? -eq 0 ]; then
    # Try to import key packages
    python3 -c "import llama_deploy" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅${NC} LlamaDeploy is importable"
    else
        echo -e "${YELLOW}⚠️${NC}  LlamaDeploy not installed - run: uv sync"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠️${NC}  Cannot access vTeam directory"
    ((WARNINGS++))
fi

# Final summary
echo ""
echo "=================================="
echo "Setup Verification Summary:"
echo "=================================="

if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}🎉 Perfect! All checks passed.${NC}"
        echo "You're 100% ready for the ACP Executive Training!"
    else
        echo -e "${YELLOW}✅ Setup mostly complete with $WARNINGS warnings.${NC}"
        echo ""
        echo "Recommended actions before training:"
        echo "1. Configure your API keys in:"
        echo "   $ENV_FILE"
        echo ""
        echo "2. Test the platform startup:"
        echo "   cd $VTEAM_DIR"
        echo "   uv run -m llama_deploy.apiserver"
    fi
else
    echo -e "${RED}❌ Setup incomplete: $ERRORS critical errors found.${NC}"
    echo ""
    echo "Required actions:"
    echo "1. Run the setup script again:"
    echo "   ~/acp-training/setup-acp-training.sh"
    echo ""
    echo "2. If errors persist, contact:"
    echo "   Slack: @jeder"
    echo "   Email: jeder@redhat.com"
fi

if [ $WARNINGS -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Warnings detected: $WARNINGS issues may affect training experience.${NC}"
fi

# Provide next steps
echo ""
echo "Next Steps:"
echo "-----------"
echo "1. If you see warnings, configure your API keys:"
echo "   vi $ENV_FILE"
echo ""
echo "2. Optional: Test the platform:"
echo "   cd $VTEAM_DIR"
echo "   uv run -m llama_deploy.apiserver"
echo ""
echo "3. Bring your laptop + charger to training"
echo ""
echo "Training Quick Reference:"
echo "   Date: [Check calendar invite]"
echo "   Duration: 2.5 hours"
echo "   Location: [Check calendar invite]"
echo ""
echo "See you at the training! 🚀"

# Exit with appropriate code
if [ $ERRORS -gt 0 ]; then
    exit 1
else
    exit 0
fi
