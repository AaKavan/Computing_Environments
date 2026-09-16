# Computing_Environments

Reproducible setup for the conda/pip environments used across my research pipelines

## Environments

-DINGO_env.yml: for installing DINGO and all dependencies

## Usage
```bash
conda env create -f environment.yml -n newenv
```

See each subfolder's own README for environment-specific notes (GPU/CUDA requirements,
non-pip dependencies, etc.).
