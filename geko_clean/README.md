# geko_clean

Pinned environment for the "clean env" geko sanity-check notebook (upstream `astro-geko`
from PyPI, no local modifications) -- JAX/CUDA12 grism kinematics fitting + pysersic
morphology priors.

## Setup on a new machine

```bash
bash setup.sh                 # creates conda env "geko_clean"
# or: bash setup.sh my_env_name
```

This installs Python 3.11 via conda, then every other package -- including `astro-geko`
itself -- via pip, pinned to the exact versions in `requirements.txt` (generated with
`pip freeze` from a working install). It also sorts out STPSF's reference data (used by
`webbpsf`/`stpsf` to generate PSFs): reuses the shared copy already on the Puma cluster if
present, otherwise downloads a fresh copy to `~/data/stpsf-data`.

## What's NOT covered here

- **GPU driver**: the `nvidia-*-cu12` pip wheels bundle the CUDA 12 *runtime*, but the
  machine still needs an NVIDIA GPU with a driver new enough to support CUDA 12. Nothing
  pip/conda can install fixes a missing/old driver -- check with `nvidia-smi` first.
- **`STPSF_PATH`**: set this env var (setup.sh prints the line to add to your shell
  profile) so geko_clean notebooks/scripts can find the downloaded PSF data. Point at
  `~/data/stpsf-data` unless you downloaded it elsewhere.

## Regenerating requirements.txt after installing something new

```bash
conda activate geko_clean
pip freeze > requirements.txt
```
