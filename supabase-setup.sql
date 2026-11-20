-- RAI Store database setup
-- Run this entire script in Supabase > SQL Editor > New query.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text,
  role text not null default 'admin' check (role in ('admin'))
);
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  icon text default '◇',
  description text default '',
  created_at timestamptz default now()
);
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category_slug text references public.categories(slug) on update cascade on delete set null,
  price numeric(12,2) not null default 0,
  old_price numeric(12,2) default 0,
  tag text default '',
  image_url text default '',
  description text default '',
  created_at timestamptz default now()
);
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_no text unique not null,
  customer_name text not null,
  phone text not null,
  city text not null,
  district text default '',
  address text not null,
  notes text default '',
  items jsonb not null,
  total numeric(12,2) not null,
  status text not null default 'جديد',
  created_at timestamptz default now()
);
create table if not exists public.complaints (
  id uuid primary key default gen_random_uuid(),
  customer_name text default '',
  contact text not null,
  message text not null,
  status text not null default 'جديدة',
  created_at timestamptz default now()
);
create table if not exists public.store_settings (
  id integer primary key default 1 check (id=1),
  contact_phone text default '',
  contact_email text default '',
  updated_at timestamptz default now()
);
insert into public.store_settings(id) values(1) on conflict do nothing;

create or replace function public.is_rai_admin()
returns boolean language sql stable security definer
set search_path=public
as $$
 select exists(select 1 from public.profiles where id=auth.uid() and role='admin');
$$;

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.complaints enable row level security;
alter table public.store_settings enable row level security;

create policy "profile self read" on public.profiles for select to authenticated using (id=auth.uid());
create policy "admin profile update" on public.profiles for update to authenticated using (public.is_rai_admin()) with check (public.is_rai_admin());

create policy "public read categories" on public.categories for select to anon, authenticated using (true);
create policy "admin manage categories" on public.categories for all to authenticated using (public.is_rai_admin()) with check (public.is_rai_admin());
create policy "public read products" on public.products for select to anon, authenticated using (true);
create policy "admin manage products" on public.products for all to authenticated using (public.is_rai_admin()) with check (public.is_rai_admin());

-- Guests may submit orders, but only authenticated admins can read/update them.
create policy "guest submit orders" on public.orders for insert to anon, authenticated with check (true);
create policy "admin read orders" on public.orders for select to authenticated using (public.is_rai_admin());
create policy "admin update orders" on public.orders for update to authenticated using (public.is_rai_admin()) with check (public.is_rai_admin());

create policy "guest submit complaints" on public.complaints for insert to anon, authenticated with check (true);
create policy "admin manage complaints" on public.complaints for all to authenticated using (public.is_rai_admin()) with check (public.is_rai_admin());

create policy "public read settings" on public.store_settings for select to anon, authenticated using (true);
create policy "admin update settings" on public.store_settings for update to authenticated using (public.is_rai_admin()) with check (public.is_rai_admin());

grant usage on schema public to anon, authenticated;
grant select on public.categories, public.products, public.store_settings to anon, authenticated;
grant insert on public.orders, public.complaints to anon, authenticated;
grant select, update on public.orders, public.complaints, public.store_settings to authenticated;
grant insert, update, delete on public.products, public.categories to authenticated;
grant select, update on public.profiles to authenticated;


insert into public.categories(slug,name,icon,description) values
('couples','منتجات الأزواج','♡','مجموعة مختارة من المنتجات المخصصة للبالغين.'),('women','العناية النسائية','✿','منتجات عناية ورفاهية شخصية.'),('men','العناية الرجالية','◈','منتجات عناية ورفاهية رجالية.'),('accessories','الإكسسوارات','◇','إكسسوارات ومنتجات مكملة.'),('wellness','العناية والرفاهية','❋','اختيارات للعناية والراحة الشخصية.'),('offers','العروض الخاصة','％','منتجات مختارة ضمن عروض المتجر.') on conflict (slug) do nothing;
insert into public.products(name,category_slug,price,old_price,tag,description) values
('مجموعة راي المميزة','couples',189,229,'الأكثر طلباً','مجموعة مختارة بتصميم أنيق وتغليف راقٍ.'),('جهاز عناية شخصي','women',149,179,'جديد','منتج عناية شخصية بتصميم عملي.'),('مجموعة العناية الرجالية','men',219,259,'عرض خاص','اختيار مميز ضمن مجموعة العناية الرجالية.'),('إكسسوار راي الأنيق','accessories',79,99,'','إكسسوار أنيق يكمل اختياراتك.'),('منتج الرفاهية اليومي','wellness',119,0,'','منتج مختار للعناية والرفاهية الشخصية.'),('مجموعة الاختيار الخاص','couples',249,299,'الأكثر مبيعاً','مجموعة راقية ضمن تشكيلة راي.'),('أساسيات العناية','women',99,0,'','منتج من أساسيات العناية الشخصية.'),('مجموعة راي اليومية','men',169,199,'خصم','مجموعة عملية بتصميم أنيق.') on conflict do nothing;
