import { runtime } from './runtime.js';

export const readArgs = () => {
	let rawArgs = [];

	if (runtime === 'Node.js') {
		rawArgs = process.argv.slice(2); // Node.js skips first 2 elements (node & script)
	}
	else if (runtime === 'Deno') {
		rawArgs = Deno.args; // Deno has args directly
	}
	else if (runtime === 'Bun') {
		rawArgs = Bun.argv.slice(2); // Bun skips first 2 elements (runtime & script)
	}

	return Object.fromEntries(
		rawArgs.map(arg => {
			const [key, value] = arg.replace(/^-/, '').split('=');
			return [key, value ? Number(value) || value : true]; // Convert to number if possible
		})
	);
};