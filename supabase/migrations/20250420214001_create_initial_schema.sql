-- Migration: Create Initial Schema for KnowQuiz Application
-- Description: Sets up all tables, relations, and security policies for the KnowQuiz MVP
-- Tables: profiles, topics, lessons, flashcards, learning_status, learning_sessions, openai_logs
-- Author: Database Administrator
-- Date: 2025-04-20

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Creates custom types
create type user_role as enum ('user', 'admin');

-- Create profiles table that extends Supabase auth.users
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role user_role not null default 'user',
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Enable RLS on profiles table
alter table public.profiles enable row level security;

-- Create RLS policies for profiles table
-- Admins can see all profiles
create policy "Admins can see all profiles"
  on public.profiles
  for select
  to authenticated
  using (auth.jwt() ->> 'role' = 'admin');

-- Users can see their own profile
create policy "Users can see their own profile"
  on public.profiles
  for select
  to authenticated
  using (auth.uid() = id);

-- Users can update their own profile
create policy "Users can update their own profile"
  on public.profiles
  for update
  to authenticated
  using (auth.uid() = id);

-- Create trigger to create a profile entry when a new user signs up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id)
  values (new.id);
  return new;
end;
$$ language plpgsql security definer;

-- Run this trigger after a user signs up
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Create topics table
create table public.topics (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  description text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  unique(user_id, name) -- Ensure topic names are unique for each user
);

-- Enable RLS on topics table
alter table public.topics enable row level security;

-- Create RLS policies for topics table
-- Admins can see all topics
create policy "Admins can see all topics"
  on public.topics
  for select
  to authenticated
  using (auth.jwt() ->> 'role' = 'admin');

-- Users can see their own topics
create policy "Users can see their own topics"
  on public.topics
  for select
  to authenticated
  using (auth.uid() = user_id);

-- Users can insert their own topics
create policy "Users can insert their own topics"
  on public.topics
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Users can update their own topics
create policy "Users can update their own topics"
  on public.topics
  for update
  to authenticated
  using (auth.uid() = user_id);

-- Users can delete their own topics
create policy "Users can delete their own topics"
  on public.topics
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- Create lessons table
create table public.lessons (
  id uuid primary key default uuid_generate_v4(),
  topic_id uuid not null references public.topics(id) on delete cascade,
  name text not null,
  description text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  unique(topic_id, name) -- Ensure lesson names are unique within a topic
);

-- Enable RLS on lessons table
alter table public.lessons enable row level security;

-- Create RLS policies for lessons table
-- Admins can see all lessons
create policy "Admins can see all lessons"
  on public.lessons
  for select
  to authenticated
  using (auth.jwt() ->> 'role' = 'admin');

-- Users can see their own lessons
create policy "Users can see their own lessons"
  on public.lessons
  for select
  to authenticated
  using (
    exists (
      select 1 from public.topics
      where topics.id = lessons.topic_id
      and topics.user_id = auth.uid()
    )
  );

-- Users can insert lessons into their own topics
create policy "Users can insert lessons into their own topics"
  on public.lessons
  for insert
  to authenticated
  with check (
    exists (
      select 1 from public.topics
      where topics.id = lessons.topic_id
      and topics.user_id = auth.uid()
    )
  );

-- Users can update their own lessons
create policy "Users can update their own lessons"
  on public.lessons
  for update
  to authenticated
  using (
    exists (
      select 1 from public.topics
      where topics.id = lessons.topic_id
      and topics.user_id = auth.uid()
    )
  );

-- Users can delete their own lessons
create policy "Users can delete their own lessons"
  on public.lessons
  for delete
  to authenticated
  using (
    exists (
      select 1 from public.topics
      where topics.id = lessons.topic_id
      and topics.user_id = auth.uid()
    )
  );

