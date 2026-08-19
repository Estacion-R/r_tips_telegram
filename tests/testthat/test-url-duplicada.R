source(here::here("R/00-funciones.R"))

# ── Tests unitarios de remove_duplicate_links() ────────────────────────────────

test_that("elimina línea con ↪ y la URL", {
  texto <- "Contenido del tip\n\n↪ https://ejemplo.com\n\n#RStats"
  resultado <- remove_duplicate_links(texto, "https://ejemplo.com")
  expect_false(grepl("https://ejemplo.com", resultado, fixed = TRUE))
})

test_that("elimina línea con 🌐 y la URL", {
  texto <- "Contenido del tip\n\n🌐 https://ejemplo.com \n\n#RStats"
  resultado <- remove_duplicate_links(texto, "https://ejemplo.com")
  expect_false(grepl("https://ejemplo.com", resultado, fixed = TRUE))
})

test_that("no altera texto que no contiene la URL", {
  texto <- "Contenido sin link\n\n#RStats"
  resultado <- remove_duplicate_links(texto, "https://ejemplo.com")
  expect_equal(resultado, texto)
})

test_that("elimina múltiples líneas con la misma URL", {
  texto <- "Intro\n\n↪ https://ejemplo.com\n\nMedio\n\n🌐 https://ejemplo.com\n\n#RStats"
  resultado <- remove_duplicate_links(texto, "https://ejemplo.com")
  expect_false(grepl("https://ejemplo.com", resultado, fixed = TRUE))
})

test_that("URL aparece exactamente una vez en redes_final después del fix", {
  url <- "https://ejemplo.com"
  contenido_llm <- glue::glue("Texto del tip\n\n↪ {url}\n\n#RStats")
  contenido_limpio <- remove_duplicate_links(contenido_llm, url)
  redes_final <- glue::glue("{contenido_limpio}\n\n🌐 {url}")
  n <- lengths(regmatches(redes_final, gregexpr(url, redes_final, fixed = TRUE)))
  expect_equal(n, 1L)
})

test_that("URL con puntos y slashes (regex especiales) se escapa correctamente", {
  url <- "https://r4ds.had.co.nz/transform.html"
  texto <- glue::glue("Contenido\n\n↪ {url}\n\n#RStats")
  resultado <- remove_duplicate_links(texto, url)
  expect_false(grepl(url, resultado, fixed = TRUE))
})

# ── Test con la última fila real del Sheets ────────────────────────────────────

test_that("última fila del Sheets: URL no se duplica en el output final", {
  skip_if_offline()
  skip_if_not_installed("googlesheets4")

  googlesheets4::gs4_deauth()
  url_sheet <- "https://docs.google.com/spreadsheets/d/1OKGyVgAy1YhKfaGP_p0rwXWdVnQfovFRsgzo5qRQ3eo/edit#gid=0"
  sheet <- googlesheets4::read_sheet(url_sheet, sheet = "Desarrollo")
  ultima_fila <- tail(sheet, 1)
  url_tip <- ultima_fila$web[[1]]

  skip_if(is.na(url_tip) || !nzchar(url_tip), "Última fila no tiene URL")

  # Simula el output del LLM con la URL ya incluida (reproduce el bug)
  contenido_con_url_duplicada <- glue::glue(
    "Contenido generado por el LLM sobre el recurso.\n\n",
    "↪ {url_tip}\n\n",
    "#RStats #RStatsES"
  )

  contenido_limpio <- remove_duplicate_links(contenido_con_url_duplicada, url_tip)
  redes_final <- glue::glue("{contenido_limpio}\n\n🌐 {url_tip}")

  n <- lengths(regmatches(redes_final, gregexpr(url_tip, redes_final, fixed = TRUE)))
  expect_equal(
    n, 1L,
    label = glue::glue("URL '{url_tip}' aparece {n} vez/veces (esperado: 1)")
  )
})
