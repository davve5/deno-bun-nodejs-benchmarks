import { benchmark } from '../utils/helpers.js';

// Run Fibonacci calculation benchmark
const runFibonacciBenchmark = async (iteration) => {
  return await benchmark('Recursive Fibonacci', async () => {
    // Recursive Fibonacci calculation
    function fibonacci(n) {
      if (n <= 1) return n;
      return fibonacci(n - 1) + fibonacci(n - 2);
    }

    const results = [];
    // Reduced iterations to avoid extremely long runtimes
    const iterations = 3;

    for (let i = 0; i < iterations; i++) {
      const n = 40; // Large enough to be CPU-intensive
      const result = fibonacci(n);
      results.push(result);
    }

    return `Calculated Fibonacci(40) ${iterations} times, result: ${results[0]}`;
  }, iteration);
};

// Run prime number calculation benchmark
const runPrimeCalculationBenchmark = async (iteration) => {
  return await benchmark('Prime Number Calculation', async () => {
    function isPrime(num) {
      if (num <= 1) return false;
      if (num <= 3) return true;
      if (num % 2 === 0 || num % 3 === 0) return false;

      let i = 5;
      while (i * i <= num) {
        if (num % i === 0 || num % (i + 2) === 0) return false;
        i += 6;
      }

      return true;
    }

    function findPrimes(max) {
      const primes = [];
      for (let i = 2; i <= max; i++) {
        if (isPrime(i)) {
          primes.push(i);
        }
      }
      return primes;
    }

    const primes = findPrimes(50000);
    return `Found ${primes.length} prime numbers up to 50,000`;
  }, iteration);
};

// Run all CPU benchmarks
export const runCPUBenchmarks = async (iteration) => {
  const results = {};
  results.fibonacci = await runFibonacciBenchmark(iteration);
  results.primeCalculation = await runPrimeCalculationBenchmark(iteration);
  return results;
};

