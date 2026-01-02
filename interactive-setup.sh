#!/bin/bash
# Interactive Setup Guide for Telegram OpenCode Bot
# This script walks you through the entire setup process

set -e

echo "🎯 Telegram OpenCode Bot - Interactive Setup Guide"
echo "=================================================="
echo ""

# Color codes for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Check prerequisites
echo -e "${BLUE}📋 Step 1: Checking Prerequisites${NC}"
echo "----------------------------------------------"

# Check Python
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo -e "${GREEN}✅${NC} Python version: $PYTHON_VERSION"

# Check pip
if command -v pip3 &> /dev/null; then
    echo -e "${GREEN}✅${NC} pip3 is installed"
else
    echo -e "${RED}❌${NC} pip3 not found"
    exit 1
fi

# Check Konsole
if command -v konsole &> /dev/null; then
    echo -e "${GREEN}✅${NC} Konsole is installed"
else
    echo -e "${RED}❌${NC} Konsole not found"
    exit 1
fi

# Check OpenCode
if command -v opencode &> /dev/null; then
    echo -e "${GREEN}✅${NC} OpenCode is installed"
else
    # Check in .opencode directory
    if [ -f "$HOME/.opencode/bin/opencode" ]; then
        echo -e "${GREEN}✅${NC} OpenCode is installed in ~/.opencode/bin"
    else
        echo -e "${YELLOW}⚠️${NC}  OpenCode not found in PATH"
        echo "   Make sure it's installed and accessible"
    fi
fi

echo ""

# Step 2: Configure Environment
echo -e "${BLUE}🔧 Step 2: Configure Environment Variables${NC}"
echo "----------------------------------------------"

echo ""
echo "You need to provide three pieces of information:"
echo ""
echo -e "${YELLOW}1. Bot Token${NC} (from @BotFather)"
echo "   - Open Telegram and search for @BotFather"
echo "   - Send /newbot to create a bot"
echo "   - Copy the token (format: 1234567890:ABCdef...)"
echo ""
echo -e "${YELLOW}2. Your User ID${NC} (from @userinfobot)"
echo "   - Open Telegram and search for @userinfobot"
echo "   - Send /start to get your ID (e.g., 123456789)"
echo ""
echo -e "${YELLOW}3. Mini App URL${NC} (from GitHub Pages)"
echo "   - After deploying Mini App to GitHub Pages"
echo "   - URL will be: https://yourusername.github.io/telegram-opencode-bot/"
echo ""

read -p "Press Enter when you have these three pieces of information ready..."

# Collect configuration
echo ""
echo -e "${BLUE}📝 Step 3: Enter Configuration${NC}"
echo "------------------------------------------"

read -p "Enter your Bot Token (from @BotFather): " BOT_TOKEN

if [ -z "$BOT_TOKEN" ]; then
    echo -e "${RED}❌ Error: Bot Token cannot be empty${NC}"
    exit 1
fi

read -p "Enter your User ID (from @userinfobot): " USER_ID

if [ -z "$USER_ID" ]; then
    echo -e "${RED}❌ Error: User ID cannot be empty${NC}"
    exit 1
fi

read -p "Enter your GitHub username: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo -e "${RED}❌ Error: GitHub username cannot be empty${NC}"
    exit 1
fi

MINI_APP_URL="https://${GITHUB_USERNAME}.github.io/telegram-opencode-bot/"

echo ""
echo -e "${GREEN}✅ Configuration Collected:${NC}"
echo "  Bot Token: ${BOT_TOKEN:0:10}..."
echo "  User ID: $USER_ID"
echo "  GitHub Username: $GITHUB_USERNAME"
echo "  Mini App URL: $MINI_APP_URL"

# Step 4: Update .env file
echo ""
echo -e "${BLUE}💾 Step 4: Update .env File${NC}"
echo "-----------------------------------------"

cd /home/willydilly47/telegram-opencode-bot/backend

# Create .env file from .env.example
if [ ! -f ".env" ]; then
    cp .env.example .env
fi

# Update values
sed -i "s|BOT_TOKEN=.*|BOT_TOKEN=$BOT_TOKEN|" .env
sed -i "s|ALLOWED_USER_ID=.*|ALLOWED_USER_ID=$USER_ID|" .env
sed -i "s|MINI_APP_URL=.*|MINI_APP_URL=$MINI_APP_URL|" .env

echo -e "${GREEN}✅${NC} .env file updated successfully"

# Step 5: Deploy to GitHub Pages
echo ""
echo -e "${BLUE}🌐 Step 5: Deploy Mini App to GitHub Pages${NC}"
echo "----------------------------------------------------"

