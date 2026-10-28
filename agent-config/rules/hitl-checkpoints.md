# HITL Checkpoint Protocol

There are exactly four mandatory human checkpoints in this pipeline. This file defines
the mechanics; `AGENTS.md` Section 5 defines what triggers each one.

| Gate | After phase | What's being approved |
|---|---|---|
| HITL 1 | 2 — Knowledge Graph | Domain boundaries are correct |
| HITL 2 | 3 — Scope Selection | Scope (one module, or `whole app`) + UI architecture approach |
| HITL 3 | 4 — Specs & Backlog | Acceptance criteria + implementation plan |
| HITL 4 | 7 — Live Preview | Final functional sign-off before merge |

## At every gate, you must:
1. Stop all further action — do not begin the next phase's work, even preparatory work.
2. Post a summary using this structure:
   - **Phase completed:** [name]
   - **What I did:** 2–5 bullets
   - **Artifacts produced:** file paths / links
   - **Decisions needed from you:** explicit numbered questions or options
   - **Risks / open questions:** anything ambiguous found
3. Wait for one of these explicit responses:
   - `approved` / `approved with changes: ...` → proceed, applying noted changes first
   - `rework: ...` → revise current phase's artifact, re-present, do not advance
   - `reject` → stop the pipeline for this run, await new direction

   At Gate 2, `approved` must name the scope: a module name or `whole app`. If it names
   neither, ask which one before starting Phase 4.
4. Never interpret silence, a partial reply, or an unrelated message as approval. If a
   reply is ambiguous, ask a direct clarifying question instead of proceeding.

## Gate 4 cannot close a gap that is still unverified

Before asking for Gate 4 approval, repeat every gap that Gate 3 accepted.

Do not treat `approved` as acceptance of a finished modernization when any of these was in the approved scope and has no passing test:

- authentication behavior
- persistence in the real database
- an API that belongs to the scoped module

In `Scope: whole application`, these apply to every domain in scope. Also repeat the out-of-scope table from `parity-map.md`, and do not call the application finished while `compare-parity.ps1 -WholeApp` fails or a cross-domain dependency has no passing test.

If `plan.md` says `Classification: prototype`, Gate 4 can accept the preview only as a prototype. The summary must say `Classification: prototype`. Do not say the module is ready to merge as the finished system.

## Escalations outside the four planned gates
Two situations also require stopping and asking, even mid-phase:
- **Phase 6 test failures** that persist past the 3-attempt retry budget (see
  `skills/test-verifier/SKILL.md`).
- **Any discovery, mid-phase, that contradicts an earlier approval** (e.g., Phase 5
  reveals that an approved spec is infeasible) — surface it immediately rather than
  quietly deviating from the approved plan.
