# Food Check AI backend

## Goal
Implement real provider-backed Food Check using the approved adapter and schemas.

## Read first
`AGENTS.md`, `README_START_HERE.md`, `docs/DECISION_LOG.md`, relevant docs, and this task.

## Preconditions
- All previous tasks are approved.
- Inspect current code before editing.
- If a required provider/account/tool is unavailable, report blocker; do not substitute silently.

## Allowed scope
First verify current provider image support, account eligibility, terms, free quota/rate limits. Server-side key only. Structured response, follow-up questions where needed, cautious status mapping, timeouts and sanitized errors.

## Acceptance criteria
- [ ] Integration tests cover each status, uncertainty, malformed provider output, timeout and quota failure; no certainty claim; provider can be swapped behind adapter; stop.
- [ ] Report exact changed files and commands/tests with actual results.
- [ ] List manual verification steps and any limitations.
- [ ] Stop here and wait for explicit user approval before the next task.

## Out of scope
No unrelated refactor, no unapproved dependencies, no destructive changes, and no later tasks.
