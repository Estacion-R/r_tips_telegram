#!/usr/bin/env Rscript
# Script para ejecutar el bot interactivo de Telegram
# Este bot escucha comandos como /nuevo_tip para generar tips a demanda

# Establecer directorio de trabajo
script_dir <- dirname(sys.frame(1)$ofile)
if(!is.null(script_dir) && nchar(script_dir) > 0) {
  setwd(script_dir)
} else {
  # Fallback: buscar por el nombre del proyecto
  if(file.exists(".Renviron")) {
    # Ya estamos en el directorio correcto
  } else if(file.exists("r_tips_telegram/.Renviron")) {
    setwd("r_tips_telegram")
  }
}

# Cargar .Renviron si existe
if(file.exists(".Renviron")) {
  readRenviron(".Renviron")
  cat("✓ Variables de entorno cargadas desde .Renviron\n")
}

# Verificar token
if(nchar(Sys.getenv("TELEGRAM_TOKEN_BOT")) == 0) {
  cat("❌ Error: TELEGRAM_TOKEN_BOT no está configurado\n")
  cat("Agregá tu token en el archivo .Renviron\n")
  quit(status = 1)
}

# Verificar API key de Anthropic (Claude)
if(nchar(Sys.getenv("ANTHROPIC_API_KEY")) == 0) {
  cat("❌ Error: ANTHROPIC_API_KEY no está configurado\n")
  cat("Agregá tu API key de Anthropic en el archivo .Renviron\n")
  quit(status = 1)
}

cat("\n")
cat("🚀 Iniciando bot interactivo de Estación R...\n")
cat("\n")

# Ejecutar bot
source("scripts/bot_interactivo.R")
