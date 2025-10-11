#!/bin/bash
# Ambient Code Platform Training Setup
# Works on macOS and Linux (Fedora/RHEL)
# Jeremy Eder - jeder@redhat.com

set -e

echo "🚀 Ambient Code Platform - Executive Training Setup"
echo "=================================================="
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo "📱 Detected macOS"
    INSTALL_CMD="brew install"
    PYTHON_CMD="python3"
else
    OS="linux"
    echo "🐧 Detected Linux"
    if command -v dnf &> /dev/null; then
        INSTALL_CMD="sudo dnf install -y"
    elif command -v apt &> /dev/null; then
        INSTALL_CMD="sudo apt install -y"
    else
        echo "❌ Unsupported Linux distribution. Please install dependencies manually."
        exit 1
    fi
    PYTHON_CMD="python3"
fi

echo ""
echo "📋 Checking prerequisites..."
echo "----------------------------"

# Function to check and install commands
check_command() {
    local cmd=$1
    local package=$2
    
    if ! command -v $cmd &> /dev/null; then
        echo "  ❌ $cmd not found. Installing..."
        if [ "$OS" == "macos" ]; then
            if ! command -v brew &> /dev/null; then
                echo "  📦 Installing Homebrew first..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
        fi
        $INSTALL_CMD $package
        echo "  ✅ $cmd installed"
    else
        echo "  ✅ $cmd found"
    fi
}

# Check required commands
check_command git git
check_command $PYTHON_CMD python3
check_command node nodejs

# Check Python version
PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | awk '{print $2}')
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 11 ]); then
    echo "  ❌ Python 3.11+ required. Current version: $PYTHON_VERSION"
    exit 1
else
    echo "  ✅ Python $PYTHON_VERSION"
fi

# Install uv if not present
if ! command -v uv &> /dev/null; then
    echo ""
    echo "📦 Installing uv (Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add to PATH for current session
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Add to shell profile
    if [ "$OS" == "macos" ]; then
        SHELL_PROFILE="$HOME/.zshrc"
    else
        SHELL_PROFILE="$HOME/.bashrc"
    fi
    
    if ! grep -q ".cargo/bin" "$SHELL_PROFILE"; then
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$SHELL_PROFILE"
        echo "  ✅ uv added to $SHELL_PROFILE"
    fi
    
    echo "  ✅ uv installed"
else
    echo "  ✅ uv found"
fi

# Create training directory
echo ""
echo "📁 Setting up training workspace..."
echo "-----------------------------------"

TRAINING_DIR="$HOME/acp-training"
mkdir -p "$TRAINING_DIR"
cd "$TRAINING_DIR"
echo "  ✅ Created $TRAINING_DIR"

# Clone repositories
echo ""
echo "📥 Cloning required repositories..."
echo "-----------------------------------"

if [ ! -d "vTeam" ]; then
    echo "  📦 Cloning vTeam repository..."
    git clone https://github.com/ambient-code/vTeam.git
    echo "  ✅ vTeam cloned"
else
    echo "  ✅ vTeam already exists"
    cd vTeam && git pull && cd ..
fi

if [ ! -d "patternfly-react-seed" ]; then
    echo "  📦 Cloning PatternFly React Seed..."
    git clone https://github.com/patternfly/patternfly-react-seed.git
    echo "  ✅ PatternFly cloned"
else
    echo "  ✅ PatternFly already exists"
    cd patternfly-react-seed && git pull && cd ..
fi

# Set up vTeam environment
echo ""
echo "🔧 Setting up vTeam environment..."
echo "----------------------------------"

cd "$TRAINING_DIR/vTeam/demos/rfe-builder"

if [ ! -d ".venv" ]; then
    echo "  📦 Creating Python environment with uv..."
    uv sync
    echo "  ✅ Environment created"
else
    echo "  ✅ Environment exists, updating..."
    uv sync
fi

# Check for API keys
echo ""
echo "🔑 API Key Configuration"
echo "------------------------"

ENV_FILE="$TRAINING_DIR/vTeam/demos/rfe-builder/src/.env"

if [ -f "$ENV_FILE" ]; then
    echo "  ✅ .env file exists"
    
    # Check if keys are set (not their values)
    if grep -q "ANTHROPIC_API_KEY=" "$ENV_FILE"; then
        echo "  ✅ ANTHROPIC_API_KEY is configured"
    else
        echo "  ⚠️  ANTHROPIC_API_KEY not found in .env"
    fi
    
    if grep -q "OPENAI_API_KEY=" "$ENV_FILE"; then
        echo "  ✅ OPENAI_API_KEY is configured"
    else
        echo "  ⚠️  OPENAI_API_KEY not found in .env"
    fi
else
    echo "  ❌ .env file not found"
    echo ""
    echo "  Creating template .env file..."
    
    cat > "$ENV_FILE" << 'EOF'
# Ambient Code Platform API Keys
# Get these from the links below:

# Anthropic Claude API
# https://console.anthropic.com/
ANTHROPIC_API_KEY=sk-ant-api03-YOUR-KEY-HERE

# OpenAI API  
# https://platform.openai.com/
OPENAI_API_KEY=sk-YOUR-KEY-HERE

