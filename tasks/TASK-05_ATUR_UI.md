# Atur UI with explicit demo repository

## Goal
Build Atur screens and states without real AI integration yet.

## Read first
`AGENTS.md`, `README_START_HERE.md`, `docs/DECISION_LOG.md`, relevant docs, and this task.

## Preconditions
- All previous tasks are approved.
- Inspect current code before editing.
- If a required provider/account/tool is unavailable, report blocker; do not substitute silently.

## Allowed scope
Image entry/preview, candidate ingredient list, add/edit/remove, confirm, exactly three demo recipe cards, recipe detail, loading/error/empty states. Demo data clearly isolated.

## Acceptance criteria
- [ ] User can edit ingredients before confirmation; exactly three cards shown in demo flow; recipe detail opens; failures do not crash; tests/analyzer pass; stop.
- [ ] Report exact changed files and commands/tests with actual results.
- [ ] List manual verification steps and any limitations.
- [ ] Stop here and wait for explicit user approval before the next task.

## Out of scope
No unrelated refactor, no unapproved dependencies, no destructive changes, and no later tasks.
