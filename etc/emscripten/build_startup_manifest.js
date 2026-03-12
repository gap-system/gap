#!/usr/bin/env node
"use strict";

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 9999;
const BASE_DIR = process.cwd(); 
const LOG_FILE = path.join(BASE_DIR, 'startup_manifest.json');

const requestedFiles = new Set();
fs.writeFileSync(LOG_FILE, '[\n]');

const server = http.createServer((req, res) => {
    let urlPath = req.url.split('?')[0];
    if (urlPath === '/') {
        urlPath = '/index.html';
    }

    const filePath = path.join(BASE_DIR, urlPath);

    fs.readFile(filePath, (err, data) => {
        if (err) {
            console.error(`[404] Ignored missing file: ${urlPath}`);
            res.writeHead(404);
            res.end(`404: File not found`);
            return;
        }

        if (urlPath !== '/favicon.ico' && !requestedFiles.has(urlPath)) {
            requestedFiles.add(urlPath);
            
            const manifest = Array.from(requestedFiles);
            fs.writeFileSync(LOG_FILE, JSON.stringify(manifest, null, 4));
            
            console.log(`[Loaded & Logged] ${urlPath} (Total: ${requestedFiles.size})`);
        }

        let contentType = 'application/octet-stream';
        if (urlPath.endsWith('.html')) contentType = 'text/html';
        else if (urlPath.endsWith('.js')) contentType = 'text/javascript';
        else if (urlPath.endsWith('.wasm')) contentType = 'application/wasm';

        res.writeHead(200, {
            'Content-Type': contentType,
            'Cross-Origin-Opener-Policy': 'same-origin',
            'Cross-Origin-Embedder-Policy': 'require-corp',
            'Access-Control-Allow-Origin': '*'
        });
        
        res.end(data);
    });
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`\n Tracker running at http://localhost:${PORT}/`);
    console.log(`Serving files from: ${BASE_DIR}`);
    console.log(`Logging valid loaded files to: ${LOG_FILE}\n`);
});