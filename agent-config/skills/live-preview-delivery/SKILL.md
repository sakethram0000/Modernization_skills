---
name: live-preview-delivery
description: Use in Phase 7 to stand up a runnable preview of the modernized module, walk through the approved backlog's key flows against it, and prepare the final HITL Gate 4 sign-off request before merge.
phase: 7 — Live Preview & Delivery
---

# Live Preview & Delivery

## When to use
After `test-verifier` reports a passing suite. This is the final phase before merge —
its job is to let a human *see* the module working, not just trust the test report.

## Inputs
- Verified Phase 5 code + passing `test-report.md`
- `backlog.md` (for the flows to walk through)

## Process
1. **Stand up a runnable instance** of the modernized module — local run, sandbox
   container, or hosted preview environment, whichever the target project setup
   supports.
2. **Walk through every user story from `backlog.md`** against the live instance,
   confirming the behavior visually/functionally matches the Gherkin acceptance
   criteria — not just that automated tests pass.
3. **Capture the walkthrough** as a short summary mapping each story to what was
   demonstrated (screenshot references, recorded steps, or a narrated sequence,
   depending on what the environment supports).
4. **Prepare the Gate 4 sign-off request** per the standard approval protocol in
   `AGENTS.md` Section 4: what was built, the preview access instructions, the
   walkthrough summary, and any remaining known gaps carried over from `plan.md`'s
   open-questions list.
5. **On approval:** merge the modernized module into the target repository/branch and
   update the backlog to mark the module complete.
   **On rejection:** capture the specific concern and route back to the appropriate
   earlier phase (spec issue → Phase 4, implementation issue → Phase 5) rather than
   patching around it in this phase.

## Output artifact
- Running preview (link or local run instructions)
- Walkthrough summary (story → demonstrated behavior)
- The Gate 4 sign-off request itself

## Guardrails
- Do not merge without an explicit Gate 4 approval message, per the approval protocol —
  a clean test report is necessary but not sufficient for merge.
- If a known gap was accepted earlier (e.g., an ambiguous behavior explicitly waved
  through at Gate 3), restate it here rather than letting it silently disappear from
  view.
