# Script simplificado para enviar tips de R via Telegram
# Sin dependencia de OpenAI - los tips vienen pre-escritos de Google Sheets

library(dplyr)
library(telegram.bot)
library(glue)
library(googlesheets4)
library(readr)
library(here)
library(stringr)
source("02-armar_tip.R")


token <- Sys.getenv("TELEGRAM_TOKEN_BOT")
bot <- Bot(token = token)


### SETUP USUARIO TELEGRAM
updates <- bot$getUpdates()

n_users <- length(updates)

if (!file.exists("r_tips_bot_usuarios.rds")) {
  stop("No se encontró r_tips_bot_usuarios.rds. El archivo es necesario para enviar tips.")
}

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



# Función para enviar tip a todos los usuarios
# Continúa aunque falle algún envío individual
enviar_tip <- function(bot) {

  enviados <- 0
  fallidos <- 0

  for (o in 1:nrow(usuarios)) {

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

# Enviar tip
cat("Enviando tip a", nrow(usuarios), "usuarios...\n")
cat("Tip a enviar:\n", tip, "\n\n")
enviar_tip(bot)
cat("\n¡Proceso completado!\n")



  
