-- Run in Supabase SQL Editor before using the member profile/dashboard.
alter table public.profiles add column if not exists member_id uuid references public.members(id);
alter table public.members add column if not exists photo_url text;

-- Link each member login to exactly one members row:
-- update public.profiles set member_id='MEMBERS_ROW_UUID' where id='AUTH_USER_UUID';

-- Members may read only their own profile/member/transactions/loans/installments.
alter table public.profiles enable row level security;
alter table public.members enable row level security;
alter table public.transactions enable row level security;
alter table public.loans enable row level security;
alter table public.loan_installments enable row level security;

create policy "Members read own member record" on public.members for select to authenticated
using (id = (select member_id from public.profiles where id = auth.uid() and role='member' and is_active=true));
create policy "Members read own transactions" on public.transactions for select to authenticated
using (member_id = (select member_id from public.profiles where id = auth.uid() and role='member' and is_active=true));
create policy "Members read own loans" on public.loans for select to authenticated
using (member_id = (select member_id from public.profiles where id = auth.uid() and role='member' and is_active=true));
create policy "Members read own installments" on public.loan_installments for select to authenticated
using (loan_id in (select id from public.loans where member_id = (select member_id from public.profiles where id = auth.uid() and role='member' and is_active=true)));
