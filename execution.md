# How to run a modernization

Open this skills repo in Cursor. Do not open the legacy repo. Paste one prompt below into the chat. Replace the angle brackets. The agent creates the run folder on your machine. That folder is not part of this git repo.

## Prompt: GitHub URL

```
Follow AGENTS.md and execution.md. This folder is the skills repo.
The legacy app is this GitHub URL: <paste url>.
Clone it into runs/<RepoName>/legacy. Do not edit legacy.
Put every phase file and the new app in runs/<RepoName>/modernized.
Start at Phase 1 and continue through the gates in execution.md.
```

## Prompt: local path

```
Follow AGENTS.md and execution.md. This folder is the skills repo.
The legacy app is already on this machine at <paste path>.
Do not edit that folder. Copy it into runs/<RepoName>/legacy.
Put every phase file and the new app in runs/<RepoName>/modernized.
Start at Phase 1 and continue through the gates in execution.md.
```

## What you get after the paste

| Step | What appears | What you reply |
|---|---|---|
| Phase 1 | `runs/<RepoName>/modernized/discovery-report.md` | Nothing. The agent goes on. |
| Phase 2 | `knowledge-graph.md`, then a stop | `approved`, `approved with changes`, `rework`, or `reject` |
| Phase 3 | `scope-proposal.md` with module options and a whole-application option, then a stop | `approved: <module name>` for one module, or `approved: whole app` for the entire application. Add `use spa` only if you want React. |
| Phase 4 | `backlog.md`, `plan.md`, `parity-map.md`, then a stop | `approved`, `approved with changes`, `rework`, or `reject` |
| Phase 5 and 6 | The new site, the tests, and `test-report.md` | Nothing, unless a test fails. Then the agent fixes that phase. |
| Phase 7 | A local URL and a short walkthrough | `approved`, `approved with changes`, `rework`, or `reject`. A prototype can be accepted only as a prototype. |

`approved` moves to the next phase. `rework` stays on the same phase. `reject` stops the run.

The agent does not commit or push `runs/`. Each new app gets its own `runs/<RepoName>/legacy` and `runs/<RepoName>/modernized`.
