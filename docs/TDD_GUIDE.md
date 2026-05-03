<!--
Corehold
File: docs/TDD_GUIDE.md
Purpose: Test-driven development guide for contributors

Contribution Flow:
Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main

Rules:
- Do not edit without a linked issue.
- Keep changes scoped to the issue.
- Add or update tests when practical.
- Update docs when behavior, architecture, setup, or data formats change.
-->

# Test-Driven Development Guide

## Purpose

Tests exist to make changes safer, easier to review, and harder for LLM agents to fake.

## Workflow

```
Issue
→ Branch
→ Failing Test
→ Minimal Implementation
→ Passing Test
→ Refactor
→ Documentation
→ Pull Request
→ Review
→ Revise
→ Squash and Merge
```

## Red / Green / Refactor

### Red

Write a test that fails for the correct reason.

### Green

Implement the smallest change that makes the test pass.

### Refactor

Clean up only after tests pass.

## Bug Fixes

Bug fixes should include regression tests when practical.

## Game Development Exception

Manual testing is acceptable for:

- Visual feedback
- Audio feedback
- Game feel
- UI layout
- Scene transitions
- Performance
- Full playthrough validation

Manual tests must be documented in the PR.

## Required PR Testing Section

Every PR must include:

```md
## Testing

### Automated Tests
- [ ] Added or updated tests
- [ ] All relevant tests pass

Commands run:

```
<commands>
```

### Manual Tests

- [ ] Game launches
- [ ] Issue behavior verified
- [ ] No obvious regressions found

Notes:

- ...

### Untested Areas

- ...
```

## Do Not Fake Testing

If tests were not run, say so clearly.

Do not claim tests passed unless they actually ran.
Do not invent test results.

If a test environment is not available, document what was manually verified and what remains untested.
