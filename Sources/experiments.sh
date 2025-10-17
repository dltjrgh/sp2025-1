#!/bin/sh
# Orchestrate all Q1 experiments in one go

set -eu

TS="$(date +%Y%m%d-%H%M%S)"
OUTDIR="out-${TS}"
echo "[*] Output dir: ${OUTDIR}"
mkdir -p "${OUTDIR}"

# ---------- Q1-1: varying dirty_ratio (bs=1M, count=512) ----------
DIRTY_LIST="10 5 1"
for D in $DIRTY_LIST; do
  DIRTY="$D" BS="1M" COUNT="512" LABEL="Q1-1-r${D}" OUTDIR="${OUTDIR}" ./run_one.sh
done

# ---------- Q1-2: varying (bs, count) at dirty_ratio=5 ----------
# 4k * 131072 (=512 MiB)
DIRTY=5 BS="4k"   COUNT="131072" LABEL="Q1-2-4k"  OUTDIR="${OUTDIR}" ./run_one.sh
# 1M * 512 (=512 MiB)
DIRTY=5 BS="1M"   COUNT="512"   LABEL="Q1-2-1M"  OUTDIR="${OUTDIR}" ./run_one.sh
# 64M * 8 (=512 MiB)
DIRTY=5 BS="64M"  COUNT="8"     LABEL="Q1-2-64M" OUTDIR="${OUTDIR}" ./run_one.sh

echo "[*] Done. Results saved under ${OUTDIR}/"
echo "[*] Files:"
ls -1 "${OUTDIR}"

