# Atur ingredient recognition

## Goal
Implement image-to-candidate-ingredient endpoint using approved provider adapter.

## Read first
`AGENTS.md`, `README_START_HERE.md`, `docs/DECISION_LOG.md`, relevant docs, and this task.

## Preconditions
- All previous tasks are approved.
- Inspect current code before editing.
- If a required provider/account/tool is unavailable, report blocker; do not substitute silently.

## Allowed scope
Return normalized candidate names and optional notes; do not imply certainty; enforce output bounds. User confirmation remains a required frontend step.

## Acceptance criteria
- [ ] Valid image returns schema-valid candidate list; poor/empty image returns recoverable state; model output is validated; tests pass; stop.
- [ ] Report exact changed files and commands/tests with actual results.
- [ ] List manual verification steps and any limitations.
- [ ] Stop here and wait for explicit user approval before the next task.

## Out of scope
No unrelated refactor, no unapproved dependencies, no destructive changes, and no later tasks.