-- Create flashcards table
create table public.flashcards (
  id uuid primary key default uuid_generate_v4(),
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  question text not null,
  answer text not null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Enable RLS on flashcards table
alter table public.flashcards enable row level security;

-- Create RLS policies for flashcards table
-- Admins can see all flashcards
create policy "Admins can see all flashcards"
  on public.flashcards
  for select
  to authenticated
  using (auth.jwt() ->> 'role' = 'admin');

-- Users can see their own flashcards
create policy "Users can see their own flashcards"
  on public.flashcards
  for select
  to authenticated
  using (
    exists (
      select 1 from public.lessons
      join public.topics on lessons.topic_id = topics.id
      where flashcards.lesson_id = lessons.id
      and topics.user_id = auth.uid()
    )
  );

-- Users can insert flashcards into their own lessons
create policy "Users can insert flashcards into their own lessons"
  on public.flashcards
  for insert
  to authenticated
  with check (
    exists (
      select 1 from public.lessons
      join public.topics on lessons.topic_id = topics.id
      where flashcards.lesson_id = lessons.id
      and topics.user_id = auth.uid()
    )
  );

-- Users can update their own flashcards
create policy "Users can update their own flashcards"
  on public.flashcards
  for update
  to authenticated
  using (
    exists (
      select 1 from public.lessons
      join public.topics on lessons.topic_id = topics.id
      where flashcards.lesson_id = lessons.id
      and topics.user_id = auth.uid()
    )
  );

-- Users can delete their own flashcards
create policy "Users can delete their own flashcards"
  on public.flashcards
  for delete
  to authenticated
  using (
    exists (
      select 1 from public.lessons
      join public.topics on lessons.topic_id = topics.id
      where flashcards.lesson_id = lessons.id
      and topics.user_id = auth.uid()
    )
  );

-- Create learning_status table to track flashcard learning progress
create table public.learning_status (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  flashcard_id uuid not null references public.flashcards(id) on delete cascade,
  is_learned boolean not null default false,
  last_reviewed_at timestamp with time zone not null default now(),
  created_at timestamp with time zone not null default now(),
  unique(user_id, flashcard_id) -- One learning status per flashcard per user
);

-- Enable RLS on learning_status table
alter table public.learning_status enable row level security;

-- Create RLS policies for learning_status table
-- Admins can see all learning statuses
create policy "Admins can see all learning statuses"
  on public.learning_status
  for select
  to authenticated
  using (auth.jwt() ->> 'role' = 'admin');

-- Users can see their own learning statuses
create policy "Users can see their own learning statuses"
  on public.learning_status
  for select
  to authenticated
  using (user_id = auth.uid());

-- Users can insert their own learning statuses
create policy "Users can insert their own learning statuses"
  on public.learning_status
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- Users can update their own learning statuses
create policy "Users can update their own learning statuses"
  on public.learning_status
  for update
  to authenticated
  using (user_id = auth.uid());

-- Users can delete their own learning statuses
create policy "Users can delete their own learning statuses"
  on public.learning_status
  for delete
  to authenticated
  using (user_id = auth.uid());

-- Create learning_sessions table
create table public.learning_sessions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  started_at timestamp with time zone not null default now(),
  ended_at timestamp with time zone,
  cards_reviewed integer not null default 0,
  cards_learned integer not null default 0,
  created_at timestamp with time zone not null default now()
);

-- Enable RLS on learning_sessions table
alter table public.learning_sessions enable row level security;

-- Create RLS policies for learning_sessions table
-- Admins can see all learning sessions
create policy "Admins can see all learning sessions"
  on public.learning_sessions
  for select
  to authenticated
  using (auth.jwt() ->> 'role' = 'admin');

-- Users can see their own learning sessions
create policy "Users can see their own learning sessions"
  on public.learning_sessions
  for select
  to authenticated
  using (user_id = auth.uid());

-- Users can insert their own learning sessions
create policy "Users can insert their own learning sessions"
  on public.learning_sessions
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- Users can update their own learning sessions
create policy "Users can update their own learning sessions"
  on public.learning_sessions
  for update
  to authenticated
  using (user_id = auth.uid());

-- Users can delete their own learning sessions
create policy "Users can delete their own learning sessions"
  on public.learning_sessions
  for delete
  to authenticated
  using (user_id = auth.uid());

-- Create openai_logs table
create table public.openai_logs (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  operation_type text not null, -- e.g., 'generate_answer', 'check_answer'
  request_data jsonb not null,
  response_data jsonb not null,
  tokens_used integer not null default 0,
  cost numeric(10, 6) not null default 0,
  created_at timestamp with time zone not null default now()
);

-- Enable RLS on openai_logs table
alter table public.openai_logs enable row level security;

-- Create RLS policies for openai_logs table
-- Admins can see all openai logs
create policy "Admins can see all openai logs"
  on public.openai_logs
  for select
  to authenticated
  using (auth.jwt() ->> 'role' = 'admin');

-- Users can see their own openai logs
create policy "Users can see their own openai logs"
  on public.openai_logs
  for select
  to authenticated
  using (user_id = auth.uid());

