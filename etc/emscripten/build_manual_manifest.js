#!/usr/bin/env node
"use strict";

const fs = require('fs');
const path = require('path');

const BASE_DIR = process.cwd();
const ASSETS_DIR = path.join(BASE_DIR, 'assets');
const OUTPUT_FILE = path.join(BASE_DIR, 'manual_manifest.json');

function findSixFiles(dir, fileList = []) {
    const items = fs.readdirSync(dir);

    for (const item of items) {
        const itemPath = path.join(dir, item);
        const stat = fs.statSync(itemPath);

        if (stat.isDirectory()) {
            findSixFiles(itemPath, fileList);
        } else if (stat.isFile() && item.endsWith('.six')) {
            const relativePath = path.relative(BASE_DIR, itemPath);
            
            fileList.push(`/${relativePath}`);
        }
    }

    return fileList;
}

function main() {
    if (!fs.existsSync(ASSETS_DIR)) {
        console.error(`Error: Could not find 'assets' directory at ${ASSETS_DIR}`);
        process.exit(1);
    }

    try {
        console.log(`Scanning for .six files in: ${ASSETS_DIR}...`);
        
        const sixFiles = findSixFiles(ASSETS_DIR);
        
        fs.writeFileSync(OUTPUT_FILE, JSON.stringify(sixFiles, null, 4));
        
        console.log(`\nSuccess! Found ${sixFiles.length} files.`);
        console.log(`Wrote manifest to: ${OUTPUT_FILE}`);
        
    } catch (err) {
        console.error("Failed to generate manifest:", err);
        process.exit(1);
    }
}

main();