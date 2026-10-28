# Legacy Guardrails

These rules apply across every phase and every skill in this engagement.

1. **Never modify the legacy .NET Framework 4.x source in place.** All modernized code
   lives in a new project/solution or a clearly separated `/modernized` path. The legacy
   app remains the behavioral reference until the module is signed off and merged.
2. **Never write to a production or shared legacy database.** Discovery is read-only.
   Any schema or data migration requires an explicit, human-approved migration script —
   never an implicit side effect of code generation.
3. **Never delete or archive legacy code as part of this pipeline.** Decommissioning the
   legacy module is a separate, later decision outside this pipeline's scope.
4. **Treat stored procedures and WCF/ASMX services as first-class sources of business
   logic**, not just plumbing — logic hidden there must be captured in `backlog.md`
   during Phase 4, not skipped because it isn't in the UI layer.
5. **No phase skipping, and no proceeding past a 🛑 HITL gate without an explicit human
   approval message**, per the protocol in the top-level `AGENTS.md`.
6. **Scope discipline:** the scope is set at Gate 2, either `Scope: module` or
   `Scope: whole application`. In module scope, do not opportunistically modernize
   adjacent modules "while in there." In whole-application scope, every controller, page,
   and service from discovery is modernized or listed as out of scope with a reason that
   Gate 3 approves. Do not change scope mid-run without going back to Gate 2.
7. **Ambiguity is escalated, not resolved by guessing.** Any unclear or contradictory
   legacy behavior goes into the relevant phase's open-questions list.
8. **Secrets and external services are configuration, not code.** Connection strings,
   JWT signing keys, OAuth client secrets, SMTP and SMS credentials become named settings
   read through `IOptions<T>`. Leave the value empty or use a clearly labeled local
   development value. Never copy a real secret from the legacy config, and never invent
   one that looks real. List every such setting in `plan.md`.
