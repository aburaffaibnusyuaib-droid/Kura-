# Privacy, security and end-to-end QA

## Goal
Audit privacy/security and run regression tests before freeze.

## Read first
`AGENTS.md`, `README_START_HERE.md`, `docs/DECISION_LOG.md`, relevant docs, and this task.

## Preconditions
- All previous tasks are approved.
- Inspect current code before editing.
- If a required provider/account/tool is unavailable, report blocker; do not substitute silently.

## Allowed scope
Check env/CORS/upload limits/logging/timeouts/RLS where used, permission denial, offline, malformed response, uncertain Food Check, guest/account behavior, no permanent image/history retention.

## Acceptance criteria
- [ ] Pass/fail report with evidence; critical issues fixed or explicitly blocked; no secret leaks; tests and physical-device QA completed where available; stop.
- [ ] Report exact changed files and commands/tests with actual results.
- [ ] List manual verification steps and any limitations.
- [ ] Stop here and wait for explicit user approval before the next task.

## Out of scope
No unrelated refactor, no unapproved dependencies, no destructive changes, and no later tasks.
