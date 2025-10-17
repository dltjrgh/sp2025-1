#!/bin/sh
# Run experiment with given parameters:
#   DIRTY=<int> BS=<blocksize> COUNT=<count> LABEL=<name> OUTDIR=<dir>
# Example:
#   DIRTY=10 BS=1M COUNT=512 LABEL=Q1-1-r10 OUTDIR=out-2025... ./run_one.sh

set -eu

# ---- read params (with defaults for safety) ----
DIRTY="${DIRTY:-10}"
BS="${BS:-1M}"
COUNT="${COUNT:-512}"
LABEL="${LABEL:-run}"
OUTDIR="${OUTDIR:-out}"

TARGET="syspro_ext4.txt"
APP_OUT="${OUTDIR}/${LABEL}_app.txt"
DISK_OUT="${OUTDIR}/${LABEL}_disk.txt"

echo "[*] Run '${LABEL}': dirty_ratio=${DIRTY}, bs=${BS}, count=${COUNT}"

# 1) prepare output dir
mkdir -p "${OUTDIR}"
rm -f "${TARGET}" "${APP_OUT}" "${DISK_OUT}"

# 2) set vm.dirty_ratio
echo "${DIRTY}" > /proc/sys/vm/dirty_ratio

# 3) start both bpftrace scripts in background
BPFTRACE_BTF=/sys/kernel/btf/vmlinux bpftrace app_latency.bt > "${APP_OUT}" &
PID_APP=$!
BPFTRACE_BTF=/sys/kernel/btf/vmlinux bpftrace disk_io_latency.bt > "${DISK_OUT}" &
PID_DISK=$!

sleep 1

# 4) generate workload
echo "[*] dd if=/dev/zero of=${TARGET} bs=${BS} count=${COUNT}"
dd if=/dev/zero of="${TARGET}" bs="${BS}" count="${COUNT}" status=none
sync

# 5) stop bpftrace (SIGINT)
kill -INT "${PID_APP}" "${PID_DISK}" 2>/dev/null || true

sleep 1

echo "---- ${LABEL}: app latency (μs) ----"
grep -A20 '@app_latency' "${APP_OUT}" || true
echo "---- ${LABEL}: disk latency (μs) ----"
grep -A20 '@disk_io_latency' "${DISK_OUT}" || true
echo

