#!/usr/bin/env python3
"""
Prometheus exporter for Telegram bots
This script exposes metrics from your Telegram bot for Prometheus to scrape
"""

from prometheus_client import start_http_server, Counter, Gauge, Histogram, Summary
import time
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Define metrics
bot_messages_total = Counter(
    'telegram_bot_messages_total',
    'Total number of messages processed by the bot',
    ['bot_name', 'chat_type', 'message_type']
)

bot_errors_total = Counter(
    'telegram_bot_errors_total',
    'Total number of errors encountered',
    ['bot_name', 'error_type']
)

bot_active_users = Gauge(
    'telegram_bot_active_users',
    'Number of active users',
    ['bot_name']
)

bot_commands_total = Counter(
    'telegram_bot_commands_total',
    'Total number of commands executed',
    ['bot_name', 'command']
)

bot_response_time = Histogram(
    'telegram_bot_response_time_seconds',
    'Response time for bot commands',
    ['bot_name', 'command']
)

bot_uptime_seconds = Gauge(
    'telegram_bot_uptime_seconds',
    'Bot uptime in seconds',
    ['bot_name']
)

class TelegramBotMetrics:
    """
    Metrics collector for Telegram bots
    Integrate this into your bot code
    """
    
    def __init__(self, bot_name='my_bot'):
        self.bot_name = bot_name
        self.start_time = time.time()
        self.active_users = set()
    
    def record_message(self, chat_type='private', message_type='text'):
        """Record a message received by the bot"""
        bot_messages_total.labels(
            bot_name=self.bot_name,
            chat_type=chat_type,
            message_type=message_type
        ).inc()
    
    def record_error(self, error_type='unknown'):
        """Record an error"""
        bot_errors_total.labels(
            bot_name=self.bot_name,
            error_type=error_type
        ).inc()
    
    def add_active_user(self, user_id):
        """Add a user to active users set"""
        self.active_users.add(user_id)
        bot_active_users.labels(bot_name=self.bot_name).set(len(self.active_users))
    
    def record_command(self, command):
        """Record a command execution"""
        bot_commands_total.labels(
            bot_name=self.bot_name,
            command=command
        ).inc()
    
    def record_response_time(self, command, duration):
        """Record response time for a command"""
        bot_response_time.labels(
            bot_name=self.bot_name,
            command=command
        ).observe(duration)
    
    def update_uptime(self):
        """Update bot uptime"""
        uptime = time.time() - self.start_time
        bot_uptime_seconds.labels(bot_name=self.bot_name).set(uptime)


# Example usage with aiogram (popular Telegram bot framework)
"""
from aiogram import Bot, Dispatcher, types
from aiogram.filters import Command

# Initialize bot
bot = Bot(token='YOUR_BOT_TOKEN')
dp = Dispatcher()
metrics = TelegramBotMetrics(bot_name='my_awesome_bot')

@dp.message(Command(commands=['start']))
async def cmd_start(message: types.Message):
    start_time = time.time()
    
    # Record the command
    metrics.record_command('start')
    metrics.add_active_user(message.from_user.id)
    metrics.record_message(chat_type=message.chat.type, message_type='command')
    
    try:
        await message.answer("Hello! I'm tracking metrics!")
        
        # Record response time
        duration = time.time() - start_time
        metrics.record_response_time('start', duration)
    except Exception as e:
        metrics.record_error('send_message_error')
        logger.error(f"Error: {e}")

@dp.message()
async def handle_message(message: types.Message):
    metrics.record_message(
        chat_type=message.chat.type,
        message_type=message.content_type
    )
    metrics.add_active_user(message.from_user.id)

async def update_metrics_periodically():
    '''Update metrics that need periodic updates'''
    while True:
        metrics.update_uptime()
        await asyncio.sleep(60)

if __name__ == '__main__':
    # Start metrics server
    start_http_server(8000)
    logger.info("Metrics server started on port 8000")
    
    # Start periodic metrics update
    import asyncio
    asyncio.create_task(update_metrics_periodically())
    
    # Start bot
    dp.run_polling(bot)
"""


if __name__ == '__main__':
    # Example standalone metrics server
    # In production, integrate this into your bot code
    
    logger.info("Starting Telegram bot metrics exporter on port 8000")
    start_http_server(8000)
    
    # Keep the server running
    metrics = TelegramBotMetrics(bot_name='example_bot')
    
    logger.info("Metrics available at http://localhost:8000/metrics")
    logger.info("Example metrics:")
    logger.info("  - telegram_bot_messages_total")
    logger.info("  - telegram_bot_errors_total")
    logger.info("  - telegram_bot_active_users")
    logger.info("  - telegram_bot_commands_total")
    logger.info("  - telegram_bot_response_time_seconds")
    logger.info("  - telegram_bot_uptime_seconds")
    
    # Simulate some metrics for demo
    while True:
        metrics.update_uptime()
        time.sleep(60)
