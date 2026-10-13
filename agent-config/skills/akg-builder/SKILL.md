---
name: akg-builder
description: Use in Phase 2 to convert the legacy-discovery output into a reviewable Application Knowledge Graph (AKG) — a diagram and doc that groups legacy components into candidate domain boundaries. Feeds directly into HITL Gate 1.
phase: 2 — Application Knowledge Graph
---

# Application Knowledge Graph Builder

## When to use
Immediately after `legacy-discovery` completes and `discovery-report.md` exists. This
skill's output is what gets presented at HITL Gate 1 — it must be understandable by a
non-technical or semi-technical reviewer, not just accurate to the code.

## Inputs
- `discovery-report.md` (call graph, data access inventory, service inventory).

## Process
1. **Cluster components into candidate domains.** Group pages/controllers/services/data
   models that change together and share data into named business domains (e.g.,
   "Billing," "Customer Onboarding," "Reporting"). Use naming the business would
   recognize, not technical layer names.
2. **Identify domain dependencies.** For each pair of domains with a direct call or
   shared-data relationship, record the direction and nature of the dependency (shared
   table, direct service call, shared static state, etc.).
3. **Flag shared/ambiguous components.** Anything used by more than one candidate domain
   (a shared utility library is fine; a shared mutable data model is a risk) — call this
   out explicitly, don't silently assign it to one domain.
4. **Render a diagram.** Produce a Mermaid `graph TD` (or equivalent) diagram: one node
   per domain, edges labeled with the dependency type. Keep it readable — collapse
   internal detail, this is a domain-level map, not a class diagram.
5. **Score each domain** on: estimated complexity (low/med/high), coupling to other
   domains (low/med/high), and — if known — business criticality. This scoring feeds the
   `scope-selector` skill in Phase 3.

## Output artifact
`knowledge-graph.md` containing:
- The rendered domain diagram
- A table: domain name → legacy components included → dependencies → complexity/coupling
  scores
- An explicit "shared/ambiguous components" section

## Guardrails
- Domain boundaries are a proposal, not a decision — this skill's output must go through
  🛑 HITL Gate 1 before Phase 3 scope selection begins.
- Do not force every component into a single domain; an "unclassified/shared" bucket is
  more honest than a wrong grouping.
