# Predict using TabICL

Predict using TabICL

## Usage

``` r
# S3 method for class 'tab_icl'
predict(object, new_data, type = NULL, ...)

# S3 method for class 'tab_icl'
augment(x, new_data, type = NULL, ...)
```

## Arguments

- object, x:

  A `tab_icl` object.

- new_data:

  A data frame or matrix of new predictors.

- type:

  For classification, one of `"class"` or `"prob"`. Defaults to all
  available prediction columns.

- ...:

  Not used.

## Value

A tibble of predictions.
