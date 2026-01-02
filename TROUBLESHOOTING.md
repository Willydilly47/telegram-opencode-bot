# Telegram OpenCode Bot - Troubleshooting Guide

**Version:** 1.0.0  
**Last Updated:** January 2, 2026

---

## Table of Contents

1. [Quick Diagnostics](#quick-diagnostics)
2. [Bot Issues](#bot-issues)
3. [Mini App Issues](#mini-app-issues)
4. [Display Issues](#display-issues)
5. [Konsole Issues](#konsole-issues)
6. [OpenCode Issues](#opencode-issues)
7. [Permission Issues](#permission-issues)
8. [Log Analysis](#log-analysis)
9. [Debug Mode](#debug-mode)

---

## Quick Diagnostics

Run this command first to gather system information:

```bash
# Check all prerequisites
echo "=== Python Version ===" && python3 --version
echo "=== Konsole Location ===" && which konsole
echo "=== OpenCode Location ===" && which opencode
echo "=== Display Variable ===" && echo $DISPLAY
echo "=== Bot Log ===" && tail -50 ~/.opencode/bot.log
echo "=== Service Status ===" && systemctl status opencode-bot 2>/dev/null || echo "Service not installed"
```

---

## Bot Issues

### Bot Doesn't Respond to /start

**Symptoms:**
- Send `/start` in Telegram
- No response from bot

**Solutions:**

1. **Check bot token:**
   ```bash
   cat /home/willydilly47/telegram-opencode-bot/backend/.env | grep BOT_TOKEN
   ```
   - Verify token is correct format: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`

2. **Check bot is running:**
   ```bash
   # If using systemd
   sudo systemctl status opencode-bot
   
   # If running manually
   ps aux | grep bot_listener
   ```

3. **Check network connectivity:**
   ```bash
   # Test Telegram API access
   curl -I https://api.telegram.org
   ```

4. **Check logs:**
   ```bash
   tail -f ~/.opencode/bot.log
   ```

### "Unauthorized Access" in Logs

**Symptoms:**
- Logs show "Unauthorized access attempt" repeatedly
- No commands execute

**Solutions:**

1. **Verify your user ID:**
   ```bash
   # Check what user ID is configured
   cat /home/willydilly47/telegram-opencode-bot/backend/.env | grep ALLOWED_USER_ID
   
   # Get your actual user ID
   # Open @userinfobot in Telegram
   ```

2. **Update the .env file:**
   ```bash
   nano /home/willydilly47/telegram-opencode-bot/backend/.env
   # Update ALLOWED_USER_ID to your actual ID
   ```

3. **Restart the bot:**
   ```bash
   sudo systemctl restart opencode-bot
   ```

### "BOT_TOKEN not set" Error

**Symptoms:**
- Bot fails to start
- Error: "BOT_TOKEN not set"

**Solutions:**

1. **Create or fix .env file:**
   ```bash
   cd /home/willydilly47/telegram-opencode-bot/backend
   cp .env.example .env
   nano .env
   ```

2. **Add your bot token:**
   ```env
   BOT_TOKEN=your_bot_token_here
   ```

3. **Restart the bot:**
   ```bash
   sudo systemctl restart opencode-bot
   ```

---

## Mini App Issues

### Mini App Button Doesn't Appear

**Symptoms:**
- `/start` works but no button appears
- Only text message shown

**Solutions:**

1. **Check MINI_APP_URL:**
   ```bash
   cat /home/willydilly47/telegram-opencode-bot/backend/.env | grep MINI_APP_URL
   ```

2. **Verify URL is accessible:**
   ```bash
   curl -I https://yourusername.github.io/telegram-opencode-bot/
   ```
   - Should return HTTP 200

3. **Check URL format:**
   - Must be HTTPS
   - Must end with `/`
   - Example: `https://username.github.io/telegram-opencode-bot/`

4. **Test in browser:**
   - Open the Mini App URL in a browser
   - Should show the interface without errors

### Mini App Shows Blank Screen

**Symptoms:**
- Button appears and is clicked
- Mini App loads but shows blank screen

**Solutions:**

1. **Check browser console for errors:**
   - Open Mini App URL in browser
   - Press F12 to open developer tools
   - Check Console tab for errors

2. **Verify GitHub Pages deployment:**
   - Go to GitHub repository → Settings → Pages
   - Ensure "Source" is set to "main" branch
   - Check deployment status

3. **Clear cache:**
   ```bash
   # Hard refresh the page
   Ctrl+Shift+R (Windows/Linux)
   Cmd+Shift+R (Mac)
   ```

### Mini App Doesn't Close After Submit

**Symptoms:**
- Prompt sent but Mini App stays open

**Solutions:**

1. **This is expected behavior** - Telegram Mini Apps stay open
2. User can manually close by tapping back button
3. The bot should send `tg.close()` but it's a user-initiated action

---

## Display Issues

### "Cannot Connect to Display" Error

**Symptoms:**
- Bot logs show display connection errors
- Konsole fails to open

**Solutions:**

1. **Set DISPLAY variable:**
   ```bash
   # Check current display
   echo $DISPLAY
   # Usually :0 or :1
   
   # Add to .env
   nano /home/willydilly47/telegram-opencode-bot/backend/.env
   DISPLAY=:0
   ```

2. **For Wayland users:**
   ```bash
   # Check Wayland display
   echo $WAYLAND_DISPLAY
   # May need to use wl-copy or xwayland
   ```

3. **Test display access:**
   ```bash
   # From the bot's user account
   xclock  # Should open a test window
   ```

### X11 Authority Issues

**Symptoms:**
- "X11 connection rejected because of wrong authentication"

**Solutions:**

1. **Check xauth:**
   ```bash
   xauth list
   ```

2. **Copy xauth to service user:**
   ```bash
   # If running as different user
   xauth -f /home/willydilly47/.Xauthority extract - willydilly47 | sudo -u willydilly47 xauth merge -
   ```

3. **For systemd service:**
   - The service file already sets `Environment="DISPLAY=:0"`
   - May need `Environment="XAUTHORITY=/home/willydilly47/.Xauthority"`

---

## Konsole Issues

### "Command Not Found: konsole"

**Symptoms:**
- Konsole fails to launch
- Error in logs: "Command not found: konsole"

**Solutions:**

1. **Check Konsole installation:**
   ```bash
   which konsole
   # Should return: /usr/bin/konsole
   ```

2. **Install Konsole:**
   ```bash
   # On CachyOS/Arch
   sudo pacman -S konsole
   
   # On Debian/Ubuntu
   sudo apt install konsole
   ```

3. **Find correct path:**
   ```bash
   # Find konsole
   find /usr -name konsole 2>/dev/null
   
   # Update .env with full path
   nano /home/willydilly47/telegram-opencode-bot/backend/.env
   # Add: KONSOLE_PATH=/usr/bin/konsole
   ```

### Konsole Opens But Closes Immediately

**Symptoms:**
- Konsole window flashes and closes

**Solutions:**

1. **The command is working correctly** - this is expected behavior
2. The window should stay open if OpenCode is running
3. Check if OpenCode exits immediately (not a bot issue)

### Konsole Opens in Wrong Location

**Symptoms:**
- Konsole opens on wrong monitor or workspace

**Solutions:**

1. **Configure Konsole defaults:**
   ```bash
   # Open Konsole settings
   konsole
   # Settings → Configure Konsole
   # Set default startup behavior
   ```

2. **Use Konsole command-line options:**
   ```bash
   # Add to bot command construction
   konsole --workdir /home/willydilly47 --new-tab
   ```

---

## OpenCode Issues

### "Command Not Found: opencode"

**Symptoms:**
- Konsole opens but OpenCode doesn't run
- Error in Konsole: "opencode: command not found"

**Solutions:**

1. **Check OpenCode installation:**
   ```bash
   which opencode
   ```

2. **Install OpenCode:**
   - Follow OpenCode installation instructions
   - Ensure it's in your PATH

3. **Add to PATH in .env:**
   ```env
   PATH=/home/willydilly47/.local/bin:/usr/bin:/bin
   ```

### OpenCode Fails to Start

**Symptoms:**
- OpenCode shows error on startup
- No output from OpenCode

**Solutions:**

1. **Test OpenCode manually:**
   ```bash
   opencode "test"
   ```

2. **Check OpenCode logs:**
   ```bash
   opencode --debug "test"
   ```

3. **Verify OpenCode API key:**
   - OpenCode may require authentication
   - Check OpenCode documentation

---

## Permission Issues

### Permission Denied When Running Bot

**Symptoms:**
- "Permission denied" error when starting bot
- Cannot execute bot_listener.py

**Solutions:**

1. **Check file permissions:**
   ```bash
   ls -la /home/willydilly47/telegram-opencode-bot/backend/bot_listener.py
   ```

2. **Fix permissions:**
   ```bash
   chmod +x /home/willydilly47/telegram-opencode-bot/backend/bot_listener.py
   ```

3. **Check file ownership:**
   ```bash
   chown willydilly47:willydilly47 /home/willydilly47/telegram-opencode-bot/backend/bot_listener.py
   ```

### Cannot Write to Log File

**Symptoms:**
- "Permission denied" for bot.log
- No logs being written

**Solutions:**

1. **Create log directory:**
   ```bash
   mkdir -p /home/willydilly47/.opencode
   touch /home/willydilly47/.opencode/bot.log
   chown -R willydilly47:willydilly47 /home/willydilly47/.opencode
   ```

2. **Update log path in .env:**
   ```env
   LOG_FILE=/home/willydilly47/.opencode/bot.log
   ```

---

## Log Analysis

### Understanding Log Entries

**INFO Level (Normal Operation):**
```
2024-01-02 10:00:00 - telegram - INFO - User 123456789 initiated /start command
2024-01-02 10:00:05 - telegram - INFO - Received prompt from user 123456789
2024-01-02 10:00:05 - telegram - INFO - Executing command: konsole
```

**WARNING Level (Recoverable Issues):**
```
2024-01-02 10:00:10 - telegram - WARNING - Prompt validation error from user 123456789: Prompt too long
```

**ERROR Level (Failed Operations):**
```
2024-01-02 10:00:15 - telegram - ERROR - Error executing command: File not found
```

**CRITICAL Level (Security Incidents):**
```
2024-01-02 10:00:20 - telegram - WARNING - Unauthorized access attempt from user ID: 999999999
```

### Search Logs

```bash
# View all logs
cat ~/.opencode/bot.log

# View recent errors
tail -50 ~/.opencode/bot.log | grep ERROR

# View unauthorized access attempts
grep -i "unauthorized" ~/.opencode/bot.log

# View today's logs
tail -f ~/.opencode/bot.log

# Search for specific user
grep "123456789" ~/.opencode/bot.log
```

---

## Debug Mode

### Enable Verbose Logging

1. **Edit .env file:**
   ```env
   LOG_LEVEL=DEBUG
   ```

2. **Restart the bot:**
   ```bash
   sudo systemctl restart opencode-bot
   ```

3. **Watch debug logs:**
   ```bash
   tail -f ~/.opencode/bot.log | grep DEBUG
   ```

### Test Individual Components

**Test User ID Validation:**
```bash
python3 -c "
from bot_listener import validate_user
# Mock update object would go here
print('User validation function loaded successfully')
"
```

**Test Command Construction:**
```bash
python3 -c "
from bot_listener import construct_konsole_command, sanitize_prompt
prompt = 'test prompt'
safe = sanitize_prompt(prompt)
cmd = construct_konsole_command(safe)
print('Command:', ' '.join(cmd))
"
```

### Network Testing

```bash
# Test Telegram API
curl https://api.telegram.org/bot<BOT_TOKEN>/getMe

# Test Mini App URL
curl -I https://yourusername.github.io/telegram-opencode-bot/

# Test local display access
xauth list
```

---

## Still Having Issues?

If you've tried all troubleshooting steps:

1. **Gather system information:**
   ```bash
   uname -a
   python3 --version
   cat /home/willydilly47/telegram-opencode-bot/backend/.env
   tail -100 ~/.opencode/bot.log
   ```

2. **Check existing issues:**
   - Search [GitHub Issues](https://github.com/yourusername/telegram-opencode-bot/issues)

3. **Create a new issue:**
   - Include:
     - Operating system and version
     - Python version
     - Complete error messages
     - Steps to reproduce
     - Log file contents

---

## Emergency Recovery

### Reset Bot Configuration

```bash
# Stop the bot
sudo systemctl stop opencode-bot

# Backup current config
cp /home/willydilly47/telegram-opencode-bot/backend/.env /tmp/.env.backup

# Reset to defaults
cp /home/willydilly47/telegram-opencode-bot/backend/.env.example /home/willydilly47/telegram-opencode-bot/backend/.env

# Reconfigure
nano /home/willydilly47/telegram-opencode-bot/backend/.env

# Restart
sudo systemctl start opencode-bot
```

### Reinstall Dependencies

```bash
# Stop the bot
sudo systemctl stop opencode-bot

# Remove virtual environment
rm -rf /home/willydilly47/telegram-opencode-bot/backend/venv

# Recreate and reinstall
python3 -m venv /home/willydilly47/telegram-opencode-bot/backend/venv
source /home/willydilly47/telegram-opencode-bot/backend/venv/bin/activate
pip install -r /home/willydilly47/telegram-opencode-bot/backend/requirements.txt

# Restart
sudo systemctl start opencode-bot
```

---

**Document Version:** 1.0.0  
**Last Updated:** January 2, 2026
