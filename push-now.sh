#!/bin/bash

# Automated SSH Push Script for Telegram OpenCode Bot

set -e

echo "🚀 Automated SSH Push for Telegram OpenCode Bot"
echo "=========================================="
echo ""

# Use the credentials that are already configured in backend/.env
echo "GitHub Username: willydilly47"
echo "Email: aaron47willis@gmail.com"
echo ""

echo "Adding all files to Git..."
git add -A
git commit -m "Telegram OpenCode Bot

Complete Telegram bot for controlling OpenCode remotely via Telegram Mini App.
- Mini App frontend with Telegram theme integration
- Security features: user ID validation, command injection prevention
- Documentation and setup guides included"

echo "✅ Files committed"

echo ""
echo "Adding remote..."
git remote add origin git@github.com:Willydilly47/telegram-opencode-bot.git

echo "✅ Remote added"

echo ""
echo "Pushing to GitHub..."
git push -u origin main

echo ""
echo "✅ Done! Files should now be on GitHub!"
echo ""
echo ""
echo "=========================================="
echo ""
echo "📋 Next Steps:"
echo ""
echo ""
echo "1. Enable GitHub Pages (3 minutes)"
echo "   - Go to: https://github.com/Willydilly47/telegram-opencode-bot"
echo "   - Click 'Settings' (top right, gear icon)"
echo "   - Scroll down to 'Pages' (left sidebar)"
echo "   - Under 'Build and deployment':"
echo "       - Source: Deploy from a branch"
echo "       - Branch: main"
echo "       - Folder: /(root)"
echo "   - Click 'Save'"
echo "   - Wait 1-2 minutes"
echo ""
echo "2. Verify Mini App"
echo "   - Open: https://willydilly47.github.io/telegram-opencode-bot/"
echo "   - You should see Mini App interface!"
echo ""
echo ""
echo "3. Test Complete System (2 minutes)"
echo "   - Start bot:"
echo "       cd /home/willydilly47/telegram-opencode-bot/backend"
echo "       source venv/bin/activate"
echo "       python3 bot_listener.py"
echo ""
echo "   - In Telegram:"
echo "       - Open @OpenCodeBridgeBot"
echo "       - Send: /start"
echo "       - Click: '🚀 Launch OpenCode'"
echo "       - Mini App should open (from GitHub Pages)"
echo "       - Type: Test prompt"
echo "       - Click: 'Run'"
echo "       - Watch Konsole window open!"
echo ""
echo ""
echo "=========================================="
echo "All files are on GitHub and ready!"
echo ""
echo "Mini App URL: https://willydilly47.github.io/telegram-opencode-bot/"
