---
dataset_info:
  features:
  - name: text
    dtype: large_string
  - name: source
    dtype: string
  - name: type
    dtype: string
  - name: metadata
    dtype: string
  splits:
  - name: train
    num_bytes: 1572760
    num_examples: 803
  download_size: 559119
  dataset_size: 1572760
configs:
- config_name: default
  data_files:
  - split: train
    path: data/train-*
---
