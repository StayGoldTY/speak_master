-- =============================================
-- SpeakMaster V2 speech runtime support
-- =============================================

alter table public.speaking_attempts
  add column if not exists attempt_source text not null default 'local_fallback'
    check (attempt_source in ('cloud', 'local_fallback')),
  add column if not exists accent_preference text
    check (accent_preference in ('american', 'british')),
  add column if not exists transcript_source text not null default 'local_hint'
    check (transcript_source in ('cloud_stt', 'local_hint')),
  add column if not exists audio_duration_ms integer,
  add column if not exists activity_kind text
    check (
      activity_kind in (
        'phoneme_intro',
        'minimal_pair',
        'word_repeat',
        'sentence_read_aloud',
        'shadowing',
        'dialog_roleplay',
        'dictation',
        'mcq',
        'speaking_reflection',
        'assessment_task'
      )
    );

alter table public.assessment_reports
  add column if not exists attempt_source text not null default 'local_fallback'
    check (attempt_source in ('cloud', 'local_fallback'));

create index if not exists idx_speaking_attempts_prompt
  on public.speaking_attempts(prompt_id, created_at desc);
