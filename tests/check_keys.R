# Check if API keys are properly loaded
cat("Checking environment variables...\n\n")

# Check OpenAI API Key
openai_key <- Sys.getenv("OPENAI_API_KEY")
if(nchar(openai_key) > 0) {
  cat("✅ OPENAI_API_KEY: Set (", nchar(openai_key), " characters)\n")
} else {
  cat("❌ OPENAI_API_KEY: Not set\n")
}

# Check Telegram Bot Token
telegram_token <- Sys.getenv("TELEGRAM_TOKEN_BOT")
if(nchar(telegram_token) > 0) {
  cat("✅ TELEGRAM_TOKEN_BOT: Set (", nchar(telegram_token), " characters)\n")
} else {
  cat("❌ TELEGRAM_TOKEN_BOT: Not set\n")
}

# Check Newsletter Email
newsletter_email <- Sys.getenv("NEWSLETTER_EMAIL")
if(nchar(newsletter_email) > 0) {
  cat("✅ NEWSLETTER_EMAIL: Set (", newsletter_email, ")\n")
} else {
  cat("❌ NEWSLETTER_EMAIL: Not set\n")
}

cat("\nIf any keys are missing, update the .Renviron file and restart R.\n")
