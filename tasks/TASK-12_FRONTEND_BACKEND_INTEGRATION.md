# Integrate both feature flows

## Goal
Connect Flutter repositories/API client to backend contracts.

## Read first
`AGENTS.md`, `README_START_HERE.md`, `docs/DECISION_LOG.md`, relevant docs, and this task.

## Preconditions
- All previous tasks are approved.
- Inspect current code before editing.
- If a required provider/account/tool is unavailable, report blocker; do not substitute silently.

## Allowed scope
Remove demo path from normal configured flow; keep demo mode explicit for offline/design tests. Implement upload progress/loading, timeouts, safe errors, retry and cancellation/back behavior where feasible.

## Acceptance criteria
- [ ] Both flows work end-to-end with real configured backend; demo mode is unmistakable; no secrets in Flutter; tests and manual test report pass; stop.
- [ ] Report exact changed files and commands/tests with actual results.
- [ ] List manual verification steps and any limitations.
- [ ] Stop here and wait for explicit user approval before the next task.

## Out of scope
No unrelated refactor, no unapproved dependencies, no destructive changes, and no later tasks.
