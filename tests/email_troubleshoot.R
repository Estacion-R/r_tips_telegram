# Email troubleshooting guide

cat("=== EMAIL CONFIGURATION TROUBLESHOOTING ===\n\n")

cat("Current configuration:\n")
cat("EMAIL_USER:", Sys.getenv("EMAIL_USER"), "\n")
cat("SMTP_HOST:", Sys.getenv("SMTP_HOST"), "\n")
cat("SMTP_PORT:", Sys.getenv("SMTP_PORT"), "\n")
cat("EMAIL_PASSWORD length:", nchar(Sys.getenv("EMAIL_PASSWORD")), "characters\n\n")

cat("GMAIL SETUP STEPS:\n")
cat("1. Go to https://myaccount.google.com/security\n")
cat("2. Enable 2-Step Verification (if not already enabled)\n")
cat("3. Go to 'App passwords' section\n")
cat("4. Generate an app password for 'Mail'\n")
cat("5. Use the 16-character app password (with spaces removed) in EMAIL_PASSWORD\n\n")

cat("COMMON ISSUES:\n")
cat("❌ Using regular Gmail password instead of App Password\n")
cat("❌ 2-Step Verification not enabled\n")
cat("❌ App Password includes spaces (remove them)\n")
cat("❌ Wrong email in EMAIL_USER (should match EMAIL_FROM)\n\n")

cat("ALTERNATIVE EMAIL PROVIDERS:\n")
cat("If Gmail doesn't work, try:\n")
cat("- Outlook: SMTP_HOST=smtp-mail.outlook.com, SMTP_PORT=587\n")
cat("- Yahoo: SMTP_HOST=smtp.mail.yahoo.com, SMTP_PORT=587\n\n")

cat("Once you fix the configuration, run: Rscript test_email_simple.R\n")