---
name: legacy-discovery
description: Use at the start of any modernization engagement (Phase 1) to statically analyze a .NET Framework 4.6.1 repository — structure, config, dependencies, cross-cutting concerns — before any design or code work begins. Do not skip even if the repo "looks familiar."
phase: 1 — Discovery & Parsing
---

# Legacy Discovery (.NET Framework 4.6.1)

## When to use
Every modernization engagement starts here. Run this skill before `akg-builder`. Re-run
the relevant parts if scope later expands to a module you haven't yet analyzed.

## Inputs
- Read access to the legacy repository root.
- No write access is required or permitted for this skill — discovery is strictly read-only.

## Process
1. **Map the project structure.** Identify `.csproj`/`.sln` files, distinguish WebForms
   (`.aspx`/`.aspx.cs`/`.ascx`) from MVC (`Controllers/`, `Views/`) from class libraries
   and WCF/ASMX service projects.
2. **Parse configuration.** Read every `Web.config`/`App.config`: connection strings,
   `appSettings`, custom `HttpModules`/`HttpHandlers`, auth mode (`<authentication mode>`),
   session state provider, binding redirects.
3. **Parse startup/bootstrap.** Read `Global.asax.cs` — `Application_Start`,
   `Application_BeginRequest`, registered routes/areas, any static/singleton state
   initialized here (common source of hidden coupling).
4. **Inventory data access.** Find EF6 `DbContext`/`.edmx` models, raw ADO.NET, or
   Dapper usage. List every stored procedure or raw SQL string invoked from code —
   these often hide business logic.
5. **Inventory services.** List WCF service contracts (`[ServiceContract]`) or ASMX
   `.asmx` endpoints, their operations, and consumers.
6. **Build a call graph.** For each entry point (page, controller action, service
   operation), trace the call chain down to data access. Note fan-out/fan-in — components
   called from many places are higher-risk to modernize in isolation.
7. **Flag cross-cutting concerns explicitly:** any use of `HttpContext.Current`,
   `Session[...]`, `Cache`, static mutable state, `Thread`/`Timer` background work,
   Windows-only APIs (registry, file shares, COM interop) — these need explicit handling
   in the target architecture and cannot be ported 1:1.
8. **Note anything undocumented or suspicious**, e.g., commented-out logic left active,
   duplicated business rules in more than one layer, or config values that look
   environment-specific but are hardcoded.

## Output artifact
`discovery-report.md` containing:
- Project/solution structure summary
- Config inventory (sanitized — do not copy real connection strings/secrets verbatim)
- Data access inventory (EF6 models, raw SQL/stored procs referenced)
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
