#!/bin/sh
# Run one experiment with given params

set -eu

DIRTY="${DIRTY:-10}"
BS="${BS:-1M}"
COUNT="${COUNT:-512}"
LABEL="${LABEL:-run}"
OUTDIR="${OUTDIR:-out}"

TARGET="syspro_ext4.txt"
APP_OUT="${OUTDIR}/${LABEL}_app.txt"
DISK_OUT="${OUTDIR}/${LABEL}_disk.txt"

echo "[*] Run ${LABEL}: dirty_ratio=${DIRTY}, bs=${BS}, count=${COUNT}"

mkdir -p "${OUTDIR}"
rm -f "${TARGET}" "${APP_OUT}" "${DISK_OUT}"

echo "${DIRTY}" > /proc/sys/vm/dirty_ratio

echo "[+] Start bpftrace"
stdbuf -oL bpftrace app_latency.bt > "${APP_OUT}" &
PID_APP=$!
stdbuf -oL bpftrace disk_io_latency.bt > "${DISK_OUT}" &
PID_DISK=$!

sleep 3

echo "[+] Run workload"
dd if=/dev/zero of="${TARGET}" bs="${BS}" count="${COUNT}" status=none
sync
sleep 3

echo "[+] Stop bpftrace"
kill -INT "$PID_APP" "$PID_DISK" 2>/dev/null || true
sleep 2
wait "$PID_APP" "$PID_DISK" 2>/dev/null || true

echo
echo "== ${LABEL}: App latency (us) =="
grep -A20 '@app_latency' "$APP_OUT" || echo "(no data)"
echo
echo "== ${LABEL}: Disk latency (us) =="
grep -A20 '@disk_io_latency' "$DISK_OUT" || echo "(no data)"
echo

