# Test complete system without Telegram
source("02-armar_tip.R")

# Load required libraries
library(blastula)
library(glue)

# Create newsletter HTML function (copied from script_bot.R)
crear_newsletter_html <- function(contenido, asunto) {
  tryCatch({
    # Create email with markdown support
    email <- compose_email(
      body = md(contenido),
      footer = md("**Estación R** - Tu punto de encuentro para el análisis de datos en R")
    )
    
    # Generate filename with timestamp
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    filename <- glue("newsletter_estacion_r_{timestamp}.html")
    filepath <- file.path("newsletters", filename)
    
    # Create newsletters directory if it doesn't exist
    if (!dir.exists("newsletters")) {
      dir.create("newsletters")
    }
    
    # Extract HTML content from the email object
    html_content <- as.character(email)
    
    # Add custom styling and subject
    complete_html <- glue('
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{asunto}</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            line-height: 1.6;
        }}
        .header {{
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
        }}
        .content {{
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        .footer {{
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            text-align: center;
            color: #666;
        }}
        a {{
            color: #0066cc;
            text-decoration: none;
        }}
        a:hover {{
            text-decoration: underline;
        }}
    </style>
</head>
<body>
    <div class="header">
        <h1>{asunto}</h1>
        <p>Generado el: {format(Sys.time(), "%d/%m/%Y %H:%M")}</p>
    </div>
    <div class="content">
        {html_content}
    </div>
    <div class="footer">
        <p>Newsletter generada automáticamente por el sistema de Estación R</p>
        <p>Fecha: {format(Sys.Date(), "%d de %B de %Y")}</p>
    </div>
</body>
</html>
    ')
    
    # Write to file
    writeLines(complete_html, filepath)
    
    cat("✅ Newsletter HTML creado exitosamente:", filepath, "\n")
    cat("📁 Archivo guardado en:", normalizePath(filepath), "\n")
    
    return(list(success = TRUE, filepath = filepath))
    
  }, error = function(e) {
    cat("Error creando newsletter HTML:", e$message, "\n")
    return(list(success = FALSE, error = e$message))
  })
}

# Test the complete system
cat("🚀 Testing complete system...\n\n")

cat("📝 Content generated:\n")
cat("Social Media Tips:\n")
cat(contenido_generado$redes)
cat("\n\n")

cat("📧 Newsletter Content:\n")
cat(substr(contenido_generado$newsletter, 1, 200), "...\n\n")

# Create HTML newsletter
asunto <- paste("Newsletter Estación R -", format(Sys.Date(), "%d/%m/%Y"))
resultado <- crear_newsletter_html(contenido_generado$newsletter, asunto)

if(resultado$success) {
  cat("🎉 SUCCESS! Complete system working!\n")
  cat("📁 HTML Newsletter:", resultado$filepath, "\n")
  cat("📱 Social Media content ready for Telegram\n")
  cat("📧 Newsletter content ready for email\n\n")
  
  cat("💡 Next steps:\n")
  cat("1. Set up Telegram bot token (optional)\n")
  cat("2. Open HTML file in browser\n")
  cat("3. Copy content and paste into email\n")
  cat("4. Send to yourself or others\n")
} else {
  cat("❌ Error:", resultado$error, "\n")
}