
library(dplyr)
library(telegram.bot)
library(glue)
library(googlesheets4)
library(readr)
source("02-armar_tip.R")


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



# FUNCION DE AVISO PARA HACER FACTURA
enviar_tip <- function(bot) {
  
  for (o in 1:nrow(usuarios)) {
    
    user_send <- usuarios[o,]
    
    bot$sendMessage(chat_id = user_send$id,
                    text = tip)
    
    Sys.sleep(0.5)
    
  } 
  
}

tryCatch(
  expr = {
    enviar_tip(bot)
  },
  error = function(e){ 
    cat("surgió un error pero fijate bien si corrió el tip en Telegram")
  }
)



  
