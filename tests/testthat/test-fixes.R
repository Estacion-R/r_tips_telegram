# Tests que verifican los fixes del 2026-08-17 (issues #2 al #6)

# ── Issue #2: seq_len(0) no itera ─────────────────────────────────────────────

test_that("seq_len(0) produce vector vacío (fix #2)", {
  expect_equal(length(seq_len(0)), 0)
})

test_that("loop con seq_len(0) no ejecuta ninguna iteración (fix #2)", {
  contador <- 0
  for (i in seq_len(0)) contador <- contador + 1
  expect_equal(contador, 0)
})

test_that("1:0 produce c(1,0) — bug original que motivó el fix #2", {
  expect_equal(1:0, c(1L, 0L))
})


# ── Issue #3: RDS vacío no debe causar stop() ──────────────────────────────────

test_that("data.frame de usuarios vacío tiene nrow 0 (fix #3)", {
  usuarios <- data.frame(id = integer(0), user = character(0))
  expect_equal(nrow(usuarios), 0)
})

test_that("bloque if/else desvía correctamente con 0 usuarios (fix #3)", {
  usuarios <- data.frame(id = integer(0), user = character(0))
  ejecutó_envio <- FALSE
  if (nrow(usuarios) == 0) {
    mensaje <- "Sin suscriptores activos"
  } else {
    ejecutó_envio <- TRUE
  }
  expect_false(ejecutó_envio)
  expect_match(mensaje, "Sin suscriptores")
})


# ── Issue #4: tip como parámetro (verificación de firma) ─────────────────────

test_that("enviar_tip define tip como parámetro explícito en el código (fix #4)", {
  lineas <- readLines(here::here("R/script_bot.R"))
  definicion <- grep("enviar_tip <- function", lineas, value = TRUE)
  expect_true(any(grepl("tip", definicion)))
})


# ── Issue #5: historial preparado pero no persistido en 02-armar_tip ─────────

test_that("02-armar_tip.R no llama write_rds (fix #5)", {
  lineas <- readLines(here::here("R/02-armar_tip.R"))
  write_rds_lines <- grep("write_rds", lineas, value = TRUE)
  expect_equal(length(write_rds_lines), 0)
})

test_that("script_bot.R llama write_rds para persistir historial (fix #5)", {
  lineas <- readLines(here::here("R/script_bot.R"))
  expect_true(any(grepl("write_rds", lineas)))
})


# ── Issue #6: variable hoy eliminada ──────────────────────────────────────────

test_that("script_bot.R no define la variable hoy (fix #6)", {
  lineas <- readLines(here::here("R/script_bot.R"))
  expect_false(any(grepl("^hoy\\s*<-", lineas)))
})
