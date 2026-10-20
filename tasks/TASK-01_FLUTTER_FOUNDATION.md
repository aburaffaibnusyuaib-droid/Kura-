# Flutter foundation

## Goal
Establish or repair the minimum Flutter Android project foundation after audit approval.

## Read first
`AGENTS.md`, `README_START_HERE.md`, `docs/DECISION_LOG.md`, relevant docs, and this task.

## Preconditions
- All previous tasks are approved.
- Inspect current code before editing.
- If a required provider/account/tool is unavailable, report blocker; do not substitute silently.

## Allowed scope
Only bootstrap the Flutter project if no usable one exists; avoid nested duplicate app; set app title/package only after inspecting current values; add `.gitignore` and README as needed.

## Acceptance criteria
- [ ] `flutter pub get` succeeds; `flutter analyze` passes or reports only explained existing issues; app launches on available emulator/device; no mockups deleted; stop.
- [ ] Report exact changed files and commands/tests with actual results.
- [ ] List manual verification steps and any limitations.
- [ ] Stop here and wait for explicit user approval before the next task.

## Out of scope
No unrelated refactor, no unapproved dependencies, no destructive changes, and no later tasks.
