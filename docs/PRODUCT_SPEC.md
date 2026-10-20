# Product Specification — Kura AI MVP

## Product purpose
Help people make a cautious first assessment based on visible food cues and turn leftover ingredients into practical recipe ideas. This is not a laboratory test, medical diagnosis, or guarantee of food safety.

## Food Check user journey
1. Enter Food Check.
2. Capture an image or choose one from gallery.
3. Validate the image and show preview; user can retake/change it.
4. Submit to backend.
5. Show a simple scanning/loading state and handle timeout/offline/provider errors.
6. If important context is missing, ask a small number of follow-up questions (e.g. storage, smell, texture for fresh food).
7. Show result status, explanation, limitations, and a practical next action.

Stable statuses:
- `LOOKS_OK`: no concerning cue identified from available information; not a safety guarantee.
- `CHECK_FURTHER`: more information or human inspection is needed.
- `AVOID_EATING`: evidence or reported signs indicate food should not be eaten.
- `UNABLE_TO_ASSESS`: insufficient/poor/conflicting information.

Never use visual AI to guess a barcode or claim to detect invisible pathogens/toxins. Expiry OCR and barcode are deferred. If uncertain, choose a cautious status.

## Atur user journey
1. Capture/select photo of leftover ingredients.
2. Preview image.
3. Backend returns candidate ingredients, clearly presented as suggestions.
4. User can edit, add, or remove ingredients and confirm the final list.
5. Generate exactly three distinct recipe cards.
6. Select a card to see ingredients, quantities where possible, and numbered cooking steps.
7. Respect user-stated allergies. If allergy data is not provided, do not claim recipes are allergen-safe.

## Accounts and guest
- Guest mode can use both main flows.
- Account registration/login is included early using Supabase Auth, but must not block guest access.
- No feature history is stored permanently by default.
- If an account profile is needed, store only minimum required profile data with appropriate access control.
- Never persist image bytes by default.

## MVP exclusions
Chat assistant, barcode scanner, expiry OCR, history, saved recipes, web release, Dark Mode, nutrition dashboard, shopping list, meal planner, push notifications and advanced analytics.

## Definition of product success
- Both flows can be completed on Android.
- User previews images before sending them.
- Food Check expresses uncertainty safely and handles follow-up questions.
- Atur allows ingredient correction and returns exactly three recipe options.
- Loading, empty, permission denied, network failure, timeout and backend failure are handled without crashing.
- Secrets remain server-side.
- Tests and repeatable setup/demo instructions exist.
