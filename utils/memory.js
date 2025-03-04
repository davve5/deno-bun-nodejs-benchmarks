import { runtime } from '../config.js';

// Get current memory usage
export const getMemoryUsage = () => {
  if (runtime === 'Node.js') {
    const memUsage = process.memoryUsage();
    return {
      rss: memUsage.rss / 1024 / 1024,
      heapTotal: memUsage.heapTotal / 1024 / 1024,
      heapUsed: memUsage.heapUsed / 1024 / 1024,
      external: memUsage.external / 1024 / 1024
    };
  } else if (runtime === 'Deno') {
    const memUsage = Deno.memoryUsage();
    return {
      rss: memUsage.rss / 1024 / 1024,
      heapTotal: memUsage.heapTotal / 1024 / 1024,
      heapUsed: memUsage.heapUsed / 1024 / 1024,
      external: memUsage.external / 1024 / 1024
    };
  } else if (runtime === 'Bun') {
    const memUsage = process.memoryUsage();
    return {
      rss: memUsage.rss / 1024 / 1024,
      heapTotal: memUsage.heapTotal / 1024 / 1024,
      heapUsed: memUsage.heapUsed / 1024 / 1024,
      external: 0 // Bun doesn't expose external memory
    };
  }
};

// Format memory for display
export const formatMemory = (mem) => {
  return {
    rss: `${mem.rss.toFixed(2)} MB`,
    heapTotal: `${mem.heapTotal.toFixed(2)} MB`,
    heapUsed: `${mem.heapUsed.toFixed(2)} MB`,
    external: `${mem.external.toFixed(2)} MB`
  };
};

// Force garbage collection if available
export const forceGC = () => {
  if (runtime === 'Bun' && typeof Bun.gc === 'function') {
    Bun.gc(true);
  } else if (runtime === 'Node.js' && global.gc) {
    global.gc();
  } else if (runtime === 'Deno' && Deno.core && typeof Deno.core.gc === 'function') {
    Deno.core.gc();
  }
  // If GC is not available, we can't force it
};

