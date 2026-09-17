# V2 Speech Functions

## Functions

- `submit-speaking-attempt`
  Receives a learner speaking attempt. If `AZURE_SPEECH_KEY` and `AZURE_SPEECH_REGION` are set and the audio is WAV/PCM or OGG/Opus, it runs Azure Pronunciation Assessment (word + phoneme scores). Otherwise it stores recognition word-alignment only and never invents acoustic scores. Optional `OPENAI_API_KEY` is used only to transcribe unsupported audio formats, not to score pronunciation.

## Required Secrets

Set these in Supabase before deploying:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

For acoustic pronunciation scores:

- `AZURE_SPEECH_KEY`
- `AZURE_SPEECH_REGION` (for example `eastasia` or `eastus`)

Optional transcript fallback for webm:

- `OPENAI_API_KEY`

## Deploy

```bash
supabase functions deploy submit-speaking-attempt
```

## Client Expectations

- The Flutter client records 16 kHz WAV when possible and uploads those bytes.
- Azure REST does not accept webm; the app falls back to recognition alignment and says so.
- If cloud assessment is unavailable, the app falls back to local word alignment and keeps the UI honest about that fallback.
