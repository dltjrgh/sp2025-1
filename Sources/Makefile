# =====================================
# Makefile: run full experiment matrix
# =====================================

SHELL := /bin/sh

.PHONY: all run clean

all:
	@echo "Usage:"
	@echo "  make run   - run Q1-1 and Q1-2 experiments"
	@echo "  make clean - remove generated outputs"

run:
	@chmod +x run_one.sh experiments.sh
	@./experiments.sh

clean:
	@rm -rf out-* syspro_ext4.txt
	@echo "[*] Cleaned."

