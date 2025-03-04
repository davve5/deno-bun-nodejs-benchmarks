#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Configuration - these can be overridden by environment variables
BENCHMARK_SCRIPT="./index.js"
ITERATIONS=${ITERATIONS:-50}
SAMPLE_RATE=${SAMPLE_RATE:-10}
RUNTIME=${RUNTIME:-"all"} # Default to all runtimes if not specified
CPU_LIMIT=${CPU_LIMIT:-"N/A"}
MEM_LIMIT=${MEM_LIMIT:-"N/A"}
RESULTS_DIR=${RESULTS_DIR:-"/test_results"}

# Create results directory if it doesn't exist
mkdir -p $RESULTS_DIR

# Function to print section header
print_header() {
  echo -e "\n${BLUE}=======================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}=======================================${NC}\n"
}

# Function to run a specific benchmark
run_benchmark() {
  local runtime=$1
  local cmd=$2
  local iterations=$3
  local sample_rate=$4
  local result_file="${RESULTS_DIR}/${runtime}_${CPU_LIMIT}_${MEM_LIMIT}.json"
  
  echo -e "${GREEN}Running $runtime benchmark:${NC} $iterations iterations, sampling every $sample_rate"
  echo -e "${GREEN}Hardware limits:${NC} CPU: $CPU_LIMIT, Memory: $MEM_LIMIT"
  echo -e "${GREEN}Results will be saved to:${NC} $result_file"
  
  # Verify runtime is available
  if [ "$runtime" == "node" ]; then
    if ! command -v node &> /dev/null; then
      echo -e "${YELLOW}Error: Node.js not found. Skipping Node.js benchmarks.${NC}"
      return 1
    fi
    echo "Node.js version: $(node --version)"
    echo "NPM version: $(npm --version)"
  elif [ "$runtime" == "deno" ]; then
    if ! command -v deno &> /dev/null; then
      echo -e "${YELLOW}Error: Deno not found. Skipping Deno benchmarks.${NC}"
      return 1
    fi
    echo "Deno version: $(deno --version | head -n 1)"
  elif [ "$runtime" == "bun" ]; then
    if ! command -v bun &> /dev/null; then
      echo -e "${YELLOW}Error: Bun not found. Skipping Bun benchmarks.${NC}"
      return 1
    fi
    echo "Bun version: $(bun --version)"
  fi
  
  # Execute the benchmark command with result file parameter
  if [ "$runtime" == "node" ]; then
    node $BENCHMARK_SCRIPT --iterations=$iterations --sampleEvery=$sample_rate --output=$result_file
  elif [ "$runtime" == "deno" ]; then
    deno run --allow-read --allow-write --allow-env $BENCHMARK_SCRIPT --iterations=$iterations --sampleEvery=$sample_rate --output=$result_file
  elif [ "$runtime" == "bun" ]; then
    bun $BENCHMARK_SCRIPT --iterations=$iterations --sampleEvery=$sample_rate --output=$result_file
  fi
  
  # Check if benchmark ran successfully
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}$runtime benchmark completed successfully${NC} (iterations=$iterations, sampleEvery=$sample_rate)"
    echo -e "${GREEN}Results saved to:${NC} $result_file\n"
    return 0
  else
    echo -e "${YELLOW}$runtime benchmark failed${NC} (iterations=$iterations, sampleEvery=$sample_rate)"
    return 1
  fi
}

# Main benchmarking function
run_all_benchmarks() {
  print_header "Starting JavaScript Runtime Benchmarks"
  print_header "Hardware Limits: CPU=$CPU_LIMIT, Memory=$MEM_LIMIT"
  
  # Check available runtimes
  if [ "$RUNTIME" = "all" ] || [ "$RUNTIME" = "node" ]; then
    if command -v node &> /dev/null; then
      run_benchmark "node" "node" $ITERATIONS $SAMPLE_RATE
    else
      echo -e "${YELLOW}Warning: Node.js not found. Skipping Node.js benchmarks.${NC}"
    fi
  fi
  
  if [ "$RUNTIME" = "all" ] || [ "$RUNTIME" = "deno" ]; then
    if command -v deno &> /dev/null; then
      run_benchmark "deno" "deno" $ITERATIONS $SAMPLE_RATE
    else
      echo -e "${YELLOW}Warning: Deno not found. Skipping Deno benchmarks.${NC}"
    fi
  fi
  
  if [ "$RUNTIME" = "all" ] || [ "$RUNTIME" = "bun" ]; then
    if command -v bun &> /dev/null; then
      run_benchmark "bun" "bun" $ITERATIONS $SAMPLE_RATE
    else
      echo -e "${YELLOW}Warning: Bun not found. Skipping Bun benchmarks.${NC}"
    fi
  fi
  
  print_header "All benchmarks completed!"
  echo "Results are available in the $RESULTS_DIR directory"
}

# Print environment information
echo -e "${BLUE}Environment Information:${NC}"
echo -e "Runtime: $RUNTIME"
echo -e "CPU Limit: $CPU_LIMIT"
echo -e "Memory Limit: $MEM_LIMIT"
echo -e "Iterations: $ITERATIONS"
echo -e "Sample Rate: $SAMPLE_RATE"
echo -e "Results Directory: $RESULTS_DIR"

# Execute the benchmarks
run_all_benchmarks