cd /home/willydilly47/telegram-opencode-bot

read -p "Do you want to deploy the Mini App to GitHub Pages now? (y/n): " DEPLOY_NOW

if [[ "$DEPLOY_NOW" == "y" || "$DEPLOY_NOW" == "Y" ]]; then
    echo ""
    echo "Initializing Git repository..."

    # Initialize git
    git init 2>/dev/null || true

    # Check if remote already exists
    if ! git remote get-url origin &>/dev/null; then
        git branch -M main
        git remote add origin "https://github.com/${GITHUB_USERNAME}/telegram-opencode-bot.git"
    fi

    # Add files
    git add mini-app/
    git add backend/bot_listener.py
    git add backend/requirements.txt
    git add backend/.env.example
    git add backend/opencode-bot.service
    git add *.md

    # Commit
    git commit -m "Initial commit: Telegram OpenCode Bot" 2>/dev/null || true

    echo ""
    echo -e "${YELLOW}📤 Pushing to GitHub...${NC}"
    echo "This will prompt for your GitHub credentials..."
    echo ""

    git push -u origin main || {
        echo ""
        echo -e "${RED}❌ Git push failed${NC}"
        echo ""
        echo "Possible reasons:"
        echo "1. Repository doesn't exist yet"
        echo "   Solution: Create repository at https://github.com/new"
        echo "   Name: telegram-opencode-bot"
        echo "   Description: Telegram bot for controlling OpenCode remotely"
        echo ""
        echo "2. Authentication issue"
        echo "   Solution: Create a GitHub Personal Access Token with 'repo' scope"
        echo "   Use: https://github.com/settings/tokens"
        echo ""
        echo "3. Repository already exists with different content"
        echo "   Solution: git push -u origin main --force"
        echo ""
    }

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Pushed to GitHub successfully!${NC}"
        echo ""
        echo -e "${BLUE}📋 Next Steps for GitHub Pages:${NC}"
        echo "--------------------------------"
        echo "1. Open: https://github.com/${GITHUB_USERNAME}/telegram-opencode-bot"
        echo "2. Go to: Settings → Pages"
        echo "3. Set:"
        echo "   - Source: Deploy from a branch"
        echo "   - Branch: main"
        echo "   - Folder: /(root)"
        echo "4. Click Save"
        echo "5. Wait 1-2 minutes"
        echo ""
        echo -e "${GREEN}🌍 Your Mini App URL:${NC}"
        echo "   ${MINI_APP_URL}"
    fi
else
    echo ""
    echo -e "${YELLOW}⏭️  Skipping GitHub Pages deployment for now${NC}"
    echo "You can run the deployment script later:"
    echo "  ./deploy-github-pages.sh"
fi

# Step 6: Test Bot
echo ""
echo -e "${BLUE}🧪 Step 6: Test Bot${NC}"
echo "--------------------------------"

read -p "Do you want to test the bot now? (y/n): " TEST_NOW

if [[ "$TEST_NOW" == "y" || "$TEST_NOW" == "Y" ]]; then
    echo ""
    echo "Starting bot..."
    echo ""
    echo -e "${YELLOW}Note: The bot will run in this terminal.${NC}"
    echo -e "${YELLOW}Open Telegram in another window to test it.${NC}"
    echo ""
    echo "1. Open your bot in Telegram"
    echo "2. Send /start"
    echo "3. Click the '🚀 Launch OpenCode' button"
    echo "4. Type a test prompt"
    echo "5. Click 'Run on Konsole'"
    echo "6. Watch for a Konsole window to open on your desktop!"
    echo ""
    echo -e "${BLUE}Press Ctrl+C to stop the bot${NC}"
    echo ""

    # Activate venv and run bot
    source venv/bin/activate
    python3 backend/bot_listener.py
else
    echo ""
    echo -e "${YELLOW}⏭️  Skipping bot test for now${NC}"
    echo "You can test it later by running:"
    echo "  cd /home/willydilly47/telegram-opencode-bot/backend"
    echo "  source venv/bin/activate"
    echo "  python3 bot_listener.py"
fi

# Final summary
echo ""
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo "===================================="
echo ""
echo "Your bot is configured and ready!"
echo ""
echo "📚 Documentation:"
echo "  - Quick Start Guide: /home/willydilly47/telegram-opencode-bot/QUICK_START.md"
echo "  - Setup Guide: /home/willydilly47/telegram-opencode-bot/SETUP_GUIDE.md"
echo "  - Troubleshooting: /home/willydilly47/telegram-opencode-bot/TROUBLESHOOTING.md"
echo ""
echo "🎉 Enjoy using your Telegram OpenCode Bot!"
