-- =============================================
-- SpeakMaster V2 learning platform schema
-- =============================================

create table if not exists public.course_tracks (
  id text primary key,
  title text not null,
  subtitle text,
  description text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.course_versions (
  id text primary key,
  track_id text not null references public.course_tracks(id) on delete cascade,
  version_number integer default 1,
  status text not null check (status in ('draft', 'published', 'archived')),
  source text default 'ai_assisted',
  generated_brief jsonb default '{}'::jsonb,
  created_by uuid references public.profiles(id) on delete set null,
  published_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.units (
  id text primary key,
  track_id text not null references public.course_tracks(id) on delete cascade,
  version_id text not null references public.course_versions(id) on delete cascade,
  legacy_unit_id text,
  sort_order integer not null,
  title text not null,
  subtitle text,
  description text,
  target_phonemes text[] default '{}',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.lessons (
  id text primary key,
  unit_id text not null references public.units(id) on delete cascade,
  version_id text not null references public.course_versions(id) on delete cascade,
  legacy_lesson_id text,
  sort_order integer not null,
  title text not null,
  subtitle text,
  description text,
  estimated_minutes integer default 5,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.activities (
  id text primary key,
  lesson_id text not null references public.lessons(id) on delete cascade,
  version_id text not null references public.course_versions(id) on delete cascade,
  sort_order integer not null,
  activity_kind text not null check (
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
  ),
  title text not null,
  instruction text not null,
  reference_text text,
  payload jsonb default '{}'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.enrollments (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  track_id text not null references public.course_tracks(id) on delete cascade,
  version_id text references public.course_versions(id) on delete set null,
  current_unit_id text references public.units(id) on delete set null,
  current_lesson_id text references public.lessons(id) on delete set null,
  started_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (user_id, track_id)
);

create table if not exists public.daily_plans (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  plan_date date not null,
  headline text not null,
  subtitle text,
  source text default 'system',
  created_at timestamptz default now(),
  unique (user_id, plan_date)
);

create table if not exists public.daily_plan_items (
  id uuid default gen_random_uuid() primary key,
  daily_plan_id uuid not null references public.daily_plans(id) on delete cascade,
  item_order integer not null,
  item_kind text not null check (item_kind in ('lesson', 'review', 'speaking', 'assessment', 'dialogue')),
  title text not null,
  subtitle text,
  route text,
  target_lesson_id text references public.lessons(id) on delete set null,
  xp_reward integer default 0,
  estimated_minutes integer default 0,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

create table if not exists public.lesson_attempts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  lesson_id text not null references public.lessons(id) on delete cascade,
  status text not null default 'started' check (status in ('started', 'completed', 'abandoned')),
  completion_rate real default 0,
  xp_earned integer default 0,
  activity_results jsonb default '[]'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.speaking_attempts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  lesson_attempt_id uuid references public.lesson_attempts(id) on delete set null,
  activity_id text references public.activities(id) on delete set null,
  prompt_id text,
  reference_text text,
  recognized_text text,
  coverage_score real default 0,
  fluency_band text,
  pace_band text,
  stress_hints text[] default '{}',
  weak_words text[] default '{}',
  retry_suggestions text[] default '{}',
  teacher_explanation text,
  fallback_used boolean default false,
  weak_point_tags jsonb default '[]'::jsonb,
  audio_url text,
  created_at timestamptz default now()
);

create table if not exists public.assessment_reports (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  source_attempt_id uuid references public.speaking_attempts(id) on delete set null,
  overall_label text not null,
  overview text not null,
  weak_targets jsonb default '[]'::jsonb,
  next_steps jsonb default '[]'::jsonb,
  recommended_route text,
  created_at timestamptz default now()
);

create table if not exists public.review_queue (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  label text not null,
  reason text not null,
  recommended_activity_kind text not null,
  score real default 0,
  source_key text,
  due_at timestamptz default now(),
  completed_at timestamptz,
  created_at timestamptz default now()
);

create table if not exists public.generation_jobs (
  id uuid default gen_random_uuid() primary key,
  created_by uuid references public.profiles(id) on delete set null,
  title text not null,
  job_type text not null,
  status text not null check (status in ('queued', 'reviewing', 'failed', 'ready')),
  input_payload jsonb default '{}'::jsonb,
  output_schema_name text,
  error_message text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.generation_artifacts (
  id uuid default gen_random_uuid() primary key,
  job_id uuid not null references public.generation_jobs(id) on delete cascade,
  artifact_type text not null,
  content jsonb default '{}'::jsonb,
  version_id text references public.course_versions(id) on delete set null,
  created_at timestamptz default now()
);

create table if not exists public.app_events (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete set null,
  event_name text not null,
  session_id text,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

create table if not exists public.plans (
  id text primary key,
  display_name text not null,
  interval text not null,
  is_active boolean default true,
  created_at timestamptz default now()
);

create table if not exists public.entitlements (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  plan_id text references public.plans(id) on delete set null,
  status text not null default 'inactive' check (status in ('inactive', 'trialing', 'active', 'expired', 'revoked')),
  starts_at timestamptz,
  ends_at timestamptz,
  source text default 'manual',
  created_at timestamptz default now()
);

create index if not exists idx_course_versions_track on public.course_versions(track_id);
create index if not exists idx_units_version on public.units(version_id, sort_order);
create index if not exists idx_lessons_unit on public.lessons(unit_id, sort_order);
create index if not exists idx_activities_lesson on public.activities(lesson_id, sort_order);
create index if not exists idx_daily_plans_user_date on public.daily_plans(user_id, plan_date desc);
create index if not exists idx_lesson_attempts_user on public.lesson_attempts(user_id, created_at desc);
create index if not exists idx_speaking_attempts_user on public.speaking_attempts(user_id, created_at desc);
create index if not exists idx_review_queue_user on public.review_queue(user_id, due_at asc);
create index if not exists idx_generation_jobs_status on public.generation_jobs(status, created_at desc);
create index if not exists idx_app_events_name on public.app_events(event_name, created_at desc);

alter table public.course_tracks enable row level security;
alter table public.course_versions enable row level security;
alter table public.units enable row level security;
alter table public.lessons enable row level security;
alter table public.activities enable row level security;
alter table public.enrollments enable row level security;
alter table public.daily_plans enable row level security;
alter table public.daily_plan_items enable row level security;
alter table public.lesson_attempts enable row level security;
alter table public.speaking_attempts enable row level security;
alter table public.assessment_reports enable row level security;
alter table public.review_queue enable row level security;
alter table public.generation_jobs enable row level security;
alter table public.generation_artifacts enable row level security;
alter table public.app_events enable row level security;
alter table public.plans enable row level security;
alter table public.entitlements enable row level security;

create policy "Published course tracks are visible"
  on public.course_tracks for select using (true);

create policy "Published course versions are visible"
  on public.course_versions for select using (status = 'published');

create policy "Published units are visible"
  on public.units for select using (
    exists (
      select 1 from public.course_versions cv
      where cv.id = version_id and cv.status = 'published'
    )
  );

create policy "Published lessons are visible"
  on public.lessons for select using (
    exists (
      select 1 from public.course_versions cv
      where cv.id = version_id and cv.status = 'published'
    )
  );

create policy "Published activities are visible"
  on public.activities for select using (
    exists (
      select 1 from public.course_versions cv
      where cv.id = version_id and cv.status = 'published'
    )
  );

create policy "Learners manage own enrollments"
  on public.enrollments for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Learners manage own daily plans"
  on public.daily_plans for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Learners view own plan items"
  on public.daily_plan_items for select using (
    exists (
      select 1 from public.daily_plans dp
      where dp.id = daily_plan_id and dp.user_id = auth.uid()
    )
  );

create policy "Learners manage own lesson attempts"
  on public.lesson_attempts for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Learners manage own speaking attempts"
  on public.speaking_attempts for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Learners manage own assessment reports"
  on public.assessment_reports for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Learners manage own review queue"
  on public.review_queue for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Learners manage own app events"
  on public.app_events for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Plans are visible"
  on public.plans for select using (true);

create policy "Learners view own entitlements"
  on public.entitlements for select using (auth.uid() = user_id);

create policy "Authenticated authors create course versions"
  on public.course_versions for insert with check (auth.uid() = created_by);

create policy "Authenticated authors update course versions"
  on public.course_versions for update using (auth.uid() = created_by);

create policy "Authenticated authors create generation jobs"
  on public.generation_jobs for insert with check (auth.uid() = created_by);

create policy "Authenticated authors update generation jobs"
  on public.generation_jobs for update using (auth.uid() = created_by);

create policy "Authenticated authors view generation jobs"
  on public.generation_jobs for select using (auth.uid() = created_by);

create policy "Authors view own generation artifacts"
  on public.generation_artifacts for select using (
    exists (
      select 1 from public.generation_jobs gj
      where gj.id = job_id and gj.created_by = auth.uid()
    )
  );

create policy "Authors insert own generation artifacts"
  on public.generation_artifacts for insert with check (
    exists (
      select 1 from public.generation_jobs gj
      where gj.id = job_id and gj.created_by = auth.uid()
    )
  );

create or replace trigger course_tracks_updated_at
  before update on public.course_tracks
  for each row execute function public.update_updated_at();

create or replace trigger course_versions_updated_at
  before update on public.course_versions
  for each row execute function public.update_updated_at();

create or replace trigger units_updated_at
  before update on public.units
  for each row execute function public.update_updated_at();

create or replace trigger lessons_updated_at
  before update on public.lessons
  for each row execute function public.update_updated_at();

create or replace trigger activities_updated_at
  before update on public.activities
  for each row execute function public.update_updated_at();

create or replace trigger enrollments_updated_at
  before update on public.enrollments
  for each row execute function public.update_updated_at();

create or replace trigger lesson_attempts_updated_at
  before update on public.lesson_attempts
  for each row execute function public.update_updated_at();

create or replace trigger generation_jobs_updated_at
  before update on public.generation_jobs
  for each row execute function public.update_updated_at();
