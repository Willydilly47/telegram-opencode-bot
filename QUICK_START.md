# Telegram OpenCode Bot - Quick Start Guide

**Estimated Time:** 10-15 minutes  
**Difficulty:** Easy

---

## Prerequisites Checklist

Before you begin, ensure you have:

- [ ] **Python 3.10+** installed (`python3 --version`)
- [ ] **Konsole** installed (part of KDE, comes with CachyOS)
- [ ] **OpenCode** installed and in your PATH
- [ ] **Telegram account** with @BotFather and @userinfobot access
- [ ] **GitHub account** (for hosting the Mini App)

---

## Step 1: Create Your Telegram Bot

1. Open Telegram and search for **@BotFather**
2. Send `/newbot` to create a new bot
3. Follow the prompts:
   - Give your bot a name (e.g., "OpenCode Bot")
   - Give it a username (must end in "bot", e.g., "myopencode_bot")
4. **IMPORTANT:** Copy your bot token (shown after creation)
   - Format: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`
   - You'll need this for the `.env` file

---

## Step 2: Get Your User ID

1. Open Telegram and search for **@userinfobot**
2. Send `/start`
3. Copy your **ID** (a number like `123456789`)
4. You'll need this for the `.env` file

---

## Step 3: Deploy the Mini App to GitHub Pages

1. **Create a GitHub repository:**
   ```bash
   cd /home/willydilly47/telegram-opencode-bot
   git init
   git add mini-app/
   git commit -m "Add Mini App"
   git branch -M main
   ```

2. **Push to GitHub:**
   ```bash
   # Create repo on GitHub first, then:
   git remote add origin https://github.com/YOURUSERNAME/telegram-opencode-bot.git
   git push -u origin main
   ```

3. **Enable GitHub Pages:**
   - Go to your repository on GitHub
   - Navigate to **Settings** → **Pages**
   - Under "Branch", select **main** and folder **/(root)**
   - Click **Save**
   - Wait 1-2 minutes for deployment

4. **Copy your Mini App URL:**
   - Format: `https://YOURUSERNAME.github.io/telegram-opencode-bot/`

---

## Step 4: Configure the Backend

1. **Navigate to backend directory:**
   ```bash
   cd /home/willydilly47/telegram-opencode-bot/backend
   ```

2. **Create the `.env` file:**
   ```bash
   cp .env.example .env
   nano .env
   ```

3. **Fill in your values:**
   ```env
   BOT_TOKEN=123456789:YOUR_BOT_TOKEN
   ALLOWED_USER_ID=123456789
   MINI_APP_URL=https://yourusername.github.io/telegram-opencode-bot/
   DISPLAY=:0
   WORKING_DIR=/home/willydilly47
   ```

4. **Save and exit:** Press `Ctrl+O`, `Enter`, then `Ctrl+X`

---

## Step 5: Install Dependencies

```bash
pip3 install -r requirements.txt
```

---

## Step 6: Test the Bot

1. **Start the bot:**
   ```bash
   python3 bot_listener.py
   ```

2. **In Telegram:**
   - Open your bot
   - Send `/start`
   - You should see a "🚀 Launch OpenCode" button

3. **Test the Mini App:**
   - Click "🚀 Launch OpenCode"
   - Enter a test prompt (e.g., "Hello, OpenCode!")
   - Click "Run on Konsole"
   - A Konsole window should open on your desktop
   - OpenCode should execute with your prompt

4. **Check the logs:**
   ```bash
   cat ~/.opencode/bot.log
   ```

---

## Step 7: Set Up Auto-Start (Optional)

1. **Install the systemd service:**
   ```bash
   sudo cp opencode-bot.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable opencode-bot
   sudo systemctl start opencode-bot
   ```

2. **Check status:**
   ```bash
   sudo systemctl status opencode-bot
   ```

3. **View logs:**
   ```bash
   sudo journalctl -u opencode-bot -f
   ```

---

## Common Issues & Quick Fixes

| Issue | Quick Fix |
|-------|-----------|
| Bot doesn't respond | Check `.env` file has correct BOT_TOKEN |
| "Cannot connect to display" | Set `DISPLAY=:0` in `.env` |
| Konsole not opening | Ensure Konsole is installed (`which konsole`) |
| OpenCode not found | Add OpenCode to PATH or use full path |
| Mini App button not showing | Check MINI_APP_URL is correct and accessible |
| Unauthorized user warning | Verify ALLOWED_USER_ID is correct |

---

## Next Steps

- Read the [Setup Guide](SETUP_GUIDE.md) for detailed configuration
- Check [Troubleshooting](TROUBLESHOOTING.md) for error solutions
- Review the [Technical Specification](TELEGRAM_OPENCODE_SPEC.md) for architecture details

---

**Need help?** See [Troubleshooting](TROUBLESHOOTING.md) or open an issue on GitHub.