-- Only admins can delete logs
create policy "Only admins can delete openai logs"
  on public.openai_logs
  for delete
  to authenticated
  using (auth.jwt() ->> 'role' = 'admin');

-- Users can insert their own openai logs
create policy "Users can insert their own openai logs"
  on public.openai_logs
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- Create indexes for better query performance
create index profiles_role_idx on public.profiles(role);
create index topics_user_id_idx on public.topics(user_id);
create index lessons_topic_id_idx on public.lessons(topic_id);
create index flashcards_lesson_id_idx on public.flashcards(lesson_id);
create index learning_status_user_id_idx on public.learning_status(user_id);
create index learning_status_flashcard_id_idx on public.learning_status(flashcard_id);
create index learning_status_is_learned_idx on public.learning_status(is_learned);
create index learning_status_last_reviewed_at_idx on public.learning_status(last_reviewed_at);
create index learning_sessions_user_id_idx on public.learning_sessions(user_id);
create index learning_sessions_lesson_id_idx on public.learning_sessions(lesson_id);
create index openai_logs_user_id_idx on public.openai_logs(user_id);
create index openai_logs_created_at_idx on public.openai_logs(created_at);

-- Function to automatically update updated_at timestamp
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Create triggers to automatically update updated_at
create trigger set_updated_at
before update on public.profiles
for each row
execute function update_updated_at_column();

create trigger set_updated_at
before update on public.topics
for each row
execute function update_updated_at_column();

create trigger set_updated_at
before update on public.lessons
for each row
execute function update_updated_at_column();

create trigger set_updated_at
before update on public.flashcards
for each row
execute function update_updated_at_column();

-- Function to update admin role in JWT claims when a user is granted admin role
create or replace function public.handle_admin_update()
returns trigger as $$
begin
  if new.role = 'admin' and (old.role is null or old.role <> 'admin') then
    update auth.users set raw_app_meta_data = 
      raw_app_meta_data || json_build_object('role', 'admin')::jsonb
      where id = new.id;
  elsif new.role = 'user' and old.role = 'admin' then
    update auth.users set raw_app_meta_data = 
      raw_app_meta_data - 'role'
      where id = new.id;
  end if;
  return new;
end;
$$ language plpgsql security definer;

-- Create trigger to update JWT claims when admin role changes
create trigger on_admin_role_update
  after update of role on public.profiles
  for each row execute function public.handle_admin_update();

-- Function to automatically create learning_status when flashcard is created
create or replace function create_learning_status_for_new_flashcard()
returns trigger as $$
declare
  creator_id uuid;
begin
  -- Find the user_id of the topic owner
  select topics.user_id into creator_id
  from public.lessons
  join public.topics on lessons.topic_id = topics.id
  where lessons.id = new.lesson_id;
  
  -- Create learning_status entry for the creator
  insert into public.learning_status (user_id, flashcard_id)
  values (creator_id, new.id);
  
  return new;
end;
$$ language plpgsql;

-- Create trigger to automatically create learning_status
create trigger create_learning_status_after_flashcard_insert
after insert on public.flashcards
for each row
execute function create_learning_status_for_new_flashcard();

-- Function to automatically update last_reviewed_at when learning_status is updated
create or replace function update_last_reviewed_at()
returns trigger as $$
begin
  new.last_reviewed_at = now();
  return new;
end;
$$ language plpgsql;

-- Create trigger to automatically update last_reviewed_at
create trigger update_last_reviewed_at_on_learning_status
before update of is_learned on public.learning_status
for each row
execute function update_last_reviewed_at();

-- Create a function to select flashcards for learning
create or replace function select_flashcards_for_learning(
  p_lesson_id uuid,
  p_user_id uuid,
  p_limit integer default 10
)
returns table (
  id uuid,
  question text,
  answer text,
  is_learned boolean,
  last_reviewed_at timestamp with time zone
)
language sql
as $$
  -- First select unlearned flashcards, then learned ones ordered by last review time
  select 
    f.id,
    f.question,
    f.answer,
    ls.is_learned,
    ls.last_reviewed_at
  from 
    public.flashcards f
  join 
    public.learning_status ls on f.id = ls.flashcard_id
  where 
    f.lesson_id = p_lesson_id
    and ls.user_id = p_user_id
  order by 
    ls.is_learned asc,
    ls.last_reviewed_at asc
  limit p_limit;
$$; 