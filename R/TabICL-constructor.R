new_tab_icl <- function(
  fit,
  levels,
  training,
  logging,
  blueprint,
  call = NULL
) {
  cls <- c(
    "tabicl._sklearn.TabICLRegressor",
    "tabicl._sklearn.TabICLClassifier",
    "tabicl._sklearn.regressor.TabICLRegressor",
    "tabicl._sklearn.classifier.TabICLClassifier",
    "tab_icl_mock"
  )

  if (!inherits(fit, cls)) {
    cli::cli_abort(
      "The model fit object should have class {.cls {.or {cls}}}, not {.cls {class(fit)}}.",
      call = call
    )
  }

  check_character(levels, allow_null = TRUE)

  hardhat::new_model(
    fit = fit,
    levels = levels,
    training = training,
    logging = logging,
    blueprint = blueprint,
    class = "tab_icl"
  )
}
