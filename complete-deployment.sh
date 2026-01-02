#!/bin/bash
# Complete GitHub Deployment Guide
# This script sets up SSH auth and deploys to GitHub Pages

set -e

echo "🚀 Complete GitHub Deployment for Telegram OpenCode Bot"
echo "======================================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Step 1: Choose Authentication Method${NC}"
echo "-----------------------------------------------"
echo ""
echo "Which method do you want to use?"
echo ""
echo "  1) Personal Access Token (Easiest - recommended for quick use)"
echo "  2) SSH Keys (Most secure - recommended for long-term)"
echo "  3) Username/Password (Deprecated - not recommended)"
echo ""
read -p "Enter choice (1, 2, or 3): " AUTH_METHOD

case $AUTH_METHOD in
    1)
        echo ""
        echo -e "${GREEN}✅${NC} Selected: Personal Access Token"
        echo ""
        echo "Instructions:"
        echo "1. Open: https://github.com/settings/tokens"
        echo "2. Click 'Generate new token (classic)'"
        echo "3. Scopes: Check only 'repo'"
        echo "4. Generate and copy token"
        echo ""
        echo "When Git prompts for password, paste token instead."
        echo ""
        read -p "Press Enter when you've created token..."
        ;;

    2)
        echo ""
        echo -e "${GREEN}✅${NC} Selected: SSH Keys"
        echo ""
        echo "Running SSH setup script..."
        bash /home/willydilly47/telegram-opencode-bot/setup-github-ssh.sh
        echo ""
        echo "After setup, Git URL will be:"
        echo "  git@github.com:Willydilly47/telegram-opencode-bot.git"
        echo ""
        read -p "Press Enter to continue with deployment..."
        ;;

    3)
        echo ""
        echo -e "${YELLOW}⚠️  ${NC}Selected: Username/Password"
        echo "Note: This method is deprecated by GitHub"
        echo ""
        read -p "Press Enter to continue..."
        ;;

    *)
        echo ""
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}📋 Step 2: Initialize Git Repository${NC}"
echo "---------------------------------------------"
echo ""

cd /home/willydilly47/telegram-opencode-bot

# Remove existing git
rm -rf .git 2>/dev/null || true

# Initialize git
git init
git config user.name "Willydilly47"
git config user.email "willydilly47@users.noreply.github.com"
git branch -M main

echo -e "${GREEN}✅${NC} Git repository initialized"

echo ""
echo -e "${BLUE}📋 Step 3: Add Files to Git${NC}"
echo "-----------------------------------"
echo ""

# Add all project files
git add mini-app/
git add backend/bot_listener.py
git add backend/requirements.txt
git add backend/.env.example
git add backend/opencode-bot.service
git add backend/test_bot_listener.py
git add README.md
git add QUICK_START.md
git add SETUP_GUIDE.md
git add TROUBLESHOOTING.md
git add TELEGRAM_OPENCODE_SPEC.md
git add deploy-github-pages.sh
git add interactive-setup.sh
git add setup-github-ssh.sh

echo -e "${GREEN}✅${NC} Files added to git"

echo ""
echo -e "${BLUE}📋 Step 4: Create Initial Commit${NC}"
echo "------------------------------------"
echo ""

git commit -m "Initial commit: Telegram OpenCode Bot

- Complete Telegram bot for controlling OpenCode remotely
- Mini App frontend with Telegram theme integration
- Security features: user ID validation, command injection prevention
- Documentation and setup guides included"

echo -e "${GREEN}✅${NC} Commit created"

echo ""
echo -e "${BLUE}📋 Step 5: Add GitHub Remote${NC}"
echo "---------------------------------"
echo ""

# Ask for repository name
read -p "Enter GitHub repository name (default: telegram-opencode-bot): " REPO_NAME

if [ -z "$REPO_NAME" ]; then
    REPO_NAME="telegram-opencode-bot"
fi

