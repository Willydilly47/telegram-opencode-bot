#!/bin/bash
# GitHub Pages Deployment Script for Telegram OpenCode Bot
# This script helps deploy the Mini App to GitHub Pages

set -e  # Exit on any error

echo "🚀 Telegram OpenCode Bot - GitHub Pages Deployment"
echo "================================================"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Error: git is not installed"
    echo "Please install it with: sudo pacman -S git"
    exit 1
fi

# Get GitHub username
read -p "Enter your GitHub username: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ Error: GitHub username cannot be empty"
    exit 1
fi

REPO_NAME="telegram-opencode-bot"
REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
PAGES_URL="https://${GITHUB_USERNAME}.github.io/${REPO_NAME}/"

echo ""
echo "📋 Deployment Details:"
echo "  - Repository: ${REPO_URL}"
echo "  - Pages URL: ${PAGES_URL}"
echo ""

# Check if we're in the right directory
if [ ! -d "mini-app" ]; then
    echo "❌ Error: mini-app directory not found"
    echo "Please run this script from the telegram-opencode-bot directory"
    exit 1
fi

echo "📦 Step 1: Initialize Git repository..."
git init

echo "📝 Step 2: Add Mini App files..."
git add mini-app/
git commit -m "Add Telegram OpenCode Mini App"

echo "🔐 Step 3: Set up Git remote..."
git branch -M main
git remote add origin "$REPO_URL"

echo "🌐 Step 4: Push to GitHub..."
echo "This will prompt for your GitHub credentials..."
git push -u origin main

echo ""
echo "✅ Step 5: Deployment Instructions"
echo "=================================="
echo ""
echo "Your Mini App code has been pushed to GitHub!"
echo ""
echo "Next steps to enable GitHub Pages:"
echo ""
echo "1. Open your browser and go to:"
echo "   https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
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
echo "6. Your Mini App will be available at:"
echo "   ${PAGES_URL}"
echo ""
echo "📝 IMPORTANT: Update your .env file with this URL:"
echo "   MINI_APP_URL=${PAGES_URL}"
echo ""
echo "✅ Deployment script completed!"
