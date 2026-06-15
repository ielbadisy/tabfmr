test_that("tab_icl regression wrapper fits and predicts through sklearn-style API", {
  fake_fit <- structure(
    list(
      predict = function(newdata) rep(1.5, nrow(newdata))
    ),
    class = "tab_icl_mock"
  )
  fake_regressor <- function(...) {
    structure(
      list(fit = function(x, y) fake_fit),
      class = "tab_icl_mock"
    )
  }
  fake_module <- list(TabICLRegressor = fake_regressor)

  local_mocked_bindings(import_tabicl = function() fake_module)

  mod <- tab_icl(mpg ~ wt + hp, data = mtcars[1:10, ])
  expect_s3_class(mod, "tab_icl")
  pred <- predict(mod, mtcars[11:12, ])
  expect_equal(pred, tibble::tibble(.pred = c(1.5, 1.5)))
})

test_that("tab_icl classification wrapper returns class and probability predictions", {
  fake_fit <- structure(
    list(
      classes_ = c("no", "yes"),
      predict_proba = function(newdata) matrix(
        c(0.8, 0.2, 0.3, 0.7),
        nrow = nrow(newdata),
        byrow = TRUE
      )
    ),
    class = "tab_icl_mock"
  )
  fake_classifier <- function(...) {
    structure(
      list(fit = function(x, y) fake_fit),
      class = "tab_icl_mock"
    )
  }
  fake_module <- list(TabICLClassifier = fake_classifier)

  local_mocked_bindings(import_tabicl = function() fake_module)

  dat <- data.frame(
    y = factor(c("no", "yes", "no", "yes")),
    x1 = 1:4,
    x2 = c(1, 1, 0, 0)
  )
  mod <- tab_icl(y ~ ., data = dat)
  pred <- predict(mod, dat[1:2, ])
  expect_equal(names(pred), c(".pred_no", ".pred_yes", ".pred_class"))
  expect_equal(as.character(pred$.pred_class), c("no", "yes"))
  expect_equal(predict(mod, dat[1:2, ], type = "prob")[0, ],
               tibble::tibble(.pred_no = numeric(), .pred_yes = numeric()))
})
