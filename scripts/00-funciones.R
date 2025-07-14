##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##                Función para armar una base de tuits de cero              ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
token_openai <- Sys.getenv("OPENAI_API_KEY")

crear_base_historica <- function(){
  
  # Link a la hoja de cálculo
  url <- "https://docs.google.com/spreadsheets/d/1OKGyVgAy1YhKfaGP_p0rwXWdVnQfovFRsgzo5qRQ3eo/edit#gid=0"
  
  # Habilito acceso público
  googlesheets4::gs4_deauth()
  
  # Leo hoja de cálculo
  base_r_tips <- googlesheets4::read_sheet(url, 
                                           sheet = "Desarrollo")
  
  ### Las que se repitieron muchas veces (ahora basado en web)
  tip1 <- base_r_tips |>
    dplyr::filter(
      stringr::str_detect(
        web,
        "clean|numeric_to|Gente Sociable|pointblank|ARTofR|madre|read_sheet|Quarto|coalesce|of Us|Metropolitana"))
  
  base_r_tips <- base_r_tips |>
    dplyr::bind_rows(tip1)
  
  conteo_tuits <- base_r_tips |> 
    dplyr::group_by(web) |> 
    dplyr::summarise(cant_tuits = dplyr::n()) |> 
    dplyr::ungroup()
  
  base_r_tips <- base_r_tips |> 
    dplyr::left_join(conteo_tuits, by = "web")
  
  if(file.exists("data/r_tips_historial.rds")){
    
    file.remove("data/r_tips_historial.rds")
    
    saveRDS(base_r_tips, "data/r_tips_historial.rds")
    
  } else {
    
    saveRDS(base_r_tips, "data/r_tips_historial.rds")
  }
}

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##                  Función para Seleccionar un tuit al azar                ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

seleccionar_tuit <- function(base){
  ### Saco al azar uno de esos tuits
  base_tuit <- base |> 
    dplyr::slice_min(order_by = cant_tuits, n = 2) |> 
    dplyr::select(-cant_tuits) |> 
    dplyr::sample_n(1)
  
  return(base_tuit)
}

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##                  Función para Seleccionar 3 tips                        ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

seleccionar_3_tips <- function(r_tips, base_hist) {
  ### TUITS INEDITOS
  tip_inedito <- r_tips |> 
    dplyr::anti_join(base_hist, by = "web")
  
  tips_seleccionados <- data.frame()
  
  ### ESTRATEGIA GRADUAL
  if(nrow(tip_inedito) >= 3){
    # Caso 1: Hay 3+ inéditos, seleccionar 3 inéditos
    tips_seleccionados <- tip_inedito |> 
      dplyr::sample_n(3)
    
  } else if(nrow(tip_inedito) > 0) {
    # Caso 2: Hay 1-2 inéditos, completar con menos publicados
    tips_seleccionados <- tip_inedito
    
    # Completar con los menos publicados (excluyendo los ya seleccionados)
    tips_restantes <- 3 - nrow(tip_inedito)
    
    tips_menos_publicados <- base_hist |> 
      dplyr::anti_join(tips_seleccionados, by = "web") |> 
      dplyr::slice_min(order_by = cant_tuits, n = tips_restantes * 2) |> 
      dplyr::select(-cant_tuits) |> 
      dplyr::sample_n(tips_restantes)
    
    tips_seleccionados <- tips_seleccionados |> 
      dplyr::bind_rows(tips_menos_publicados)
    
  } else {
    # Caso 3: No hay inéditos, seleccionar 3 menos publicados
    tips_seleccionados <- base_hist |> 
      dplyr::slice_min(order_by = cant_tuits, n = 6) |> 
      dplyr::select(-cant_tuits) |> 
      dplyr::sample_n(3)
  }
  
  return(tips_seleccionados)
}



##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##                    Función para obtener contenido de URLs               ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

