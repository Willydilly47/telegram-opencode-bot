#!/usr/bin/env python3
"""
Telegram OpenCode Bot - Main Listener

This bot enables remote control of OpenCode on a Linux desktop via Telegram Mini App.
Users can type prompts in Telegram, which triggers a Konsole window running OpenCode.

Features:
- User ID validation (security whitelist)
- Command injection prevention
- Konsole subprocess execution
- Comprehensive logging

Usage:
    python3 bot_listener.py

Requirements:
    - Telegram bot token (via @BotFather)
    - Allowed user ID (via @userinfobot)
    - Mini App URL (hosted on GitHub Pages)
    - Konsole and OpenCode installed on the system

Author: OpenCode Bot
Version: 1.0.0
"""

import asyncio
import json
import logging
import os
import shlex
import subprocess
import sys
from pathlib import Path
from typing import Optional

from telegram import KeyboardButton, ReplyKeyboardMarkup, Update, WebAppInfo
from telegram.ext import (
    Application,
    CommandHandler,
    ContextTypes,
    MessageHandler,
    filters,
)

# =============================================================================
# Configuration
# =============================================================================

# Load environment variables from .env file
from dotenv import load_dotenv

load_dotenv()

# Required configuration
BOT_TOKEN: str = os.getenv("BOT_TOKEN", "")
ALLOWED_USER_ID: int = int(os.getenv("ALLOWED_USER_ID", "0"))
MINI_APP_URL: str = os.getenv("MINI_APP_URL", "")

# Optional configuration
WORKING_DIR: str = os.getenv("WORKING_DIR", str(Path.home()))
DISPLAY: str = os.getenv("DISPLAY", ":0")
LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
LOG_FILE: str = os.getenv("LOG_FILE", str(Path.home() / ".opencode" / "bot.log"))

# Security: Maximum prompt length
MAX_PROMPT_LENGTH: int = 5000

# =============================================================================
# Logging Setup
# =============================================================================

def setup_logging() -> logging.Logger:
    """
    Configure logging for the bot.
    
    Creates log directory if it doesn't exist and sets up file and console logging.
    
    Returns:
        Configured logger instance
    """
    # Create log directory if it doesn't exist
    log_dir = Path(LOG_FILE).parent
    log_dir.mkdir(parents=True, exist_ok=True)
    
    # Configure logging format
    log_format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    
    # Set up logging
    logging.basicConfig(
        format=log_format,
        level=getattr(logging, LOG_LEVEL, logging.INFO),
        handlers=[
            logging.FileHandler(LOG_FILE),
            logging.StreamHandler(sys.stdout),
        ],
    )
    
    logger = logging.getLogger(__name__)
    logger.info(f"Logging initialized. Level: {LOG_LEVEL}, File: {LOG_FILE}")
    return logger


# Initialize logger
logger = setup_logging()


# =============================================================================
# Security Functions
# =============================================================================

def validate_user(update: Update) -> bool:
    """
    Validate that the user is in the allowed list.
    
    This is the primary security check - all handlers must call this first.
    
    Args:
        update: Telegram update object containing user information
        
    Returns:
        True if user is authorized, False otherwise
    """
    if not update.effective_user:
        logger.warning("No user information in update")
        return False
    
    user_id = update.effective_user.id
    
    if user_id != ALLOWED_USER_ID:
        logger.warning(
            f"Unauthorized access attempt from user ID: {user_id}",
            extra={"levelname": "CRITICAL"}
        )
        return False
    
    return True


def sanitize_prompt(prompt: str) -> str:
    """
    Sanitize user prompt to prevent command injection.
    
    Uses shlex.quote() to safely escape special characters and quotes.
    This ensures the prompt is treated as a single string argument.
    
    Args:
        prompt: Raw user input from Mini App
        
    Returns:
        Safely quoted prompt string
        
    Raises:
        ValueError: If prompt exceeds maximum length
    """
    # Check length
    if len(prompt) > MAX_PROMPT_LENGTH:
        raise ValueError(f"Prompt exceeds maximum length of {MAX_PROMPT_LENGTH} characters")
    
    # Use shlex.quote to safely escape special characters
    # This prevents command injection by treating the entire prompt as one argument
    safe_prompt = shlex.quote(prompt)
    
    return safe_prompt


