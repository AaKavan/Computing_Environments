#!/bin/bash
# Recreate the geko_clean environment on a new machine.
#
#   git clone https://github.com/AaKavan/Computing_Environments.git
#   cd Computing_Environments
#   bash geko_clean_setup.sh                  # env named geko_clean
#   bash geko_clean_setup.sh my_env_name      # or pick a name
#
# GPU support is added automatically when `nvidia-smi` reports a GPU and the machine is
# Linux x86_64; otherwise you get a CPU-only install (same results, ~10-20x slower).
# Force either way with:  GEKO_GPU=1 bash geko_clean_setup.sh   /   GEKO_GPU=0 ...
#
# NOT handled here, because pip/conda cannot:
#   - an NVIDIA kernel driver new enough for CUDA 12. Check `nvidia-smi` first.
set -euo pipefail

ENV_NAME="${1:-geko_clean}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- should this be a GPU install? ---------------------------------------------------
if [ -n "${GEKO_GPU:-}" ]; then
    WANT_GPU="$GEKO_GPU"
elif [ "$(uname -s)" = "Linux" ] && [ "$(uname -m)" = "x86_64" ] && command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1; then
    WANT_GPU=1
else
    WANT_GPU=0
fi

echo "==> creating conda env '$ENV_NAME' (python 3.11)"
conda create -n "$ENV_NAME" python=3.11 -y

echo "==> installing pinned requirements"
conda run --no-capture-output -n "$ENV_NAME" pip install -r "$HERE/geko_clean_requirements.txt"

if [ "$WANT_GPU" = "1" ]; then
    echo "==> NVIDIA GPU detected -- installing CUDA 12 extras (~3 GB)"
    conda run --no-capture-output -n "$ENV_NAME" pip install -r "$HERE/geko_clean_requirements_gpu.txt"
else
    echo "==> no NVIDIA GPU (or GEKO_GPU=0) -- CPU-only install"
    echo "    geko still runs; expect ~10-20x longer per chain."
fi

# --- STPSF reference data (~450 MB), needed by webbpsf/stpsf to generate PSFs ---------
# Reuse a shared copy if one is already on this filesystem rather than making every user
# on the same cluster download the same bundle into their own quota.
echo "==> locating STPSF reference data"
# (on Puma the live copy is $HOME/data/stpsf-data -- checked first)
STPSF_DATA_PATH=""
for cand in "${STPSF_PATH:-}" "$HOME/data/stpsf-data" "/xdisk/egami/aakhtarkavan/data/stpsf-data"; do
    [ -n "$cand" ] || continue
    if [ -f "$cand/version.txt" ]; then
        echo "    reusing existing copy at $cand"
        STPSF_DATA_PATH="$cand"
        break
    fi
done
if [ -z "$STPSF_DATA_PATH" ]; then
    echo "    none found -- downloading via stpsf"
    STPSF_DATA_PATH=$(conda run -n "$ENV_NAME" python -c \
        "from stpsf.utils import auto_download_stpsf_data; print(auto_download_stpsf_data())" | tail -1)
fi

echo "==> registering Jupyter kernel '$ENV_NAME'"
conda run --no-capture-output -n "$ENV_NAME" python -m ipykernel install --user --name "$ENV_NAME" --display-name "$ENV_NAME"

# --- verify, rather than assume, that the install works ------------------------------
echo "==> verifying"
conda run --no-capture-output -n "$ENV_NAME" env STPSF_PATH="$STPSF_DATA_PATH" python - <<'PYEOF'
import sys
# ~/.local/lib/pythonX.Y/site-packages is on sys.path for EVERY conda env of that python
# version, so a stray `pip install --user` silently leaks into this env. Nothing there
# shadows geko's deps today, but say so rather than let it become a mystery later.
_leak = [p for p in sys.path if "/.local/lib/python" in p]
if _leak:
    print(f"    NOTE: user site-packages is on sys.path ({_leak[0]}).")
    print("          Run with PYTHONNOUSERSITE=1 if anything there ever shadows a pinned package.")
import jax, numpyro, numpy, geko
import numpyro.distributions as dist
from numpyro.infer import MCMC, NUTS
from geko.fitting import run_geko_fit     # noqa: F401
from pysersic import FitSingle            # noqa: F401
print(f"    python      {sys.version.split()[0]}")
print(f"    jax         {jax.__version__}   backend={jax.default_backend()}  devices={jax.devices()}")
print(f"    numpyro     {numpyro.__version__}")
print(f"    numpy       {numpy.__version__}")
print(f"    geko        {geko.__file__}")
assert jax.__version__ == "0.8.3", f"jax is {jax.__version__}, expected 0.8.3"
assert numpyro.__version__ == "0.19.0", f"numpyro is {numpyro.__version__}, expected 0.19.0"

# actually sample, so a broken jit / GPU plugin fails here rather than 40 minutes into a fit
def _model():
    numpyro.sample("x", dist.Normal(0.0, 1.0))
MCMC(NUTS(_model), num_warmup=5, num_samples=5, progress_bar=False).run(jax.random.PRNGKey(0))
print("    numpyro NUTS ran on this backend -- stack is working")
PYEOF

cat <<EOF

Done.

  conda activate $ENV_NAME
  export STPSF_PATH="$STPSF_DATA_PATH"      # add this to your shell profile

In notebooks, set STPSF_PATH *after* 'import webbpsf' -- webbpsf 2.0.0's compat shim
blanks it on import.
EOF
