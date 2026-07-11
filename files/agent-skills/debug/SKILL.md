---
name: debug
description: Systematic debugging workflow. Use when a failure, error, flaky test, or unclear bug needs root cause analysis before fixing.
---

Systematic debugging. Never guess. Diagnose first. Follow these steps in order and do not jump to a fix before the root cause is understood.

## Steps

1. Capture the full failure: exact error, stack trace, command run, and recent changes via `git diff` or `git log`.
2. Read the whole error literally, including files, line numbers, and values.
3. Reproduce reliably with the smallest consistent trigger.
4. Trace the data flow backwards from the failure point until you find where the bad value first appears.
5. Form a specific, testable hypothesis.
6. Test the hypothesis with a log, breakpoint, or tiny experiment. If refuted, go back to tracing.
7. Fix the root cause only when you understand it.
8. Verify the original trigger and relevant tests.

## Red Flags

- Changes with no clear reason.
- Rapid successive attempts.
- A fix you cannot explain.
- Reverting versions hoping it helps.
- Suppressing the error with swallowed `catch`, `@ts-ignore`, or `eslint-disable`.
