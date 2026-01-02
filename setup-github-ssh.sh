#!/bin/bash
# GitHub SSH Key Setup Script
# This script generates SSH key and helps you add it to GitHub

set -e

echo "🔐 GitHub SSH Key Setup"
echo "========================"
echo ""

# Check if ssh-keygen is installed
if ! command -v ssh-keygen &> /dev/null; then
    echo "❌ Error: ssh-keygen not found"
    echo "Install with: sudo pacman -S openssh"
    exit 1
fi

echo "📋 Step 1: Generate SSH Key"
echo "--------------------------------"

# Default email
DEFAULT_EMAIL="willydilly47@users.noreply.github.com"

read -p "Enter email for SSH key (press Enter for $DEFAULT_EMAIL): " EMAIL

if [ -z "$EMAIL" ]; then
    EMAIL="$DEFAULT_EMAIL"
fi

# Generate key with no passphrase (easier for automated use)
# If you want passphrase, remove -N "" flag
echo ""
echo "Generating SSH key..."
ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/github_key -N "" -q

if [ $? -eq 0 ]; then
    echo "✅ SSH key generated successfully"
else
    echo "❌ Error generating SSH key"
    exit 1
fi

echo ""
echo "📋 Step 2: Display Public Key"
echo "--------------------------------"
echo ""
echo "Copy this public key:"
echo ""
cat ~/.ssh/github_key.pub
echo ""
echo "========================================"
echo ""

# Ask if they want to copy to clipboard
read -p "Do you want to copy public key to clipboard? (y/n): " COPY_CLIPBOARD

if [[ "$COPY_CLIPBOARD" == "y" || "$COPY_CLIPBOARD" == "Y" ]]; then
    if command -v wl-copy &> /dev/null; then
        cat ~/.ssh/github_key.pub | wl-copy
        echo "✅ Copied to clipboard (Wayland)"
    elif command -v xclip &> /dev/null; then
        cat ~/.ssh/github_key.pub | xclip -selection clipboard
        echo "✅ Copied to clipboard (X11)"
    elif command -v xsel &> /dev/null; then
        cat ~/.ssh/github_key.pub | xsel --clipboard --input
        echo "✅ Copied to clipboard (xsel)"
    else
        echo "⚠️  No clipboard tool found"
        echo "   Install one: sudo pacman -S wl-clipboard (for Wayland)"
        echo "              sudo pacman -S xclip (for X11)"
    fi
fi

echo ""
echo "📋 Step 3: Add SSH Key to GitHub"
echo "------------------------------------"
echo ""
echo "Next steps:"
echo ""
echo "1. Open this link in your browser:"
echo "   https://github.com/settings/keys"
echo ""
echo "2. Click 'New SSH key'"
echo "3. Title: 'CachyOS Bot - $(date +%Y-%m-%d)'"
echo "4. Paste the public key above (you can copy from clipboard)"
echo "5. Click 'Add SSH key'"
echo ""

# Wait for user to add key
read -p "Press Enter once you've added the key to GitHub..."

echo ""
echo "📋 Step 4: Test SSH Connection"
echo "-------------------------------------"
echo ""

# Test SSH connection to GitHub
echo "Testing SSH connection to GitHub..."
ssh -T git@github.com 2>&1 | head -1

if [ $? -eq 1 ]; then
    # Exit code 1 is expected (GitHub returns message "Hi Willydilly47! You've successfully authenticated...")
    echo "✅ SSH authentication successful!"
    echo ""
    echo "📋 Step 5: Configure Git to Use SSH"
    echo "---------------------------------------"
    echo ""
    echo "Now you can use SSH URL for Git:"
    echo ""
    echo "  git remote set-url origin git@github.com:Willydilly47/telegram-opencode-bot.git"
    echo ""
else
    echo "❌ SSH connection failed"
    echo ""
    echo "Possible issues:"
    echo "1. SSH key not added to GitHub yet"
    echo "2. Wrong key file"
    echo "3. Firewall blocking SSH"
    echo ""
    echo "Try manual connection test:"
    echo "  ssh -T git@github.com"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📚 Next: Run git push with SSH URL:"
echo "  git remote set-url origin git@github.com:Willydilly47/telegram-opencode-bot.git"
echo "  git push -u origin main"
