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
##                    Función para armar el tuit a publicar                 ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Armado de tuit
library(ellmer)
library(glue)

armar_tuit <- function(base, model = "gpt-3.5-turbo") {
  web <- base$web
  
  hashtags <- "#RStats #RStatsES #Rtips #DataScience @rstats@a.gup.pe"
  
  prompt <- glue(
    "Eres el redactor de contenido de 'Estación R'. Tu tarea es crear una publicación educativa basándote ÚNICAMENTE en el contenido de esta URL: {web}\n\n",
    
    "PASO 1 - ANÁLISIS DEL CONTENIDO:\n",
    "- Accede y analiza completamente el contenido de la URL\n",
    "- Identifica el tipo: paquete, función, tutorial, recurso, dataset, libro, curso, herramienta, etc.\n",
    "- Extrae información clave: qué hace, cómo se usa, para qué sirve, ejemplos prácticos\n",
    "- Si es un paquete: funciones principales, casos de uso, público objetivo\n",
    "- Si es tutorial/artículo: puntos clave y aprendizajes principales\n",
    "- Si es herramienta/recurso: utilidad y beneficios para la comunidad\n\n",
    
    "PASO 2 - ESTRUCTURA DE LA PUBLICACIÓN:\n",
    "1. Etiqueta clasificatoria: [TIP], [PAQUETE], [RECURSO], [TUTORIAL], etc.\n",
    "2. Título llamativo o pregunta de impacto\n",
    "3. Explicación didáctica del contenido\n",
    "4. Puntos clave (2-4 viñetas con ✔️, ➡️, 🔸)\n",
    "5. Llamada a la acción motivadora\n\n",
    
    "PASO 3 - ESTILO Y TONO:\n",
    "- Usa tono argentino informal con voseo: '¿Sabías que...?', '¿Querés...?'\n",
    "- Sé entusiasta, cercano y didáctico\n",
    "- Habla desde 'Estación R' en plural: 'les compartimos', 'nos parece'\n",
    "- Incluye emojis relevantes: 💡 🎓 📊 🛠️ 📈 ⚡\n",
    "- Agrega espacios entre párrafos para legibilidad\n\n",
    
    "PASO 4 - EXTENSIÓN:\n",
    "- Texto principal: 800-1000 caracteres (ideal para LinkedIn)\n",
    "- Si es contenido muy técnico, puede extenderse hasta 1300 caracteres\n",
    "- Prioriza claridad sobre brevedad\n\n",
    
    "IMPORTANTE: NO agregues hashtags, URLs ni menciones. Solo el contenido de la publicación. Debe ser autocontenido y listo para publicar."
  )
  
  chat <- ellmer::chat_openai(model = model, api_key = token_openai)
  tuit_gpt <- chat$chat(prompt)  # <-- la respuesta es un character
  
  tuit_gpt_web <- if (!is.na(web) && nzchar(web)) glue("{tuit_gpt}\n\n🌐 {web}") else tuit_gpt
  
  tuit_final <- glue("{tuit_gpt_web}\n\n{hashtags}")
  
  return(tuit_final)
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


