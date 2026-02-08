# R Tips Telegram Bot - Project Structure

## Dos sistemas paralelos

Este proyecto tiene dos modos de operacion:

### 1. Produccion (root) - GitHub Actions
Tips pre-escritos desde Google Sheets, sin IA. Se ejecuta automaticamente.

```
script_bot.R → 02-armar_tip.R → 00-funciones.R
```
- Lee tips de la hoja "Produccion"
- Selecciona tip segun prioridad (nuevo > inedito > menos publicado)
- Envia via Telegram
- GitHub Actions persiste el historial automaticamente

### 2. Desarrollo (scripts/) - Local
Genera contenido con Claude AI (ellmer). Se ejecuta manualmente.

```
run_bot_interactivo.R → scripts/bot_interactivo.R → scripts/00-funciones.R
run_telegram_bot.R    → scripts/script_bot.R      → scripts/02-armar_tip.R
```
- Lee tips de la hoja "Desarrollo"
- Genera contenido con Claude API (ANTHROPIC_API_KEY)
- Bot interactivo con comandos /nuevo_tip, /otro, /ayuda

## Estructura de archivos

```
r_tips_telegram/
├── .github/workflows/
│   └── calendario.yaml         # GitHub Actions (L-V 7:00 AM ARG)
│
├── # --- Sistema produccion (root) ---
├── script_bot.R                # Entry point: selecciona y envia tip
├── 02-armar_tip.R              # Logica de seleccion (3 prioridades)
├── 00-funciones.R              # Funciones helper (emojis, formato)
├── 01-instalacion_paquetes.R   # Instalacion de dependencias
│
├── # --- Sistema desarrollo (scripts/) ---
├── scripts/
│   ├── bot_interactivo.R       # Bot con comandos /nuevo_tip
│   ├── script_bot.R            # Envio con newsletter
│   ├── 02-armar_tip.R          # Seleccion + generacion IA
│   └── 00-funciones.R          # Funciones con Claude API
├── run_bot_interactivo.R       # Runner: bot interactivo
├── run_telegram_bot.R          # Runner: envio directo
├── run_newsletter.R            # Runner: solo newsletter
│
├── # --- Datos ---
├── data/
│   ├── r_tips_historial.rds    # Historial de tips publicados
│   └── rtips-tuits.log         # Log de publicaciones
├── r_tips_bot_usuarios.rds     # Usuarios del bot
│
├── # --- Otros ---
├── archive/                    # Codigo viejo archivado
├── tests/                      # Scripts de test
├── docs/                       # Documentacion
├── .Renviron                   # Variables de entorno (NO en git)
└── .Renviron.template          # Template de variables
```

## Variables de entorno

| Variable | Produccion (GH Actions) | Desarrollo (local) |
|----------|------------------------|-------------------|
| TELEGRAM_TOKEN_BOT | Requerido (secret) | Requerido (.Renviron) |
| OPENAI_API_KEY | Secret legacy | No usado |
| ANTHROPIC_API_KEY | No usado | Requerido para bot interactivo |

## Flujo de datos

1. Tips se escriben en Google Sheets (hoja "Produccion")
2. GitHub Actions ejecuta `script_bot.R` (L-V 7:00 AM)
3. Se selecciona un tip segun prioridad:
   - Prioridad 1: Ultimo tip de la sheet (si es nuevo)
   - Prioridad 2: Cualquier tip inedito al azar
   - Prioridad 3: Tip menos publicado (repeticion)
4. Se envia a todos los usuarios via Telegram
5. Se actualiza `data/r_tips_historial.rds` y se pushea al repo
