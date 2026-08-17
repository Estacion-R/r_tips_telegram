# Script simplificado para enviar tips de R via Telegram
# Sin dependencia de OpenAI - los tips vienen pre-escritos de Google Sheets

library(dplyr)
library(telegram.bot)
library(glue)
library(googlesheets4)
library(readr)
library(here)
library(stringr)
library(curl)
source("R/02-armar_tip.R")


token <- Sys.getenv("TELEGRAM_TOKEN_BOT")
bot <- Bot(token = token)


### SETUP USUARIO TELEGRAM
updates <- bot$getUpdates()

n_users <- length(updates)

if (!file.exists("data/r_tips_bot_usuarios.rds")) {
  stop("No se encontró data/r_tips_bot_usuarios.rds. El archivo es necesario para enviar tips.")
}

if (n_users == 0) {

  usuarios <- readRDS("data/r_tips_bot_usuarios.rds")

} else {
  
  users <- data.frame()
  
  for (i in 1:n_users) {
    users <- rbind(users,
                   data.frame(id = updates[[i]]$message$chat$id,
                              user = updates[[i]]$message$chat$first_name))
  }
  
  usuarios <- readRDS("data/r_tips_bot_usuarios.rds")
  
  usuarios <- rbind(usuarios, users) %>% distinct()
  
  saveRDS(usuarios, "data/r_tips_bot_usuarios.rds")
  
}

updates <- bot$clean_updates()


# Función para enviar tip a todos los usuarios
# Continúa aunque falle algún envío individual
enviar_tip <- function(bot, tip) {

  enviados <- 0
  fallidos <- 0

  for (o in seq_len(nrow(usuarios))) {

    user_send <- usuarios[o,]

    tryCatch({
      bot$sendMessage(chat_id = user_send$id, text = tip)
      cat("✓ Enviado a:", user_send$user, "\n")
      enviados <- enviados + 1
    }, error = function(e) {
      cat("✗ Falló envío a:", user_send$user, "(ID:", user_send$id, ")\n")
      cat("  Error:", conditionMessage(e), "\n")
      fallidos <<- fallidos + 1
    })

    Sys.sleep(0.1)
  }

  cat("\nResumen: ", enviados, "enviados,", fallidos, "fallidos\n")

  # Solo fallar si NO se envió a nadie
  if (enviados == 0) {
    stop("No se pudo enviar a ningún usuario")
  }
}

cat("Tip generado:\n", tip, "\n\n")

if (nrow(usuarios) == 0) {
  cat("Sin suscriptores activos. Tip disponible en el log.\n")
} else {
  cat("Enviando tip a", nrow(usuarios), "usuarios...\n")
  enviar_tip(bot, tip)
}

# Persistir historial solo después de que el tip fue procesado correctamente
readr::write_rds(base_hist_nueva, "data/r_tips_historial.rds")

cat("\n¡Proceso completado!\n")



  
