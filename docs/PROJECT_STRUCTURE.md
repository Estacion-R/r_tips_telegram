# R Tips Telegram Bot - Project Structure

## 📁 Folder Organization

```
r_tips_telegram/
├── 📁 archive/                 # Old/unused files
├── 📁 data/                    # Data files
│   └── r_tips_historial.rds   # Historical tips data
├── 📁 docs/                    # Documentation
│   ├── PROJECT_STRUCTURE.md   # This file
│   ├── README.md              # General documentation
│   └── README_newsletter.md   # Newsletter documentation
├── 📁 output/                  # Generated output files
│   ├── 📁 logs/               # Log files
│   │   └── rtips-tuits.log    # Tips publication log
│   └── 📁 newsletters/        # Generated newsletters
│       └── newsletter_*.txt   # TXT newsletter files
├── 📁 scripts/                 # Main scripts
│   ├── 00-funciones.R         # Core functions
│   ├── 02-armar_tip.R         # Content generation
│   └── script_bot.R           # Bot execution
├── 📁 tests/                   # Test and utility files
│   ├── check_keys.R           # API key validation
│   ├── test_*.R               # Various test scripts
│   └── email_*.R              # Email testing utilities
├── .Renviron                   # Environment variables
├── 01-instalacion_paquetes.R   # Package installation
├── r_tips_bot_usuarios.rds     # Bot users data
├── r_tips_telegram.Rproj       # R project file
├── run_newsletter.R            # Main newsletter runner
└── run_telegram_bot.R          # Main bot runner
```

## 🚀 Main Entry Points

### 1. Newsletter Generation Only
```r
source("run_newsletter.R")
```
- Generates 3 tips content
- Creates TXT newsletter file
- No Telegram sending required

### 2. Complete System with Telegram
```r
source("run_telegram_bot.R")
```
- Generates content
- Sends social media tips via Telegram
- Creates TXT newsletter file
- Requires Telegram bot token

## 📋 Core Scripts

### `scripts/00-funciones.R`
- Core functions for content generation
- URL content fetching
- OpenAI API integration
- Tip selection logic

### `scripts/02-armar_tip.R`
- Main content generation logic
- Google Sheets integration
- Tip selection and formatting
- Updates historical data

### `scripts/script_bot.R`
- Telegram bot integration
- Newsletter TXT file creation
- User management
- Message sending logic

## 🔧 Configuration Files

### `.Renviron`
Required environment variables:
```
OPENAI_API_KEY=sk-your-openai-key
TELEGRAM_TOKEN_BOT=your-telegram-bot-token
```

### `01-instalacion_paquetes.R`
Package installation script for dependencies

## 📊 Data Files

### `data/r_tips_historial.rds`
- Historical tips data
- Usage frequency tracking
- Updated after each run

### `r_tips_bot_usuarios.rds`
- Telegram bot users
- Chat IDs and user info

## 📈 Output Files

### `output/newsletters/newsletter_*.txt`
- Generated newsletter files
- Timestamped filenames
- Ready for email copy/paste

### `output/logs/rtips-tuits.log`
- Publication history
- URL tracking
- Timestamp records

## 🧪 Testing & Utilities

### `tests/` folder contains:
- API key validation scripts
- Email testing utilities
- System testing scripts
- Troubleshooting tools

## 📚 Documentation

### `docs/` folder contains:
- Project structure documentation
- Usage instructions
- Newsletter system documentation

## 🎯 Workflow

1. **Setup**: Configure API keys in `.Renviron`
2. **Content Generation**: Run `run_newsletter.R`
3. **Newsletter Distribution**: Use generated TXT file
4. **Optional**: Run `run_telegram_bot.R` for Telegram integration
5. **Review**: Check `output/` folder for generated files

## 🔄 Maintenance

- Historical data automatically updated
- Log files track all publications
- Archive folder for old unused files
- Organized test scripts for troubleshooting