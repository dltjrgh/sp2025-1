#!/bin/sh
# Measure app latency first, then disk latency

set -eu

DIRTY="${DIRTY:-10}"
BS="${BS:-1M}"
COUNT="${COUNT:-512}"
LABEL="${LABEL:-run}"
OUTDIR="${OUTDIR:-out}"

TARGET="syspro_ext4.txt"
APP_OUT="${OUTDIR}/${LABEL}_app.txt"
DISK_OUT="${OUTDIR}/${LABEL}_disk.txt"

echo "[*] ${LABEL}: dirty_ratio=${DIRTY}, bs=${BS}, count=${COUNT}"

mkdir -p "${OUTDIR}"
rm -f "${TARGET}" "${APP_OUT}" "${DISK_OUT}"

echo "${DIRTY}" > /proc/sys/vm/dirty_ratio

# app latency
echo "[+] app_latency.bt"
bpftrace app_latency.bt > "${APP_OUT}" &
PID=$!
sleep 2
dd if=/dev/zero of="${TARGET}" bs="${BS}" count="${COUNT}" status=none
sync
sleep 2
kill -INT "${PID}" 2>/dev/null || true
wait "${PID}" 2>/dev/null || true

echo
echo "== ${LABEL}: app latency (us) =="
grep -A20 '@app_latency' "${APP_OUT}" || echo "(no data)"
echo

# disk latency
echo "[+] disk_io_latency.bt"
rm -f "${TARGET}"
bpftrace disk_io_latency.bt > "${DISK_OUT}" &
PID=$!
sleep 2
dd if=/dev/zero of="${TARGET}" bs="${BS}" count="${COUNT}" status=none
sync
sleep 2
kill -INT "${PID}" 2>/dev/null || true
wait "${PID}" 2>/dev/null || true

echo
echo "== ${LABEL}: disk latency (us) =="
grep -A20 '@disk_io_latency' "${DISK_OUT}" || echo "(no data)"
echo
