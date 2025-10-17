#!/bin/bash

# This script runs a single dd experiment while tracing with bpftrace.
# It requires elevated privileges to run bpftrace and modify sysctl vm values.

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <dirty_ratio> <bs> <count>"
    exit 1
fi

# Assign arguments to variables
DIRTY_RATIO=$1
BS=$2
COUNT=$3
TARGET_FILE="syspro_ext4.txt"
BPF_SCRIPT="combined_latency.bt"
OUTPUT_FILE="results_dirty${DIRTY_RATIO}_bs${BS}_count${COUNT}.txt"

# --- Start of Experiment ---
echo "------------------------------------------------------------"
echo "Starting experiment: dirty_ratio=${DIRTY_RATIO}, bs=${BS}, count=${COUNT}"
echo "------------------------------------------------------------"

# 1. Set the dirty_ratio
echo "Setting dirty_ratio to ${DIRTY_RATIO}..."
echo ${DIRTY_RATIO} | sudo tee /proc/sys/vm/dirty_ratio > /dev/null
if [ $? -ne 0 ]; then
    echo "Error: Failed to set dirty_ratio. Are you running with sudo?"
    exit 1
fi

# 2. Start bpftrace in the background
echo "Starting bpftrace..."
sudo bpftrace ${BPF_SCRIPT} > ${OUTPUT_FILE} &
BPF_PID=$!

# Give bpftrace a moment to start up properly
sleep 2

# 3. Run the dd command to generate I/O
echo "Running dd if=/dev/zero of=${TARGET_FILE} bs=${BS} count=${COUNT}..."
dd if=/dev/zero of=${TARGET_FILE} bs=${BS} count=${COUNT} conv=fdatasync &> /dev/null

# 4. Ensure all cached data is written to disk
echo "Syncing filesystem..."
sync

# Allow a few seconds for bpftrace to capture completion events
sleep 5

# 5. Stop the bpftrace process gracefully
echo "Stopping bpftrace (PID: ${BPF_PID})..."
sudo kill -SIGINT ${BPF_PID}
wait ${BPF_PID} 2>/dev/null

# 6. Clean up the large file created by dd
echo "Cleaning up ${TARGET_FILE}..."
rm -f ${TARGET_FILE}

echo "Experiment finished. Results saved to ${OUTPUT_FILE}"
echo ""
