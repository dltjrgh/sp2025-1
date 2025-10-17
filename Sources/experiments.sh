#!/bin/bash

# This script orchestrates the series of experiments to measure latency.
# It calls run_one.sh for each parameter combination.

# Ensure the helper script is executable
chmod +x run_one.sh

echo "============================================================"
echo "               STARTING LATENCY MEASUREMENT                 "
echo "============================================================"

# --- Q1-1: Varying dirty_ratio ---
echo ""
echo "Part A: Varying dirty_ratio (bs=1M, count=512)"
./run_one.sh 10 1M 512
./run_one.sh 5 1M 512
./run_one.sh 1 1M 512


# --- Q1-2: Varying (bs, count) ---
echo ""
echo "Part B: Varying Block Size and Count (dirty_ratio=5)"
./run_one.sh 5 4k 131072
./run_one.sh 5 1M 512
./run_one.sh 5 64M 8

echo "============================================================"
echo "                  ALL EXPERIMENTS COMPLETE                  "
echo "============================================================"

