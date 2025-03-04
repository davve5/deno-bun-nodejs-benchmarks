import { runCPUBenchmarks } from './benchmarks/cpu.js';
import { runDiskIOBenchmarks } from './benchmarks/disk.js';
import { runMemoryBenchmarks } from './benchmarks/memory.js';
import { createBenchmarkConfig, runtime } from './config.js';
import { generateTestFiles } from './generators/test-files.js';
import {
  addIterationResults,
  calculateSummaryStatistics,
  initBenchmarkResults,
  saveResults
} from './results/collector.js';
import { combineResults } from './results/combiner.js';
import { readArgs } from './utils/cli.js';
import { sleep } from './utils/helpers.js';
// Import test-files generator
// Checking document 6 shows test-files.js is at the root level

// Main benchmark runner
const runBenchmarkSuite = async () => {
  const args = readArgs();
  console.log('Parsed arguments:', args);

  // Extract iterations and sampleEvery from args, with defaults
  const iterations = args.iterations || 10;
  const sampleEvery = args.sampleEvery || 2;

  // Create benchmark config with the extracted parameters
  const BENCHMARK_CONFIG = createBenchmarkConfig(iterations, sampleEvery);
  console.log(`Configured benchmarks with ${iterations} iterations, sampling every ${sampleEvery} iterations`);
  console.log(`Results will be saved to: ${BENCHMARK_CONFIG.outputFile}`);

  // Initialize results object
  const benchmarkResults = initBenchmarkResults();

  // Set benchmark config in results
  benchmarkResults.config = BENCHMARK_CONFIG;

  // Generate test files if requested
  if (args.generateTestFiles) {
    await generateTestFiles()
  }

  console.log(`Starting benchmarks for ${runtime}. Will run ${iterations} iterations`);

  // Run benchmarks for multiple iterations
  for (let i = 0; i < iterations; i++) {
    console.log(`\n===== STARTING BENCHMARK ITERATION ${i + 1}/${iterations} =====`);

    const iterationResults = {
      iteration: i + 1,
      timestamp: new Date().toISOString(),
      tests: {}
    };

    // Run memory benchmarks
    console.log("\nRunning memory benchmarks...");
    iterationResults.tests.memory = await runMemoryBenchmarks(i);

    // Run disk I/O benchmarks
    console.log("\nRunning disk I/O benchmarks...");
    iterationResults.tests.diskIO = await runDiskIOBenchmarks(i);

    // Run CPU benchmarks
    console.log("\nRunning CPU benchmarks...");
    iterationResults.tests.cpu = await runCPUBenchmarks(i);

    // Store iteration results
    addIterationResults(benchmarkResults, iterationResults);

    // Write intermediate results to keep data safe
    if (i % 10 === 0 || i === iterations - 1) {
      await saveResults(calculateSummaryStatistics(benchmarkResults), BENCHMARK_CONFIG.outputFile);
    }

    // Pause between iterations to let system stabilize
    if (i < iterations - 1) {
      console.log(`\nCompleted iteration ${i + 1}/${iterations}. Pausing before next iteration...`);
      await sleep(1000);
    }
  }

  // Calculate final summary statistics
  const finalResults = calculateSummaryStatistics(benchmarkResults);

  // Save final results
  await saveResults(finalResults, BENCHMARK_CONFIG.outputFile);
  console.log(`\nAll benchmarks completed! Results saved to ${BENCHMARK_CONFIG.outputFile}`);

  // Try to combine results if this is the last runtime being tested
  try {
    await combineResults(BENCHMARK_CONFIG.combinedOutputFile);
  } catch (error) {
    console.error('Error combining results:', error);
  }
};

// Start benchmarking
runBenchmarkSuite();