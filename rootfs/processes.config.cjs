"use strict";

// Reuse the upstream API process definition so this image never drifts from the Flixer image it is built on,
// then run the two small helpers the single-container layout needs next to it.
const upstream = require("/opt/processes.config.cjs");

module.exports = {
	apps: [
		...upstream.apps,
		{
			// Redis is required by the Flixer setup wizard (sessions, rate limits, parties); it stays private to the container.
			name: "redis",
			script: "redis-server",
			args: "--bind 127.0.0.1 --protected-mode yes --dir /data/redis --appendonly yes",
			interpreter: "none",
			autorestart: true,
		},
		{
			// Serves the web app and proxies /api to the API on the same origin.
			name: "nginx",
			script: "nginx",
			args: "-e /tmp/nginx/error.log -g 'daemon off;'",
			interpreter: "none",
			autorestart: true,
		},
	],
};
