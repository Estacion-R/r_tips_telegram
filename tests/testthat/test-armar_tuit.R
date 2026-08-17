source(here::here("R/00-funciones.R"))

# ── Tips nuevos (generados por el bot de ingesta) ─────────────────────────────

test_that("tip con header [Tip de R...] se publica sin modificar", {
  base <- data.frame(
    tema   = "paquete",
    tip    = "[Tip de R - Paquete 📦] · dplyr: filtrá filas\n\n🔗 https://example.com\n✍️ Autor\n\n#RStats",
    autor  = "Autor",
    web    = "https://example.com",
    stringsAsFactors = FALSE
  )
  expect_equal(armar_tuit(base), trimws(base$tip))
})

test_that("tip con espacios iniciales y header [Tip de R...] se publica sin modificar", {
  base <- data.frame(
    tema   = "recurso",
    tip    = "   [Tip de R - Recurso 📚] · ggplot2: guía visual\n\n#RStats",
    autor  = NA_character_,
    web    = NA_character_,
    stringsAsFactors = FALSE
  )
  result <- armar_tuit(base)
  expect_match(result, "^\\[Tip de R")
})


# ── Tips legacy (anteriores al bot de ingesta) ────────────────────────────────

test_that("tema paquete genera emoji 📦 y formato [PAQUETE 📦] - tip", {
  base <- data.frame(
    tema  = "paquete",
    tip   = "dplyr es increíble",
    autor = "Hadley",
    web   = "https://dplyr.tidyverse.org",
    stringsAsFactors = FALSE
  )
  result <- armar_tuit(base)
  expect_match(result, "^\\[PAQUETE")
  expect_match(result, "\U0001f4e6")
  expect_match(result, "dplyr es increíble")
})

test_that("tema funcion genera emoji 🛠", {
  base <- data.frame(
    tema  = "funcion",
    tip   = "mutate() agrega columnas",
    autor = NA_character_,
    web   = NA_character_,
    stringsAsFactors = FALSE
  )
  result <- armar_tuit(base)
  expect_match(result, "^\\[FUNCION")
  expect_match(result, "\U0001F6E0")
})

test_that("tema recurso genera emoji 📚", {
  base <- data.frame(
    tema  = "recurso",
    tip   = "R for Data Science es el mejor libro",
    autor = "Hadley",
    web   = "https://r4ds.had.co.nz",
    stringsAsFactors = FALSE
  )
  result <- armar_tuit(base)
  expect_match(result, "^\\[RECURSO")
  expect_match(result, "\U0001f4da")
})

test_that("tip legacy incluye URL cuando hay web", {
  base <- data.frame(
    tema  = "paquete",
    tip   = "Un tip copado",
    autor = NA_character_,
    web   = "https://ejemplo.com",
    stringsAsFactors = FALSE
  )
  result <- armar_tuit(base)
  expect_match(result, "https://ejemplo.com")
})

test_that("tip legacy no incluye URL cuando web es NA", {
  base <- data.frame(
    tema  = "paquete",
    tip   = "Un tip sin URL",
    autor = NA_character_,
    web   = NA_character_,
    stringsAsFactors = FALSE
  )
  result <- armar_tuit(base)
  expect_false(grepl("\U0001F310", result))
})

test_that("tip legacy incluye autor cuando hay autor", {
  base <- data.frame(
    tema  = "paquete",
    tip   = "Un tip con autor",
    autor = "Hadley Wickham",
    web   = NA_character_,
    stringsAsFactors = FALSE
  )
  result <- armar_tuit(base)
  expect_match(result, "Hadley Wickham")
})

test_that("tip legacy no incluye ✍️ cuando autor es NA", {
  base <- data.frame(
    tema  = "paquete",
    tip   = "Un tip sin autor",
    autor = NA_character_,
    web   = NA_character_,
    stringsAsFactors = FALSE
  )
  result <- armar_tuit(base)
  expect_false(grepl("\U270D", result))
})

test_that("tip legacy siempre incluye hashtags", {
  base <- data.frame(
    tema  = "funcion",
    tip   = "cualquier tip",
    autor = NA_character_,
    web   = NA_character_,
    stringsAsFactors = FALSE
  )
  result <- armar_tuit(base)
  expect_match(result, "#RStats")
})
