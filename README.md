# .NET Framework 4.x → .NET 10 skill pack

This folder is the playbook. It does not contain your legacy application.
Copy `AGENTS.md` and `agent-config/` into the root of the legacy repo, open that repo in Cursor, and say: "Follow AGENTS.md. Start Phase 1 only."

## What "the same" means

The new app is .NET 10. Controller names, action names, URLs, labels, input names, column headers, and button text stay the same as the old module. See `agent-config/rules/parity-contract.md`.

Example: `OrdersController.Details` and a field named `CustomerName` stay `OrdersController.Details` and `CustomerName`.

## Checks you can run

Each run is `runs/<RepoName>/legacy` and `runs/<RepoName>/modernized`. A new run does not create a `samples` folder.

```powershell
powershell -File agent-config/scripts/inventory.ps1 -RepoRoot runs/<RepoName>/legacy
powershell -File agent-config/scripts/compare-parity.ps1 -LegacyRoot runs/<RepoName>/legacy -ModernRoot runs/<RepoName>/modernized/<WebProject> -ParityMap runs/<RepoName>/modernized/parity-map.md -BaseUrl http://127.0.0.1:5099
dotnet test runs/<RepoName>/modernized/<TestsProject>
```