# Determine Git URL based on auth method
case $AUTH_METHOD in
    2)
        # SSH - already configured by setup script
        REMOTE_URL="git@github.com:Willydilly47/${REPO_NAME}.git"
        ;;
    *)
        # HTTPS - for token or username/password
        REMOTE_URL="https://github.com/Willydilly47/${REPO_NAME}.git"
        ;;
esac

git remote add origin "$REMOTE_URL"

echo -e "${GREEN}✅${NC} Remote URL set to: $REMOTE_URL"

echo ""
echo -e "${BLUE}📋 Step 6: Push to GitHub${NC}"
echo "------------------------------"
echo ""

echo "Pushing to GitHub..."
echo "This may take a moment..."

git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ SUCCESS!${NC}"
    echo ""
    echo "Code pushed to GitHub successfully!"
    echo ""
    echo "Repository: https://github.com/Willydilly47/${REPO_NAME}"
    echo ""
    echo -e "${BLUE}📋 Step 7: Enable GitHub Pages${NC}"
    echo "-------------------------------"
    echo ""
    echo "Next steps to enable GitHub Pages:"
    echo ""
    echo "1. Open your browser and go to:"
    echo "   https://github.com/Willydilly47/${REPO_NAME}"
    echo ""
    echo "2. Navigate to: Settings → Pages"
    echo ""
    echo "3. Under 'Build and deployment':"
    echo "   - Source: Deploy from a branch"
    echo "   - Branch: main"
    echo "   - Folder: /(root)"
    echo ""
    echo "4. Click 'Save'"
    echo ""
    echo "5. Wait 1-2 minutes for deployment"
    echo ""
    echo -e "${GREEN}Your Mini App will be at:${NC}"
    echo "   https://willydilly47.github.io/${REPO_NAME}/"
    echo ""
    echo -e "${BLUE}📋 Step 8: Update .env if Needed${NC}"
    echo "----------------------------------"
    echo ""
    CURRENT_URL=$(grep "^MINI_APP_URL" /home/willydilly47/telegram-opencode-bot/backend/.env | cut -d'=' -f2)
    echo "Current MINI_APP_URL: $CURRENT_URL"
    echo ""
    NEW_URL="https://willydilly47.github.io/${REPO_NAME}/"
    if [ "$CURRENT_URL" != "$NEW_URL" ]; then
        echo "Updating .env with new URL..."
        sed -i "s|MINI_APP_URL=.*|MINI_APP_URL=$NEW_URL|" /home/willydilly47/telegram-opencode-bot/backend/.env
        echo -e "${GREEN}✅${NC} .env updated!"
    else
        echo -e "${GREEN}✅${NC} .env already has correct URL"
    fi
    echo ""
    echo -e "${GREEN}🎉 Deployment Complete!${NC}"
    echo ""
    echo "After enabling GitHub Pages:"
    echo "1. Restart the bot:"
    echo "   cd /home/willydilly47/telegram-opencode-bot/backend"
    echo "   source venv/bin/activate"
    echo "   python3 bot_listener.py"
    echo ""
    echo "2. Test in Telegram:"
    echo "   - Open @OpenCodeBridgeBot"
    echo "   - Send /start"
    echo "   - Click '🚀 Launch OpenCode' button"
    echo "   - Type a test prompt"
    echo "   - Click 'Run on Konsole'"
    echo "   - Watch Konsole window open on desktop!"
else
    echo ""
    echo -e "${RED}❌ Push failed${NC}"
    echo ""
    echo "Possible reasons:"
    echo "1. Repository doesn't exist"
    echo "   Solution: Create at https://github.com/new"
    echo "   Name: $REPO_NAME"
    echo "   Description: Telegram bot for controlling OpenCode remotely"
    echo ""
    echo "2. Authentication failed"
    echo "   Solution: Check your token/SSH key is correct"
    echo ""
    echo "3. Internet connection issue"
    echo "   Solution: Check your connection"
    echo ""
    echo "Try pushing again:"
    echo "  git push -u origin main"
    exit 1
fi
