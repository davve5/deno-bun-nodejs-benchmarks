import fs from 'node:fs';

const getRuntimeName = () => {
	if (typeof Bun !== 'undefined') return 'Bun';
	if (typeof Deno !== 'undefined') return 'Deno';
	if (typeof process !== 'undefined') return 'Node.js';
	throw new Error('Unknown JavaScript runtime');
};

export const runtime = getRuntimeName();

export const createBenchmarkConfig = (iterations = 10, sampleEvery = 2) => {
	// Create directory path
	const dirPath = `../visualization/public/data/${iterations}-${sampleEvery}`;

	// Ensure the directory exists
	try {
		if (runtime === 'Node.js') {
			// For Node.js, use fs.mkdirSync with recursive option
			fs.mkdirSync(dirPath, { recursive: true });
		} else if (runtime === 'Deno') {
			// For Deno, use Deno.mkdirSync with recursive option
			Deno.mkdirSync(dirPath, { recursive: true });
		} else if (runtime === 'Bun') {
			// For Bun, use fs.mkdirSync with recursive option
			fs.mkdirSync(dirPath, { recursive: true });
		}
	} catch (error) {
		console.warn(`Warning: Could not create directory ${dirPath}: ${error.message}`);
	}

	// Get runtime name in lowercase without dots
	const runtimeFileName = runtime.toLowerCase().replace('.', '');

	// Create config with file paths
	const config = {
		iterations,
		sampleEvery,
		outputFile: `${dirPath}/benchmark-results-${runtimeFileName}.json`,
		combinedOutputFile: `${dirPath}/benchmark-results-combined.json`
	};

	// Make config globally available for the benchmark function
	globalThis.BENCHMARK_CONFIG = config;

	return config;
};