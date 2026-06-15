#' Fit a tabular foundation model
#'
#' `fit_tabfm()` is a small convenience wrapper over [tab_pfn()] and
#' [tab_icl()]. Use the explicit backend functions when you need backend-specific
#' arguments.
#'
#' @param x A data frame, matrix, recipe, or formula.
#' @param ... Arguments passed to the selected backend.
#' @param engine One of `"tabpfn"` or `"tabicl"`.
#' @return A fitted foundation-model object.
#' @export
fit_tabfm <- function(x, ..., engine = c("tabpfn", "tabicl")) {
  engine <- match.arg(engine)
  switch(
    engine,
    tabpfn = tab_pfn(x, ...),
    tabicl = tab_icl(x, ...)
  )
}
