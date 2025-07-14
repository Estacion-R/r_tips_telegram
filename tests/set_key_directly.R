# Alternative: Set OpenAI API key directly in R session
# Replace YOUR_ACTUAL_KEY with your real OpenAI API key

# Sys.setenv(OPENAI_API_KEY = "sk-your-actual-long-api-key-here")

cat("To set the API key directly in R:\n")
cat("1. Run: Sys.setenv(OPENAI_API_KEY = 'sk-your-actual-key-here')\n")
cat("2. Replace 'sk-your-actual-key-here' with your real key\n")
cat("3. Then run: source('script_bot.R')\n\n")

cat("Example:\n")
cat("Sys.setenv(OPENAI_API_KEY = 'sk-proj-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456')\n\n")

cat("This is temporary - for permanent solution, update .Renviron file\n")