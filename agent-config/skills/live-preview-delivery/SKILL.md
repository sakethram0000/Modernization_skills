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
   criteria — not just that automated tests pass. Sign in through the real login page.
   In `Scope: whole application`, walk the shared foundation first (login, account
   screens, layout and menu), then each domain, then each cross-domain story, and group
   the walkthrough by domain.
3. **Capture the walkthrough** as a short summary mapping each story to what was
   demonstrated (screenshot references, recorded steps, or a narrated sequence,
   depending on what the environment supports).
4. **State the data source** in the walkthrough. A real database uses `Data source: <connection name>`. A prototype uses both `Classification: prototype` and `Data source: preview data is fake`, plus the seeded rows.
5. **Prepare the Gate 4 sign-off request** per `rules/hitl-checkpoints.md`. Repeat every gap accepted at Gate 3. In `Scope: whole application`, also repeat the parity map's out-of-scope table and the `-WholeApp` result. If authentication, real persistence, or an in-scope API has no passing test, stop and say the run cannot be accepted as finished. A prototype can be accepted only with the sentence `Classification: prototype`.
6. **On approval of a finished module:** do not merge and do not push. Tell the human the branch name and the
   exact `git merge` command, and update the backlog text to say the module is ready to merge. On approval of a prototype, update the backlog to say `Classification: prototype` and do not say it is ready to merge as the finished system.
   **On rejection:** capture the specific concern and route back to the appropriate
   earlier phase (spec issue → Phase 4, implementation issue → Phase 5) rather than
   patching around it in this phase.

## Output artifact
- Running preview (link or local run instructions)
- Walkthrough summary (story → demonstrated behavior)
- The Gate 4 sign-off request itself

## Guardrails
- Do not merge or push. Gate 4 approval of a finished module means the human may merge. A clean test report is necessary but not sufficient.
- If a known gap was accepted earlier, restate it here. Do not accept the run as finished while an in-scope authentication rule, real database write, or API still has no passing test.
- A prototype preview stays labeled `Classification: prototype`.
