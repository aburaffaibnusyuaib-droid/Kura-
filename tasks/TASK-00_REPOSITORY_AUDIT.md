# Repository and toolchain audit

## Goal
Inspect the existing project and tools without changing files.

## Read first
`AGENTS.md`, `README_START_HERE.md`, `docs/DECISION_LOG.md`, relevant docs, and this task.

## Preconditions
- All previous tasks are approved.
- Inspect current code before editing.
- If a required provider/account/tool is unavailable, report blocker; do not substitute silently.

## Allowed scope
Read-only inspection of folder structure, Git status, Flutter/Dart, Python, Android Studio/SDK, mockup locations, existing docs, and any existing app/backend. Do not print secrets or `.env` contents.

## Acceptance criteria
- [ ] Report findings, blockers, safe next steps, and exact commands. No source files changed. Stop for approval.
- [ ] Report exact changed files and commands/tests with actual results.
- [ ] List manual verification steps and any limitations.
- [ ] Stop here and wait for explicit user approval before the next task.

## Out of scope
No unrelated refactor, no unapproved dependencies, no destructive changes, and no later tasks.
