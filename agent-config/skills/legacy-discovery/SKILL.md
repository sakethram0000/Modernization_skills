---
name: legacy-discovery
description: Use at the start of any modernization engagement (Phase 1) to statically analyze a .NET Framework 4.x repository — structure, config, controllers, views, dependencies, cross-cutting concerns — before any design or code work begins. Do not skip even if the repo "looks familiar."
disable-model-invocation: true
phase: 1 — Discovery & Parsing
---

# Legacy Discovery (.NET Framework 4.x)

## When to use
Every modernization engagement starts here. Run this skill before `akg-builder`. Re-run
the relevant parts if scope later expands to a module you haven't yet analyzed.

## Inputs
- Read access to the legacy repository root.
- No write access is required or permitted for this skill — discovery is strictly read-only.

## Process
1. **Run the inventory script first.** From the skill repo (or the copy inside the legacy repo):
   `powershell -File agent-config/scripts/inventory.ps1 -RepoRoot <legacy repo>`.
   Record each `TargetFrameworkVersion` (`v4.5` through `v4.8`). Do not assume 4.6.1.
   If the script prints a STOP line, copy it into the report and follow `agent-config/rules/stop-list.md`.
2. **Map the project structure.** Identify `.csproj`/`.sln` files, distinguish WebForms
   (`.aspx`/`.aspx.cs`/`.ascx`) from MVC (`Controllers/`, `Views/`) from class libraries
   and WCF/ASMX service projects.
3. **Parse configuration.** Read every `Web.config`/`App.config`: connection strings,
   `appSettings`, custom `HttpModules`/`HttpHandlers`, auth mode (`<authentication mode>`),
   session state provider, binding redirects.
4. **Parse startup/bootstrap.** Read `Global.asax.cs` — `Application_Start`,
   `Application_BeginRequest`, registered routes/areas, any static/singleton state
   initialized here (common source of hidden coupling).
5. **Inventory data access.** Find EF6 `DbContext`/`.edmx` models, raw ADO.NET, or
   Dapper usage. List every stored procedure or raw SQL string invoked from code —
   these often hide business logic.
6. **Inventory services.** List WCF service contracts (`[ServiceContract]`) or ASMX
   `.asmx` endpoints, their operations, and consumers.
7. **Build a call graph.** For each entry point (page, controller action, service
   operation), trace the call chain down to data access. Note fan-out/fan-in — components
   called from many places are higher-risk to modernize in isolation.
8. **Inventory authentication.** Record the auth mode, the login path, global filters such as `Authorize` and `RequireHttps`, roles, external login providers, and which actions are anonymous. A report that only says "has login" is not done.
9. **Inventory Web APIs.** For every `ApiController` or controller under an `Api` folder, list the action name, HTTP verb, and route. The inventory script's controller section includes these actions. Do not leave that section empty when the file has public API methods.
10. **Inventory dependencies.** Copy the package id and version lines from the script's `=== Dependencies ===` section into the report. Call out any package that is used for auth, data access, or JSON.
11. **Flag cross-cutting concerns explicitly:** any use of `HttpContext.Current`,
   `Session[...]`, `Cache`, static mutable state, `Thread`/`Timer` background work,
   Windows-only APIs (registry, file shares, COM interop) — these need explicit handling
   in the target architecture and cannot be ported 1:1.
12. **Note anything undocumented or suspicious**, e.g., commented-out logic left active,
   duplicated business rules in more than one layer, or config values that look
   environment-specific but are hardcoded.

## Output artifact
`runs/<RepoName>/modernized/discovery-report.md`. The clone is `runs/<RepoName>/legacy/` and is not edited. The report contains:
- Detected 4.x version per project (from the script, not from memory)
- Controller and action name list, plus the `.aspx` page and `.svc`/`.asmx` service lists, copied from the script (these lists feed `parity-map.md` and the whole-application coverage check later)
- Project/solution structure summary
- Authentication inventory (mode, login path, global filters, roles, anonymous actions)
- Database inventory (EF6 models, raw SQL/stored procs referenced, connection name with the secret removed)
- API inventory (Web API, WCF, and ASMX operations with verb and route)
- Configuration inventory (sanitized — do not copy real connection strings/secrets verbatim)
- Dependency inventory (package id and version from the script)
- Service inventory (WCF/ASMX contracts + consumers)
- Call graph summary (entry points → data access, noting fan-out)
- Cross-cutting concerns list
- Open questions / red flags list

## Guardrails
- Read-only. Never modify legacy source or config during this skill.
- Do not skip stored-procedure inspection — business logic hidden in SQL is the most
  common source of behavior mismatches after modernization.
- If the repo is large, prioritize breadth (a full structural map) over depth in the
  first pass; deep-dive into a specific module happens in Phase 4 once scope is chosen.
  Discovery always covers the whole repo, so the whole-application option at Gate 2 can
  be counted from this report.
- The report is not done until the authentication, database, API, configuration, and dependency sections are present. Write "none" when the repo has none. Do not omit the heading.
