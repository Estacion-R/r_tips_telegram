source(here::here("R/00-funciones.R"))

test_that("selecciona el tip con menor cant_tuits", {
  base <- data.frame(
    tip       = c("tip A", "tip B", "tip C"),
    web       = c("a.com", "b.com", "c.com"),
    cant_tuits = c(5, 1, 3),
    stringsAsFactors = FALSE
  )
  set.seed(42)
  resultado <- seleccionar_tuit(base)
  expect_equal(resultado$web, "b.com")
})

test_that("en empate selecciona uno de los dos mínimos", {
  base <- data.frame(
    tip        = c("tip A", "tip B", "tip C"),
    web        = c("a.com", "b.com", "c.com"),
    cant_tuits = c(2, 2, 5),
    stringsAsFactors = FALSE
  )
  set.seed(1)
  resultado <- seleccionar_tuit(base)
  expect_true(resultado$web %in% c("a.com", "b.com"))
})

test_that("devuelve exactamente una fila", {
  base <- data.frame(
    tip        = c("tip A", "tip B"),
    web        = c("a.com", "b.com"),
    cant_tuits = c(1, 2),
    stringsAsFactors = FALSE
  )
  resultado <- seleccionar_tuit(base)
  expect_equal(nrow(resultado), 1)
})

test_that("no incluye la columna cant_tuits en el resultado", {
  base <- data.frame(
    tip        = c("tip A", "tip B"),
    web        = c("a.com", "b.com"),
    cant_tuits = c(1, 2),
    stringsAsFactors = FALSE
  )
  resultado <- seleccionar_tuit(base)
  expect_false("cant_tuits" %in% names(resultado))
})
