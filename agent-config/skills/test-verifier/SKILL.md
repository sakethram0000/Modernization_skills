---
name: test-verifier
description: Use in Phase 6 to run compare-parity.ps1 and dotnet test, then generate xUnit tests from the Gherkin in backlog.md. On failure, routes back to target-modernizer within a bounded retry budget.
disable-model-invocation: true
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
1. **Run the rendered parity check** and stop if it exits non-zero. The new app must already be running.
   `powershell -File agent-config/scripts/compare-parity.ps1 -LegacyRoot <old module> -ModernRoot <new module> -ParityMap <parity-map.md> -BaseUrl <http://host:port>`.
   The script checks controller action names, then fetches each Page URL and looks for that row's visible text in the HTML. It also requests every stylesheet linked from those pages. If the legacy layout styles the screen, a page with no stylesheet link fails, and a link that is not HTTP 200 with a non-empty body fails. A missing menu title, link, label, button, or stylesheet is a Phase 5 bug. Do not pass the check by comparing Razor source.
2. **Run** `dotnet restore`, `dotnet build`, and `dotnet test` on the new .NET 10 project. Paste the output into `test-report.md`.
3. **Generate one test per Gherkin scenario** in `backlog.md`. The test name must
   contain the `Scenario:` title. If `backlog.md` has no `Scenario:` lines, stop and
   return to Phase 4. Do not close Phase 6 with a shorter test list than the scenario list.
4. **Generate integration tests** for API endpoints/data access — covering the happy
   path and the validation/error cases captured in Phase 4. Those scenarios need their
   own tests too, with the scenario title in the test name.
5. **Re-run** `dotnet test` after the new tests exist.
6. **On any failure:**
   a. Inspect the failure (stack trace, assertion diff) and form a specific hypothesis
      about the cause.
   b. Hand the specific failure + hypothesis back to `target-modernizer` for a targeted
      fix — do not regenerate the whole module from scratch.
   c. Re-run. Repeat up to **3 total attempts**.
   d. If still failing after 3 attempts, **stop** and escalate to the human with: the
      specific failing scenario(s), what you tried, and your best hypothesis for why it's
      still failing. Do not keep looping silently.
7. **On success**, list every `Scenario:` title in `test-report.md` next to the test
   that covers it. The phase fails while any title has no passing test. Do not mark
   the module done from a passing `dotnet test` alone.

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
