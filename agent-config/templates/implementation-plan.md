# Implementation Plan Template (`plan.md`)

Produced by `requirement-extractor` in Phase 4; approved at HITL Gate 3; followed
(not reinterpreted) by `target-modernizer` in Phase 5.

---

Scope: [module | whole application]

## Module
[Name of the scoped module/domain, or the application name in whole-application scope]

## Target project structure
```
[proposed folder/project layout for the target net10.0 solution]
```

## Build order
In whole-application scope, list the shared foundation first (data context with every
entity, authentication and account screens, layout and menu, home and error pages), then
each domain in dependency order. Repeat steps 1–4 under each heading. `dotnet build` must
pass after each one.

1. Data layer — [EF Core DbContext/entities to create, mapped from which legacy
   models/tables]
2. Service/business logic layer — [services to create, and which legacy business rules
   they encapsulate]
3. API/controller layer — [endpoints or pages to create]
4. UI layer — [components/views to create; note whether SPA or server-rendered, per
   HITL Gate 2]

## Technology mapping applied
[Reference `AGENTS.md` Section 2 — note any module-specific deviations and why]

## Persistence
Name the real database the new module will use, or write `Classification: prototype` and list every fake row. Do not leave this blank.

## Configuration and secrets
| Setting | Legacy source | New key | Value in this run |
|---|---|---|---|
| [connection string, JWT key, OAuth secret, SMTP, SMS] | [file and key, secret removed] | [`appsettings.json` key] | [empty, or labeled local development value] |

Write "none" if the repo has no secrets or external services.

## Data migration notes
[Any schema changes required, and how they will be handled — must be human-approved
separately per `rules/legacy-guardrails.md`; write "none required" if not applicable]

## Open questions / ambiguous behavior
[Every item flagged during Phase 4 that needs a decision before or during Phase 5 —
this list must be explicitly addressed at HITL Gate 3, not silently carried forward]

## Out of scope for this run
[Anything adjacent that was noticed but deliberately excluded, per the scope-discipline
guardrail. In whole-application scope, repeat the out-of-scope table from
`parity-map.md` here and in the open questions.]