def construct_konsole_command(prompt: str) -> list:
    """
    Construct the Konsole command with proper argument separation.
    
    Uses list-based subprocess execution to prevent command injection.
    The command structure:
    - konsole: Opens a new terminal window
    - --workdir: Sets the working directory
    - -e: Executes the following command
    - bash -c: Runs the command in bash
    - opencode '{prompt}': Executes OpenCode with the prompt
    - ; exec bash: Keeps the terminal open after execution
    
    Args:
        prompt: Sanitized user prompt
        
    Returns:
        List of command arguments for subprocess execution
    """
    # Construct command as a list for safe subprocess execution
    # This is the recommended approach for subprocess to prevent injection
    command = [
        "konsole",
        "--workdir", WORKING_DIR,
        "-e", "bash", "-c",
        f"opencode {prompt}; echo '--- Done ---'; exec bash"
    ]
    
    logger.debug(f"Constructed command: {' '.join(command[:3])} ... [{len(command)} args total]")
    return command


def execute_command(command: list) -> tuple:
    """
    Execute the Konsole command subprocess.
    
    Sets necessary environment variables and executes the command.
    
    Args:
        command: List of command arguments
        
    Returns:
        Tuple of (return_code, stdout, stderr)
    """
    # Prepare environment
    env = os.environ.copy()
    env["DISPLAY"] = DISPLAY
    env["PYTHONUNBUFFERED"] = "1"  # Immediate output
    
    try:
        logger.info(f"Executing command: {command[0]} with {len(command)-1} arguments")
        
        # Execute subprocess
        # Using subprocess.Popen for better control over the process
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env=env,
            # Start process in own process group for better cleanup
            start_new_session=True,
        )
        
        # Wait for process to complete (with timeout)
        try:
            stdout, stderr = process.communicate(timeout=10)
            return_code = process.returncode
        except subprocess.TimeoutExpired:
            # Process is still running (expected for Konsole)
            logger.info("Konsole launched successfully (process continues running)")
            stdout = ""
            stderr = ""
            return_code = 0
        
        logger.info(f"Command completed with return code: {return_code}")
        return return_code, stdout, stderr
        
    except FileNotFoundError as e:
        logger.error(f"Command not found: {e}")
        raise
    except PermissionError as e:
        logger.error(f"Permission denied: {e}")
        raise
    except Exception as e:
        logger.error(f"Error executing command: {e}")
        raise


# =============================================================================
# Bot Handlers
# =============================================================================

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """
    Handle the /start command.
    
    Sends a welcome message with a button to launch the Mini App.
    Validates user ID before sending any information.
    
    Args:
        update: Telegram update object
        context: Bot context
    """
    # Validate user
    if not validate_user(update):
        return
    
    user = update.effective_user
    logger.info(f"User {user.id} ({user.full_name}) initiated /start command")
    
    # Create keyboard with Mini App button
    keyboard = [
        [KeyboardButton(
            text="🚀 Launch OpenCode",
            web_app=WebAppInfo(url=MINI_APP_URL)
        )]
    ]
    reply_markup = ReplyKeyboardMarkup(keyboard, resize_keyboard=True)
    
    # Send welcome message
    welcome_message = (
        f"👋 Hello, {user.full_name}!\n\n"
        "I'm your OpenCode Bot. I can help you run OpenCode commands remotely.\n\n"
        "Click the button below to open the Mini App and enter your prompt."
    )
    
    try:
        await update.message.reply_text(
            text=welcome_message,
            reply_markup=reply_markup
        )
        logger.info(f"Sent Mini App button to user {user.id}")
    except Exception as e:
        logger.error(f"Error sending welcome message: {e}")
        await update.message.reply_text(
            "Sorry, something went wrong. Please try again."
        )


