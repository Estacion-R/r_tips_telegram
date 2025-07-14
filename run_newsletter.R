#!/usr/bin/env Rscript
# Main script to generate newsletter content and TXT file

# Load required libraries
library(dplyr)
library(glue)
library(googlesheets4)
library(readr)
library(ellmer)

# Set working directory to script location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Source the content generation script
source("scripts/02-armar_tip.R")

# Load newsletter TXT creation function
source("scripts/script_bot.R")

# Create newsletter TXT file
asunto <- paste("Newsletter Estación R -", format(Sys.Date(), "%d/%m/%Y"))
resultado <- crear_newsletter_txt(contenido_generado$newsletter, asunto)

if(resultado$success) {
  cat("🎉 Newsletter generado exitosamente!\n")
  cat("📄 Archivo TXT:", resultado$filepath, "\n")
  cat("📱 Contenido redes sociales listo\n")
  cat("📧 Contenido newsletter listo\n")
  
  # Print preview
  cat("\n=== PREVIEW REDES SOCIALES ===\n")
  cat(substr(contenido_generado$redes, 1, 200), "...\n")
  
  cat("\n=== PREVIEW NEWSLETTER ===\n")
  cat(substr(contenido_generado$newsletter, 1, 200), "...\n")
  
  cat("\n💡 Archivo TXT creado en:", normalizePath(resultado$filepath), "\n")
} else {
  cat("❌ Error generando newsletter\n")
}