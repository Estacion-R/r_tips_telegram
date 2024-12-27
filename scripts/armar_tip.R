


source("scripts/00-funciones.R")


# Link a la hoja de cálculo
url <- "https://docs.google.com/spreadsheets/d/1OKGyVgAy1YhKfaGP_p0rwXWdVnQfovFRsgzo5qRQ3eo/edit#gid=0"

# Habilito acceso público
googlesheets4::gs4_deauth()

# Leo hoja de cálculo
r_tips <- googlesheets4::read_sheet(url, sheet = "Produccion")

### Cargo historial de tuits
base_hist <- readr::read_rds("data/r_tips_historial.rds") |> 
  dplyr::select(-cant_tuits)


### Calculo los tuis menos frecuentes en publicacion
conteo_tuits <- base_hist |> 
  dplyr::group_by(tip) |> 
  dplyr::summarise(cant_tuits = dplyr::n()) |> 
  dplyr::ungroup()

### Traigo la columna cant_tuit a la base
base_hist <- base_hist |> 
  dplyr::left_join(conteo_tuits)


### TUIT INEDITO
tip_inedito <- r_tips |> 
  dplyr::anti_join(base_hist)

if(nrow(tip_inedito) > 0){
  
  tip_seleccion <- tip_inedito |> 
    dplyr::sample_n(1)
  
} else {
  
  tip_seleccion <- seleccionar_tuit(base_hist)
  
}

### Armo tuit
tip <- armar_tuit(base = tip_seleccion)


### Creo nueva base historial con último tuit publicado
base_hist_nueva <- base_hist |> 
  dplyr::bind_rows(tip_seleccion)

#file.remove("data/r_tips_historial.rds")
readr::write_rds(base_hist_nueva, "data/r_tips_historial.rds")  


### Creo log de tuits
tuit_archivo <- paste(as.character(Sys.time()), tip, sep = " ")
write(tuit_archivo, file = here::here("data/rtips-tuits.log"), append = TRUE)


