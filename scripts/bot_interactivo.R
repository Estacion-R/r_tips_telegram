#!/usr/bin/env Rscript
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##                      Bot Interactivo de Telegram                         ----
##                    Escucha comandos y genera tips                        ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(telegram.bot)
library(glue)

# Cargar funciones
source("scripts/00-funciones.R")

# Configurar bot
token <- Sys.getenv("TELEGRAM_TOKEN_BOT")

if(nchar(token) == 0) {
  stop("Error: TELEGRAM_TOKEN_BOT no está configurado en .Renviron")
}

# Crear updater
updater <- Updater(token = token)

# ══════════════════════════════════════════════════════════════════════════════
# HANDLERS DE COMANDOS
# ══════════════════════════════════════════════════════════════════════════════

# /start - Mensaje de bienvenida
start <- function(bot, update) {
  bot$sendMessage(
    chat_id = update$message$chat_id,
    text = glue(
      "👋 ¡Hola! Soy el bot de Tips de R de Estación R.\n\n",
      "📋 *Comandos disponibles:*\n",
      "/nuevo_tip - Generar un tip nuevo\n",
      "/ayuda - Ver esta ayuda\n\n",
      "🔄 Usá /nuevo_tip para recibir un tip diferente al de hoy."
    ),
    parse_mode = "Markdown"
  )
}

# /ayuda - Mostrar ayuda
ayuda <- function(bot, update) {
  bot$sendMessage(
    chat_id = update$message$chat_id,
    text = glue(
      "📚 *Ayuda del Bot de Estación R*\n\n",
      "*Comandos:*\n",
      "• /nuevo_tip - Genera y envía un tip de R diferente\n",
      "• /ayuda - Muestra este mensaje\n",
      "• /start - Mensaje de bienvenida\n\n",
      "*¿Cómo funciona?*\n",
      "Cada mañana se envía un tip automáticamente. ",
      "Si no te convence, usá /nuevo_tip para generar otro.\n\n",
      "🌐 https://estacion-r.com"
    ),
    parse_mode = "Markdown"
  )
}

# /nuevo_tip - Generar un tip nuevo
nuevo_tip <- function(bot, update) {
  chat_id <- update$message$chat_id

  # Enviar mensaje de "generando..."
  bot$sendMessage(
    chat_id = chat_id,
    text = "⏳ Generando un nuevo tip de R... Esto puede tomar unos segundos."
  )

  tryCatch({
    # Generar nuevo tip (excluyendo el último publicado)
    resultado <- generar_tip_nuevo(excluir_ultimo = TRUE)

    # Enviar el tip para redes (sin parse_mode para evitar errores con caracteres especiales)
    bot$sendMessage(
      chat_id = chat_id,
      text = glue(
        "🆕 Nuevo Tip Generado ({resultado$tipo_seleccion})\n\n",
        "─────────────────────\n\n",
        "{resultado$contenido$redes}"
      )
    )

    # Preguntar si quiere guardarlo
    bot$sendMessage(
      chat_id = chat_id,
      text = "✅ Tip generado. Si te gusta, podés copiarlo y publicarlo."
    )

  }, error = function(e) {
    bot$sendMessage(
      chat_id = chat_id,
      text = glue("❌ Error generando el tip: {e$message}\n\nIntentá de nuevo en unos minutos.")
    )
  })
}

# ══════════════════════════════════════════════════════════════════════════════
# REGISTRAR HANDLERS
# ══════════════════════════════════════════════════════════════════════════════

updater <- updater + CommandHandler("start", start)
updater <- updater + CommandHandler("ayuda", ayuda)
updater <- updater + CommandHandler("help", ayuda)
updater <- updater + CommandHandler("nuevo_tip", nuevo_tip)
updater <- updater + CommandHandler("otro", nuevo_tip)  # Alias corto

# ══════════════════════════════════════════════════════════════════════════════
# INICIAR BOT
# ══════════════════════════════════════════════════════════════════════════════

cat("══════════════════════════════════════════════════════════════\n")
cat("🤖 Bot de Estación R iniciado\n")
cat("══════════════════════════════════════════════════════════════\n")
cat("\n")
cat("Comandos disponibles:\n")
cat("  /start     - Mensaje de bienvenida\n")
cat("  /nuevo_tip - Generar un tip nuevo\n")
cat("  /otro      - Alias de /nuevo_tip\n")
cat("  /ayuda     - Ver ayuda\n")
cat("\n")
cat("Presioná Ctrl+C para detener el bot\n")
cat("══════════════════════════════════════════════════════════════\n")

# Iniciar polling (escucha continua)
updater$start_polling(verbose = TRUE)
