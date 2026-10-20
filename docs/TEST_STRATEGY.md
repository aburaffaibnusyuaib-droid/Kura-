# Test Strategy and Definition of Done

## Per task
- Format code.
- Run Dart analyzer / Flutter tests for Flutter changes.
- Run relevant Python lint/type/tests for backend changes where configured.
- Run targeted unit/widget/integration tests.
- Review diff and confirm no unrelated edits or secrets.
- Give manual test steps and actual results.
- Stop and wait for approval.

## Feature cases
Food Check: valid image; unsupported/oversized image; retake; permission denied; poor image; follow-up required; each status; malformed AI response; timeout; offline; quota exhausted; retry; user backs out.
Atur: empty/poor image; no ingredients detected; edit/add/remove; allergy input; empty confirmed list; AI failure; exactly three distinct recipes; recipe detail; safe retry.
Auth: guest entry; registration/login/logout; invalid credentials; expired session; network failure; feature flows remain usable as guest.
Privacy/security: no secrets in app bundle/repo/logs; uploads bounded; photos not permanently retained by default; RLS/access checks for any user data; no sensitive payloads in logs.

## Device QA
- Android emulator if practical and a physical Android phone.
- Small and common screen sizes, keyboard, text scaling, permission denial, airplane/offline mode.
- Capture screenshots for visual review against mockups.
- Check cold start, navigation/back behavior, loading states, crashes and basic performance.

## MVP done
Both feature flows work end-to-end with real backend/AI integration; any demo mode is clearly labelled and not mistaken for production. Android build installs and runs. User can edit ingredients. Exactly three recipe options are returned. Food Check states uncertainty. No privileged keys in client. Setup, test and demo steps are reproducible.
