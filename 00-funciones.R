
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##                Función para armar una base de tuits de cero              ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

crear_base_historica <- function(){
  
  # Link a la hoja de cálculo
  url <- "https://docs.google.com/spreadsheets/d/1OKGyVgAy1YhKfaGP_p0rwXWdVnQfovFRsgzo5qRQ3eo/edit#gid=0"
  
  # Habilito acceso público
  googlesheets4::gs4_deauth()
  
  # Leo hoja de cálculo
  base_r_tips <- googlesheets4::read_sheet(url, 
                                           sheet = "Produccion")
  
  ### Las que se repitieron muchas veces
  tip1 <- base_r_tips |>
    dplyr::filter(
      stringr::str_detect(
        tip,
        "clean|numeric_to|Gente Sociable|pointblank|ARTofR|madre|read_sheet|Quarto|coalesce|of Us|Metropolitana"))
  
  base_r_tips <- base_r_tips |>
    dplyr::bind_rows(tip1)
  
  conteo_tuits <- base_r_tips |> 
    dplyr::group_by(tip) |> 
    dplyr::summarise(cant_tuits = dplyr::n()) |> 
    dplyr::ungroup()
  
  base_r_tips <- base_r_tips |> 
    dplyr::left_join(conteo_tuits)
  
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
  base_tuit <- base_hist |> 
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
library(ellmer)
library(glue)

armar_tuit <- function(base, model = "gpt-3.5-turbo") {
  tema_original <- base$tema
  tip <- base$tip
  autor <- base$autor
  web <- base$web
  
  emoji_list <- list(
    funcion = "\U0001F6E0",
    paquete = "\U0001f4e6",
    recurso = "\U0001f4da",
    referente = "\U0001f5e3",
    bot = "\U0001F916",
    mapas = "\U0001f5fa",
    shiny = "\U0001F5A5"
  )
  
  tema <- tema_original
  if (tema %in% names(emoji_list)) {
    tema <- glue("{toupper(tema)} {emoji_list[[tema]]}")
  }
  
  hashtags <- "#RStats #RStatsES #Rtips #DataScience @rstats@a.gup.pe"
  
  prompt <- glue(
    "Eres una cuenta de divulgación de R. Vas a escribir un texto para publicar en redes sociales. La información la vas a obtener de {web}. Escribe un texto, didáctico y atractivo .\n\n",
    "Tema: {tema_original}\n",
    "Tip: {tip}\n",
    "El tono debe ser en argentino, no neutro y siempre la referencia es en plural, 'desde Estación R'.",
    "Agrega espacios entre párrafos para mejorar la legibilidad del texto.",
    "Si el {tema} es un paquete, trata de listar las principales funciones o usos del mismo identificando a qué comunidad le puede ser útil.",
    if (!is.na(autor) && nzchar(autor)) glue("Autor: {autor}\n") else "",
    if (!is.na(web) && nzchar(web)) glue("Fuente: {web}\n") else "",
    "Incluye un llamado a la acción para que la comunidad aprenda o comparta.\nNo uses hashtags ni menciones, los agregaré después."
  )
  
  chat <- chat_openai(model = model)
  tuit_gpt <- chat$chat(prompt)  # <-- la respuesta es un character
  
  tuit_gpt_web <- if (!is.na(web) && nzchar(web)) glue("{tuit_gpt}\n\n🌐 {web}") else tuit_gpt
  tuit_gpt_web_autor <- if (!is.na(autor) && nzchar(autor)) glue("{tuit_gpt_web}\n✍🏼 {autor}") else tuit_gpt_web
  
  tuit_final <- glue("[{tema}] {tuit_gpt_web_autor}\n\n{hashtags}")
  
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
  
  
  for (i in seq_along(base$tip)) {
    
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



