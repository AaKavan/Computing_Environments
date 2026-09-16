# Computing_Environments

Reproducible setup for the conda/pip environments used across my research pipelines --
one subfolder per environment, each with a pinned `requirements.txt` and a `setup.sh`
that recreates it on a new machine.

## Environments

- [`geko_clean/`](geko_clean/) Environment for running the unmodified [GEKO](https://github.com/angelicalola-danhaive/geko) code and all of it's dependencies. This environment heavily utlizies the [JAX](https://github.com/jax-ml/jax) + [CUDA](https://github.com/nvidia/cuda-samples) packages, and so the environment is heavily optimized for a Linux/Windows with the ability to install CUDA.

## Usage

```bash
git clone https://github.com/AaKavan/Computing_Environments.git
bash Computing_Environments/geko_clean/setup.sh
```

See each subfolder's own README for environment-specific notes (GPU/CUDA requirements,
non-pip dependencies, etc.).
