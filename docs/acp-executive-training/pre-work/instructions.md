# Pre-Work Instructions - ACP Executive Training

**Time Required**: 15 minutes  
**Must Complete By**: 24 hours before training

## Why This Matters

We're going to fix the velocity problem that's been eating 40% of our sprint capacity. But we need your machine ready so we can focus on value, not setup.

## Step 1: Run Setup Script (5 minutes)

Open your terminal and run:

```bash
curl -L https://raw.githubusercontent.com/ambient-code/vTeam/main/training/setup-acp-training.sh | bash
```

This script will:

- ✅ Check your system (macOS or Linux)
- ✅ Install required tools (git, python3, node, uv)
- ✅ Clone the vTeam and PatternFly repositories
- ✅ Set up your Python environment
- ✅ Create a template for API keys

### If the script fails

**On macOS:**

```bash
# Install Homebrew if missing
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install prerequisites
brew install git python@3.11 node

# Try the setup script again
```

**On Fedora/RHEL:**

```bash
# Install prerequisites
sudo dnf install -y git python3 nodejs

# Try the setup script again
```

## Step 2: Get Your API Keys (5 minutes)

You need two API keys. These are YOUR keys - keep them secure.

### Anthropic Claude API Key

1. Go to: <https://console.anthropic.com/>
2. Sign up or sign in
3. Navigate to "API Keys"
4. Create a new key
5. Copy the key (starts with `sk-ant-api03-`)

### OpenAI API Key

1. Go to: <https://platform.openai.com/>
2. Sign up or sign in
3. Navigate to "API Keys"
4. Create a new key
5. Copy the key (starts with `sk-`)

## Step 3: Configure Your Environment (3 minutes)

Add your keys to the environment file:

```bash
# Open the .env file
vi ~/acp-training/vTeam/demos/rfe-builder/src/.env

# Or use your favorite editor
code ~/acp-training/vTeam/demos/rfe-builder/src/.env
```

Replace the placeholder text with your actual keys:

```bash
ANTHROPIC_API_KEY=sk-ant-api03-YOUR-ACTUAL-KEY-HERE
OPENAI_API_KEY=sk-YOUR-ACTUAL-KEY-HERE
```

Save and close the file.

## Step 4: Verify Everything Works (2 minutes)

Run the verification script:

```bash
~/acp-training/verify-setup.sh
```

You should see:

- ✅ All prerequisites installed
- ✅ Repositories cloned
- ✅ API keys configured
- ✅ Ready for training

### Quick Test (Optional)

Want to see it work? Try this:

```bash
cd ~/acp-training/vTeam/demos/rfe-builder

# Start the API server (in one terminal)
uv run -m llama_deploy.apiserver

# Wait 5 seconds, then in another terminal:
uv run llamactl deploy deployment.yml

# Open your browser to:
# http://localhost:4501/deployments/rhoai-ai-feature-sizing/ui
```

Type: "Help me create an RFE for adding dark mode to our application"

Watch the AI work. This is what we're going to master in training.

## Troubleshooting

### "Command not found" errors

- Make sure you're using a bash or zsh terminal
- On macOS: Use Terminal.app or iTerm2
- On Linux: Use your default terminal

### API Key Issues

- Keys must be exact - no extra spaces or quotes
- Anthropic keys start with `sk-ant-api03-`
- OpenAI keys start with `sk-`
- Make sure you have credits in your accounts

### Network Issues

- If behind a corporate proxy, configure git:

  ```bash
  git config --global http.proxy http://your-proxy:port
  ```

- Use HTTPS clone URLs instead of SSH

### Still Stuck?

- Slack me: @jeder
- Email: <jeder@redhat.com>
- We'll fix it before training starts

## What to Expect at Training

You'll:

1. See the platform eliminate 96% of refinement time
2. Build your own AI agent for your specific needs
3. Transform a real RFE using 7 specialized agents
4. Leave with tools you can use immediately

## Pre-Work Checklist

Before training, ensure:

- [ ] Setup script completed successfully
- [ ] API keys configured in .env file
- [ ] Verification script shows all green
- [ ] You can access <http://localhost:4501> (optional)
- [ ] You have your laptop charger
- [ ] You're ready to solve our velocity problem

## See You at Training

Come ready to build. We're not just talking about AI - we're using it to fix real problems.

Questions before training? Slack @jeder

---

*Time invested in setup: 15 minutes*  
*Time we'll save per sprint: 16 hours*  
*ROI: 64x*

That's the kind of math I like.

-Jeremy
