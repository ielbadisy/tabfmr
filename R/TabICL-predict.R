#' Predict using TabICL
#'
#' @param object,x A `tab_icl` object.
#' @param new_data A data frame or matrix of new predictors.
#' @param type For classification, one of `"class"` or `"prob"`. Defaults to
#'   all available prediction columns.
#' @param ... Not used.
#' @return A tibble of predictions.
#' @export
predict.tab_icl <- function(object, new_data, type = NULL, ...) {
  rlang::check_dots_empty()
  forged <- hardhat::forge(new_data, object$blueprint)$predictors
  predict(object$fit, forged, object$levels, type = type)
}

# ------------------------------------------------------------------------------
# Implementation

#' @export
predict.tabicl._sklearn.TabICLRegressor <- function(
  object,
  new_data,
  levels,
  type = NULL,
  ...
) {
  captured <- capture_python_or_r(res <- try(object$predict(new_data), silent = TRUE))
  if (inherits(res, "try-error")) {
    cli::cli_abort("Prediction failed: {as.character(res)}")
  }
  tibble::tibble(.pred = as.vector(res))
}

#' @export
predict.tabicl._sklearn.regressor.TabICLRegressor <- predict.tabicl._sklearn.TabICLRegressor

#' @export
predict.tabicl._sklearn.TabICLClassifier <- function(
  object,
  new_data,
  levels,
  type = NULL,
  ...
) {
  captured <- capture_python_or_r(prob <- try(object$predict_proba(new_data), silent = TRUE))
  if (inherits(prob, "try-error")) {
    cli::cli_abort("Prediction failed: {as.character(prob)}")
  }

  cls <- as.character(object$classes_)
  colnames(prob) <- paste0(".pred_", cls)
  cls_ind <- apply(prob, 1, which.max)
  res <- tibble::as_tibble(prob)
  res$.pred_class <- factor(cls[cls_ind], levels = levels)

  if (!is.null(type)) {
    type <- rlang::arg_match(type, c("class", "prob"))
    if (type == "class") {
      res <- res[, ".pred_class"]
    } else if (type == "prob") {
      res <- res[, names(res) != ".pred_class"]
    }
  }
  res
}

#' @export
predict.tabicl._sklearn.classifier.TabICLClassifier <- predict.tabicl._sklearn.TabICLClassifier

#' @export
predict.tab_icl_mock <- function(
  object,
  new_data,
  levels,
  type = NULL,
  ...
) {
  if (is.null(levels)) {
    return(predict.tabicl._sklearn.TabICLRegressor(object, new_data, levels, type = type, ...))
  }
  predict.tabicl._sklearn.TabICLClassifier(object, new_data, levels, type = type, ...)
}

#' @export
#' @rdname predict.tab_icl
augment.tab_icl <- function(x, new_data, type = NULL, ...) {
  new_data <- tibble::new_tibble(new_data)
  res <- predict(x, new_data, type = type)
  res <- cbind(res, new_data)
  tibble::new_tibble(res)
}
