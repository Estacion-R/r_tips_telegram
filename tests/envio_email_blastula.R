# Alternative email function using blastula package
# More modern and easier to configure

enviar_email_blastula <- function(destinatario, asunto, cuerpo) {
  tryCatch({
    library(blastula)
    
    # Create email
    email <- compose_email(
      body = md(cuerpo),
      footer = md("**Estación R** - Tu punto de encuentro para el análisis de datos en R")
    )
    
    # Configure SMTP credentials
    smtp_send(
      email,
      to = destinatario,
      from = Sys.getenv("EMAIL_FROM"),
      subject = asunto,
      credentials = creds_envvar(
        user = Sys.getenv("EMAIL_USER"),
        pass_envvar = "EMAIL_PASSWORD",
        host = Sys.getenv("SMTP_HOST"),
        port = as.numeric(Sys.getenv("SMTP_PORT")),
        use_ssl = TRUE
      )
    )
    
    cat("Email enviado exitosamente a:", destinatario, "\n")
    return(TRUE)
  }, error = function(e) {
    cat("Error enviando email:", e$message, "\n")
    return(FALSE)
  })
}

# To use this version, replace the enviar_email call in script_bot.R with:
# enviar_email_blastula(email_destinatario, asunto, contenido_generado$newsletter)