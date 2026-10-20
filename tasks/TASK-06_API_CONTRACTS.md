# Freeze API contracts

## Goal
Write precise request/response/error schemas shared by Flutter and FastAPI before integrating.

## Read first
`AGENTS.md`, `README_START_HERE.md`, `docs/DECISION_LOG.md`, relevant docs, and this task.

## Preconditions
- All previous tasks are approved.
- Inspect current code before editing.
- If a required provider/account/tool is unavailable, report blocker; do not substitute silently.

## Allowed scope
Define content types, image limits, auth behavior, response enums, follow-up interaction, exactly-three recipe validation, timeouts, retention, sanitized errors and versioning. Update docs only.

## Acceptance criteria
- [ ] Every proposed endpoint has request/response examples and validation rules; schemas align with product/safety rules; tests or schema examples included; no implementation changes; stop.
- [ ] Report exact changed files and commands/tests with actual results.
- [ ] List manual verification steps and any limitations.
- [ ] Stop here and wait for explicit user approval before the next task.

## Out of scope
No unrelated refactor, no unapproved dependencies, no destructive changes, and no later tasks.
