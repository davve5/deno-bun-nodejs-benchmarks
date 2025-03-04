#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Configuration
BENCHMARK_SCRIPT="./benchmark/index.js"
ITERATIONS_ARRAY=(50)
SAMPLE_RATES_ARRAY=(1 10)
GENERATE_TEST_FILES=true

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
  
  echo -e "${GREEN}Running $runtime benchmark:${NC} $iterations iterations, sampling every $sample_rate"
  
  # Execute the benchmark command
  if [ "$runtime" == "Node.js" ]; then
    $cmd $BENCHMARK_SCRIPT iterations=$iterations sampleEvery=$sample_rate
    # Only generate test files once
    GENERATE_TEST_FILES=false
  elif [ "$runtime" == "Deno" ]; then
    $cmd run --allow-read --allow-write --allow-env $BENCHMARK_SCRIPT iterations=$iterations sampleEvery=$sample_rate
  elif [ "$runtime" == "Bun" ]; then
    $cmd $BENCHMARK_SCRIPT iterations=$iterations sampleEvery=$sample_rate
  fi
  
  echo -e "${GREEN}$runtime benchmark completed${NC} (iterations=$iterations, sampleEvery=$sample_rate)\n"
}

# Main benchmarking function
run_all_benchmarks() {
  print_header "Starting JavaScript Runtime Benchmarks"
  
  # Check if required runtimes are installed
  if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Warning: Node.js not found. Skipping Node.js benchmarks.${NC}"
    NODE_AVAILABLE=false
  else
    NODE_AVAILABLE=true
  fi
  
  if ! command -v deno &> /dev/null; then
    echo -e "${YELLOW}Warning: Deno not found. Skipping Deno benchmarks.${NC}"
    DENO_AVAILABLE=false
  else
    DENO_AVAILABLE=true
  fi
  
  if ! command -v bun &> /dev/null; then
    echo -e "${YELLOW}Warning: Bun not found. Skipping Bun benchmarks.${NC}"
    BUN_AVAILABLE=false
  else
    BUN_AVAILABLE=true
  fi
  
  # Run benchmarks for each combination of iterations and sample rates
  for iterations in "${ITERATIONS_ARRAY[@]}"; do
    for sample_rate in "${SAMPLE_RATES_ARRAY[@]}"; do
      print_header "Benchmark: $iterations iterations, sampling every $sample_rate"
      
      # Run Node.js benchmarks
      if [ "$NODE_AVAILABLE" = true ]; then
        run_benchmark "Node.js" "node" $iterations $sample_rate
      fi
      
      # Run Deno benchmarks
      if [ "$DENO_AVAILABLE" = true ]; then
        run_benchmark "Deno" "deno" $iterations $sample_rate
      fi
      
      # Run Bun benchmarks
      if [ "$BUN_AVAILABLE" = true ]; then
        run_benchmark "Bun" "bun" $iterations $sample_rate
      fi
    done
  done
  
  print_header "All benchmarks completed!"
  echo "Results are available in the visualization/public/data/ directory"
}

# Execute the benchmarks
run_all_benchmarks