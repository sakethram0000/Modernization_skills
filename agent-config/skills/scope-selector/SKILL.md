---
name: scope-selector
description: Use in Phase 3 to turn the approved knowledge graph into a ranked shortlist of candidate modules for the first modernization increment (strangler-fig approach), and to surface the target-architecture question (server-rendered vs. SPA) ahead of HITL Gate 2.
phase: 3 — Scope Selection
---

# Scope Selector (Strangler-Fig Candidate Ranking)

## When to use
After `knowledge-graph.md` has been approved at HITL Gate 1. This skill does not choose
the module — it prepares a ranked shortlist and a clear rationale so the human can decide
quickly and with full information at HITL Gate 2.

## Inputs
- Approved `knowledge-graph.md` (domains + complexity/coupling scores).

## Process
1. **Rank domains** using a simple weighted view of: low coupling to other domains
   (easier to strangle in isolation), moderate-to-high business value (worth doing
   first), and manageable complexity (a good "prove the pipeline works" candidate isn't
   necessarily the hardest one).
2. **Shortlist 2–4 domains**, not just one — the human should be choosing between real
   options, not rubber-stamping a single recommendation.
3. **For each shortlisted domain, write a one-paragraph rationale**: why it's a good
   (or risky) first candidate, and what its blast radius is if something goes wrong
   (does it touch shared state used elsewhere?).
4. **Keep the screens the same by default.** Recommend ASP.NET Core MVC on `net10.0`
   so controller names, action names, and view fields stay as they are in the legacy module.
   Mention React only as an option the human must explicitly request by replying `use spa`.
   A SPA is a redesign, and it breaks the parity contract unless they accept that.
5. **Recommend one** as a default, but make clear it's a recommendation, not a
   pre-decision.
6. **Write two lists before the gate.** Dependencies: the shared data, APIs, and auth rules this module uses or that other modules use from it. Exclusions: every domain, controller, and behavior that this run will not modernize. Gate 2 is not ready until both lists are in the proposal.

## Output artifact
Scope proposal (short, presented directly in the HITL Gate 2 message — no separate file
required unless the team prefers one):
- Ranked shortlist (2–4 domains) with rationale and blast-radius notes per domain
- Dependencies for the recommended module
- Explicit exclusions for this run
- UI-architecture trade-off summary with a recommendation

## Guardrails
- Never proceed past this point (i.e., never start Phase 4 spec extraction) until
  🛑 HITL Gate 2 explicitly confirms both   the target module. UI stays server-rendered MVC unless they replied `use spa`.
