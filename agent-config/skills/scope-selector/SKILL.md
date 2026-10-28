---
name: scope-selector
description: Use in Phase 3 to turn the approved knowledge graph into a ranked shortlist of candidate modules (strangler-fig approach) plus a whole-application option, and to surface the target-architecture question (server-rendered vs. SPA) ahead of HITL Gate 2.
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
5. **Always add the whole-application option** after the ranked modules. Write:
   - Size, from the `inventory.ps1` output in `discovery-report.md`: controllers, actions, `.aspx` pages, and `.svc`/`.asmx` services. Count them. Do not estimate.
   - The shared foundation it must build before any domain: the data context with every entity, authentication with every account screen in the repo, the layout and menu, and the home and error pages.
   - Anything that cannot be modernized as-is, such as a stop-list item, an external provider that needs keys the repo does not contain, or a third-party service. These become proposed out-of-scope rows. The human confirms them at Gate 3.
   - The risk: the Gate 3 files cover every domain and take longer to review.
6. **Recommend one option** as a default (a module or the whole application), but make clear it's a recommendation, not a
   pre-decision.
7. **Write two lists before the gate.** Dependencies: the shared data, APIs, and auth rules this module uses or that other modules use from it. Exclusions: every domain, controller, and behavior that this run will not modernize. For the whole-application option, the dependencies are the cross-domain edges in `knowledge-graph.md`, and the exclusions are only the proposed out-of-scope rows from step 5. Gate 2 is not ready until both lists are in the proposal for the recommended option.

## Output artifact
`runs/<RepoName>/modernized/scope-proposal.md`, also summarized in the HITL Gate 2 message:
- Ranked shortlist (2–4 domains) with rationale and blast-radius notes per domain
- The whole-application option with its counted size, shared foundation, and proposed exclusions
- Dependencies for the recommended option
- Explicit exclusions for this run
- UI-architecture trade-off summary with a recommendation
- How to reply: a module name, or `whole app`. After Gate 2, write `Scope: module` or `Scope: whole application` on the first line under the title.

## Guardrails
- Never proceed past this point (i.e., never start Phase 4 spec extraction) until
  🛑 HITL Gate 2 explicitly confirms the scope: a module name or `whole app`. UI stays server-rendered MVC unless they replied `use spa`.
- A whole-application run is one pass through Phases 4–7. Do not split it into several module runs unless the human changes the scope at Gate 2.
