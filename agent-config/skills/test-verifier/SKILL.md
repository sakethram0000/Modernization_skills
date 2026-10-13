---
name: test-verifier
description: Use in Phase 6 to generate and run xUnit unit/integration tests derived from the Gherkin acceptance criteria in backlog.md, verifying the Phase 5 output actually matches specified behavior. On failure, routes back to target-modernizer within a bounded retry budget.
phase: 6 — Verification & Test Execution
retry_budget: 3 attempts before escalating to human
---

# Test Verifier

## When to use
Immediately after `target-modernizer` produces code for the scoped module. This skill
does not modify implementation code directly — it verifies and reports; fixes happen by
looping back to `target-modernizer`.

## Inputs
- `backlog.md` (Gherkin acceptance criteria — the source of truth for what "correct"
  means)
- Phase 5 implementation code

## Process
1. **Generate unit tests** (xUnit + FluentAssertions/Moq) for business logic and service
   layers, one test (or test group) per Gherkin scenario in `backlog.md`.
2. **Generate integration tests** for API endpoints/data access — covering the happy
   path and the validation/error cases captured in Phase 4.
3. **Run the full suite.**
4. **On any failure:**
   a. Inspect the failure (stack trace, assertion diff) and form a specific hypothesis
      about the cause.
   b. Hand the specific failure + hypothesis back to `target-modernizer` for a targeted
      fix — do not regenerate the whole module from scratch.
   c. Re-run. Repeat up to **3 total attempts**.
   d. If still failing after 3 attempts, **stop** and escalate to the human with: the
      specific failing scenario(s), what you tried, and your best hypothesis for why it's
      still failing. Do not keep looping silently.
5. **On success**, compute simple coverage against the acceptance criteria: which
   Gherkin scenarios have a passing test, and flag any that don't have test coverage yet.

## Output artifact
- Test suite (checked into the same branch as the Phase 5 code)
- `test-report.md`: pass/fail summary, acceptance-criteria coverage, and (if applicable)
  the escalation note from step 4d

## Guardrails
- Never mark a scenario "passing" by weakening the test to match buggy behavior — if the
  implementation is wrong, it goes back to `target-modernizer`, not the test.
- Respect the retry budget. Looping indefinitely wastes review cycles and hides a
  problem that likely needs human judgment (e.g., a genuinely ambiguous legacy behavior
  that Phase 4 missed).
