#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print section header
print_header() {
  echo -e "\n${BLUE}=======================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}=======================================${NC}\n"
}

# Function to show usage information
show_usage() {
  echo -e "${YELLOW}Usage:${NC}"
  echo -e "  $0 [option]"
  echo -e "\n${YELLOW}Options:${NC}"
  echo -e "  all             Run all benchmarks for all runtimes and configurations"
  echo -e "  node            Run all benchmarks for Node.js only"
  echo -e "  deno            Run all benchmarks for Deno only"
  echo -e "  bun             Run all benchmarks for Bun only"
  echo -e "  250mhz_500mb    Run benchmarks for the 250MHz/500MB configuration only"
  echo -e "  500mhz_500mb    Run benchmarks for the 500MHz/500MB configuration only"
  echo -e "  1ghz_1gb        Run benchmarks for the 1GHz/1GB configuration only"
  echo -e "  2ghz_2gb        Run benchmarks for the 2GHz/2GB configuration only"
  echo -e "  2ghz_5gb        Run benchmarks for the 2GHz/5GB configuration only"
  echo -e "  node_1ghz_1gb   Run a specific runtime with a specific configuration"
  echo -e "  clean           Remove all Docker containers and generated results"
  echo -e "  help            Show this help message"
}

# Function to run specific benchmark
run_benchmark() {
  local service=$1
  print_header "Running benchmark: $service"
  
  # Ensure the results directory exists
  mkdir -p ./results
  
  # Run the specified service
  docker-compose up --build $service
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully completed benchmark: $service${NC}"
  else
    echo -e "${RED}Failed to complete benchmark: $service${NC}"
  fi
}

# Function to run all benchmarks
run_all_benchmarks() {
  print_header "Starting all benchmarks"
  
  # Ensure the results directory exists
  mkdir -p ./results
  
  # Run all services
  docker-compose up --build
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully completed all benchmarks${NC}"
  else
    echo -e "${RED}Some benchmarks may have failed${NC}"
  fi
}

# Function to run benchmarks for a specific runtime
run_runtime_benchmarks() {
  local runtime=$1
  print_header "Running all $runtime benchmarks"
  
  # Run services matching the runtime
  docker-compose up --build $(docker-compose config --services | grep "benchmark_${runtime}")
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully completed $runtime benchmarks${NC}"
  else
    echo -e "${RED}Some benchmarks may have failed${NC}"
  fi
}

# Function to run benchmarks for a specific configuration
run_config_benchmarks() {
  local config=$1
  print_header "Running all $config benchmarks"
  
  # Run services matching the configuration
  docker-compose up --build $(docker-compose config --services | grep "${config}")
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully completed $config benchmarks${NC}"
  else
    echo -e "${RED}Some benchmarks may have failed${NC}"
  fi
}

# Function to clean up resources
clean_resources() {
  print_header "Cleaning up resources"
  
  # Stop and remove containers
  docker-compose down
  
  # Remove results directory
  read -p "Do you want to remove all benchmark results? (y/n): " confirm
  if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    rm -rf ./results
    echo -e "${GREEN}Results directory removed${NC}"
  else
    echo -e "${YELLOW}Results directory kept${NC}"
  fi
}

# Main execution
if [ $# -eq 0 ]; then
  show_usage
  exit 1
fi

case "$1" in
  all)
    run_all_benchmarks
    ;;
  node)
    run_runtime_benchmarks "node"
    ;;
  deno)
    run_runtime_benchmarks "deno"
    ;;
  bun)
    run_runtime_benchmarks "bun"
    ;;
  250mhz_500mb)
    run_config_benchmarks "250mhz_500mb"
    ;;
  500mhz_500mb)
    run_config_benchmarks "500mhz_500mb"
    ;;
  1ghz_1gb)
    run_config_benchmarks "1ghz_1gb"
    ;;
  2ghz_2gb)
    run_config_benchmarks "2ghz_2gb"
    ;;
  2ghz_5gb)
    run_config_benchmarks "2ghz_5gb"
    ;;
  node_250mhz_500mb|deno_250mhz_500mb|bun_250mhz_500mb|\
  node_500mhz_500mb|deno_500mhz_500mb|bun_500mhz_500mb|\
  node_1ghz_1gb|deno_1ghz_1gb|bun_1ghz_1gb|\
  node_2ghz_2gb|deno_2ghz_2gb|bun_2ghz_2gb|\
  node_2ghz_5gb|deno_2ghz_5gb|bun_2ghz_5gb)
    run_benchmark "benchmark_$1"
    ;;
  clean)
    clean_resources
    ;;
  help)
    show_usage
    ;;
  *)
    echo -e "${RED}Unknown option: $1${NC}"
    show_usage
    exit 1
    ;;
esac

exit 0