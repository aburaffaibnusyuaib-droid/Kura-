# AGENTS.md — Kura AI

## Authority
Read `README_START_HERE.md`, `docs/DECISION_LOG.md`, `docs/PRODUCT_SPEC.md`, `docs/ARCHITECTURE.md`, `docs/DESIGN_SYSTEM.md`, `docs/SAFETY_PRIVACY.md`, and the current task. This pack supersedes older conflicting project notes.

## Work protocol
1. Inspect current repository before any edits.
2. Do only the explicitly named task. Never silently move to the next task.
3. Before editing, summarize intended files and approach when a change is non-trivial.
4. Preserve existing source, mockups, and assets. Never delete/rename/move without approval.
5. Never create a nested duplicate Flutter project. If structure/toolchain is broken, report it before attempting broad repair.
6. Avoid unrelated refactors and destructive commands. Explain new dependencies and keep them minimal.
7. After work, run applicable formatter, analyzer, tests, and build checks. If a check cannot run, explain why.
8. Demo data must be clearly labelled and isolated behind a repository; never fake a successful live AI response.
9. Never put AI keys, Supabase service-role keys, signing credentials, or privileged secrets in Flutter, Git, logs, screenshots, or responses.
10. Do not log raw images, passwords, tokens, or sensitive user content.
11. Food Check must never claim that an image guarantees food safety. Follow `docs/SAFETY_PRIVACY.md`.
12. Default UI language is Indonesian. Implement Light Mode only unless a task says otherwise.
13. Out of scope unless explicitly re-approved: Kura AI Chat, web release, barcode scanner, expiry OCR, history, saved recipes, Dark Mode, shopping list, meal planner.
14. After every task report: summary; changed files; commands/tests and results; manual verification steps; remaining risks/blockers; confirmation that you stopped.
15. If acceptance criteria fail, fix only within current scope or report a blocker. Wait for user approval before continuing.
