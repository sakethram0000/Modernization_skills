# Implementation Plan Template (`plan.md`)

Produced by `requirement-extractor` in Phase 4; approved at HITL Gate 3; followed
(not reinterpreted) by `target-modernizer` in Phase 5.

---

## Module
[Name of the scoped module/domain being modernized]

## Target project structure
```
[proposed folder/project layout for the target .NET 8+ solution]
```

## Build order
1. Data layer — [EF Core DbContext/entities to create, mapped from which legacy
   models/tables]
2. Service/business logic layer — [services to create, and which legacy business rules
   they encapsulate]
3. API/controller layer — [endpoints or pages to create]
4. UI layer — [components/views to create; note whether SPA or server-rendered, per
   HITL Gate 2]

## Technology mapping applied
[Reference `AGENTS.md` Section 2 — note any module-specific deviations and why]

## Data migration notes
[Any schema changes required, and how they will be handled — must be human-approved
separately per `rules/legacy-guardrails.md`; write "none required" if not applicable]

## Open questions / ambiguous behavior
[Every item flagged during Phase 4 that needs a decision before or during Phase 5 —
this list must be explicitly addressed at HITL Gate 3, not silently carried forward]

## Out of scope for this run
[Anything adjacent that was noticed but deliberately excluded, per the scope-discipline
guardrail]
