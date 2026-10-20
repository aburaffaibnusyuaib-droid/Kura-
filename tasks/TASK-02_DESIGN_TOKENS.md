# Light theme tokens

## Goal
Implement centralized Light Mode design tokens based on docs and mockups.

## Read first
`AGENTS.md`, `README_START_HERE.md`, `docs/DECISION_LOG.md`, relevant docs, and this task.

## Preconditions
- All previous tasks are approved.
- Inspect current code before editing.
- If a required provider/account/tool is unavailable, report blocker; do not substitute silently.

## Allowed scope
Theme colors, typography, spacing/radius constants, ThemeData; Plus Jakarta Sans only if safely available; no screen redesign and no Dark Mode.

## Acceptance criteria
- [ ] No unexplained scattered palette values in new theme-related code; sample preview/test verifies theme loads; contrast-sensitive text remains readable; analyzer/tests pass; stop.
- [ ] Report exact changed files and commands/tests with actual results.
- [ ] List manual verification steps and any limitations.
- [ ] Stop here and wait for explicit user approval before the next task.

## Out of scope
No unrelated refactor, no unapproved dependencies, no destructive changes, and no later tasks.
