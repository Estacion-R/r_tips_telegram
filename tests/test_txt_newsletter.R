# Test TXT newsletter generation
source("scripts/02-armar_tip.R")

# Create newsletter TXT function
crear_newsletter_txt <- function(contenido, asunto) {
  tryCatch({
    library(glue)
    
    # Generate filename with timestamp
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    filename <- glue("newsletter_estacion_r_{timestamp}.txt")
    filepath <- file.path("output", "newsletters", filename)
    
    # Create newsletters directory if it doesn't exist
    if (!dir.exists("output")) {
      dir.create("output")
    }
    if (!dir.exists("output/newsletters")) {
      dir.create("output/newsletters")
    }
    
    # Create formatted TXT content
    complete_txt <- glue('
================================================================================
{asunto}
================================================================================

Generado el: {format(Sys.time(), "%d/%m/%Y %H:%M")}
Fecha: {format(Sys.Date(), "%d de %B de %Y")}

================================================================================
CONTENIDO DEL NEWSLETTER
================================================================================

{contenido}

================================================================================
PIE DE PÁGINA
================================================================================

Newsletter generada automáticamente por el sistema de Estación R
Estación R - Tu punto de encuentro para el análisis de datos en R

Para más información visita nuestro sitio web
Síguenos en redes sociales: #RStats #RStatsES #EstacionR

================================================================================
FIN DEL NEWSLETTER
================================================================================
    ')
    
    # Write to file
    writeLines(complete_txt, filepath)
    
    cat("✅ Newsletter TXT creado exitosamente:", filepath, "\n")
    cat("📁 Archivo guardado en:", normalizePath(filepath), "\n")
    
    return(list(success = TRUE, filepath = filepath))
    
  }, error = function(e) {
    cat("Error creando newsletter TXT:", e$message, "\n")
    return(list(success = FALSE, error = e$message))
  })
}

# Test the system
cat("🧪 Testing TXT newsletter generation...\n\n")

# Create TXT newsletter
asunto <- paste("Newsletter Estación R - TEST -", format(Sys.Date(), "%d/%m/%Y"))
resultado <- crear_newsletter_txt(contenido_generado$newsletter, asunto)

if(resultado$success) {
  cat("🎉 SUCCESS! TXT newsletter created!\n")
  cat("📁 File:", resultado$filepath, "\n")
  
  # Show preview
  if(file.exists(resultado$filepath)) {
    cat("\n📄 First 10 lines of TXT file:\n")
    lines <- readLines(resultado$filepath, n = 10)
    for(i in 1:min(10, length(lines))) {
      cat(paste0("  ", i, ": ", lines[i], "\n"))
    }
  }
  
  cat("\n💡 You can now:\n")
  cat("1. Open the TXT file in any text editor\n")
  cat("2. Copy the content\n")
  cat("3. Paste into your email client\n")
  cat("4. Send to yourself or others\n")
} else {
  cat("❌ Test failed\n")
}