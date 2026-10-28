---
name: target-modernizer
description: Use in Phase 5 to generate .NET 10 (ASP.NET Core) implementation code for the module or whole application specified in the approved backlog.md, plan.md, and parity-map.md. Keep controller names, action names, URLs, and screen fields the same as the .NET Framework 4.x module.
disable-model-invocation: true
phase: 5 — Code Modernization
requires_approval: backlog.md and plan.md must be approved at HITL Gate 3 before this skill runs
---

# Target Modernizer (.NET Framework 4.x → .NET 10)

## When to use
Only after `backlog.md` and `plan.md` are approved at HITL Gate 3. This skill implements
exactly what those documents specify — it is not a place to make new design decisions.

## Inputs
- Approved `backlog.md` (user stories + Gherkin acceptance criteria)
- Approved `plan.md` (build order, project structure)
- Approved `parity-map.md` (controller, action, URL, and screen-field names)
- `rules/target-architecture.md` and `rules/parity-contract.md`

## Process
1. **Scaffold the target project** per `plan.md`: SDK-style `.csproj` with
   `<TargetFramework>net10.0</TargetFramework>`, `Program.cs` minimal hosting model,
   `appsettings.json` / `appsettings.Development.json`.
2. **Copy names from `parity-map.md`.** Create `OrdersController` only if the map says
   `OrdersController`. Create action `Details` only if the map lists `Details`.
   Put the same labels, input names, column headers, and button text on the new view.
   Do this before any "cleanup" rename.
3. **Implement in the plan's stated order** — typically:
   a. **Data layer** — EF Core `DbContext` + entity classes, mapped from EF6
      models/`.edmx` or from raw SQL/stored-procedure logic identified in discovery.
      Preserve column/table names unless the plan explicitly calls for a rename.
   b. **Service/business logic layer** — port business rules from Phase 4's stories,
      including logic that was previously embedded in stored procedures or WCF
      services. Make it unit-testable (no static state, constructor-injected
      dependencies).
   c. **Controller layer** — the same controller class names and action names as `parity-map.md`.
   d. **View layer** — Razor views that show the same headings, labels, input names,
      column headers, and button text as the old view. Use React only if Gate 2 was
      answered with `use spa`.
4. **Apply the standard mapping** from `AGENTS.md` Section 2 consistently: DI via
   `Microsoft.Extensions.DependencyInjection`, config via `IOptions<T>`, logging via
   `Microsoft.Extensions.Logging`, no `HttpContext.Current`, async I/O throughout.
5. **Do not add scope.** If you notice a related improvement outside what `backlog.md`
   specifies, note it as a suggestion in your Phase 5 summary — do not implement it
   without it going through Phase 4 first.
6. **Render every shared-chrome row** in the new layout. The module view alone is not enough.
7. **Follow the persistence choice in `plan.md`.** If the plan names a real database, use that database. Do not replace it with an in-memory collection. In-memory data is allowed only when the approved plan says `Classification: prototype` and lists every seeded row. The phase summary must repeat `Classification: prototype` and `Data source: preview data is fake`, and it must list those rows. Do not describe a prototype, or those rows, as the finished modernization or as the legacy database.
8. **Put secrets and external services in configuration.** Every setting listed in the
   plan's Configuration section is read through `IOptions<T>`. Values are empty or clearly
   labeled local development values. Where the legacy code calls an external service that
   has no configuration in the repo (an email or SMS sender, an OAuth provider), keep the
   same behavior the legacy code has without that configuration. Do not invent a working
   provider.
9. **In `Scope: whole application`**, build one web project and one test project for the
   whole app, named after the application, not after one domain. Build the plan's shared
   foundation first, then one domain at a time in the plan's order. Run `dotnet build`
   after each domain, and fix it before starting the next one. Do not leave a domain
   half-built to come back to later.
10. **Do not add preview-only sign-in shortcuts** that bypass the real login. If the
    rendered check needs a signed-in user, `compare-parity.ps1` signs in through the login
    form with `-LoginUrl` and `-LoginFields`. Seeded preview users are allowed and must be
    listed in `plan.md`.
11. **Self-review against `rules/target-architecture.md` and `rules/parity-contract.md`** before handing off to
   `test-verifier` — check DI usage, async usage, and config usage are compliant.

## Output artifact
Target-stack source code under `runs/<RepoName>/modernized/`, next to the phase files.
The test project is a sibling of the web project, still inside `modernized/`. Never
write into `legacy/`.

## Guardrails
- Never modify legacy .NET Framework 4.x source files.
- Never rename a controller, action, URL, or view field that `parity-map.md` lists.
- Never introduce a new NuGet dependency that isn't implied by `plan.md` without
  flagging it in your phase summary.
- If something in `backlog.md` turns out to be infeasible or contradictory once you're
  implementing it, stop and flag it rather than silently deviating — this may require
  looping back to Phase 4.
