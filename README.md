# Computing_Environments

Reproducible setup for the conda/pip environments used across my research pipelines

## Environments

-DINGO_env.yml: for installing DINGO and all dependencies
```bash
conda env create -f DINGO_env.yml -n DINGO
```

## Usage
```bash
conda env create -f environment.yml -n newenv
```

## Register as Kernel
```bash
python -m ipykernel install --user --name env_name --display-name "env_name"
```
