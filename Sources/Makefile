# Makefile to run and clean the latency experiments

# The default target is 'run'
all: run

# 'run' target executes all experiments sequentially.
# It requires sudo privileges for bpftrace and sysctl modifications.
run:
	@echo "Making scripts executable..."
	@chmod +x experiments.sh run_one.sh
	@echo "Starting experiment suite. This will take some time..."
	@echo "You may be prompted for your password for sudo."
	@sudo ./experiments.sh
	@echo "\nSuite finished. Check the 'results_*.txt' files for histograms."

# 'clean' target removes all generated files.
clean:
	@echo "Cleaning up generated result files and temporary data..."
	@rm -f results_*.txt
	@rm -f syspro_ext4.txt
	@echo "Cleanup complete."

.PHONY: all run clean
