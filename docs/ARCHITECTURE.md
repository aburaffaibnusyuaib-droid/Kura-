# Architecture

## Chosen stack
- Frontend: Flutter/Dart, Android first.
- Backend: FastAPI/Python.
- Auth/database: Supabase Auth + PostgreSQL.
- AI: provider adapter in backend; select provider only after verifying current image support, account eligibility, rate limits, terms and free quota. Quotas and pricing can change.

## Responsibilities
Flutter: UI, navigation, camera/gallery permissions, preview, appropriate image compression, typed API client, state rendering.
FastAPI: request validation, feature orchestration, AI provider calls, response validation, safe errors, bounded rate limits/timeouts.
Supabase: Auth and minimal relational data only where needed. Use Row Level Security for user-owned data.
AI adapter: provider-specific implementation hidden behind a stable interface; never called directly from Flutter.

## Request flow
Flutter feature screen → feature repository → API client → FastAPI route → input validation → service/use case → AI adapter → schema validation → safe response → UI.

## API proposal (schemas must be frozen in TASK-06)
- `GET /health`
- `POST /api/v1/food-check/assess`
- `POST /api/v1/food-check/answer`
- `POST /api/v1/atur/ingredients`
- `POST /api/v1/atur/recipes`

Every endpoint spec must define auth behavior, content type/size limit, request and response schemas, errors, timeout, data retention, and tests.

## Engineering rules
- `.env` is ignored by Git; `.env.example` has placeholders only.
- AI and privileged Supabase secrets are backend-only.
- Validate MIME type, file size, dimensions and request payload.
- Compress images sensibly (roughly 1200–1600 px longest edge where quality permits).
- Use explicit timeouts and bounded retries only when safe.
- Sanitize logs; do not log image bytes or secret values.
- Validate all AI output against typed schemas (Pydantic backend; typed Dart models).
- Keep UI independent from provider response format.
- Add directories only when needed; do not pre-create a huge empty structure.
