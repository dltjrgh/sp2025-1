#!/bin/sh
# Run all latency experiments (Q1-1, Q1-2)

set -eu

TS="$(date +%Y%m%d-%H%M%S)"
OUTDIR="out-${TS}"
mkdir -p "${OUTDIR}"

echo "[*] Output directory: ${OUTDIR}"

# Q1-1: varying dirty_ratio
for D in 10 5 1; do
  ./run_one.sh "$D" 1M 512
done

# Q1-2: varying (bs, count) with dirty_ratio=5
./run_one.sh 5 4k 131072
./run_one.sh 5 1M 512
./run_one.sh 5 64M 8

echo "[*] All experiments completed."
echo "[*] Results saved in ${OUTDIR}/"
