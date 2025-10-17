#!/bin/sh
# Run all experiments

set -eu

TS="$(date +%Y%m%d-%H%M%S)"
OUTDIR="out-${TS}"
mkdir -p "${OUTDIR}"
echo "[*] Output: ${OUTDIR}"

# Q1-1: varying dirty_ratio
for D in 10 5 1; do
  DIRTY=$D BS=1M COUNT=512 LABEL="Q1-1-r${D}" OUTDIR="${OUTDIR}" ./run_one.sh
done

# Q1-2: varying (bs, count)
DIRTY=5 BS=4k  COUNT=131072 LABEL="Q1-2-4k"  OUTDIR="${OUTDIR}" ./run_one.sh
DIRTY=5 BS=1M  COUNT=512    LABEL="Q1-2-1M"  OUTDIR="${OUTDIR}" ./run_one.sh
DIRTY=5 BS=64M COUNT=8      LABEL="Q1-2-64M" OUTDIR="${OUTDIR}" ./run_one.sh

echo "[*] Done. Results in ${OUTDIR}/"
