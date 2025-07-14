# Email alternatives and diagnostics

cat("=== GMAIL AUTHENTICATION ISSUE SOLUTIONS ===\n\n")

cat("The 'Login denied' error usually means:\n")
cat("1. App Password is incorrect or expired\n")
cat("2. 2-Step Verification is not enabled\n")
cat("3. Account has restrictions\n\n")

cat("STEP-BY-STEP GMAIL FIX:\n")
cat("1. Go to https://myaccount.google.com/security\n")
cat("2. Scroll to 'Signing in to Google'\n")
cat("3. Click '2-Step Verification' - MUST be ON\n")
cat("4. Scroll down to 'App passwords'\n")
cat("5. Click 'App passwords'\n")
cat("6. Select 'Mail' from dropdown\n")
cat("7. Generate password - copy the 16-char code (like: 'abcd efgh ijkl mnop')\n")
cat("8. Remove spaces: 'abcdefghijklmnop'\n")
cat("9. Update .Renviron with this password\n\n")

cat("ALTERNATIVE EMAIL PROVIDERS (easier setup):\n\n")

cat("=== OUTLOOK/HOTMAIL SETUP ===\n")
cat("EMAIL_FROM=your-email@outlook.com\n")
cat("EMAIL_USER=your-email@outlook.com\n")
cat("EMAIL_PASSWORD=your-outlook-password\n")
cat("SMTP_HOST=smtp-mail.outlook.com\n")
cat("SMTP_PORT=587\n\n")

cat("=== YAHOO SETUP ===\n")
cat("EMAIL_FROM=your-email@yahoo.com\n")
cat("EMAIL_USER=your-email@yahoo.com\n")
cat("EMAIL_PASSWORD=your-yahoo-app-password\n")
cat("SMTP_HOST=smtp.mail.yahoo.com\n")
cat("SMTP_PORT=587\n\n")

cat("=== SIMPLE FILE OUTPUT ALTERNATIVE ===\n")
cat("If email continues to fail, we can save newsletter to a file:\n")
cat("- Creates HTML file with newsletter content\n")
cat("- You can manually send via your email client\n")
cat("- Always works regardless of SMTP issues\n\n")

cat("Would you like to:\n")
cat("A) Try fixing Gmail setup one more time\n")
cat("B) Switch to Outlook/Yahoo\n") 
cat("C) Use file output instead of email\n")
cat("D) Keep Telegram for both messages\n")