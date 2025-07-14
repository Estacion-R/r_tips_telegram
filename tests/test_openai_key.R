# Test OpenAI API key validity
library(httr2)

test_openai_key <- function() {
  api_key <- Sys.getenv("OPENAI_API_KEY")
  
  cat("Testing OpenAI API key...\n")
  cat("Key length:", nchar(api_key), "characters\n")
  cat("Key starts with:", substr(api_key, 1, 5), "\n")
  
  # Test with a simple API call
  tryCatch({
    response <- request("https://api.openai.com/v1/models") %>%
      req_headers(Authorization = paste("Bearer", api_key)) %>%
      req_perform()
    
    cat("✅ API key is valid!\n")
    return(TRUE)
  }, error = function(e) {
    cat("❌ API key is invalid or expired\n")
    cat("Error:", e$message, "\n")
    return(FALSE)
  })
}

# Check key format
api_key <- Sys.getenv("OPENAI_API_KEY")
if(nchar(api_key) < 40) {
  cat("⚠️  WARNING: OpenAI API keys are usually 50+ characters long\n")
  cat("Your key is only", nchar(api_key), "characters\n")
  cat("This might be a placeholder or incomplete key\n\n")
}

if(substr(api_key, 1, 3) != "sk-") {
  cat("⚠️  WARNING: OpenAI API keys should start with 'sk-'\n")
  cat("Your key starts with:", substr(api_key, 1, 5), "\n\n")
}

# Test the key
test_openai_key()

cat("\nIf the key is invalid:\n")
cat("1. Go to https://platform.openai.com/account/api-keys\n")
cat("2. Create a new API key\n")
cat("3. Copy the FULL key (50+ characters, starts with sk-)\n")
cat("4. Update .Renviron file\n")
cat("5. Restart R session\n")