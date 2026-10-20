# Supabase auth and guest flow

## Goal
Implement guest access and registration/login using Supabase Auth without requiring login for features.

## Read first
`AGENTS.md`, `README_START_HERE.md`, `docs/DECISION_LOG.md`, relevant docs, and this task.

## Preconditions
- All previous tasks are approved.
- Inspect current code before editing.
- If a required provider/account/tool is unavailable, report blocker; do not substitute silently.

## Allowed scope
Configure only through environment variables; document setup; minimum account/profile data; secure session handling; no feature history persistence. Do not paste secrets in chat or source.

## Acceptance criteria
- [ ] Guest can enter both features; signup/login/logout and session errors behave clearly when configured; core flows remain accessible without login; secret scan/review passes; stop.
- [ ] Report exact changed files and commands/tests with actual results.
- [ ] List manual verification steps and any limitations.
- [ ] Stop here and wait for explicit user approval before the next task.

## Out of scope
No unrelated refactor, no unapproved dependencies, no destructive changes, and no later tasks.
