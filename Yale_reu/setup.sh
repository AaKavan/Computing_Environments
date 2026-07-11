#!/bin/bash
# Recreate the Yale_reu conda env on a new machine from this folder's requirements.txt.
#
# Usage:
#   git clone <your-envs-repo> && cd <repo>/Yale_reu
#   bash setup.sh
#
# TODO: adjust PYTHON_VERSION below to match what Yale_reu actually pins, and add any
# non-pip setup steps here (e.g. instrument-specific data/config, the way geko_clean's
# setup.sh handles STPSF reference data).
set -euo pipefail

ENV_NAME="${1:-Yale_reu}"
PYTHON_VERSION="3.11"

conda create -n "$ENV_NAME" python="$PYTHON_VERSION" -y
conda run -n "$ENV_NAME" pip install -r "$(dirname "$0")/requirements.txt"

conda run -n "$ENV_NAME" python -m ipykernel install --user --name "$ENV_NAME" --display-name "$ENV_NAME"

echo ""
echo "Done."
