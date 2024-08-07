#!/bin/bash

# Places all outputs used for input in model execution into a single directory.
# Always called after successful chgres_cube.sh run.

set -x
set -e

MAIN_OUTPUT_DIR="/workdir/outputs/model_inputs"  # inside container

# Create the main output directory if it doesn't exist
mkdir -p "$MAIN_OUTPUT_DIR"

# Generate a unique subdirectory name using a timestamp
TIMESTAMP=$(date +%Y%m%d%H%M%S)
RUN_OUTPUT_DIR="${MAIN_OUTPUT_DIR}/run_${TIMESTAMP}"
mkdir -p "$RUN_OUTPUT_DIR"

cd $GRIDDIR  # set by chgres_cube.sh

cp C${res}_grid.tile?.nc /workdir/outputs/model_inputs/run_${TIMESTAMP}
cp C${res}_mosaic.nc /workdir/outputs/model_inputs/run_${TIMESTAMP}/grid_spec.nc

for file in C${res}_oro_data.tile?.nc; do
  cp "$file" "/workdir/outputs/model_inputs/run_${TIMESTAMP}/${file#C${res}_}"
done

cd $ICDIR
cd "$(ls -td -- */ | head -n 1)"  # use most recent directory

cp gfs_ctrl.nc /workdir/outputs/model_inputs/run_${TIMESTAMP}
cp gfs_data.tile?.nc /workdir/outputs/model_inputs/run_${TIMESTAMP}
cp sfc_data.tile?.nc /workdir/outputs/model_inputs/run_${TIMESTAMP}






