#!/bin/bash
# Recreate the geko_clean conda env on a new machine from this folder's requirements.txt.
#
# Usage:
#   git clone <your-envs-repo> && cd <repo>/envs/geko_clean
#   bash setup.sh
#
# Everything geko/pysersic/jax-side is a pinned pip package (see requirements.txt, made
# with `pip freeze`) -- conda is only used here to get the right Python version. The one
# non-pip piece is STPSF's ~450MB reference data bundle, which stpsf itself knows how to
# fetch (see the auto_download_stpsf_data() call below) -- no manual download/path needed.
#
# NOT handled by this script (host-level, not installable via pip/conda):
#   - An NVIDIA GPU + driver new enough for CUDA 12 (the nvidia-*-cu12 pip wheels bundle
#     the CUDA *runtime*, but the host's kernel driver is still a hard requirement for GPU
#     use). CPU-only will still work for testing, just slower.
set -euo pipefail

ENV_NAME="${1:-geko_clean}"
PYTHON_VERSION="3.11"

conda create -n "$ENV_NAME" python="$PYTHON_VERSION" -y
conda run -n "$ENV_NAME" pip install -r "$(dirname "$0")/requirements.txt"

# STPSF reference data: reuse a shared copy if one is already on this filesystem (avoids
# every user on the same cluster re-downloading the same ~450MB into their own home dir,
# which can matter on a small home-dir quota) -- otherwise fetch a fresh copy via stpsf's
# own downloader. Either way, STPSF_DATA_PATH ends up pointing at a valid data dir.
KNOWN_SHARED_STPSF_DATA="/xdisk/egami/aakhtarkavan/kinematics_backups/pysersic_tutorial/stpsf_data/stpsf-data"
if [ -f "$KNOWN_SHARED_STPSF_DATA/version.txt" ]; then
    echo "Found existing shared STPSF data at $KNOWN_SHARED_STPSF_DATA -- reusing it instead of downloading a fresh copy."
    STPSF_DATA_PATH="$KNOWN_SHARED_STPSF_DATA"
else
    STPSF_DATA_PATH=$(conda run -n "$ENV_NAME" python3 -c "from stpsf.utils import auto_download_stpsf_data; print(auto_download_stpsf_data())" | tail -1)
fi

conda run -n "$ENV_NAME" python -m ipykernel install --user --name "$ENV_NAME" --display-name "$ENV_NAME"

echo ""
echo "Done. Add this to your shell profile (or run before each session) so notebooks/scripts find the PSF data:"
echo "  export STPSF_PATH=\"$STPSF_DATA_PATH\""
