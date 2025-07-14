# Setup Instructions

## 1. Environment Variables

Copy the template file and configure your credentials:

```bash
cp .Renviron.template .Renviron
```

Edit `.Renviron` with your actual values:

```bash
# OpenAI API Key (required)
OPENAI_API_KEY=sk-your-actual-openai-key-here

# Telegram Bot Token (optional, for bot functionality)
TELEGRAM_TOKEN_BOT=your-telegram-bot-token-here

# Email configuration (optional, for email functionality)
NEWSLETTER_EMAIL=your-email@gmail.com
EMAIL_FROM=your-email@gmail.com
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-gmail-app-password
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
```

## 2. Get OpenAI API Key

1. Go to https://platform.openai.com/account/api-keys
2. Create a new API key
3. Copy the full key (starts with `sk-`)

## 3. Get Telegram Bot Token (Optional)

1. Open Telegram and search for @BotFather
2. Send `/newbot` command
3. Follow instructions to create a bot
4. Copy the token provided

## 4. Gmail App Password (Optional)

1. Enable 2-factor authentication on Gmail
2. Go to Google Account → Security → App passwords
3. Generate an app password for "Mail"
4. Use the 16-character password (no spaces)

## 5. Test Configuration

```bash
# Test API keys
Rscript tests/check_keys.R

# Test OpenAI connection
Rscript tests/test_openai_key.R

# Test newsletter generation
Rscript tests/test_txt_newsletter.R
```

## 6. Run the System

```bash
# Generate newsletter only
Rscript run_newsletter.R

# Full system with Telegram
Rscript run_telegram_bot.R
```

## Important Notes

- The `.Renviron` file contains sensitive information and should NOT be committed to Git
- Keep your API keys secure and never share them publicly
- The system works without Telegram token (newsletter-only mode)
- Email configuration is optional (newsletter generates TXT files)