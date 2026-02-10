# Setup Instructions

## 1. Environment Variables

Copy the template file and configure your credentials:

```bash
cp .Renviron.template .Renviron
```

Edit `.Renviron` with your actual values:

```bash
# Telegram Bot Token (requerido)
TELEGRAM_TOKEN_BOT=tu-token-de-telegram

# Anthropic API Key (requerido para bot interactivo)
ANTHROPIC_API_KEY=tu-api-key-de-anthropic
```

## 2. Get Telegram Bot Token

1. Open Telegram and search for @BotFather
2. Send `/newbot` command
3. Follow instructions to create a bot
4. Copy the token provided

## 3. Get Anthropic API Key (solo para bot interactivo)

1. Go to https://console.anthropic.com/
2. Create a new API key
3. Copy the full key (starts with `sk-ant-`)

> Nota: El sistema de producción (GitHub Actions) no necesita esta key.
> Solo es necesaria para el bot interactivo (`/nuevo_tip`).

## 4. GitHub Actions Secrets

Para que el envío automático funcione en GitHub Actions, configurar estos secrets en el repo:

1. Go to Settings → Secrets and variables → Actions
2. Add `TELEGRAM_TOKEN_BOT` with your bot token
3. Add `OPENAI_API_KEY` (legacy, usado por el workflow)

## 5. Test Configuration

```bash
# Test API keys
Rscript tests/check_keys.R

# Test newsletter generation
Rscript tests/test_txt_newsletter.R
```

## 6. Run the System

### Produccion (GitHub Actions) - Recomendado

El tip se envía automáticamente de lunes a viernes a las 7:00 AM (Argentina).
También se puede ejecutar manualmente desde GitHub Actions → rtip → Run workflow.

### Local (desarrollo)

```bash
# Bot interactivo con /nuevo_tip
Rscript run_bot_interactivo.R

# Envío directo (misma lógica que GitHub Actions)
Rscript run_telegram_bot.R

# Solo generar newsletter
Rscript run_newsletter.R
```

## Important Notes

- The `.Renviron` file contains sensitive information and should NOT be committed to Git
- Keep your API keys secure and never share them publicly
- Email configuration is optional (newsletter generates TXT files)
