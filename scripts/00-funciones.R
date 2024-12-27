
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
  tip1 <- r_tips |>
    dplyr::filter(
      stringr::str_detect(
        tip,
        "clean|numeric_to|Gente Sociable|pointblank|ARTofR|madre|read_sheet|Quarto|coalesce|of Us|Metropolitana"))
  
  base_r_tips <- r_tips |>
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
armar_tuit <- function(base){
  
  tema <- base$tema
  tip <- base$tip
  autor <- base$autor
  #web <- achicar_url(base$web)
  web <- base$web
  
  ### unicode source: https://unicode.org/emoji/charts/full-emoji-list.html
  funcion <- "\U0001F6E0"
  recursos <- "\U0001f4da"
  paquete <- "\U0001f4e6"
  referentes <- "\U0001f5e3"
  mapas <- "\U0001f5fa"
  bot <- "\U0001F916"
  shiny <- "\U0001F5A5"
  referente <- "\U0001F9D1 \U0001F468 "
  
  
  
  if(tema == "funcion"){
    tema <- glue::glue("{toupper(tema)} {funcion}")
  }
  
  if(tema == "paquete"){
    tema <- glue::glue("{toupper(tema)} {paquete}")
  }
  
  if(tema == "recurso"){
    tema <- glue::glue("{toupper(tema)} {recursos}")
  }
  
  if(tema == "referente"){
    tema <- glue::glue("{toupper(tema)} {referentes}")
  }
  
  if(tema == "bot"){
    tema <- glue::glue("{toupper(tema)} {bot}")
  }
  
  if(tema == "mapas"){
    tema <- glue::glue("{toupper(tema)} {mapas}")
  }
  
  if(tema == "shiny"){
    tema <- glue::glue("{toupper(tema)} {shiny}")
  }
  
  if(tema == "referente"){
    tema <- glue::glue("{toupper(tema)} {referente}")
  }
  
  hashtag_maxima <- "#RStats #RStatsES #Rtips #DataScience @rstats@a.gup.pe"
  #hashtag_minima <- "#RStats #RStatsES #Rtips"
  #hashtag_minima_v2 <- "#RStats #Rtips"
  #espacios <- 4
  
  
  ### Estructura del tuit al 100%
  ## tema
  ## tip
  ## web
  ## hashtag_maxima / minima
  
  tuit_tema_tip <- glue::glue("[{tema}] - {tip}")
  
  ### Si hay web
  if(!is.null(web)){
    tuit_tema_tip_web <- glue::glue("{tuit_tema_tip} \n \n🌐 {web}")
  } else {
    tuit_tema_tip_web <- glue::glue("{tuit_tema_tip}")
  }
  
  ### Si hay autor/a
  if(!is.na(autor)){
    tuit_tema_tip_web_autor <- glue::glue("{tuit_tema_tip_web}\n✍🏼 {autor} \n \n{hashtag_maxima}")
  } else {
    tuit_tema_tip_web_autor <- glue::glue("{tuit_tema_tip_web} \n \n{hashtag_maxima}")
  }
  
  ### hashtag por tamaño
  #if(nchar(tuit_tema_tip_web_autor) + nchar(hashtag_maxima) + espacios <= 280){
  #  
  #  tuit_tema_tip_web_autor_hash <- glue::glue("{tuit_tema_tip_web_autor} \n \n{hashtag_maxima}")
  #  
  #} else if(nchar(tuit_tema_tip_web_autor) + nchar(hashtag_minima) + espacios <= 280){
  #  
  #  tuit_tema_tip_web_autor_hash <- glue::glue("{tuit_tema_tip_web_autor} \n \n{hashtag_minima}")
  #  
  #} else if(nchar(tuit_tema_tip_web_autor) + nchar(hashtag_minima_v2) + espacios <= 280){
  #  
  #  tuit_tema_tip_web_autor_hash <- glue::glue("{tuit_tema_tip_web_autor} \n \n{hashtag_minima_v2}")
  #  
  #} else {
  #  
  #  tuit_tema_tip_web_autor_hash <- tuit_tema_tip_web_autor
  #  
  #}
  
  
  
  # ### Tuit de menos de 252 caracteres y con autores
  # if(nchar(tip) < 239 & (!is.na(autor) & !is.null(web))){
  #   
  #   ### Si hay dato en autor o web
  #   tuit <- glue::glue("[{tema}] - {tip} \n \n🌐 {web} \ {autor}  \n {hashtag_maxima}")
  #   
  #   return(tuit)
  # }
  # 
  # ### Tuit de menos de 252 caracteres y con autores
  # if(nchar(tip) >= 240 & nchar(tip) < 252 & (!is.na(autor) & !is.null(web))){
  #   
  #   ### Si hay dato en autor o web
  #   tuit <- glue::glue("[{tema}] - {tip} \n \n🌐 {web} \n✍🏼 {autor}  \n {hashtag_minima}")
  #   
  #   return(tuit)
  # }
  # 
  # ### Tuit de menos de 252 caracteres y sin autores
  # if(nchar(tip) < 252 & (is.na(autor) & is.null(web))){
  #   
  #   tuit <- glue::glue("[{tema}] - {tip} - \n #rstats #rstatsES #rtips")
  #   
  #   return(tuit)
  #   
  # }
  # 
  # ### Tuit con más de 252 caracteres y con autores
  # if(nchar(base$tip) >= 252 & (!is.na(base$autor) & !is.null(web))){
  #   
  #   ### Tuit de más de 252 caracteres
  #   tuit <- glue::glue("[{tema}] - {tip} - \n \n🌐 {web} \n✍🏼 {autor} ")
  #   
  #   return(tuit)
  # }
  # 
  # ### Tuit con más de 252 caracteres y sin autores
  # if(nchar(base$tip) >= 252 & (is.na(base$autor) & is.null(web))){
  #   
  #   ### Tuit de más de 252 caracteres
  #   tuit <- glue::glue("[{tema}] - {tip}")
  #   
  #   return(tuit)
  # }
  
  return(tuit_tema_tip_web_autor)
}




##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##                              Preparar imágen                             ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

preparar_media <- function(imagen){
  
  if(!is.na(imagen)){
    
    if(stringr::str_ends(imagen, ".png")){
      
      ### Obtengo imagen de url
      tryCatch(expr = {
        
        tuit_imagen <-  png::readPNG(RCurl::getURLContent(imagen))
        
        cat("imágen cargada sin problema")
      }, 
      
      error = function(e) {
        
        message(glue::glue("Revisar links imágen, algo falló en el tuit nro {i}"))
      }
      )
      
      return(tuit_imagen)
      
    }
    
    if(stringr::str_ends(imagen, ".svg")){
      
      ### Transformo de svg a png
      rsvg::rsvg_png(imagen, 'img/image.png', width = 800)
      
      ### Cargo png
      tuit_imagen <-  png::readPNG("img/image.png")
      
      cat("imágen cargada sin problema")
      
      return(tuit_imagen)
    }
    
    if(stringr::str_ends(imagen, ".gif")){
      
      tuit_imagen <-  magick::image_read(imagen)
      
      return(tuit_imagen)
    }
  } 
  
  tuit_imagen <-  NA_real_
  
  return(tuit_imagen)
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



