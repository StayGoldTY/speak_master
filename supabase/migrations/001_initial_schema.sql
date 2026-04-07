-- =============================================
-- SpeakMaster 数据库初始化迁移
-- =============================================

-- 1. 用户资料表
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique,
  display_name text,
  avatar_url text,
  is_pro boolean default false,
  accent_preference text default 'american' check (accent_preference in ('american', 'british')),
  daily_reminder_time time,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Users can view all profiles"
  on public.profiles for select using (true);

create policy "Users can update own profile"
  on public.profiles for update using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.profiles for insert with check (auth.uid() = id);

-- 2. 学习进度表
create table if not exists public.user_progress (
  user_id uuid references public.profiles(id) on delete cascade primary key,
  streak_days integer default 0,
  total_xp integer default 0,
  level integer default 1,
  today_assessment_count integer default 0,
  last_active_date timestamptz,
  completed_lessons text[] default '{}',
  completed_units text[] default '{}',
  earned_badges text[] default '{}',
  phoneme_scores jsonb default '{}',
  streak_freeze_remaining integer default 1,
  updated_at timestamptz default now()
);

alter table public.user_progress enable row level security;

create policy "Users can view own progress"
  on public.user_progress for select using (auth.uid() = user_id);

create policy "Users can update own progress"
  on public.user_progress for update using (auth.uid() = user_id);

create policy "Users can insert own progress"
  on public.user_progress for insert with check (auth.uid() = user_id);

-- 3. 发音评测记录表
create table if not exists public.assessment_records (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  sentence text not null,
  accuracy_score real default 0,
  fluency_score real default 0,
  intonation_score real default 0,
  stress_score real default 0,
  overall_score real default 0,
  weak_phonemes text[] default '{}',
  audio_url text,
  created_at timestamptz default now()
);

alter table public.assessment_records enable row level security;

create policy "Users can view own assessments"
  on public.assessment_records for select using (auth.uid() = user_id);

create policy "Users can insert own assessments"
  on public.assessment_records for insert with check (auth.uid() = user_id);

-- 4. 社区帖子表
create table if not exists public.posts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  content text not null check (char_length(content) <= 500),
  post_type text default 'share' check (post_type in ('share', 'achievement', 'streak')),
  likes_count integer default 0,
  comments_count integer default 0,
  created_at timestamptz default now()
);

alter table public.posts enable row level security;

create policy "Anyone can view posts"
  on public.posts for select using (true);

create policy "Authenticated users can create posts"
  on public.posts for insert with check (auth.uid() = user_id);

create policy "Users can delete own posts"
  on public.posts for delete using (auth.uid() = user_id);

-- 5. 评论表
create table if not exists public.comments (
  id uuid default gen_random_uuid() primary key,
  post_id uuid references public.posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  content text not null check (char_length(content) <= 300),
  created_at timestamptz default now()
);

alter table public.comments enable row level security;

create policy "Anyone can view comments"
  on public.comments for select using (true);

create policy "Authenticated users can create comments"
  on public.comments for insert with check (auth.uid() = user_id);

create policy "Users can delete own comments"
  on public.comments for delete using (auth.uid() = user_id);

-- 6. 点赞表
create table if not exists public.likes (
  user_id uuid references public.profiles(id) on delete cascade,
  post_id uuid references public.posts(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (user_id, post_id)
);

alter table public.likes enable row level security;

create policy "Anyone can view likes"
  on public.likes for select using (true);

create policy "Authenticated users can toggle likes"
  on public.likes for insert with check (auth.uid() = user_id);

create policy "Users can remove own likes"
  on public.likes for delete using (auth.uid() = user_id);

-- 7. 排行榜视图
create or replace view public.leaderboard as
select
  p.id,
  p.username,
  p.display_name,
  p.avatar_url,
  up.total_xp,
  up.streak_days,
  up.level,
  rank() over (order by up.total_xp desc) as rank
from public.profiles p
join public.user_progress up on p.id = up.user_id
where up.total_xp > 0
order by up.total_xp desc
limit 100;

-- 8. 每周排行榜需要的 weekly_xp 表
create table if not exists public.weekly_xp (
  user_id uuid references public.profiles(id) on delete cascade,
  week_start date not null,
  xp_earned integer default 0,
  primary key (user_id, week_start)
);

alter table public.weekly_xp enable row level security;

create policy "Anyone can view weekly xp"
  on public.weekly_xp for select using (true);

create policy "Users can update own weekly xp"
  on public.weekly_xp for upsert using (auth.uid() = user_id);

create policy "Users can insert own weekly xp"
  on public.weekly_xp for insert with check (auth.uid() = user_id);

-- 9. 自动创建 profile 和 progress 的触发器
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', '发音学习者'),
    coalesce(new.raw_user_meta_data ->> 'avatar_url', null)
  );

  insert into public.user_progress (user_id)
  values (new.id);

  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 10. 更新 updated_at 的通用触发器
create or replace function public.update_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.update_updated_at();

create trigger user_progress_updated_at
  before update on public.user_progress
  for each row execute function public.update_updated_at();

-- 11. 点赞计数同步函数
create or replace function public.update_post_likes_count()
returns trigger
language plpgsql
security definer
as $$
begin
  if TG_OP = 'INSERT' then
    update public.posts set likes_count = likes_count + 1 where id = new.post_id;
    return new;
  elsif TG_OP = 'DELETE' then
    update public.posts set likes_count = likes_count - 1 where id = old.post_id;
    return old;
  end if;
end;
$$;

create trigger on_like_change
  after insert or delete on public.likes
  for each row execute function public.update_post_likes_count();

-- 12. 评论计数同步
create or replace function public.update_post_comments_count()
returns trigger
language plpgsql
security definer
as $$
begin
  if TG_OP = 'INSERT' then
    update public.posts set comments_count = comments_count + 1 where id = new.post_id;
    return new;
  elsif TG_OP = 'DELETE' then
    update public.posts set comments_count = comments_count - 1 where id = old.post_id;
    return old;
  end if;
end;
$$;

create trigger on_comment_change
  after insert or delete on public.comments
  for each row execute function public.update_post_comments_count();
