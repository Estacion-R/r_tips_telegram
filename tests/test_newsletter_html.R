# Test the HTML newsletter creation
source("02-armar_tip.R")
source("script_bot.R")

# Test the HTML newsletter function
asunto <- paste("Newsletter Estación R -", format(Sys.Date(), "%d/%m/%Y"))

cat("Testing HTML newsletter creation...\n")
resultado <- crear_newsletter_html(contenido_generado$newsletter, asunto)

if(resultado$success) {
  cat("✅ Test successful!\n")
  cat("📁 File created:", resultado$filepath, "\n")
  cat("📁 Full path:", normalizePath(resultado$filepath), "\n")
  
  # Check if file exists and get size
  if(file.exists(resultado$filepath)) {
    file_size <- file.info(resultado$filepath)$size
    cat("📏 File size:", file_size, "bytes\n")
    
    # Show first few lines
    cat("\n📄 First lines of HTML file:\n")
    lines <- readLines(resultado$filepath, n = 10)
    for(i in 1:min(10, length(lines))) {
      cat(paste0("  ", i, ": ", lines[i], "\n"))
    }
  }
} else {
  cat("❌ Test failed:", resultado$error, "\n")
}