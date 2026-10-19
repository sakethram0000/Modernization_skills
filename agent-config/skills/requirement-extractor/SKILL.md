---
name: requirement-extractor
description: Use in Phase 4 to reverse-engineer the selected legacy module's actual behavior — including logic buried in code-behind, WCF services, and stored procedures — into plain-language user stories, Gherkin acceptance criteria, and an implementation plan. This is the last skill before any code is written.
phase: 4 — Specs & Backlog Generation
templates_used: [user-story.md, gherkin-feature.md, implementation-plan.md]
---

# Requirement Extractor

## When to use
After the target module and UI approach are confirmed at HITL Gate 2. This is the most
important skill in the pipeline for avoiding silent behavior drift — treat it as
"reverse-engineering," not "summarizing."

## Inputs
- Legacy source for the scoped module only (code-behind/controllers, services, stored
  procedures, validation logic, any business-rule constants/config).
- `discovery-report.md` and `knowledge-graph.md` for context.

## Process
1. **Walk every user-facing flow in the module** (page loads, form submits, service
   calls) and note what the legacy code actually does — including validation rules,
   error paths, and edge cases, not just the happy path.
2. **Trace business rules to their true source.** If a stored procedure computes a
   value, or a WCF service applies a business rule, that rule belongs in the spec — don't
   describe only the UI layer's behavior and miss logic hiding lower down.
3. **Write one user story per distinct capability**, using `templates/user-story.md`.
   Each story should be small enough that a reviewer can verify it against the legacy
   app in a few minutes.
4. **Write Gherkin acceptance criteria per story**, using `templates/gherkin-feature.md`.
   Cover the happy path, validation/error cases, and any edge cases found in step 1–2.
   `backlog.md` is not done until it contains a `Scenario:` line for each of those cases.
   A short summary with no `Scenario:` lines does not pass Phase 4. Do not start Phase 5.
5. **List every ambiguous or undocumented behavior explicitly** — do not resolve
   ambiguity by guessing what "makes sense." Examples: unclear validation thresholds,
   dead code that might or might not be intentionally unreachable, inconsistent
   behavior between two code paths that should be equivalent.
6. **Write `parity-map.md`** using `templates/parity-map.md`. One row per controller action,
   one row per label, input name, column header, and button, and one row per layout title,
   menu link, and footer line found in this repo. Each row needs the page URL where the
   rendered check will look. Copy the words from this repo. Do not reuse words from a
   previous run.
7. **Write the implementation plan** using `templates/implementation-plan.md`: target
   project structure for `net10.0`, build order (data → services → controllers → views),
   the mapping from Section 2 of `AGENTS.md` for this module, and a Persistence section that either names the real database or says `Classification: prototype` and lists every fake row.

## Output artifacts
- `backlog.md` — all user stories + Gherkin acceptance criteria for the scoped module
- `plan.md` — implementation plan, build order, and the open-questions list
- `parity-map.md` — old controller/action/field names that must exist on .NET 10

## Guardrails
- Every ambiguous-behavior item found must appear in `plan.md`'s open-questions list —
  this list is what gets explicitly resolved (or explicitly accepted as a known gap) at
  🛑 HITL Gate 3, before Phase 5 coding starts.
- Do not begin Phase 5 code generation until Gate 3 is approved, even if the specs
  "look obviously right" — parity bugs are cheaper to catch here than after generation.
- Do not hand `backlog.md` to Gate 3 when it has no `Scenario:` lines. Count them.
  Each story needs the happy path and every error case the legacy code actually has
  (missing id, unknown row, failed save, validation text).
