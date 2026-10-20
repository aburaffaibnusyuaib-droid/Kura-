# FastAPI foundation

## Goal
Create minimal backend only after architecture and API contract approval.

## Read first
`AGENTS.md`, `README_START_HERE.md`, `docs/DECISION_LOG.md`, relevant docs, and this task.

## Preconditions
- All previous tasks are approved.
- Inspect current code before editing.
- If a required provider/account/tool is unavailable, report blocker; do not substitute silently.

## Allowed scope
Health route, config loading, `.env.example`, safe logging, CORS development config, request validation baseline, tests. No provider integration yet.

## Acceptance criteria
- [ ] Backend starts with documented command; `/health` works; tests pass; no secrets committed or logged; errors don't expose stack traces; stop.
- [ ] Report exact changed files and commands/tests with actual results.
- [ ] List manual verification steps and any limitations.
- [ ] Stop here and wait for explicit user approval before the next task.

## Out of scope
No unrelated refactor, no unapproved dependencies, no destructive changes, and no later tasks.