# Optional: Google Vertex AI
# VERTEX_PROJECT_ID=your-gcp-project-id
# VERTEX_LOCATION=us-central1
EOF
    
    echo "  ✅ Template .env created at:"
    echo "     $ENV_FILE"
fi

# Generate embeddings if data directory exists
echo ""
echo "📊 Checking document embeddings..."
echo "----------------------------------"

if [ -d "$TRAINING_DIR/vTeam/demos/rfe-builder/data" ]; then
    cd "$TRAINING_DIR/vTeam/demos/rfe-builder"
    
    # Check if embeddings exist
    if [ -d "chroma_db" ] || [ -d ".chroma" ]; then
        echo "  ✅ Embeddings already exist"
    else
        echo "  📦 Generating document embeddings..."
        echo "  ⚠️  This requires valid API keys in .env"
        
        # Only run if API keys are configured
        if grep -q "sk-ant-api03-[^Y]" "$ENV_FILE" 2>/dev/null || grep -q "sk-[^Y]" "$ENV_FILE" 2>/dev/null; then
            uv run generate || echo "  ⚠️  Could not generate embeddings. Check API keys."
        else
            echo "  ⚠️  Skipping embedding generation - API keys not configured"
        fi
    fi
else
    echo "  ℹ️  No data directory found - embeddings generation skipped"
fi

# Create verification script
echo ""
echo "✅ Creating verification script..."
echo "----------------------------------"

VERIFY_SCRIPT="$TRAINING_DIR/verify-setup.sh"
cat > "$VERIFY_SCRIPT" << 'VERIFY_EOF'
#!/bin/bash
# ACP Training Setup Verification

echo "🔍 Verifying ACP Training Setup"
echo "================================"
echo ""

ERRORS=0
WARNINGS=0

# Check commands
check_command() {
    if command -v $1 &> /dev/null; then
        echo "✅ $1 is installed"
    else
        echo "❌ $1 is NOT installed"
        ((ERRORS++))
    fi
}

echo "Prerequisites:"
check_command git
check_command python3
check_command node
check_command uv

# Check Python version
echo ""
echo "Python Version:"
python3 --version

# Check directories
echo ""
echo "Directory Structure:"
if [ -d "$HOME/acp-training/vTeam" ]; then
    echo "✅ vTeam repository exists"
else
    echo "❌ vTeam repository missing"
    ((ERRORS++))
fi

if [ -d "$HOME/acp-training/patternfly-react-seed" ]; then
    echo "✅ PatternFly repository exists"
else
    echo "❌ PatternFly repository missing"
    ((ERRORS++))
fi

# Check API keys
echo ""
echo "API Configuration:"
ENV_FILE="$HOME/acp-training/vTeam/demos/rfe-builder/src/.env"
if [ -f "$ENV_FILE" ]; then
    echo "✅ .env file exists"
    
    if grep -q "ANTHROPIC_API_KEY=sk-ant-api03-[^Y]" "$ENV_FILE" 2>/dev/null; then
        echo "✅ Anthropic API key appears configured"
    else
        echo "⚠️  Anthropic API key needs configuration"
        ((WARNINGS++))
    fi
    
    if grep -q "OPENAI_API_KEY=sk-[^Y]" "$ENV_FILE" 2>/dev/null; then
        echo "✅ OpenAI API key appears configured"
    else
        echo "⚠️  OpenAI API key needs configuration"
        ((WARNINGS++))
    fi
else
    echo "❌ .env file missing"
    ((ERRORS++))
fi

# Test platform startup (quick check only)
echo ""
echo "Platform Quick Check:"
cd "$HOME/acp-training/vTeam/demos/rfe-builder" 2>/dev/null
if [ -d ".venv" ] || [ -d "venv" ]; then
    echo "✅ Python environment exists"
else
    echo "⚠️  Python environment not found"
    ((WARNINGS++))
fi

# Summary
echo ""
echo "================================"
echo "Summary:"
if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo "✅ All checks passed! You're ready for training."
    else
        echo "⚠️  Setup complete with $WARNINGS warnings."
        echo "   Please configure API keys before training."
    fi
else
    echo "❌ Setup incomplete: $ERRORS errors found."
    echo "   Please run setup-acp-training.sh again."
fi

echo ""
echo "Next steps:"
echo "1. Configure API keys in: $ENV_FILE"
echo "2. Test the platform:"
echo "   cd ~/acp-training/vTeam/demos/rfe-builder"
echo "   uv run -m llama_deploy.apiserver"
VERIFY_EOF

chmod +x "$VERIFY_SCRIPT"
echo "  ✅ Created $VERIFY_SCRIPT"

# Final summary
echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "✅ Training workspace: $TRAINING_DIR"
echo "✅ Verification script: $VERIFY_SCRIPT"
echo ""
echo "⚠️  REQUIRED ACTIONS:"
echo "-------------------"
echo ""
echo "1. Get your API keys:"
echo "   • Anthropic: https://console.anthropic.com/"
echo "   • OpenAI: https://platform.openai.com/"
echo ""
echo "2. Add them to your .env file:"
echo "   $ENV_FILE"
echo ""
echo "3. Verify your setup:"
echo "   $VERIFY_SCRIPT"
echo ""
echo "📚 Training materials will be provided at the session."
echo "💬 Questions? Slack @jeder"
echo ""
echo "See you at the training! 🚀"
