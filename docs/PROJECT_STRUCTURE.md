# Target Structure (incremental, not a demand to create everything at once)

At root:
- `AGENTS.md`
- `README_START_HERE.md`
- `docs/`
- `tasks/`
- `frontend/` (Flutter)
- `backend/` (FastAPI)
- `.gitignore`

Flutter feature-oriented structure, added incrementally:
`frontend/lib/main.dart`
`frontend/lib/app/` (app, router)
`frontend/lib/core/` (theme, constants, network, errors)
`frontend/lib/shared/` (reusable widgets/models)
`frontend/lib/features/home/`
`frontend/lib/features/food_check/`
`frontend/lib/features/atur/`
`frontend/lib/features/authentication/`
`frontend/assets/` and `frontend/test/`

Backend, added incrementally:
`backend/app/main.py`
`backend/app/api/routes/`
`backend/app/core/` (config/security)
`backend/app/services/` (food_check, atur, ai)
`backend/app/schemas/`
`backend/tests/`
`backend/requirements.txt`
`backend/.env.example`

Do not force this structure onto an existing project without auditing it. Preserve existing structure when reasonable and report deviations.
