# Safety, Privacy and Security Rules

## Food Check safety
- A photo cannot prove food is free of pathogens, toxins, contamination or unsafe storage.
- Never present model confidence as the probability that food is safe.
- `LOOKS_OK` means only that no concerning visible cue was identified from available input.
- Poor/conflicting evidence → `CHECK_FURTHER` or `UNABLE_TO_ASSESS`.
- Strong spoilage signs reported by user → advise avoiding consumption.
- Ask follow-up questions only when they can materially improve the assessment.
- Use calm language, clearly state limits, and provide a practical next step.

## Atur safety
- AI-detected ingredients are candidates until user confirms them.
- User can edit/add/remove before recipe generation.
- Respect stated allergies and do not knowingly include a named allergen.
- Do not claim a recipe is allergen-free unless ingredients and cross-contamination limitations are clearly addressed.
- Mark optional pantry ingredients as optional.

## Privacy
- Photos are processed for the request and not permanently stored by default.
- Before first use, clearly disclose that the image is sent to the Kura backend and may be processed by an external AI provider.
- Do not persist feature results/history in MVP unless a later approved task explicitly changes policy.
- Request camera/gallery permission only when needed; provide a usable alternative when permission is denied.
- If account data is stored, collect the minimum and document purpose/retention.

## Security
- Never put provider API keys or Supabase service-role key in Flutter.
- Never commit `.env`, signing keys, passwords or tokens.
- Validate uploads and bound inputs/outputs.
- Use TLS in production, restrictive CORS, authentication/authorization where relevant, and RLS for user-owned data.
- Never log images, tokens, passwords or secrets.
- Sanitize provider errors; do not expose stack traces or internal credentials to users.
- Do not claim deletion/privacy behavior unless it has been implemented and tested.