obtener_contenido_url <- function(url) {
  tryCatch({
    # Usar httr para obtener el contenido
    response <- httr::GET(url, httr::timeout(30))
    
    if (httr::status_code(response) == 200) {
      # Obtener el contenido HTML
      contenido_html <- httr::content(response, as = "text", encoding = "UTF-8")
      
      # Extraer texto del HTML (básico)
      # Remover tags HTML básicos
      texto <- gsub("<script[^>]*>.*?</script>", "", contenido_html, ignore.case = TRUE)
      texto <- gsub("<style[^>]*>.*?</style>", "", texto, ignore.case = TRUE)
      texto <- gsub("<[^>]+>", " ", texto)
      texto <- gsub("\\s+", " ", texto)
      texto <- trimws(texto)
      
      # Limitar a los primeros 3000 caracteres para evitar prompts muy largos
      if (nchar(texto) > 3000) {
        texto <- substr(texto, 1, 3000)
        texto <- paste0(texto, "...")
      }
      
      return(list(
        exito = TRUE,
        contenido = texto,
        url = url
      ))
    } else {
      return(list(
        exito = FALSE,
        error = paste("Error HTTP:", httr::status_code(response)),
        url = url
      ))
    }
  }, error = function(e) {
    return(list(
      exito = FALSE,
      error = paste("Error al acceder a URL:", e$message),
      url = url
    ))
  })
}

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##                    Función para armar el tuit a publicar                 ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Armado de tuit
library(ellmer)
library(glue)
library(httr)

armar_contenido <- function(base, model = "gpt-3.5-turbo") {
  # Detectar si es un solo tip o múltiples tips
  if(nrow(base) == 1) {
    return(armar_contenido_simple(base, model))
  } else {
    return(armar_contenido_multiple(base, model))
  }
}

# Función de compatibilidad hacia atrás
armar_tuit <- function(base, model = "gpt-3.5-turbo") {
  contenido <- armar_contenido(base, model)
  return(contenido$redes)
}

# Función para un solo tip - genera ambos formatos
armar_contenido_simple <- function(base, model = "gpt-3.5-turbo") {
  web <- base$web
  
  # Obtener contenido real de la URL
  contenido_url <- obtener_contenido_url(web)
  
  if (!contenido_url$exito) {
    stop(paste("Error al obtener contenido de", web, ":", contenido_url$error))
  }
  
  # PROMPT PARA REDES SOCIALES CON CONTENIDO REAL
  prompt_redes <- glue(
    "Eres el redactor de contenido de 'Estación R'. Te proporciono el contenido REAL de esta URL: {web}\n\n",
    
    "CONTENIDO REAL DE LA PÁGINA:\n",
    "---\n{contenido_url$contenido}\n---\n\n",
    
    "INSTRUCCIONES:\n",
    "- Analiza ÚNICAMENTE el contenido proporcionado arriba\n",
    "- Identifica el TEMA al que pertenece: visualización, procesamiento, bibliografía, notas, referentes, experiencias, etc.\n",
    "- Identifica el nombre EXACTO del paquete/herramienta según aparece en el contenido\n",
    "- Describe SOLO las funciones/características mencionadas en el texto\n\n",
    
    "FORMATO PARA REDES SOCIALES:\n",
    "- Estructura: [TEMA] Nombre exacto según el contenido\n",
    "- Descripción basada 100% en el contenido real\n",
    "- 2-3 características verificadas del texto\n",
    "- Tono argentino con voseo: 'les compartimos desde Estación R'\n",
    "- Incluye emojis relevantes: 💡 🎓 📊 🛠️ 📈 ⚡\n",
    "- Al final: mensaje de engagement pidiendo experiencias de la audiencia\n",
    "- Hashtags: Siempre incluir #RStats #RStatsES #EstacionR #Rtips + otros relevantes según popularidad\n",
    "- 800-1000 caracteres total\n\n",
    
    "IMPORTANTE: Solo usa información literal del contenido. NO inventes conexiones temáticas."
  )
  
  # PROMPT PARA NEWSLETTER CON CONTENIDO REAL
  prompt_newsletter <- glue(
    "Basándote en el MISMO contenido real, crea una versión para newsletter de Mailchimp:\n\n",
    
    "CONTENIDO REAL DE LA PÁGINA:\n",
    "---\n{contenido_url$contenido}\n---\n\n",
    
    "FORMATO NEWSLETTER:\n",
    "1. Título atractivo para email\n",
    "2. Introducción profesional sobre el recurso\n",
    "3. Desarrollo detallado basado únicamente en el contenido proporcionado\n",
    "4. Casos de uso específicos mencionados en el texto\n",
    "5. Beneficios concretos extraídos del contenido\n",
    "6. Call-to-action para explorar el recurso\n\n",
    
    "CARACTERÍSTICAS:\n",
    "- Extensión: 1500-2000 caracteres\n",
    "- Tono profesional pero cercano\n",
    "- Estructura clara con párrafos separados\n",
    "- Solo información literal del contenido proporcionado\n",
    "- Enfoque educativo profundo\n\n",
    
    "IMPORTANTE: Usar ÚNICAMENTE información que aparece en el contenido proporcionado."
  )
  
  chat <- ellmer::chat_openai(model = model, api_key = token_openai)
  
  # Generar contenido para redes
  contenido_redes <- chat$chat(prompt_redes)
  redes_final <- if (!is.na(web) && nzchar(web)) glue("{contenido_redes}\n\n🌐 {web}") else contenido_redes
  
  # Generar contenido para newsletter
  contenido_newsletter <- chat$chat(prompt_newsletter)
  newsletter_final <- if (!is.na(web) && nzchar(web)) glue("{contenido_newsletter}\n\n🌐 Recurso: {web}") else contenido_newsletter
  
  return(list(
    redes = redes_final,
    newsletter = newsletter_final
  ))
}

