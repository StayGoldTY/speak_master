# V2 Speech Functions

## Functions

- `submit-speaking-attempt`
  Receives a learner speaking attempt, optionally transcribes uploaded audio with OpenAI, generates structured speaking feedback and an assessment report, then writes `speaking_attempts`, `assessment_reports`, and `review_queue`.

## Required Secrets

Set these in Supabase before deploying:

- `OPENAI_API_KEY`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

## Deploy

```bash
supabase functions deploy submit-speaking-attempt
```

## Client Expectations

- The Flutter web client will try to upload recorded audio bytes for cloud transcription.
- If cloud assessment is unavailable, the app falls back to local transcript-based feedback and keeps the UI honest about that fallback.
