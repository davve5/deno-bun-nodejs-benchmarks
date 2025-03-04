import { benchmark } from '../utils/helpers.js';
import { fs, runtime } from '../utils/runtime.js';

// Run large file read benchmark
const runFileReadBenchmark = async (iteration) => {
  return await benchmark('Large File Read', async () => {
    const filePath = 'large-binary.dat';
    const chunkSize = 1024 * 1024; // 1MB chunks
    let totalRead = 0;

    if (runtime === 'Node.js') {
      const readStream = fs.createReadStream(filePath, { highWaterMark: chunkSize });

      await new Promise(resolve => {
        readStream.on('data', chunk => {
          totalRead += chunk.length;
        });
        readStream.on('end', resolve);
      });
    }
    else if (runtime === 'Deno') {
      const file = await Deno.open(filePath, { read: true });
      const buffer = new Uint8Array(chunkSize);

      let bytesRead;
      while ((bytesRead = await file.read(buffer)) !== null) {
        totalRead += bytesRead;
      }

      file.close();
    }
    else if (runtime === 'Bun') {
      const file = Bun.file(filePath);
      const arrayBuffer = await file.arrayBuffer();
      totalRead = arrayBuffer.byteLength;
    }

    return `Read ${totalRead / (1024 * 1024)} MB file`;
  }, iteration);
};

// Run all disk I/O benchmarks
export const runDiskIOBenchmarks = async (iteration) => {
  const results = {};
  results.fileRead = await runFileReadBenchmark(iteration);
  return results;
};