# Nueva función para múltiples tips - genera ambos formatos
armar_contenido_multiple <- function(base, model = "gpt-3.5-turbo") {
  webs <- paste(base$web, collapse = "\n")
  
  # Obtener contenido real de cada URL
  contenidos_urls <- list()
  contenidos_texto <- ""
  
  for(i in 1:nrow(base)) {
    url <- base$web[i]
    contenido <- obtener_contenido_url(url)
    
    if (!contenido$exito) {
      stop(paste("Error al obtener contenido de", url, ":", contenido$error))
    }
    
    contenidos_urls[[i]] <- contenido
    contenidos_texto <- paste0(contenidos_texto, 
                              "\n=== CONTENIDO DE ", url, " ===\n",
                              contenido$contenido, "\n")
  }
  
  # PROMPT PARA REDES SOCIALES CON CONTENIDO REAL
  urls_con_contenido_redes <- ""
  for(i in 1:nrow(base)) {
    urls_con_contenido_redes <- paste0(urls_con_contenido_redes, 
                                      "URL ", i, ": ", base$web[i], "\n")
  }
  
  prompt_redes <- glue(
    "Eres el redactor de contenido de 'Estación R'. Te proporciono el contenido REAL de estos 3 recursos:\n\n",
    
    "URLS DE LOS RECURSOS:\n",
    "{urls_con_contenido_redes}\n",
    
    "CONTENIDO REAL DE LAS 3 PÁGINAS:\n",
    "---\n{contenidos_texto}\n---\n\n",
    
    "INSTRUCCIONES:\n",
    "- Analiza ÚNICAMENTE el contenido proporcionado arriba\n",
    "- Para cada recurso:\n",
    "  • Identifica el TEMA: visualización, procesamiento, bibliografía, notas, referentes, experiencias, etc.\n",
    "  • Identifica el nombre EXACTO según aparece en su contenido\n",
    "  • Describe SOLO funcionalidades mencionadas en el texto\n",
    "- NO busques conexiones entre los recursos\n",
    "- Presenta cada uno de forma independiente\n\n",
    
    "FORMATO PARA REDES SOCIALES:\n",
    "- Inicio obligatorio: '¡Llegaron los Rtips de la semana!' seguido de una línea en blanco\n",
    "- Luego: '[SELECCIÓN] 3 recursos de R'\n",
    "- Para cada recurso:\n",
    "  [EMOJI RELACIONADO AL CONTENIDO] **[TEMA] Nombre exacto**: Descripción verificada del contenido (1-2 líneas)\n",
    "  🌐 [URL correspondiente]\n",
    "- Elige emojis específicos según el contenido: 📊 visualización, 🛠️ procesamiento, 📚 bibliografía, 🎓 cursos, 🌍 mapas, 🤖 machine learning, etc.\n",
    "- NO hagas conexiones entre los 3 recursos\n",
    "- Al final: mensaje de engagement: '¿Conocías o usaste alguno de estos paquetes? Contanos o compartí lo que hayas hecho que lo difundimos'\n",
    "- Tono argentino con voseo desde Estación R\n",
    "- Hashtags: Siempre incluir #RStats #RStatsES #EstacionR #Rtips + otros relevantes según popularidad\n",
    "- 1000-1300 caracteres total\n\n",
    
    "IMPORTANTE: Solo usa información literal del contenido. NO inventes conexiones entre recursos."
  )
  
  # PROMPT PARA NEWSLETTER CON CONTENIDO REAL
  urls_con_contenido <- ""
  for(i in 1:nrow(base)) {
    urls_con_contenido <- paste0(urls_con_contenido, 
                                "URL ", i, ": ", base$web[i], "\n")
  }
  
  prompt_newsletter <- glue(
    "Basándote en el MISMO contenido real, crea una versión detallada para newsletter:\n\n",
    
    "URLS DE LOS RECURSOS:\n",
    "{urls_con_contenido}\n",
    
    "CONTENIDO REAL DE LAS 3 PÁGINAS:\n",
    "---\n{contenidos_texto}\n---\n\n",
    
    "FORMATO NEWSLETTER:\n",
    "1. Título atractivo para email\n",
    "2. Introducción profesional sobre la selección\n",
    "3. Cada recurso desarrollado:\n",
    "   - Subtítulo con nombre exacto del contenido\n",
    "   - Descripción detallada basada únicamente en el contenido proporcionado\n",
    "   - Casos de uso específicos mencionados en el texto\n",
    "   - Beneficios concretos extraídos del contenido\n",
    "   - INMEDIATAMENTE después: 🌐 [URL correspondiente del recurso]\n",
    "4. Conclusión integradora\n",
    "5. Call-to-action para explorar los recursos\n\n",
    
    "CARACTERÍSTICAS:\n",
    "- Extensión: 1500-2000 caracteres total (máximo 2000)\n",
    "- Cada recurso: información concisa pero detallada del contenido proporcionado\n",
    "- Tono profesional pero cercano\n",
    "- Estructura clara con subtítulos\n",
    "- Enfoque educativo profundo\n\n",
    
    "IMPORTANTE: Usar ÚNICAMENTE información literal del contenido proporcionado."
  )
  
  chat <- ellmer::chat_openai(model = model, api_key = token_openai)
  
  # Generar contenido para redes
  contenido_redes <- chat$chat(prompt_redes)
  # Las URLs ya están incluidas en cada descripción, no las agregamos al final
  redes_final <- contenido_redes
  
  # Generar contenido para newsletter
  contenido_newsletter <- chat$chat(prompt_newsletter)
  # Las URLs ya están incluidas en cada descripción, no las agregamos al final
  newsletter_final <- contenido_newsletter
  
  return(list(
    redes = redes_final,
    newsletter = newsletter_final
  ))
}

