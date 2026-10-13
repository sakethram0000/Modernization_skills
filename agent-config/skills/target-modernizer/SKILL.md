---
name: target-modernizer
description: Use in Phase 5 to generate .NET 8+ (ASP.NET Core) implementation code for the module specified in the approved backlog.md and plan.md, applying the standard .NET Framework 4.6.1 -> .NET 8 mapping rules and architecture constraints.
phase: 5 — Code Modernization
requires_approval: backlog.md and plan.md must be approved at HITL Gate 3 before this skill runs
---

# Target Modernizer (.NET Framework 4.6.1 → .NET 8+)

## When to use
Only after `backlog.md` and `plan.md` are approved at HITL Gate 3. This skill implements
exactly what those documents specify — it is not a place to make new design decisions.

## Inputs
- Approved `backlog.md` (user stories + Gherkin acceptance criteria)
- Approved `plan.md` (build order, project structure)
- `rules/target-architecture.md` (non-negotiable target constraints)

## Process
1. **Scaffold the target project** per `plan.md`: SDK-style `.csproj`, `Program.cs`
   minimal hosting model, `appsettings.json`/`appsettings.Development.json`.
2. **Implement in the plan's stated order** — typically:
   a. **Data layer** — EF Core `DbContext` + entity classes, mapped from EF6
      models/`.edmx` or from raw SQL/stored-procedure logic identified in discovery.
      Preserve column/table names unless the plan explicitly calls for a rename.
   b. **Service/business logic layer** — port business rules from Phase 4's stories,
      including logic that was previously embedded in stored procedures or WCF
      services. Make it unit-testable (no static state, constructor-injected
      dependencies).
   c. **API/controller layer** — ASP.NET Core Web API controllers or Razor Pages,
      per the UI approach confirmed at HITL Gate 2.
   d. **UI layer** — React/TypeScript components (if SPA was chosen) or Razor
      views (if server-rendered was chosen), matching the legacy UI's actual behavior,
      not its literal markup.
3. **Apply the standard mapping** from `AGENTS.md` Section 2 consistently: DI via
   `Microsoft.Extensions.DependencyInjection`, config via `IOptions<T>`, logging via
   `Microsoft.Extensions.Logging`, no `HttpContext.Current`, async I/O throughout.
4. **Do not add scope.** If you notice a related improvement outside what `backlog.md`
   specifies, note it as a suggestion in your Phase 5 summary — do not implement it
   without it going through Phase 4 first.
5. **Self-review against `rules/target-architecture.md`** before handing off to
   `test-verifier` — check DI usage, async usage, and config usage are compliant.

## Output artifact
Target-stack source code for the scoped module, committed to a feature branch or a
clearly separated `/modernized` path (never overwriting legacy source in place).

## Guardrails
- Never modify legacy `.NET Framework 4.6.1` source files.
- Never introduce a new NuGet dependency that isn't implied by `plan.md` without
  flagging it in your phase summary.
- If something in `backlog.md` turns out to be infeasible or contradictory once you're
  implementing it, stop and flag it rather than silently deviating — this may require
  looping back to Phase 4.
