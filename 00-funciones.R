##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##                Función para armar una base de tuits de cero              ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Versión simplificada - Sin OpenAI
# Los tips se generan con /agregar-tip y se guardan en la hoja "Produccion"

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
  base_tuit <- base |>
    dplyr::slice_min(order_by = cant_tuits, n = 2) |>
    dplyr::select(-cant_tuits) |>
    dplyr::sample_n(1)

  return(base_tuit)
}



##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##                    Función para armar el tuit a publicar                 ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Armado de tuit - Versión simple (sin IA)
### Lee el tip ya escrito de la columna "tip" en Google Sheets

armar_tuit <- function(base){

  tema <- base$tema
  tip <- base$tip
  autor <- base$autor
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
  tidyverse <- "\U0001F9F9"

  # Asignar emoji según tema
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

  if(tema == "tidyverse"){
    tema <- glue::glue("{toupper(tema)} {tidyverse}")
  }

  hashtag_maxima <- "#RStats #RStatsES #Rtips #DataScience"

  ### Estructura del tuit
  ## [TEMA] - tip
  ## web
  ## autor
  ## hashtags

  tuit_tema_tip <- glue::glue("[{tema}] - {tip}")

  ### Si hay web
  if(!is.null(web) && !is.na(web)){
    tuit_tema_tip_web <- glue::glue("{tuit_tema_tip} \n \n\U0001F310 {web}")
  } else {
    tuit_tema_tip_web <- glue::glue("{tuit_tema_tip}")
  }

  ### Si hay autor/a
  if(!is.na(autor)){
    tuit_tema_tip_web_autor <- glue::glue("{tuit_tema_tip_web}\n\U270D\U0001F3FC {autor} \n \n{hashtag_maxima}")
  } else {
    tuit_tema_tip_web_autor <- glue::glue("{tuit_tema_tip_web} \n \n{hashtag_maxima}")
  }

  return(tuit_tema_tip_web_autor)
}
