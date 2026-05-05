create extension if not exists pgcrypto;

create unique index if not exists idx_rol_empresa_nombre_unique
on public.rol (empresa_id, lower(nombre));

create unique index if not exists idx_acceso_rol_unique
on public.acceso_rol (rol_id, codigo_acceso);

create unique index if not exists idx_bodega_usuario_unique
on public.bodega_usuario (usuario_id, bodega_id);

create or replace function public.sync_staff_profile(
  p_user_id uuid,
  p_empresa_id uuid,
  p_rol_id uuid,
  p_nombre_completo text,
  p_correo text,
  p_password_hash text,
  p_usuario_registro_id uuid,
  p_bodega_ids uuid[]
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_usuario jsonb;
  v_bodegas jsonb;
begin
  insert into public.usuario (
    id,
    empresa_id,
    rol_id,
    nombre_completo,
    correo,
    password_hash,
    usuario_registro_id,
    fecha_registro,
    estado,
    ultima_actualizacion
  )
  values (
    p_user_id,
    p_empresa_id,
    p_rol_id,
    p_nombre_completo,
    p_correo,
    p_password_hash,
    p_usuario_registro_id,
    now(),
    true,
    now()
  )
  on conflict (id) do update
  set
    rol_id = excluded.rol_id,
    nombre_completo = excluded.nombre_completo,
    correo = excluded.correo,
    password_hash = excluded.password_hash,
    estado = true,
    fecha_eliminacion = null,
    ultima_actualizacion = now();

  update public.bodega_usuario
  set
    estado = false,
    fecha_eliminacion = now(),
    ultima_actualizacion = now()
  where usuario_id = p_user_id
    and estado = true
    and not (bodega_id = any(coalesce(p_bodega_ids, '{}'::uuid[])));

  insert into public.bodega_usuario (
    id,
    bodega_id,
    usuario_id,
    usuario_registro_id,
    estado,
    fecha_registro,
    ultima_actualizacion
  )
  select
    gen_random_uuid(),
    bodega_id,
    p_user_id,
    p_usuario_registro_id,
    true,
    now(),
    now()
  from unnest(coalesce(p_bodega_ids, '{}'::uuid[])) as bodega_id
  on conflict (usuario_id, bodega_id) do update
  set
    estado = true,
    fecha_eliminacion = null,
    ultima_actualizacion = now();

  select to_jsonb(u.*)
  into v_usuario
  from public.usuario u
  where u.id = p_user_id;

  select coalesce(jsonb_agg(to_jsonb(bu.*)), '[]'::jsonb)
  into v_bodegas
  from public.bodega_usuario bu
  where bu.usuario_id = p_user_id
    and bu.estado = true;

  return jsonb_build_object(
    'usuario', v_usuario,
    'bodega_usuario', v_bodegas
  );
end;
$$;

grant execute on function public.sync_staff_profile(
  uuid,
  uuid,
  uuid,
  text,
  text,
  text,
  uuid,
  uuid[]
) to service_role;
