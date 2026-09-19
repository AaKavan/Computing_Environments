# Computing_Environments

Reproducible setup for the conda/pip environments used across my research pipelines

## Environments

- **DINGO_env.yml** — for installing DINGO and all dependencies
```bash
conda env create -f DINGO_env.yml -n DINGO
```

- **geko_clean** — upstream `astro-geko` + `pysersic` + a pinned JAX/CUDA-12 stack, for the
  NIRCam grism kinematics notebooks. Use the setup script rather than the yml: it also
  installs the GPU extras, finds the STPSF reference data and registers the Jupyter kernel.
```bash
bash geko_clean_setup.sh              # or: bash geko_clean_setup.sh my_env_name
```
  GPU support is added automatically on Linux x86_64 when `nvidia-smi` reports a GPU;
  override with `GEKO_GPU=1` / `GEKO_GPU=0`. On a Mac, or any machine without an NVIDIA
  GPU, you get a CPU-only install — same results, roughly 10–20× slower per chain.

  The script ends by importing the stack and running a short numpyro NUTS chain, so a
  broken jit or CUDA plugin fails at setup instead of 40 minutes into a fit.

  Files: `geko_clean_setup.sh`, `geko_clean_requirements.txt` (pinned direct deps),
  `geko_clean_requirements_gpu.txt` (CUDA 12 extras), `geko_clean_env.yml` (conda-only path).

  After setup, add the line the script prints to your shell profile:
```bash
export STPSF_PATH="$HOME/data/stpsf-data"
```
  In notebooks set `STPSF_PATH` **after** `import webbpsf` — webbpsf 2.0.0's compat shim
  blanks it on import.

## Usage
```bash
conda env create -f environment.yml -n newenv
```

## Register as Kernel
```bash
python -m ipykernel install --user --name env_name --display-name "env_name"
```

## A note on pinning

`geko_clean_requirements.txt` is a hand-maintained list of *direct* dependencies, not a
`pip freeze`. The Puma env was built mostly from conda-forge, so `pip freeze` records those
packages as `@ file:///home/conda/...` paths that exist on no other machine — the older
`geko_clean/requirements.txt` in this repo's history has exactly that problem and cannot be
installed anywhere. The current list resolves on PyPI and lands on the same versions as the
working Puma env for every package that affects results.

To check what a fresh install would actually pull, without installing anything:
```bash
pip install --dry-run --report /tmp/r.json -r geko_clean_requirements.txt
```
