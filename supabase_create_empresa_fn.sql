-- =================================================================
-- INVENTARIO V2 — FUNCIÓN RPC: crear_empresa_inicial
-- 
-- Esta función crea una empresa + rol admin + usuario en una sola
-- transacción atómica desde la app Flutter (AuthRepository).
-- 
-- La función usa SECURITY DEFINER para bypassear RLS ya que el
-- usuario recién registrado aún no tiene datos en la tabla 'usuario'.
--
-- Ejecutar en el SQL Editor de Supabase.
-- =================================================================

CREATE OR REPLACE FUNCTION public.crear_empresa_inicial(
    p_nombre_empresa  TEXT,
    p_ruc_empresa     TEXT,
    p_user_id         UUID,
    p_user_email      TEXT,
    p_user_nombre     TEXT,
    p_user_password   TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER  -- Bypassea RLS para poder insertar sin política de empresa aún
SET search_path = public
AS $$
DECLARE
    v_empresa_id  UUID;
    v_rol_id      UUID;
    v_empresa     JSON;
    v_usuario     JSON;
    v_rol         JSON;
BEGIN
    -- ---------------------------------------------------------------
    -- 1. Crear empresa
    -- ---------------------------------------------------------------
    INSERT INTO public.empresa (
        nombre,
        nombre_comercial,
        ruc,
        estado,
        fecha_registro,
        usuario_registro_id,
        ultima_actualizacion
    ) VALUES (
        p_nombre_empresa,
        p_nombre_empresa,   -- nombre_comercial igual al nombre por defecto
        p_ruc_empresa,
        true,
        now(),
        p_user_id,
        now()
    )
    RETURNING id INTO v_empresa_id;

    -- ---------------------------------------------------------------
    -- 2. Crear rol de administrador para esta empresa
    -- ---------------------------------------------------------------
    INSERT INTO public.rol (
        empresa_id,
        nombre,
        user_admin,
        usuario_registro_id,
        fecha_registro,
        estado,
        ultima_actualizacion
    ) VALUES (
        v_empresa_id,
        'Administrador',
        true,
        p_user_id,
        now(),
        true,
        now()
    )
    RETURNING id INTO v_rol_id;

    -- ---------------------------------------------------------------
    -- 3. Crear usuario vinculado a auth.users, empresa y rol
    -- ---------------------------------------------------------------
    INSERT INTO public.usuario (
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
    ) VALUES (
        p_user_id,
        v_empresa_id,
        v_rol_id,
        p_user_nombre,
        p_user_email,
        p_user_password,
        p_user_id,
        now(),
        true,
        now()
    );

    -- ---------------------------------------------------------------
    -- 4. Construir respuesta JSON con los datos creados
    -- ---------------------------------------------------------------
    SELECT row_to_json(e) INTO v_empresa
    FROM (SELECT * FROM public.empresa WHERE id = v_empresa_id) e;

    SELECT row_to_json(u) INTO v_usuario
    FROM (SELECT * FROM public.usuario WHERE id = p_user_id) u;

    SELECT row_to_json(r) INTO v_rol
    FROM (SELECT * FROM public.rol WHERE id = v_rol_id) r;

    -- Retornar los tres objetos en un solo JSON
    RETURN json_build_object(
        'empresa', v_empresa,
        'usuario', v_usuario,
        'rol',     v_rol
    );

EXCEPTION WHEN OTHERS THEN
    -- Revertir todo si algo falla
    RAISE EXCEPTION 'Error al crear empresa inicial: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
$$;

-- Permisos: solo usuarios autenticados pueden llamar esta función
REVOKE ALL ON FUNCTION public.crear_empresa_inicial FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.crear_empresa_inicial TO authenticated;


-- =================================================================
-- VERIFICACIÓN: Probar que la función existe
-- =================================================================
-- SELECT routine_name FROM information_schema.routines 
-- WHERE routine_schema = 'public' AND routine_name = 'crear_empresa_inicial';
