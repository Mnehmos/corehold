<!--
Corehold
File: docs/LLM_CONTRIBUTING.md
Purpose: LLM and human contributor workflow guide

Contribution Flow:
Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main

Rules:
- Do not edit without a linked issue.
- Keep changes scoped to the issue.
- Add or update tests when practical.
- Update docs when behavior, architecture, setup, or data formats change.
-->

# LLM Contributing Guide

## Core Rule

No issue, no branch.
No branch, no code.
No behavior change without validation.
No PR without testing notes.
No merge without review.

## Required Workflow

```
Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main
```

## 1. Issue

Every change must begin with a GitHub issue.

The issue must define:

- Problem or goal
- Acceptance criteria
- Relevant files/systems
- Testing expectations
- Documentation impact

## 2. Branch

Create one branch per issue.

Branch format:

```
issue-<number>/<short-description>
```

Never work directly on `main`.

## 3. Test

Before implementation, identify how the change will be validated.

When practical, write a failing test first.

## 4. Implement

Implement the smallest complete change that satisfies the issue.

Avoid unrelated refactors.

## 5. Pull Request

Open a PR linked to the issue.

Every PR must include:

- Summary
- Files changed
- Testing performed
- Documentation updated
- Known risks
- Screenshots or recordings when relevant

## 6. Review

Wait for human or automated review.

If automated review is unavailable, perform a rigorous self-review.

The review mindset is:

> Try to break the code before the user does.

## 7. Revise

Apply valid review suggestions.

Re-test after changes.

Repeat review and revision until acceptable.

## 8. Documentation

Update all relevant docs before merge.

If no docs are needed, state that explicitly in the PR.

## 9. Squash and Merge

Only merge after review, validation, and documentation are complete.

Use squash merge into `main`.

## LLM Agent Rules

1. Never work without an issue.
2. Never commit directly to `main`.
3. Never mix unrelated changes into one PR.
4. Never skip validation.
5. Never claim tests passed unless they actually ran.
6. Never invent test results.
7. Prefer small, reviewable changes.
8. Prefer clear, boring code over clever code.
9. Update docs when behavior, setup, architecture, or data formats change.
10. Stop after completing the assigned issue unless explicitly told to continue.
