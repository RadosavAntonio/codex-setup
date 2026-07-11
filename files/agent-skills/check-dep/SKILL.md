---
name: check-dep
description: Research a dependency before adding it. Use proactively before yarn add, npm install, npm i, npm add, or pnpm add with package names.
---

Research a dependency before adding it to the project.

The user may provide a package name, or you should use this skill proactively before running `yarn add`, `npm install`, or adding any new dependency.

## Process

1. Check if it is already installed:

```bash
rg '"package-name"' package.json
```

2. Research the package:

- Search npm: `npm view <package> description version license homepage`
- Check bundle size with Bundlephobia or BundleJS.
- Check downloads, last publish date, open issues, and maintenance.
- Check release frequency and whether the package is actively maintained.

3. Evaluate alternatives:

- Are there lighter alternatives?
- Can existing project dependencies already do this?
- Can a few lines of code replace the dependency?
- For React Native, does it require native linking and support both iOS and Android?

4. Check compatibility:

- Does it work with the current project versions of React, React Native, and Node?
- Any known issues with the current stack?
- Does it have TypeScript types, built in or via `@types/`?

5. Present findings:

```text
Package: <name>
Version: <latest>
Size: <minified + gzipped>
Last published: <date>
Weekly downloads: <count>
Licence: <licence>
Types: <built-in / @types / none>
Native linking: <yes/no> (React Native only)
Alternatives: <list>
Recommendation: <add / use alternative / write it yourself>
```

6. Only proceed with installation after user approval.

## Red Flags

- Last published over 12 months ago.
- Fewer than 1,000 weekly downloads.
- No TypeScript support.
- Licence incompatible with the project.
- Large bundle size for what it does.
- Requires native linking for a simple feature.
- Many open issues with no maintainer responses.
