# Atur recipe generation

## Goal
Implement recipe endpoint using user-confirmed ingredients.

## Read first
`AGENTS.md`, `README_START_HERE.md`, `docs/DECISION_LOG.md`, relevant docs, and this task.

## Preconditions
- All previous tasks are approved.
- Inspect current code before editing.
- If a required provider/account/tool is unavailable, report blocker; do not substitute silently.

## Allowed scope
Return exactly three distinct recipe options or a safe recoverable error; ingredients and steps structured; respect stated allergies; label optional pantry ingredients.

## Acceptance criteria
- [ ] Schema rejects fewer/more than three recipes; duplicate recipes are filtered/retried safely or error clearly; allergen constraints tested; tests pass; stop.
- [ ] Report exact changed files and commands/tests with actual results.
- [ ] List manual verification steps and any limitations.
- [ ] Stop here and wait for explicit user approval before the next task.

## Out of scope
No unrelated refactor, no unapproved dependencies, no destructive changes, and no later tasks.
