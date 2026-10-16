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
6. **Scope discipline:** one bounded module per pipeline run. Do not opportunistically
   modernize adjacent modules "while in there."
7. **Ambiguity is escalated, not resolved by guessing.** Any unclear or contradictory
   legacy behavior goes into the relevant phase's open-questions list.