# Función de compatibilidad para múltiples tips
armar_tuit_multiple <- function(base, model = "gpt-3.5-turbo") {
  contenido <- armar_contenido_multiple(base, model)
  return(contenido$redes)
}




##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##                              Preparar imágen                             ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(httr)
library(jsonlite)
library(glue)

genera_imagen_tip_dalle <- function(tip, 
                                    output_path = tempfile(fileext = ".png"),
                                    api_key = Sys.getenv("OPENAI_API_KEY")) {
  # Prompt visual consistente y claro
  prompt <- glue(
    "Diseña una imagen tipo carrusel para Instagram, de estilo minimalista, profesional y educativo, para ilustrar el siguiente tip de R: '{tip}'. ",
    "El fondo debe ser azul (#405BFF) o amarillo (#EAFF38). Si es un paquete de R, el logo original debe estar en el centro",
    "con tipografía Ubuntu clara y legible (preferentemente Ubuntu). Deja márgenes generosos y que el diseño sea minimalista y limpio. ",
    "Incluye un espacio en la esquina inferior derecha para el logo horizontal de Estación R (aquí el link al logo: https://github.com/Estacion-R/manual_estilo/blob/main/Logo_PNG_Baja_Mesa%20de%20trabajo%201.png), pero no escribas 'Estación R' ni otro texto extra.",
    "Evita fotografías, usa solo los logos o imágenes originales ",
    "No agregues texto adicional ni hashtags. "
  )
  
  # Llama a la API de OpenAI/DALL·E
  url <- "https://api.openai.com/v1/images/generations"
  body <- list(
    model = "dall-e-3",
    prompt = prompt,
    n = 1,
    size = "1024x1024"
  )
  res <- POST(
    url,
    add_headers(
      Authorization = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    ),
    body = toJSON(body, auto_unbox = TRUE)
  )
  
  if (http_status(res)$category != "Success") {
    stop("No se pudo generar la imagen: ", content(res, as = "text"))
  }
  
  response <- content(res, as = "parsed")
  img_url <- response$data[[1]]$url
  
  download.file(img_url, destfile = output_path, mode = "wb")
  return(output_path)
}




