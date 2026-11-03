-- KICEBREAKER 저장소 설정. Supabase 대시보드 > SQL Editor 에 통째로 붙여 넣고 실행하십시오.
-- 실행 전에 아래 OWNER_EMAIL 한 곳만 관리자 구글 계정 주소로 바꾸십시오.

create table if not exists public.docs(
  coll text not null,
  id text not null,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (coll, id)
);
alter table public.docs enable row level security;

-- 관리자 판별: 구글 로그인 이메일이 일치할 때만 true (익명 로그인은 이메일이 없어 항상 false)
create or replace function public.is_owner() returns boolean
language sql stable as $$
  select coalesce(auth.jwt()->>'email','') = 'OWNER_EMAIL'
$$;

-- 쓰기 권한: 관리자는 전부, 방문자는 자기 번호의 문서만
create or replace function public.can_write(c text, i text) returns boolean
language sql stable as $$
  select public.is_owner()
      or (c in ('votes','comments','nicks','reacts','reports') and i = auth.uid()::text)
$$;

-- 읽기: 제보(reports)는 본인과 관리자만, 나머지는 모두
create policy docs_read on public.docs for select
  using (coll <> 'reports' or id = auth.uid()::text or public.is_owner());
create policy docs_insert on public.docs for insert
  with check (public.can_write(coll, id) and pg_column_size(data) < 250000);
create policy docs_update on public.docs for update
  using (public.can_write(coll, id))
  with check (public.can_write(coll, id) and pg_column_size(data) < 250000);
create policy docs_delete on public.docs for delete
  using (public.can_write(coll, id));

-- 실시간 갱신
alter publication supabase_realtime add table public.docs;

-- 이미지 저장소(공개 읽기, 업로드와 삭제는 관리자만, 3MB 이하 이미지)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('img', 'img', true, 3145728, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do nothing;
create policy img_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'img' and public.is_owner());
create policy img_delete on storage.objects for delete to authenticated
  using (bucket_id = 'img' and public.is_owner());
