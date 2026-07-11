# Computing_Environments

Reproducible setup for the conda/pip environments used across my research pipelines --
one subfolder per environment, each with a pinned `requirements.txt` and a `setup.sh`
that recreates it on a new machine.

## Environments

- [`geko_clean/`](geko_clean/) -- upstream `astro-geko` (JAX/CUDA12 grism kinematics +
  pysersic morphology priors), used for sanity-checking against the modified local geko
  install.

## Usage

```bash
git clone https://github.com/AaKavan/Computing_Environments.git
bash Computing_Environments/geko_clean/setup.sh
```

See each subfolder's own README for environment-specific notes (GPU/CUDA requirements,
non-pip dependencies, etc.).
