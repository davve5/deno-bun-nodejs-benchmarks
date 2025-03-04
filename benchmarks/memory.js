import { benchmark, sleep } from '../utils/helpers.js';
import { forceGC } from '../utils/memory.js';
import { fsPromises, runtime } from '../utils/runtime.js';

// Run memory allocation/deallocation benchmark
const runMemoryAllocationBenchmark = async (iteration) => {
  return await benchmark('Memory Allocation/Deallocation', async () => {
    const iterations = 1000;
    const results = { allocations: 0, deallocations: 0 };

    for (let i = 0; i < iterations; i++) {
      // Allocate a random-sized buffer
      const size = Math.floor(Math.random() * 1000000) + 1000;
      let buffer;

      if (runtime === 'Node.js') {
        buffer = Buffer.alloc(size);
      } else {
        buffer = new Uint8Array(size);
      }

      // Fill buffer with random data
      for (let j = 0; j < size; j += 1000) {
        buffer[j] = Math.floor(Math.random() * 256);
      }

      results.allocations++;

      // Force deallocation
      buffer = null;
      results.deallocations++;

      // Occasionally force GC if available
      if (i % 100 === 0) {
        forceGC();
        await sleep(10); // Small delay to allow GC to run
      }
    }

    return `Completed ${results.allocations} allocations and ${results.deallocations} deallocations`;
  }, iteration);
};

// Run large JSON memory load benchmark
const runJsonLoadBenchmark = async (iteration) => {
  return await benchmark('Large JSON Memory Load', async () => {
    let jsonData;

    if (runtime === 'Node.js') {
      const data = await fsPromises.readFile('large-data.json', 'utf8');
      jsonData = JSON.parse(data);
    }
    else if (runtime === 'Deno') {
      const data = await Deno.readTextFile('large-data.json');
      jsonData = JSON.parse(data);
    }
    else if (runtime === 'Bun') {
      const file = Bun.file('large-data.json');
      const data = await file.text();
      jsonData = JSON.parse(data);
    }

    return `Loaded JSON with ${jsonData.data.length} entries`;
  }, iteration);
};

// Run all memory benchmarks
export const runMemoryBenchmarks = async (iteration) => {
  const results = {};
  results.allocationDeallocation = await runMemoryAllocationBenchmark(iteration);
  results.jsonLoad = await runJsonLoadBenchmark(iteration);
  return results;
};

