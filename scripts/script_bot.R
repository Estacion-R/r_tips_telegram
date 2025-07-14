
library(dplyr)
library(telegram.bot)
library(glue)
library(googlesheets4)
library(readr)
library(ellmer)
source("scripts/02-armar_tip.R")

# Asegurar que contenido_generado esté disponible globalmente
if(!exists("contenido_generado")) {
  stop("Error: contenido_generado no fue generado correctamente")
}


token <- Sys.getenv("TELEGRAM_TOKEN_BOT")
bot <- Bot(token = token)


### SETUP USUARIO TELEGRAM
updates <- bot$getUpdates()

n_users <- length(updates)


if (n_users == 0) {
  
  usuarios <- readRDS("r_tips_bot_usuarios.rds")
  
} else {
  
  users <- data.frame()
  
  for (i in 1:n_users) {
    users <- rbind(users,
                   data.frame(id = updates[[i]]$message$chat$id,
                              user = updates[[i]]$message$chat$first_name))
  }
  
  usuarios <- readRDS("r_tips_bot_usuarios.rds")
  
  usuarios <- rbind(usuarios, users) %>% distinct()
  
  saveRDS(usuarios, "r_tips_bot_usuarios.rds")
  
}

updates <- bot$clean_updates()

hoy <- Sys.Date()



# FUNCION PARA CREAR ARCHIVO TXT DE NEWSLETTER
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

# FUNCION PARA ENVIAR CONTENIDO A TELEGRAM Y EMAIL
enviar_contenido <- function(bot) {
  
  cat("Verificando usuarios...\n")
  if(nrow(usuarios) == 0) {
    cat("No hay usuarios registrados.\n")
    return()
  }
  
  cat("Enviando mensaje de redes sociales...\n")
  
  # Enviar mensaje para redes sociales
  tryCatch({
    for (o in 1:nrow(usuarios)) {
      
      user_send <- usuarios[o,]
      cat("Enviando a usuario:", user_send$id, "\n")
      
      # Verificar longitud del mensaje
      if(nchar(contenido_generado$redes) > 4000) {
        cat("Mensaje de redes demasiado largo:", nchar(contenido_generado$redes), "caracteres\n")
        next
      }
      
      bot$sendMessage(chat_id = user_send$id,
                      text = contenido_generado$redes)
      
      Sys.sleep(0.1)
      
    } 
    cat("Mensaje de redes sociales enviado exitosamente.\n")
  }, error = function(e) {
    cat("Error en mensaje de redes:", e$message, "\n")
  })
  
  cat("Esperando antes del newsletter...\n")
  Sys.sleep(2)  # Pausa más larga entre mensajes
  
  # Crear newsletter TXT
  cat("Creando newsletter TXT...\n")
  asunto <- paste("Newsletter Estación R -", format(Sys.Date(), "%d/%m/%Y"))
  resultado_txt <- crear_newsletter_txt(contenido_generado$newsletter, asunto)
  
  if(resultado_txt$success) {
    cat("✅ Newsletter TXT creado exitosamente!\n")
    cat("📁 Archivo:", resultado_txt$filepath, "\n")
    cat("💡 Puedes abrir este archivo y copiarlo a tu email\n")
    
    # También enviar por Telegram como respaldo
    cat("Enviando versión texto por Telegram como respaldo...\n")
    tryCatch({
      for (o in 1:nrow(usuarios)) {
        
        user_send <- usuarios[o,]
        
        mensaje_newsletter <- glue("📧 VERSIÓN NEWSLETTER:\n\n{contenido_generado$newsletter}\n\n📄 Newsletter TXT generado: {resultado_txt$filepath}")
        
        # Verificar longitud del mensaje
        if(nchar(mensaje_newsletter) > 4000) {
          cat("Mensaje de newsletter demasiado largo:", nchar(mensaje_newsletter), "caracteres. Recortando...\n")
          mensaje_newsletter <- paste0(substr(mensaje_newsletter, 1, 3950), "...")
        }
        
        bot$sendMessage(chat_id = user_send$id,
                        text = mensaje_newsletter)
        
        Sys.sleep(0.1)
        
      }
      cat("Mensaje de newsletter enviado exitosamente por Telegram.\n")
    }, error = function(e) {
      cat("Error en mensaje de newsletter:", e$message, "\n")
    })
    
  } else {
    cat("❌ Error creando newsletter TXT, enviando solo por Telegram\n")
    # Fallback: enviar solo por Telegram
    tryCatch({
      for (o in 1:nrow(usuarios)) {
        
        user_send <- usuarios[o,]
        
        mensaje_newsletter <- glue("📧 VERSIÓN NEWSLETTER:\n\n{contenido_generado$newsletter}")
        
        # Verificar longitud del mensaje
        if(nchar(mensaje_newsletter) > 4000) {
          cat("Mensaje de newsletter demasiado largo:", nchar(mensaje_newsletter), "caracteres. Recortando...\n")
          mensaje_newsletter <- paste0(substr(mensaje_newsletter, 1, 3950), "...")
        }
        
        bot$sendMessage(chat_id = user_send$id,
                        text = mensaje_newsletter)
        
        Sys.sleep(0.1)
        
      }
      cat("Mensaje de newsletter enviado exitosamente por Telegram.\n")
    }, error = function(e) {
      cat("Error en mensaje de newsletter:", e$message, "\n")
    })
  }
  
  cat("Proceso de envío completado.\n")
  
}

# Función de compatibilidad hacia atrás
enviar_tip <- function(bot) {
  enviar_contenido(bot)
}

tryCatch(
  expr = {
    enviar_contenido(bot)
  },
  error = function(e){ 
    cat("surgió un error:", e$message, "\n")
    cat("pero fijate bien si corrió el tip en Telegram\n")
  }
)



  
