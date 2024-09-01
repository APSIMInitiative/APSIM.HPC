#!/usr/bin/env bash

###################################################################
# Constants
###################################################################

DATA_DIR=data
CONFIG_FILE=SWIM.apsimx
WEATHER_FILE=lincoln.met
OUT_DIR=output

###################################################################
# Main
###################################################################

for i in {1..3}; do
  echo "Copying $CONFIG_FILE to ${OUT_DIR}/${i}_${CONFIG_FILE}"
  cp ${DATA_DIR}/${CONFIG_FILE} ${OUT_DIR}/${i}_${CONFIG_FILE}
done

echo "Running Nextflow batch simulations"
nextflow run nextflow/batch_sims.nf -config nextflow/nextflow.config -profile reports
echo "Nextflow batch simulations completed"

echo "Output results"
ls $OUT_DIR