import path from 'node:path';
import { fileExists, readJsonFromFile, saveJsonToFile } from '../utils/filesystem.js';

// Get paths to individual runtime result files based on the combinedOutputFile path
const getResultFilePaths = (combinedOutputFilePath) => {
  const dirPath = path.dirname(combinedOutputFilePath);

  return [
    `${dirPath}/benchmark-results-nodejs.json`,
    `${dirPath}/benchmark-results-deno.json`,
    `${dirPath}/benchmark-results-bun.json`
  ];
};

// Combine results from all runtimes
export const combineResults = async (combinedOutputFile) => {
  console.log('\n----- Combining results from all runtimes -----');

  const filePaths = getResultFilePaths(combinedOutputFile);
  const combinedResults = {
    date: new Date().toISOString(),
    runtimes: []
  };

  // Check for existing files and read them
  for (const filePath of filePaths) {
    if (await fileExists(filePath)) {
      console.log(`Reading results from ${filePath}`);
      const results = await readJsonFromFile(filePath);

      if (results) {
        // Extract just the necessary data (runtime and summary)
        combinedResults.runtimes.push({
          name: results.runtime,
          summary: results.summary,
          date: results.date,
          config: results.config
        });
      }
    } else {
      console.log(`File not found: ${filePath}`);
    }
  }

  // If we have results from all runtimes, save the combined file
  if (combinedResults.runtimes.length > 0) {
    await saveJsonToFile(combinedOutputFile, combinedResults);
    console.log(`Combined results saved to ${combinedOutputFile}`);
    return true;
  } else {
    console.log('No results found to combine');
    return false;
  }
};