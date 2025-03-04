import { runtime as _runtime } from '../config.js';

export const getRuntimeSpecificAPIs = async () => {
  let fs, fsPromises, path, crypto, performance;

  if (_runtime === 'Node.js') {
    const fsModule = await import('fs');
    fs = fsModule.default;
    fsPromises = fsModule.promises;

    const pathModule = await import('path');
    path = pathModule.default;

    const cryptoModule = await import('crypto');
    crypto = cryptoModule.default;

    const perfHooks = await import('perf_hooks');
    performance = perfHooks.performance;
  } else if (_runtime === 'Deno') {
    fs = Deno.fs;
    fsPromises = null;
    path = { join: (...paths) => paths.join('/') };
    crypto = globalThis.crypto;
    performance = globalThis.performance;
  } else if (_runtime === 'Bun') {
    fs = Bun.file;
    fsPromises = null;
    path = { join: (...paths) => paths.join('/') };
    crypto = globalThis.crypto;
    performance = globalThis.performance;
  } else {
    throw new Error('Unsupported runtime');
  }

  return { fs, fsPromises, path, crypto, performance };
};

// Ensure top-level await works in ES modules
export const runtime = _runtime;
export const runtimeAPIs = await getRuntimeSpecificAPIs();
export const { fs, fsPromises, path, crypto, performance } = runtimeAPIs;