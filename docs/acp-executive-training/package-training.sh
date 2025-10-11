#!/bin/bash
# Package ACP Executive Training Materials for Distribution
# Jeremy Eder - jeder@redhat.com

set -e

PACKAGE_NAME="acp-executive-training-$(date +%Y%m%d)"
PACKAGE_DIR="/tmp/$PACKAGE_NAME"

echo "📦 Packaging ACP Executive Training Materials"
echo "============================================"

# Clean up any existing package
rm -rf "$PACKAGE_DIR" "/tmp/$PACKAGE_NAME.tar.gz" 2>/dev/null || true

# Copy all materials
echo "📋 Copying training materials..."
cp -r /tmp/acp-executive-training "$PACKAGE_DIR"

# Make scripts executable
echo "🔧 Setting script permissions..."
chmod +x "$PACKAGE_DIR/setup-acp-training.sh"
chmod +x "$PACKAGE_DIR/pre-work/verify-setup.sh"
find "$PACKAGE_DIR/labs" -name "*.sh" -exec chmod +x {} \;

# Create a manifest
echo "📝 Creating manifest..."
cat > "$PACKAGE_DIR/MANIFEST.txt" << EOF
ACP Executive Training Package
==============================
Version: 1.0.0
Date: $(date)
Author: Jeremy Eder <jeder@redhat.com>

Contents:
---------
- Setup scripts for macOS and Linux
- Pre-work instructions and verification
- Training slides (Markdown format)
- Lab exercises with solutions
- Agent templates and examples
- Visual diagrams (Mermaid format)
- Quick reference materials

Training Structure:
------------------
1. Platform Introduction (30 min)
2. Lab 1: Build Your First Agent (30 min)
3. Break (30 min)
4. Lab 2: PatternFly Dark Mode RFE (60 min)

Prerequisites:
-------------
- Python 3.11+
- Anthropic API key
- OpenAI API key
- 15 minutes pre-work setup

Support:
--------
Slack: @jeder
Email: jeder@redhat.com
GitHub: https://github.com/ambient-code/vTeam
EOF

# Create README for distribution
echo "📄 Creating distribution README..."
cat > "$PACKAGE_DIR/DISTRIBUTE.md" << 'EOF'
# ACP Executive Training - Distribution Guide

## For Training Organizers

### Pre-Training (1 Week Before)

1. **Send pre-work email** to all attendees:
   - Include link to download this package
   - Emphasize 15-minute setup requirement
   - Provide API key instructions

2. **Test the setup** yourself:
   ```bash
   ./setup-acp-training.sh
   ./pre-work/verify-setup.sh
   ```

3. **Prepare backup options**:
   - USB drives with this package
   - Backup API keys (if permitted)
   - Recorded demo videos

### Training Day

1. **Arrive 30 minutes early**
2. **Test projector/screen sharing**
3. **Have this package ready on USB**
4. **Open Slack for support**

### Post-Training

1. **Collect feedback**
2. **Share success metrics**
3. **Follow up in 1 week**

## For Attendees

### Quick Start

1. **Run setup (15 minutes before training)**:
   ```bash
   cd acp-executive-training
   ./setup-acp-training.sh
   ```

2. **Add your API keys**:
   Edit `~/acp-training/vTeam/demos/rfe-builder/src/.env`

3. **Verify setup**:
   ```bash
   ./pre-work/verify-setup.sh
   ```

4. **Bring to training**:
   - Laptop + charger
   - API keys configured
   - Questions ready

## Package Contents

```
acp-executive-training/
├── README.md                 # Overview
├── setup-acp-training.sh     # Auto-setup script
├── CLAUDE.md                 # Maintenance guide
├── pre-work/                 # Pre-training prep
├── slides/                   # Training presentations
├── labs/                     # Hands-on exercises
├── visuals/                  # Diagrams
└── handouts/                 # Reference materials
```

## Support

**Jeremy Eder**
- Slack: @jeder
- Email: jeder@redhat.com
EOF

# Create tarball
echo "🗜️  Creating archive..."
cd /tmp
tar -czf "$PACKAGE_NAME.tar.gz" "$PACKAGE_NAME"

# Calculate size
SIZE=$(du -h "/tmp/$PACKAGE_NAME.tar.gz" | cut -f1)

# Final report
echo ""
echo "✅ Package created successfully!"
echo "================================"
echo "📦 File: /tmp/$PACKAGE_NAME.tar.gz"
echo "📏 Size: $SIZE"
echo ""
echo "Distribution commands:"
echo "----------------------"
echo "# Upload to shared drive:"
echo "scp /tmp/$PACKAGE_NAME.tar.gz user@server:/path/to/training/"
echo ""
echo "# Share via curl:"
echo "curl -F 'file=@/tmp/$PACKAGE_NAME.tar.gz' https://file.io"
echo ""
echo "# Extract package:"
echo "tar -xzf $PACKAGE_NAME.tar.gz"
echo ""
echo "Ready for distribution! 🚀"
