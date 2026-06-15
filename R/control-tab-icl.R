#' Controlling TabICL execution
#'
#' @param n_estimators Number of ensemble members.
#' @param norm_methods Normalization methods passed to the Python constructor.
#' @param feat_shuffle_method Feature permutation strategy.
#' @param class_shuffle_method Class permutation strategy for classification.
#' @param outlier_threshold Z-score threshold for outlier clipping.
#' @param softmax_temperature Temperature for classification probabilities.
#' @param average_logits Whether to average logits before probabilities.
#' @param support_many_classes Whether to enable TabICL's many-class support.
#' @param batch_size Number of ensemble members processed together.
#' @param kv_cache Whether to cache key-value projections for repeated inference.
#' @param model_path Optional local checkpoint path.
#' @param allow_auto_download Whether the Python package may download checkpoints.
#' @param checkpoint_version Optional checkpoint version.
#' @param device Inference device, such as `"cpu"`, `"cuda"`, or `NULL`.
#' @param use_amp Automatic mixed precision setting.
#' @param use_fa3 Flash Attention 3 setting.
#' @param offload_mode CPU/disk offloading mode.
#' @param disk_offload_dir Optional disk offload directory.
#' @param random_state Random seed.
#' @param n_jobs Number of PyTorch CPU threads.
#' @param verbose Whether Python should print inference details.
#' @param inference_config Optional fine-grained Python inference config.
#' @param ... Additional named arguments passed to the Python constructor.
#' @return A list with class `"control_tab_icl"`.
#' @export
control_tab_icl <- function(
  n_estimators = 8L,
  norm_methods = NULL,
  feat_shuffle_method = "latin",
  class_shuffle_method = "shift",
  outlier_threshold = 4.0,
  softmax_temperature = 0.9,
  average_logits = TRUE,
  support_many_classes = TRUE,
  batch_size = 8L,
  kv_cache = FALSE,
  model_path = NULL,
  allow_auto_download = TRUE,
  checkpoint_version = NULL,
  device = NULL,
  use_amp = "auto",
  use_fa3 = "auto",
  offload_mode = "auto",
  disk_offload_dir = NULL,
  random_state = 42L,
  n_jobs = NULL,
  verbose = FALSE,
  inference_config = NULL,
  ...
) {
  check_number_whole(n_estimators, min = 1)
  check_string(feat_shuffle_method)
  check_string(class_shuffle_method)
  check_number_decimal(outlier_threshold, min = 0)
  check_number_decimal(softmax_temperature, min = .Machine$double.eps)
  check_logical(average_logits)
  check_logical(support_many_classes)
  check_number_whole(batch_size, min = 1)
  check_logical(kv_cache)
  check_logical(allow_auto_download)
  check_number_whole(random_state)
  check_logical(verbose)
  if (!is.null(device)) check_string(device)
  if (!is.null(model_path)) check_string(model_path)
  if (!is.null(checkpoint_version)) check_string(checkpoint_version)
  if (!is.null(n_jobs)) check_number_whole(n_jobs, min = 1)

  args <- c(
    list(
      n_estimators = as.integer(n_estimators),
      norm_methods = norm_methods,
      feat_shuffle_method = feat_shuffle_method,
      class_shuffle_method = class_shuffle_method,
      outlier_threshold = outlier_threshold,
      softmax_temperature = softmax_temperature,
      average_logits = average_logits,
      support_many_classes = support_many_classes,
      batch_size = as.integer(batch_size),
      kv_cache = kv_cache,
      model_path = model_path,
      allow_auto_download = allow_auto_download,
      checkpoint_version = checkpoint_version,
      device = device,
      use_amp = use_amp,
      use_fa3 = use_fa3,
      offload_mode = offload_mode,
      disk_offload_dir = disk_offload_dir,
      random_state = as.integer(random_state),
      n_jobs = if (is.null(n_jobs)) NULL else as.integer(n_jobs),
      verbose = verbose,
      inference_config = inference_config
    ),
    rlang::list2(...)
  )
  args <- args[!vapply(args, is.null, logical(1))]
  class(args) <- "control_tab_icl"
  args
}

#' @export
print.control_tab_icl <- function(x, ...) {
  cli::cli_inform("control object for {.fn tab_icl}")
  cat("\n")
  lst <- purrr::map2(
    names(x),
    x,
    ~ cli::format_inline("{.arg {.x}}: {.val {.y}}")
  )
  names(lst) <- rep("*", length(lst))
  cli::cli_bullets(lst)
  invisible(x)
}
