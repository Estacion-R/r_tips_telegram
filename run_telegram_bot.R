#!/usr/bin/env Rscript
# Main script to run the complete Telegram bot system

# Load required libraries
library(dplyr)
library(telegram.bot)
library(glue)
library(googlesheets4)
library(readr)
library(ellmer)

# Set working directory to script location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Check if Telegram token is set
if(nchar(Sys.getenv("TELEGRAM_TOKEN_BOT")) == 0) {
  cat("❌ Error: TELEGRAM_TOKEN_BOT no está configurado\n")
  cat("Configure su token de Telegram en el archivo .Renviron\n")
  cat("Ejecute run_newsletter.R para generar solo el archivo TXT\n")
  quit(status = 1)
}

# Run the complete system
tryCatch({
  source("scripts/script_bot.R")
  cat("✅ Sistema completo ejecutado exitosamente\n")
}, error = function(e) {
  cat("❌ Error ejecutando el sistema:", e$message, "\n")
  cat("Verifique sus credenciales en .Renviron\n")
})
