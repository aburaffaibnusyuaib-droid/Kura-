# Locked Decisions and Conflict Resolution

Last confirmed: 19 October 2026.

1. Platform: Android first; web later.
2. Features: Food Check + Atur only; no Chat MVP.
3. Account: guest + registered account built early. Both main feature flows must work without login. Do not persist feature data by default.
4. Food Check: photo, preview, AI, follow-up questions, result, error handling. Barcode/OCR postponed.
5. Atur: photo, AI ingredient candidates, edit/confirm, exactly three recipes, detail.
6. Privacy: don't permanently retain photos/results by default; history postponed.
7. Design: follow dedicated mockups; documented UX/accessibility improvements allowed.
8. Release goal: working school/portfolio MVP, not a promise of public-store readiness.
9. Agent autonomy: one task then stop for approval.
10. Language: Indonesian first, localization-ready.
11. Architecture: Flutter + FastAPI + Supabase; AI provider behind backend adapter.
12. Design: Light Mode first; central theme tokens; Dark Mode later.
13. Date: target code freeze 30 Nov 2026; early December reserved for critical bug fixes.

If any older document says Kura AI Chat, history, saved recipes, barcode/OCR, web, or Dark Mode are MVP, treat that as outdated and follow this log.
