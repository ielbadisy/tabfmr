# Controlling TabICL execution

Controlling TabICL execution

## Usage

``` r
control_tab_icl(
  n_estimators = 8L,
  norm_methods = NULL,
  feat_shuffle_method = "latin",
  class_shuffle_method = "shift",
  outlier_threshold = 4,
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
)
```

## Arguments

- n_estimators:

  Number of ensemble members.

- norm_methods:

  Normalization methods passed to the Python constructor.

- feat_shuffle_method:

  Feature permutation strategy.

- class_shuffle_method:

  Class permutation strategy for classification.

- outlier_threshold:

  Z-score threshold for outlier clipping.

- softmax_temperature:

  Temperature for classification probabilities.

- average_logits:

  Whether to average logits before probabilities.

- support_many_classes:

  Whether to enable TabICL's many-class support.

- batch_size:

  Number of ensemble members processed together.

- kv_cache:

  Whether to cache key-value projections for repeated inference.

- model_path:

  Optional local checkpoint path.

- allow_auto_download:

  Whether the Python package may download checkpoints.

- checkpoint_version:

  Optional checkpoint version.

- device:

  Inference device, such as `"cpu"`, `"cuda"`, or `NULL`.

- use_amp:

  Automatic mixed precision setting.

- use_fa3:

  Flash Attention 3 setting.

- offload_mode:

  CPU/disk offloading mode.

- disk_offload_dir:

  Optional disk offload directory.

- random_state:

  Random seed.

- n_jobs:

  Number of PyTorch CPU threads.

- verbose:

  Whether Python should print inference details.

- inference_config:

  Optional fine-grained Python inference config.

- ...:

  Additional named arguments passed to the Python constructor.

## Value

A list with class `"control_tab_icl"`.
