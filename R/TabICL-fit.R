#' Fit a TabICLv2 model
#'
#' `tab_icl()` fits the Python `tabicl` classifier or regressor through
#' `reticulate` and returns an R object with `predict()` and `augment()`
#' methods.
#'
#' @param x A data frame, matrix, recipe, or formula.
#' @param y Outcome vector for the data-frame and matrix interfaces.
#' @param data Data frame for formula and recipe interfaces.
#' @param formula Formula for the formula interface.
#' @param training_set_limit Maximum number of training rows retained before
#'   fitting. Use `Inf` to disable downsampling.
#' @param control A list from [control_tab_icl()].
#' @param ... Not currently used.
#' @return A `tab_icl` model object.
#' @export
tab_icl <- function(x, ...) {
  UseMethod("tab_icl")
}

#' @export
#' @rdname tab_icl
tab_icl.default <- function(x, ...) {
  cli::cli_abort("{.fn tab_icl} is not defined for {obj_type_friendly(x)}.")
}

#' @export
#' @rdname tab_icl
tab_icl.data.frame <- function(
  x,
  y,
  training_set_limit = Inf,
  control = control_tab_icl(),
  ...
) {
  check_number_whole(training_set_limit, min = 2, allow_infinite = TRUE)
  processed <- hardhat::mold(x, y)
  processed <- limit_training_set(processed, training_set_limit)
  tab_icl_bridge(processed, control, ...)
}

#' @export
#' @rdname tab_icl
tab_icl.matrix <- function(
  x,
  y,
  training_set_limit = Inf,
  control = control_tab_icl(),
  ...
) {
  check_number_whole(training_set_limit, min = 2, allow_infinite = TRUE)
  processed <- hardhat::mold(x, y)
  processed <- limit_training_set(processed, training_set_limit)
  tab_icl_bridge(processed, control, ...)
}

#' @export
#' @rdname tab_icl
tab_icl.formula <- function(
  formula,
  data,
  training_set_limit = Inf,
  control = control_tab_icl(),
  ...
) {
  check_number_whole(training_set_limit, min = 2, allow_infinite = TRUE)
  bp <- hardhat::default_formula_blueprint(
    intercept = FALSE,
    allow_novel_levels = FALSE,
    indicators = "none",
    composition = "tibble"
  )
  processed <- hardhat::mold(formula, data, blueprint = bp)
  processed <- limit_training_set(processed, training_set_limit)
  tab_icl_bridge(processed, control, ...)
}

#' @export
#' @rdname tab_icl
tab_icl.recipe <- function(
  x,
  data,
  training_set_limit = Inf,
  control = control_tab_icl(),
  ...
) {
  check_number_whole(training_set_limit, min = 2, allow_infinite = TRUE)
  processed <- hardhat::mold(x, data)
  processed <- limit_training_set(processed, training_set_limit)
  tab_icl_bridge(processed, control, ...)
}

limit_training_set <- function(processed, training_set_limit) {
  tr_ind <- sample_indicies(processed, size_limit = training_set_limit)
  if (length(tr_ind) > 0) {
    processed$predictors <- processed$predictors[tr_ind, , drop = FALSE]
    processed$outcomes <- processed$outcomes[tr_ind, , drop = FALSE]
  }
  processed
}

tab_icl_bridge <- function(processed, options, ...) {
  rlang::check_dots_empty()

  predictors <- processed$predictors
  outcome <- processed$outcomes[[1]]
  res <- tab_icl_impl(predictors, outcome, options)

  new_tab_icl(
    fit = res$fit,
    levels = res$lvls,
    training = res$train,
    logging = res$logging,
    blueprint = processed$blueprint
  )
}

tab_icl_impl <- function(x, y, opts) {
  tabicl <- import_tabicl()

  cls_wrapper <- function(...) {
    tabicl$TabICLClassifier(...)
  }
  reg_wrapper <- function(...) {
    tabicl$TabICLRegressor(...)
  }

  if (is.factor(y)) {
    mod_opts <- opts
    cls_cl <- rlang::call2("cls_wrapper", !!!mod_opts)
    mod_obj <- rlang::eval_bare(cls_cl)
    y_fit <- as.character(y)
    lvls <- levels(y)
  } else if (is.numeric(y)) {
    drop_args <- c(
      "class_shuffle_method",
      "softmax_temperature",
      "average_logits",
      "support_many_classes"
    )
    mod_opts <- opts[setdiff(names(opts), drop_args)]
    reg_cl <- rlang::call2("reg_wrapper", !!!mod_opts)
    mod_obj <- rlang::eval_bare(reg_cl)
    y_fit <- y
    lvls <- NULL
  } else {
    cli::cli_abort("`y` must be numeric for regression or a factor for classification.")
  }

  captured <- capture_python_or_r(model_fit <- try(mod_obj$fit(x, y_fit), silent = TRUE))
  py_msg <- captured$output

  if (inherits(model_fit, "try-error")) {
    msgs <- as.character(model_fit)
    cli::cli_abort("Model failed: {msgs}")
  } else {
    msgs <- character(0)
  }

  res <- list(
    fit = model_fit,
    lvls = lvls,
    train = dim(x),
    logging = c(r = msgs, py = py_msg)
  )
  class(res) <- c("tab_icl")
  res
}

capture_python_or_r <- function(expr) {
  value <- NULL
  output <- try(reticulate::py_capture_output(value <- eval.parent(substitute(expr))), silent = TRUE)
  if (inherits(output, "try-error")) {
    value <- eval.parent(substitute(expr))
    output <- character(0)
  }
  list(value = value, output = output)
}

#' @export
print.tab_icl <- function(x, ...) {
  type <- ifelse(is.null(x$levels), "Regression", "Classification")
  cli::cli_inform("TabICL {type} Model")
  cat("\n")
  cli::cli_inform("Training set\n\n")
  cli::cli_inform(c(i = "{x$training[1]} data point{?s}"))
  cli::cli_inform(c(i = "{x$training[2]} predictor{?s}"))

  if (!is.null(x$levels)) {
    cli::cli_inform(c(i = "class levels: {.val {x$levels}}"))
  }

  invisible(x)
}
