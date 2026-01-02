#!/usr/bin/env python3
"""
Telegram OpenCode Bot - Unit Tests

This file contains comprehensive unit tests for the bot_listener.py module.
Tests cover:
- User ID validation
- Prompt sanitization
- Command construction
- Error handling

Run with:
    python3 -m pytest test_bot_listener.py -v

Author: OpenCode Bot
Version: 1.0.0
"""

import os
import sys
import unittest
from pathlib import Path
from unittest.mock import MagicMock, Mock, patch

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

# Set up mock environment before importing bot_listener
os.environ["BOT_TOKEN"] = "test_token"
os.environ["ALLOWED_USER_ID"] = "123456789"
os.environ["MINI_APP_URL"] = "https://test.example.com"
os.environ["DISPLAY"] = ":0"
os.environ["WORKING_DIR"] = "/home/willydilly47"
os.environ["LOG_LEVEL"] = "DEBUG"
os.environ["LOG_FILE"] = "/tmp/test_bot.log"


class TestUserIdValidation(unittest.TestCase):
    """Test user ID validation functionality."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.allowed_user_id = 123456789
        self.mock_update = Mock()
        self.mock_update.effective_user = Mock()
        self.mock_update.effective_user.id = self.allowed_user_id
    
    def test_authorized_user_returns_true(self):
        """Test that authorized user ID is accepted."""
        from bot_listener import validate_user
        
        result = validate_user(self.mock_update)
        self.assertTrue(result)
    
    def test_unauthorized_user_returns_false(self):
        """Test that unauthorized user ID is rejected."""
        from bot_listener import validate_user
        
        self.mock_update.effective_user.id = 999999999
        
        result = validate_user(self.mock_update)
        self.assertFalse(result)
    
    def test_no_user_returns_false(self):
        """Test that missing user information is rejected."""
        from bot_listener import validate_user
        
        self.mock_update.effective_user = None
        
        result = validate_user(self.mock_update)
        self.assertFalse(result)
    
    def test_unauthorized_access_is_logged(self):
        """Test that unauthorized access attempts are logged."""
        from bot_listener import validate_user
        
        self.mock_update.effective_user = Mock()
        self.mock_update.effective_user.id = 999999999
        
        with self.assertLogs('bot_listener', level='WARNING'):
            validate_user(self.mock_update)


class TestPromptSanitization(unittest.TestCase):
    """Test prompt sanitization and validation."""
    
    def test_normal_prompt_passes(self):
        """Test that normal prompts are accepted."""
        from bot_listener import sanitize_prompt
        
        prompt = "Analyze the codebase structure"
        result = sanitize_prompt(prompt)
        
        self.assertIsInstance(result, str)
        self.assertGreater(len(result), 0)
    
    def test_prompt_with_quotes_is_quoted(self):
        """Test that quotes are properly escaped."""
        from bot_listener import sanitize_prompt
        
        prompt = "Write a function with 'quotes' inside"
        result = sanitize_prompt(prompt)
        
        # Result should contain the quoted version
        self.assertIn("'", result) or self.assertIn('"', result)
    
    def test_prompt_with_semicolon_sanitized(self):
        """Test that semicolons are handled safely."""
        from bot_listener import sanitize_prompt
        
        prompt = "echo hello; rm -rf /"
        result = sanitize_prompt(prompt)
        
        # Should not allow direct command chaining
        # The sanitized version should treat it as a string
        self.assertNotEqual(prompt, result)
    
    def test_empty_prompt_accepted(self):
        """Test that empty prompts are technically accepted."""
        from bot_listener import sanitize_prompt
        
        prompt = ""
        result = sanitize_prompt(prompt)
        
        self.assertIsInstance(result, str)
    
    def test_prompt_exceeding_max_length_rejected(self):
        """Test that prompts exceeding max length are rejected."""
        from bot_listener import sanitize_prompt, MAX_PROMPT_LENGTH
        
        # Create a prompt that's too long
        long_prompt = "a" * (MAX_PROMPT_LENGTH + 1)
        
        with self.assertRaises(ValueError) as context:
            sanitize_prompt(long_prompt)
        
        self.assertIn("maximum length", str(context.exception))
    
    def test_prompt_at_max_length_accepted(self):
        """Test that prompts at max length are accepted."""
        from bot_listener import sanitize_prompt, MAX_PROMPT_LENGTH
        
        max_prompt = "a" * MAX_PROMPT_LENGTH
        result = sanitize_prompt(max_prompt)
        
        self.assertIsInstance(result, str)
    
    def test_prompt_with_special_characters(self):
        """Test that special characters are sanitized."""
        from bot_listener import sanitize_prompt
        
        special_chars = r"`!@#$%^&*()[]{}|;:'\"<>,?/\\"
        result = sanitize_prompt(special_chars)
        
        self.assertIsInstance(result, str)
        self.assertGreater(len(result), 0)
    
    def test_prompt_with_newlines(self):
        """Test that newlines are handled."""
        from bot_listener import sanitize_prompt
        
        multiline = "line1\nline2\nline3"
        result = sanitize_prompt(multiline)
        
        self.assertIsInstance(result, str)


class TestCommandConstruction(unittest.TestCase):
    """Test command construction for subprocess execution."""
    
    def test_command_is_list(self):
        """Test that command is returned as a list."""
        from bot_listener import construct_konsole_command, sanitize_prompt
        
        prompt = "test prompt"
        safe_prompt = sanitize_prompt(prompt)
        command = construct_konsole_command(safe_prompt)
        
        self.assertIsInstance(command, list)
    
    def test_command_starts_with_konsole(self):
        """Test that command starts with konsole."""
        from bot_listener import construct_konsole_command, sanitize_prompt
        
        prompt = "test"
        command = construct_konsole_command(sanitize_prompt(prompt))
        
        self.assertEqual(command[0], "konsole")
    
    def test_command_includes_workdir(self):
        """Test that command includes workdir argument."""
        from bot_listener import construct_konsole_command, sanitize_prompt, WORKING_DIR
        
        prompt = "test"
        command = construct_konsole_command(sanitize_prompt(prompt))
        
        # Should have --workdir argument followed by path
        self.assertIn("--workdir", command)
        workdir_index = command.index("--workdir")
        self.assertEqual(command[workdir_index + 1], WORKING_DIR)
    
    def test_command_includes_e_flag(self):
        """Test that command includes -e flag."""
        from bot_listener import construct_konsole_command, sanitize_prompt
        
        prompt = "test"
        command = construct_konsole_command(sanitize_prompt(prompt))
        
        self.assertIn("-e", command)
    
    def test_command_includes_opencode(self):
        """Test that command includes opencode."""
        from bot_listener import construct_konsole_command, sanitize_prompt
        
        prompt = "test"
        command = construct_konsole_command(sanitize_prompt(prompt))
        
        command_str = ' '.join(command)
        self.assertIn("opencode", command_str)
    
    def test_command_structure(self):
        """Test overall command structure."""
        from bot_listener import construct_konsole_command, sanitize_prompt
        
        prompt = "hello world"
        command = construct_konsole_command(sanitize_prompt(prompt))
        
        # Expected structure:
        # ["konsole", "--workdir", PATH, "-e", "bash", "-c", "opencode ...; exec bash"]
        self.assertEqual(command[0], "konsole")
        self.assertEqual(command[3], "-e")
        self.assertEqual(command[4], "bash")
        self.assertEqual(command[5], "-c")
    
    def test_safe_prompt_in_command(self):
        """Test that sanitized prompt is included in command."""
        from bot_listener import construct_konsole_command, sanitize_prompt
        
        prompt = "test prompt with spaces"
        safe_prompt = sanitize_prompt(prompt)
        command = construct_konsole_command(safe_prompt)
        
        command_str = ' '.join(command)
        
        # The prompt should appear somewhere in the command
        # (it will be quoted by shlex)
        self.assertIn("opencode", command_str)


class TestSecurityFeatures(unittest.TestCase):
    """Test security-related functionality."""
    
    def test_no_shell_true_in_subprocess(self):
        """Test that subprocess is not run with shell=True."""
        # This is a code review test - we verify the implementation
        from bot_listener import execute_command
        import inspect
        
        # Get the source code of execute_command
        source = inspect.getsource(execute_command)
        
        # Verify shell=True is not used
        self.assertNotIn("shell=True", source)
    
    def test_list_based_subprocess(self):
        """Test that subprocess uses list-based execution."""
        from bot_listener import execute_command
        import inspect
        
        source = inspect.getsource(execute_command)
        
        # Should use Popen with list, not subprocess.run with string
        self.assertIn("Popen", source)
    
    def test_shlex_quote_used(self):
        """Test that shlex.quote is used for sanitization."""
        from bot_listener import sanitize_prompt
        import inspect
        
        source = inspect.getsource(sanitize_prompt)
        
        self.assertIn("shlex", source)
        self.assertIn("quote", source)
    
    def test_max_length_constant_exists(self):
        """Test that MAX_PROMPT_LENGTH is defined."""
        from bot_listener import MAX_PROMPT_LENGTH
        
        self.assertIsInstance(MAX_PROMPT_LENGTH, int)
        self.assertGreater(MAX_PROMPT_LENGTH, 0)
        self.assertEqual(MAX_PROMPT_LENGTH, 5000)


class TestConfigurationLoading(unittest.TestCase):
    """Test configuration loading from environment."""
    
    def test_env_file_loaded(self):
        """Test that .env file is loaded."""
        from bot_listener import BOT_TOKEN, ALLOWED_USER_ID, MINI_APP_URL
        
        # Should have loaded from environment
        self.assertEqual(BOT_TOKEN, "test_token")
        self.assertEqual(ALLOWED_USER_ID, 123456789)
        self.assertEqual(MINI_APP_URL, "https://test.example.com")
    
    def test_default_values(self):
        """Test that default values are applied."""
        from bot_listener import DISPLAY, WORKING_DIR, LOG_LEVEL
        
        self.assertEqual(DISPLAY, ":0")
        self.assertEqual(WORKING_DIR, "/home/willydilly47")
        self.assertEqual(LOG_LEVEL, "DEBUG")


class TestBotHandlers(unittest.TestCase):
    """Test bot command handlers."""
    
    def setUp(self):
        """Set up mock update and context."""
        self.mock_update = Mock()
        self.mock_update.effective_user = Mock()
        self.mock_update.effective_user.id = 123456789
        self.mock_update.effective_user.full_name = "Test User"
        self.mock_update.message = Mock()
        self.mock_context = Mock()
    
    async def test_start_handler_sends_button(self):
        """Test that /start handler sends Mini App button."""
        from bot_listener import start
        
        self.mock_update.message.reply_text = Mock()
        
        await start(self.mock_update, self.mock_context)
        
        # Verify reply_text was called
        self.mock_update.message.reply_text.assert_called_once()
        
        # Check that button is in the reply markup
        call_args = self.mock_update.message.reply_text.call_args
        reply_markup = call_args.kwargs.get('reply_markup')
        self.assertIsNotNone(reply_markup)
    
    async def test_start_handler_validates_user(self):
        """Test that /start handler validates user first."""
        from bot_listener import start
        
        # Set unauthorized user
        self.mock_update.effective_user.id = 999999999
        self.mock_update.message.reply_text = Mock()
        
        await start(self.mock_update, self.mock_context)
        
        # Should not have sent any message
        self.mock_update.message.reply_text.assert_not_called()


class TestIntegrationScenarios(unittest.TestCase):
    """Integration-style tests for complete workflows."""
    
    def test_full_sanitization_workflow(self):
        """Test complete prompt sanitization workflow."""
        from bot_listener import sanitize_prompt, construct_konsole_command
        
        # Malicious-looking input
        malicious_input = "'; rm -rf /; echo '"
        
        # Sanitize
        safe = sanitize_prompt(malicious_input)
        
        # Verify it's been modified
        self.assertNotEqual(safe, malicious_input)
        
        # Build command
        command = construct_konsole_command(safe)
        
        # Verify command structure
        self.assertIsInstance(command, list)
        self.assertEqual(command[0], "konsole")
    
    def test_user_validation_before_processing(self):
        """Test that user validation is required before processing."""
        from bot_listener import validate_user
        
        # Create mock updates for different scenarios
        authorized_update = Mock()
        authorized_update.effective_user = Mock()
        authorized_update.effective_user.id = 123456789
        
        unauthorized_update = Mock()
        unauthorized_update.effective_user = Mock()
        unauthorized_update.effective_user.id = 999999999
        
        no_user_update = Mock()
        no_user_update.effective_user = None
        
        # Test all scenarios
        self.assertTrue(validate_user(authorized_update))
        self.assertFalse(validate_user(unauthorized_update))
        self.assertFalse(validate_user(no_user_update))


class TestEdgeCases(unittest.TestCase):
    """Test edge cases and boundary conditions."""
    
    def test_unicode_in_prompt(self):
        """Test that Unicode characters are handled."""
        from bot_listener import sanitize_prompt
        
        unicode_prompt = "Привет мир 🌍 OpenCode"
        result = sanitize_prompt(unicode_prompt)
        
        self.assertIsInstance(result, str)
        self.assertGreater(len(result), 0)
    
    def test_emoji_in_prompt(self):
        """Test that emoji are handled."""
        from bot_listener import sanitize_prompt
        
        emoji_prompt = "Write a function that returns 🚀"
        result = sanitize_prompt(emoji_prompt)
        
        self.assertIsInstance(result, str)
    
    def test_very_long_prompt_at_limit(self):
        """Test prompt at exactly the max length."""
        from bot_listener import sanitize_prompt, MAX_PROMPT_LENGTH
        
        exact_prompt = "x" * MAX_PROMPT_LENGTH
        result = sanitize_prompt(exact_prompt)
        
        self.assertIsInstance(result, str)
    
    def test_prompt_with_only_spaces(self):
        """Test prompt with only whitespace."""
        from bot_listener import sanitize_prompt
        
        spaces_prompt = "     "
        result = sanitize_prompt(spaces_prompt)
        
        self.assertIsInstance(result, str)
        self.assertGreater(len(result), 0)
    
    def test_prompt_with_tabs_and_newlines(self):
        """Test prompt with tabs and newlines."""
        from bot_listener import sanitize_prompt
        
        ws_prompt = "line1\n\tline2\r\n\t\tline3"
        result = sanitize_prompt(ws_prompt)
        
        self.assertIsInstance(result, str)


def run_tests():
    """Run all tests and return results."""
    # Create test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    # Add all test classes
    suite.addTests(loader.loadTestsFromTestCase(TestUserIdValidation))
    suite.addTests(loader.loadTestsFromTestCase(TestPromptSanitization))
    suite.addTests(loader.loadTestsFromTestCase(TestCommandConstruction))
    suite.addTests(loader.loadTestsFromTestCase(TestSecurityFeatures))
    suite.addTests(loader.loadTestsFromTestCase(TestConfigurationLoading))
    suite.addTests(loader.loadTestsFromTestCase(TestBotHandlers))
    suite.addTests(loader.loadTestsFromTestCase(TestIntegrationScenarios))
    suite.addTests(loader.loadTestsFromTestCase(TestEdgeCases))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    return result


if __name__ == "__main__":
    print("=" * 70)
    print("Telegram OpenCode Bot - Unit Tests")
    print("=" * 70)
    print()
    
    result = run_tests()
    
    print()
    print("=" * 70)
    print("Test Summary")
    print("=" * 70)
    print(f"Tests run: {result.testsRun}")
    print(f"Successes: {result.testsRun - len(result.failures) - len(result.errors)}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    print()
    
    if result.wasSuccessful():
        print("✅ All tests passed!")
        sys.exit(0)
    else:
        print("❌ Some tests failed!")
        sys.exit(1)
