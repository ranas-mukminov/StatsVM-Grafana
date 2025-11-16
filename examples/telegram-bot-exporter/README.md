# Telegram Bot Prometheus Exporter

This directory contains an example Prometheus exporter for Telegram bots.

## Features

- Track total messages processed
- Monitor error rates
- Count active users
- Record command executions
- Measure response times
- Track bot uptime

## Installation

```bash
pip install -r requirements.txt
```

## Usage

### Standalone Mode

For testing the metrics server:

```bash
python bot_exporter.py
```

Then visit http://localhost:8000/metrics to see the exported metrics.

### Integration with Your Bot

Import the `TelegramBotMetrics` class into your bot code:

```python
from bot_exporter import TelegramBotMetrics
import time

# Initialize metrics
metrics = TelegramBotMetrics(bot_name='my_bot')

# Record messages
@dp.message()
async def handle_message(message):
    metrics.record_message(
        chat_type=message.chat.type,
        message_type=message.content_type
    )
    metrics.add_active_user(message.from_user.id)
    # ... your bot logic

# Record commands with timing
@dp.message(Command(commands=['start']))
async def cmd_start(message):
    start_time = time.time()
    metrics.record_command('start')
    
    # ... your command logic
    
    duration = time.time() - start_time
    metrics.record_response_time('start', duration)

# Start metrics server
from prometheus_client import start_http_server
start_http_server(8000)
```

## Prometheus Configuration

Add this to your `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'telegram-bot'
    static_configs:
      - targets: ['bot-exporter:8000']
        labels:
          instance: 'telegram-bot'
```

## Docker Integration

You can add the bot exporter to the monitoring stack:

```yaml
# docker-compose.yml
services:
  telegram-bot:
    build: ./examples/telegram-bot-exporter
    ports:
      - "8000:8000"
    environment:
      - BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
    networks:
      - monitoring
```

## Grafana Dashboard

Create a dashboard with panels for:

1. **Message Rate**: `rate(telegram_bot_messages_total[5m])`
2. **Error Rate**: `rate(telegram_bot_errors_total[5m])`
3. **Active Users**: `telegram_bot_active_users`
4. **Command Distribution**: `telegram_bot_commands_total`
5. **Response Time**: `histogram_quantile(0.95, telegram_bot_response_time_seconds_bucket)`
6. **Uptime**: `telegram_bot_uptime_seconds`
