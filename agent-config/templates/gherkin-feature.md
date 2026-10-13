# Gherkin Feature Template

One feature block per user story. Cover the happy path, validation/error cases, and any
edge cases found while reverse-engineering the legacy module.

---

```gherkin
Feature: [Story title — matches the User Story ID/Title]
  As a [role]
  I want to [capability]
  So that [business reason]

  Background:
    Given [shared setup/context, if any]

  Scenario: [happy path]
    Given [initial state]
    When [action]
    Then [expected result — must match verified legacy behavior]

  Scenario: [validation / error case]
    Given [initial state]
    When [invalid action]
    Then [expected error/validation behavior]

  Scenario: [edge case found during discovery, if any]
    Given [initial state]
    When [edge-case action]
    Then [expected result]
```

**Traceability:** link back to User Story ID `US-[###]` and the legacy source
reference(s) it was derived from.
