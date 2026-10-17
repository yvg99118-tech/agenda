-- Cole tudo isto no Supabase: SQL Editor > New query > Run
create extension if not exists btree_gist;
create table consultas (
  id uuid primary key default gen_random_uuid(),
  paciente text not null,
  tel text default '',
  profissional text not null,
  sala int not null check (sala in (1,2)),
  inicio timestamptz not null,
  fim timestamptz not null,
  status text not null default 'agendado' check (status in ('agendado','confirmado','compareceu','faltou','remarcado','cancelado')),
  obs text default '',
  serie uuid,
  criado_por text, atualizado_por text,
  criado_em timestamptz default now(), atualizado_em timestamptz default now()
);
-- impede dois pacientes na mesma sala/horário e o mesmo profissional em dois lugares
alter table consultas add constraint sem_conflito_sala exclude using gist (sala with =, tstzrange(inicio,fim) with &&) where (status not in ('cancelado','remarcado'));
alter table consultas add constraint sem_conflito_prof exclude using gist (profissional with =, tstzrange(inicio,fim) with &&) where (status not in ('cancelado','remarcado'));
alter table consultas enable row level security;
create policy equipe on consultas for all to authenticated using (true) with check (true);
alter publication supabase_realtime add table consultas;
