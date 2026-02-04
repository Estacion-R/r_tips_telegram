# r_tips_telegram

Sistema de tips de R para Telegram de Estación R.

## Estructura

```
r_tips_telegram/
├── scripts/
│   ├── 00-funciones.R       # Funciones principales
│   ├── 02-armar_tip.R       # Selección y armado de tips
│   ├── script_bot.R         # Envío automático (diario)
│   └── bot_interactivo.R    # Bot con comandos (/nuevo_tip)
├── data/
│   └── r_tips_historial.rds # Historial de tips publicados
├── output/
│   ├── logs/                # Logs de publicaciones
│   └── newsletters/         # Archivos TXT generados
├── run_telegram_bot.R       # Ejecutar envío diario
├── run_bot_interactivo.R    # Ejecutar bot interactivo
└── run_newsletter.R         # Solo generar newsletter (sin Telegram)
```

## Configuración

Crear archivo `.Renviron` con:

```
TELEGRAM_TOKEN_BOT=tu_token_de_telegram
OPENAI_API_KEY=tu_api_key_de_openai
```

## Uso

### Envío automático (diario)

Ejecuta el tip de la mañana:

```r
source("run_telegram_bot.R")
```

### Bot interactivo (regenerar tips)

Para tener un bot que escuche comandos y regenere tips a demanda:

```r
source("run_bot_interactivo.R")
```

Este bot queda corriendo y escucha los siguientes comandos:

| Comando | Descripción |
|---------|-------------|
| `/start` | Mensaje de bienvenida |
| `/nuevo_tip` | Genera un tip diferente al último |
| `/otro` | Alias de /nuevo_tip |
| `/ayuda` | Ver comandos disponibles |

Para detener el bot: `Ctrl+C`

### Solo newsletter (sin Telegram)

```r
source("run_newsletter.R")
```

## Formato de tips

Los tips se generan con el siguiente formato:

```
[TIP de R - {TIPO} {EMOJI}] - {Titular como pregunta}

{Descripción del recurso}

✔️ Beneficio 1
✔️ Beneficio 2
✔️ Beneficio 3

🔥 Tip: {Consejo destacado}

{Mensaje de engagement}

🌐 {URL del recurso}

#RStats #RStatsES #Rtips #DataScience
```

Tipos de recursos:
- 📦 PAQUETE
- 📚 RECURSO
- 🎓 TUTORIAL
- 📝 ARTÍCULO
- 🛠️ HERRAMIENTA
- 🌍 MAPAS
- 📊 VISUALIZACIÓN

## Fuente de datos

Los tips se leen de Google Sheets:
- Hoja "Produccion": Tips pre-escritos listos para publicar
- Hoja "Desarrollo": Tips en desarrollo

## Notas

- El bot interactivo debe correr en segundo plano para escuchar comandos
- Cada `/nuevo_tip` genera contenido con OpenAI (puede tomar unos segundos)
- El historial de tips publicados se guarda en `data/r_tips_historial.rds`