async def handle_webapp_data(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """
    Handle data sent from the Telegram Mini App.
    
    This is the main handler for processing user prompts:
    1. Validates user ID
    2. Extracts prompt from web_app_data
    3. Sanitizes prompt to prevent injection
    4. Constructs and executes Konsole command
    5. Sends confirmation to user
    
    Args:
        update: Telegram update object
        context: Bot context
    """
    # Validate user
    if not validate_user(update):
        return
    
    # Get user information
    user = update.effective_user
    user_id = user.id
    user_name = user.full_name
    
    # Extract prompt from web_app_data
    if not update.message or not update.message.web_app_data:
        logger.warning(f"Received webapp_data without data from user {user_id}")
        await update.message.reply_text(
            "Error: No data received from Mini App."
        )
        return
    
    raw_prompt = update.message.web_app_data.data
    logger.info(f"Received prompt from user {user_id}: {raw_prompt[:50]}...")
    
    try:
        # Sanitize prompt to prevent command injection
        safe_prompt = sanitize_prompt(raw_prompt)
        logger.debug(f"Sanitized prompt: {safe_prompt}")
        
        # Construct Konsole command
        command = construct_konsole_command(safe_prompt)
        
        # Execute command
        return_code, stdout, stderr = execute_command(command)
        
        # Send confirmation
        confirmation = (
            f"✅ Command sent to Konsole!\n\n"
            f"📝 Your prompt: {raw_prompt[:100]}{'...' if len(raw_prompt) > 100 else ''}\n\n"
            f"💻 A Konsole window should now be open with OpenCode running."
        )
        
        await update.message.reply_text(confirmation)
        logger.info(f"Successfully processed prompt from user {user_id}")
        
    except ValueError as e:
        # Prompt validation error
        error_message = f"❌ Error: {str(e)}"
        await update.message.reply_text(error_message)
        logger.warning(f"Prompt validation error from user {user_id}: {e}")
        
    except Exception as e:
        # General error
        error_message = (
            f"❌ Error executing command: {str(e)}\n\n"
            "Please check that:\n"
            "- Konsole is installed\n"
            "- OpenCode is installed and in PATH\n"
            "- DISPLAY is set correctly"
        )
        await update.message.reply_text(error_message)
        logger.error(f"Error processing prompt from user {user_id}: {e}", exc_info=True)


async def error_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """
    Handle errors and exceptions in the bot.
    
    Logs all errors and sends a user-friendly message if appropriate.
    
    Args:
        update: Telegram update object (may be None)
        context: Bot context containing the error
    """
    logger.error(
        f"Exception while handling update: {context.error}",
        exc_info=context.error
    )
    
    if update and update.message:
        try:
            await update.message.reply_text(
                "Sorry, an error occurred. Please try again later."
            )
        except Exception:
            logger.error("Failed to send error message to user")


# =============================================================================
# Main Application
# =============================================================================

def main() -> None:
    """
    Main entry point for the bot.
    
    Sets up the Telegram Application, registers handlers, and starts polling.
    """
    logger.info("Starting Telegram OpenCode Bot...")
    
    # Validate configuration
    if not BOT_TOKEN:
        logger.error("BOT_TOKEN not set. Please configure .env file.")
        sys.exit(1)
    
    if not ALLOWED_USER_ID:
        logger.error("ALLOWED_USER_ID not set. Please configure .env file.")
        sys.exit(1)
    
    if not MINI_APP_URL:
        logger.error("MINI_APP_URL not set. Please configure .env file.")
        sys.exit(1)
    
    logger.info(f"Configuration validated. Bot Token: {BOT_TOKEN[:10]}...")
    logger.info(f"Allowed User ID: {ALLOWED_USER_ID}")
    logger.info(f"Mini App URL: {MINI_APP_URL}")
    
    # Create Application
    application = (
        Application.builder()
        .token(BOT_TOKEN)
        .concurrent_updates(True)
        .build()
    )
    
    # Register handlers
    # /start command handler
    application.add_handler(CommandHandler("start", start))
    
    # WebApp data handler - accept all messages and check for web_app_data
    application.add_handler(
        MessageHandler(filters.ALL & ~filters.COMMAND, handle_webapp_data)
    )
    
    # Error handler
    application.add_handler(MessageHandler(filters.ALL, error_handler))
    
    # Start polling
    logger.info("Bot is starting...")
    application.run_polling(
        drop_pending_updates=True,
        allowed_updates=Update.ALL_TYPES
    )


if __name__ == "__main__":
    main()
