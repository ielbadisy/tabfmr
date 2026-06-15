# Fit a tabular foundation model

`fit_tabfm()` is a small convenience wrapper over
[`tab_pfn()`](https://tabpfn.tidymodels.org/dev/reference/tab_pfn.md)
and
[`tab_icl()`](https://tabpfn.tidymodels.org/dev/reference/tab_icl.md).
Use the explicit backend functions when you need backend-specific
arguments.

## Usage

``` r
fit_tabfm(x, ..., engine = c("tabpfn", "tabicl"))
```

## Arguments

- x:

  A data frame, matrix, recipe, or formula.

- ...:

  Arguments passed to the selected backend.

- engine:

  One of `"tabpfn"` or `"tabicl"`.

## Value

A fitted foundation-model object.
