#!/bin/sh
# Run one latency experiment

set -eu

DIRTY="${DIRTY:-10}"
BS="${BS:-1M}"
COUNT="${COUNT:-512}"
LABEL="${LABEL:-run}"
OUTDIR="${OUTDIR:-out}"

TARGET="syspro_ext4.txt"
OUT="${OUTDIR}/${LABEL}.txt"

echo "[*] ${LABEL}: dirty=${DIRTY}, bs=${BS}, count=${COUNT}"
mkdir -p "${OUTDIR}"
rm -f "${TARGET}" "${OUT}"

echo "${DIRTY}" > /proc/sys/vm/dirty_ratio

bpftrace combined_latency.bt > "${OUT}" 2>&1 &
PID=$!
sleep 2
dd if=/dev/zero of="${TARGET}" bs="${BS}" count="${COUNT}" status=none
sync
kill -INT "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true

echo
echo "== ${LABEL}: results =="
grep -A20 '@app_latency' "${OUT}" || echo "(no app data)"
grep -A20 '@disk_io_latency' "${OUT}" || echo "(no disk data)"
echo

