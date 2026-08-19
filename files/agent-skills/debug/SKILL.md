---
name: debug
description: Systematic root cause debugging. Use when diagnosing a bug, when an error recurs after a fix attempt, or before making a speculative change.
---

# Debug systematically

1. Capture the exact failure, full stack, command, environment, and recent changes.
2. Reproduce it reliably with the smallest trigger.
3. Trace data and control flow backwards from the failure to the first incorrect state.
4. State one specific, testable hypothesis and predict its evidence.
5. Test the hypothesis with the smallest useful experiment.
6. Fix the root cause only after it is understood.
7. Re-run the original trigger and relevant regression tests.

Do not suppress errors, guess through rapid edits, or claim a fix you cannot explain.
