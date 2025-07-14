# Test the HTML newsletter creation with sample content
library(blastula)
library(glue)

# FUNCION PARA CREAR ARCHIVO HTML DE NEWSLETTER
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

# Sample newsletter content
sample_content <- "**¡Descubre los Recursos de la Semana en R!**

¡Hola a toda la comunidad de análisis de datos en R! Esta semana, hemos seleccionado tres recursos que te ayudarán a mejorar tus habilidades y proyectos en visualización y procesamiento de datos. ¡No te los pierdas!

---

**GitHub rOpenSpain/MicroDatosEs: R package providing utilities for reading and processing microdata from Spanish official statistics**

GitHub rOpenSpain/MicroDatosEs es un paquete de R que brinda utilidades para leer y procesar microdatos de las estadísticas oficiales de España. Con este paquete, puedes trabajar con datos microeconómicos de una manera eficiente y efectiva. Este recurso es ideal para analistas de datos que necesitan acceder y manipular datos estadísticos de España en sus proyectos.

🌐 https://github.com/rOpenSpain/MicroDatosEs

---

**gganimate 1.0.10.9000: A Grammar of Animated Graphics**

gganimate es una extensión de la gramática de gráficos implementada por ggplot2 que te permite incluir animaciones en tus visualizaciones. Gracias a nuevas clases de gramática, como transition_*(), view_*(), shadow_*(), enter_*() / exit_*() y ease_aes(), puedes personalizar tus gráficos para mostrar cambios a lo largo del tiempo. Este recurso es perfecto para crear visualizaciones dinámicas y atractivas que resalten la evolución de los datos.

🌐 https://gganimate.com/

---

**ColorBrewer: Color Advice for Maps**

ColorBrewer es una herramienta que ofrece consejos sobre esquemas de color para mapas, garantizando la legibilidad y la accesibilidad de tus visualizaciones. Puedes elegir entre esquemas seguros para personas con problemas de visión, impresión amigable y copiado en blanco y negro. Esta herramienta es imprescindible para cartógrafos y diseñadores que buscan seleccionar colores efectivos para representar datos geoespaciales.

🌐 https://colorbrewer2.org/

---

¡Aprovecha al máximo estos recursos para potenciar tus habilidades en análisis de datos en R! ¿Qué esperas para explorar estas herramientas y llevar tus visualizaciones al siguiente nivel?

¡Hasta la próxima semana con más novedades en R!

*Estación R - Tu punto de encuentro para el análisis de datos en R*

---
¿Conocías o usaste alguno de estos paquetes? ¡Compartí tu experiencia con la comunidad! #RStats #RStatsES #EstacionR #VisualizaciónDatos"

# Test the HTML newsletter function
asunto <- paste("Newsletter Estación R -", format(Sys.Date(), "%d/%m/%Y"))

cat("Testing HTML newsletter creation with sample content...\n")
resultado <- crear_newsletter_html(sample_content, asunto)

if(resultado$success) {
  cat("✅ Test successful!\n")
  cat("📁 File created:", resultado$filepath, "\n")
  cat("📁 Full path:", normalizePath(resultado$filepath), "\n")
  
  # Check if file exists and get size
  if(file.exists(resultado$filepath)) {
    file_size <- file.info(resultado$filepath)$size
    cat("📏 File size:", file_size, "bytes\n")
    
    cat("\n💡 To view the newsletter:\n")
    cat("1. Open the file in your browser\n")
    cat("2. Copy the content and paste it into your email client\n")
    cat("3. Send to yourself or others\n")
    
    # Show first few lines
    cat("\n📄 First lines of HTML file:\n")
    lines <- readLines(resultado$filepath, n = 5)
    for(i in 1:min(5, length(lines))) {
      cat(paste0("  ", i, ": ", lines[i], "\n"))
    }
  }
} else {
  cat("❌ Test failed:", resultado$error, "\n")
}