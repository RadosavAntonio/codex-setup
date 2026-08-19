#!/usr/bin/env node
'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const HOME = os.homedir();
const CODEX_DIR = path.join(HOME, '.codex');
const CODEX_SKILLS_DIR = path.join(CODEX_DIR, 'skills');
const LEGACY_SKILLS_DIR = path.join(HOME, '.agents', 'skills');
const FILES_DIR = path.join(__dirname, '..', 'files');
const CONFIG_ONLY = process.argv.includes('--config-only');
const PERSONAL_SKILLS = ['caveman', 'check-dep', 'debug', 'mute', 'scan-secrets', 'unmute'];

const colour = {
  green: (value) => `\x1b[32m${value}\x1b[0m`,
  yellow: (value) => `\x1b[33m${value}\x1b[0m`,
  red: (value) => `\x1b[31m${value}\x1b[0m`,
  bold: (value) => `\x1b[1m${value}\x1b[0m`,
  dim: (value) => `\x1b[2m${value}\x1b[0m`,
};

function log(symbol, message) {
  console.log(`${symbol} ${message}`);
}

function ok(message) {
  log(colour.green('✓'), message);
}

function warn(message) {
  log(colour.yellow('⚠'), message);
}

function info(message) {
  log(colour.dim('·'), message);
}

function fail(message) {
  log(colour.red('✗'), message);
}

function ensureDir(directory) {
  fs.mkdirSync(directory, { recursive: true });
}

function commandExists(command) {
  return spawnSync('bash', ['-lc', `command -v ${command}`], {
    encoding: 'utf8',
  }).status === 0;
}

function walk(directory, base = directory) {
  if (!fs.existsSync(directory)) return [];
  const files = [];
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const absolute = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...walk(absolute, base));
    else files.push(path.relative(base, absolute));
  }
  return files;
}

function renderedSource(source) {
  return fs.readFileSync(source, 'utf8').replaceAll('{{HOME}}', HOME);
}

function installFile(sourceRoot, destinationRoot, relativePath) {
  const source = path.join(sourceRoot, relativePath);
  const destination = path.join(destinationRoot, relativePath);
  const rendered = renderedSource(source);
  ensureDir(path.dirname(destination));

  if (fs.existsSync(destination)) {
    const current = fs.readFileSync(destination, 'utf8');
    if (current === rendered) {
      info(`Unchanged: ${relativePath}`);
    } else {
      fs.copyFileSync(destination, `${destination}.bak`);
      fs.writeFileSync(destination, rendered);
      ok(`Updated: ${relativePath} (backup: ${relativePath}.bak)`);
    }
  } else {
    fs.writeFileSync(destination, rendered);
    ok(`Installed: ${relativePath}`);
  }

  if (/\.(sh|py)$/.test(relativePath)) fs.chmodSync(destination, 0o755);
}

function installTree(sourceRoot, destinationRoot) {
  for (const relativePath of walk(sourceRoot)) {
    installFile(sourceRoot, destinationRoot, relativePath);
  }
}

function backupLegacySkills() {
  for (const skill of PERSONAL_SKILLS) {
    const legacy = path.join(LEGACY_SKILLS_DIR, skill);
    if (!fs.existsSync(legacy)) continue;

    const backup = `${legacy}.legacy.bak`;
    if (fs.existsSync(backup)) {
      warn(`Legacy skill remains because backup already exists: ${legacy}`);
      continue;
    }

    try {
      fs.renameSync(legacy, backup);
      ok(`Backed up legacy skill: ${legacy} -> ${backup}`);
    } catch (error) {
      warn(`Could not back up legacy skill ${legacy}: ${error.message}`);
    }
  }
}

function checkRequirements() {
  if (!commandExists('codex')) {
    fail('Codex CLI not found. Install Codex before using this configuration.');
    process.exit(1);
  }
  ok('Codex CLI present');

  if (commandExists('jq')) ok('jq present');
  else warn('jq missing. Command inspection hooks will remain inactive until jq is installed.');

  if (commandExists('python3')) ok('python3 present');
  else warn('python3 missing. Transcript search and video FPS reminder will remain inactive.');

  if (commandExists('git')) ok('git present');
  else warn('git missing. Commit scanning and changed file verification will remain inactive.');

  if (commandExists('xcodebuild')) ok('Xcode present');
  else warn('Xcode missing. XcodeBuildMCP tools will be unavailable.');

  if (commandExists('adb')) ok('adb present');
  else warn('adb missing. Android MCP tools will be unavailable.');

  const androidServer = path.join(HOME, 'mcp-servers', 'android-mcp-server', 'dist', 'index.js');
  if (fs.existsSync(androidServer)) ok('Android MCP server present');
  else warn('Android MCP server missing. Follow the audited manual setup in the README before using it.');
}

function main() {
  console.log(colour.bold("\ncodex-setup: installing Antonio's Codex configuration\n"));

  if (!CONFIG_ONLY) {
    console.log(colour.bold('Requirements:'));
    checkRequirements();
  }

  console.log(colour.bold('\nCodex configuration:'));
  ensureDir(CODEX_DIR);
  installTree(path.join(FILES_DIR, 'codex'), CODEX_DIR);

  console.log(colour.bold('\nPersonal skills:'));
  ensureDir(CODEX_SKILLS_DIR);
  installTree(path.join(FILES_DIR, 'agent-skills'), CODEX_SKILLS_DIR);
  backupLegacySkills();

  console.log(colour.bold(colour.green('\nDone. Restart Codex to apply.')));
  console.log(colour.dim('Changed managed files were backed up to <file>.bak. Unmanaged files were not deleted.'));
  console.log(colour.yellow('Approve installed hooks when Codex first asks. Hook trust state is intentionally not shipped.'));
  console.log(colour.yellow('Sign in to Codex separately. Credentials and runtime data are intentionally not shipped.'));
}

main();