##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##              Función para chequear tuits con +280 caracteres             ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
chequear_tuit <- function(){
  
  # Link a la hoja de cálculo
  url <- "https://docs.google.com/spreadsheets/d/1OKGyVgAy1YhKfaGP_p0rwXWdVnQfovFRsgzo5qRQ3eo/edit#gid=0"
  
  # Habilito acceso público
  googlesheets4::gs4_deauth()
  
  # Leo hoja de cálculo
  base <- googlesheets4::read_sheet(url, sheet = "Desarrollo")
  
  
  for (i in seq_along(base$web)) {
    
    base_tuit <- base[i, ]
    
    tuit <- armar_tuit(base = base_tuit)
    
    tryCatch(expr = {
      
      ### Si el tuit tiene más de 280 caracteres
      if(nchar(tuit) > 500){ 
        
        cat(glue::glue("Ojota, el tuit nro {i} tiene {nchar(tuit)} caracteres"))
        
        if(!exists("tip_malo")){
          
          tip_malo <- readRDS("data/tip_malos.rds")
          
          tip_malo <- tip_malo |> 
            dplyr::bind_rows(base_tuit)
          
        } else {
          
          tip_malo <- tip_malo |> 
            dplyr::bind_rows(base_tuit)
        }
      }
      
      ### Si el tuit tiene menos de 280 caracteres
      if(nchar(tuit) <= 500) { 
        
        print(glue::glue("todo piola ameo con el tuit {i}"))
      }
      
    },
    
    error = function(e) {
      
      message(glue::glue("Revisar links de la web, tip, imágen, algo falló en el tuit nro {i}"))
    })
    
  }  
  
  
  if(exists("tip_malo")){
    
    return(tip_malo)
    
  } else {
    
    cat(glue::glue("Van {nrow(base)} tuits y todos están joya"))
  }
}



##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##                                Achica urls                               ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

achicar_url <- function(link, linkPreview = FALSE) {
  
  if(!is.null(link)){
    
    api <- if(linkPreview) {"http://v.gd/create.php?format=json"} else {"http://is.gd/create.php?format=json"}
    query <- list(url = link)
    request <- httr::GET(api, query = query)
    contenido <- httr::content(request, as = "text", encoding = "utf-8")
    
    if(stringr::str_detect(contenido, "error") == FALSE){
      
      resultado <- jsonlite::fromJSON(contenido)
      
    } else {
      
      resultado <- link
    }
    
    return(resultado)
    
  } else {
    
    resultado <- NULL
    
    return(resultado)
  }
}


