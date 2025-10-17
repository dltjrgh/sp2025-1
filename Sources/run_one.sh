#!/bin/sh
set -eu

DIRTY="${1:-10}"
BS="${2:-1M}"
COUNT="${3:-512}"
LABEL="r${DIRTY}_${BS}_${COUNT}"
OUTDIR="${OUTDIR:-out}"
OUT="${OUTDIR}/${LABEL}.txt"
TARGET="syspro_ext4.txt"

mkdir -p "${OUTDIR}"
rm -f "${TARGET}" "${OUT}"

echo "[*] ${LABEL}: dirty=${DIRTY}, bs=${BS}, count=${COUNT}"

# Start bpftrace in background
bpftrace combined_latency.bt > "${OUT}" 2>&1 &
PID=$!

# Wait until tracing is fully attached
until grep -q "Attaching" "${OUT}" 2>/dev/null; do sleep 0.2; done
sleep 1  # ensure attach complete

# Run workload
echo "${DIRTY}" > /proc/sys/vm/dirty_ratio
dd if=/dev/zero of="${TARGET}" bs="${BS}" count="${COUNT}" status=none
sync

# Stop tracing and wait
kill -INT "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true

echo "[+] Saved: ${OUT}"
grep -A20 '@app_latency' "${OUT}" || echo "(no app data)"
grep -A20 '@disk_io_latency' "${OUT}" || echo "(no disk data)"
