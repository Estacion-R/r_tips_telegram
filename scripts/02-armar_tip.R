

token_openai <- Sys.getenv("OPENAI_API_KEY")
source("scripts/00-funciones.R")


# Link a la hoja de cálculo
url <- "https://docs.google.com/spreadsheets/d/1OKGyVgAy1YhKfaGP_p0rwXWdVnQfovFRsgzo5qRQ3eo/edit#gid=0"

# Habilito acceso público
googlesheets4::gs4_deauth()

# Leo hoja de cálculo
r_tips <- googlesheets4::read_sheet(url, sheet = "Desarrollo")

### Cargo historial de tuits
base_hist <- readr::read_rds("data/r_tips_historial.rds") |> 
  dplyr::select(-cant_tuits)


### Calculo los tuis menos frecuentes en publicacion
conteo_tuits <- base_hist |> 
  dplyr::group_by(web) |> 
  dplyr::summarise(cant_tuits = dplyr::n()) |> 
  dplyr::ungroup()

### Traigo la columna cant_tuit a la base
base_hist <- base_hist |> 
  dplyr::left_join(conteo_tuits, by = "web")


### SELECCION DE 3 TIPS
tips_seleccionados <- seleccionar_3_tips(r_tips, base_hist)

### Armo contenido con 3 tips (redes + newsletter)
contenido_generado <<- armar_contenido(base = tips_seleccionados)

# Para compatibilidad hacia atrás
tip <- contenido_generado$redes

### Creo nueva base historial con los 3 tips publicados
base_hist_nueva <- base_hist |> 
  dplyr::bind_rows(tips_seleccionados)

#file.remove("data/r_tips_historial.rds")
readr::write_rds(base_hist_nueva, "data/r_tips_historial.rds")  


### Creo log de tuits con URLs de los 3 tips
urls_tips <- paste(tips_seleccionados$web, collapse = " | ")
tuit_archivo <- paste(as.character(Sys.time()), "MULTI-TIP:", urls_tips, sep = " ")
write(tuit_archivo, file = here::here("output/logs/rtips-tuits.log"), append = TRUE)


