#!/usr/bin/env node
'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');

const HOME = os.homedir();
const REPO = path.resolve(__dirname, '..');
const OUTPUT = path.join(REPO, 'files');
const CHECK = process.argv.includes('--check');
const TEMP_OUTPUT = path.join(os.tmpdir(), `codex-setup-sync-${process.pid}`);
const TARGET = CHECK ? TEMP_OUTPUT : OUTPUT;

const codexFiles = ['config.toml', 'AGENTS.md', 'hooks.json'];
const codexDirectories = ['hooks', 'rules', 'agents'];
const personalSkills = ['caveman', 'check-dep', 'debug', 'mute', 'scan-secrets', 'unmute'];
const ignoredNames = new Set(['__pycache__', '.DS_Store']);

function ensureDir(directory) {
  fs.mkdirSync(directory, { recursive: true });
}

function stripRuntimeState(config) {
  const lines = config.split('\n');
  const kept = [];
  let skipping = false;

  for (const line of lines) {
    const table = line.match(/^\[([^\]]+)\]$/);
    if (table) {
      skipping = table[1] === 'hooks.state'
        || table[1].startsWith('hooks.state.')
        || table[1] === 'tui.model_availability_nux';
    }
    if (!skipping) kept.push(line);
  }

  return kept.join('\n').replace(/\n{3,}$/u, '\n');
}

function portableText(source, relativePath) {
  let text = fs.readFileSync(source, 'utf8').replaceAll(HOME, '{{HOME}}');
  if (relativePath === 'config.toml') text = stripRuntimeState(text);
  return text;
}

function copyPortable(source, destination, relativePath) {
  ensureDir(path.dirname(destination));
  fs.writeFileSync(destination, portableText(source, relativePath));
  const mode = fs.statSync(source).mode & 0o777;
  fs.chmodSync(destination, mode);
}

function copyDirectory(sourceRoot, destinationRoot, relativeRoot) {
  for (const entry of fs.readdirSync(sourceRoot, { withFileTypes: true })) {
    if (ignoredNames.has(entry.name) || entry.name.endsWith('.pyc')) continue;
    const source = path.join(sourceRoot, entry.name);
    const destination = path.join(destinationRoot, entry.name);
    const relativePath = path.join(relativeRoot, entry.name);
    if (entry.isDirectory()) copyDirectory(source, destination, relativePath);
    else copyPortable(source, destination, relativePath);
  }
}

function build(target) {
  fs.rmSync(target, { recursive: true, force: true });
  ensureDir(path.join(target, 'codex'));
  ensureDir(path.join(target, 'agent-skills'));

  for (const relativePath of codexFiles) {
    copyPortable(
      path.join(HOME, '.codex', relativePath),
      path.join(target, 'codex', relativePath),
      relativePath,
    );
  }

  for (const relativePath of codexDirectories) {
    copyDirectory(
      path.join(HOME, '.codex', relativePath),
      path.join(target, 'codex', relativePath),
      relativePath,
    );
  }

  for (const skill of personalSkills) {
    const source = path.join(HOME, '.agents', 'skills', skill);
    if (!fs.existsSync(source)) throw new Error(`Missing personal skill: ${skill}`);
    copyDirectory(source, path.join(target, 'agent-skills', skill), path.join('agent-skills', skill));
  }
}

function listFiles(root, base = root) {
  if (!fs.existsSync(root)) return [];
  const files = [];
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const absolute = path.join(root, entry.name);
    if (entry.isDirectory()) files.push(...listFiles(absolute, base));
    else files.push(path.relative(base, absolute));
  }
  return files.sort();
}

function assertParity(expected, actual) {
  const expectedFiles = listFiles(expected);
  const actualFiles = listFiles(actual);
  if (JSON.stringify(expectedFiles) !== JSON.stringify(actualFiles)) {
    throw new Error(`File list differs.\nExpected: ${expectedFiles.join(', ')}\nActual: ${actualFiles.join(', ')}`);
  }

  const differences = expectedFiles.filter((relativePath) => {
    const left = fs.readFileSync(path.join(expected, relativePath));
    const right = fs.readFileSync(path.join(actual, relativePath));
    return !left.equals(right);
  });

  if (differences.length) throw new Error(`Content differs: ${differences.join(', ')}`);
}

try {
  build(TARGET);
  if (CHECK) {
    assertParity(TEMP_OUTPUT, OUTPUT);
    console.log('Portable package files match live Codex setup.');
  } else {
    console.log(`Synced portable Codex setup into ${OUTPUT}`);
  }
} finally {
  if (CHECK) fs.rmSync(TEMP_OUTPUT, { recursive: true, force: true });
}
