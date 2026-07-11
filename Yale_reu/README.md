# Yale_reu

Environment for my Summer Fellowship at Yale University (Dorrit Hoffleit Research
Fellowship, Summer 2026). A fairly complete environment for astronomy, with a focus on
observational stellar astrophysics -- RR Lyrae and other variable stars, radial velocity
measurements, and light curve analysis -- using the Keck/DEIMOS instrument.

## Setup on a new machine

```bash
bash setup.sh                 # creates conda env "Yale_reu"
# or: bash setup.sh my_env_name
```

This installs Python via conda, then every other package via pip, pinned to the exact
versions in `requirements.txt`.

<!-- TODO: fill in any non-pip dependencies, GPU/instrument-specific notes, etc.,
     the way geko_clean's README documents STPSF_PATH and the CUDA driver requirement. -->

## Regenerating requirements.txt after installing something new

```bash
conda activate Yale_reu
pip freeze > requirements.txt
```
