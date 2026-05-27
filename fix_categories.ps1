$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding
$query = @'
DO $$
DECLARE
    p_empresa_id UUID := '5cb78293-e533-40be-959c-99d6894bb5d9'; 
    p_usuario_id UUID := '046a62db-f9b9-470b-a714-8e09d16e8d89'; 
    
    id_ropa UUID := gen_random_uuid();
    id_ropa_interior UUID := gen_random_uuid();
    id_calzado UUID := gen_random_uuid();
    id_accesorios UUID := gen_random_uuid();
    id_hogar UUID := gen_random_uuid();
    id_plasticos UUID := gen_random_uuid();
    id_otros UUID := gen_random_uuid();

BEGIN
    -- 0. ELIMINAR CATEGORÍAS CORRUPTAS
    DELETE FROM categoria WHERE empresa_id = p_empresa_id;

    -- 1. INSERTAR CATEGORÍAS PADRE
    INSERT INTO categoria (id, empresa_id, nombre, categoria_padre_id, usuario_registro_id, estado)
    VALUES 
        (id_ropa, p_empresa_id, 'Ropa', NULL, p_usuario_id, true),
        (id_ropa_interior, p_empresa_id, 'Ropa Interior y Calcetería', NULL, p_usuario_id, true),
        (id_calzado, p_empresa_id, 'Calzado', NULL, p_usuario_id, true),
        (id_accesorios, p_empresa_id, 'Accesorios', NULL, p_usuario_id, true),
        (id_hogar, p_empresa_id, 'Hogar y Blancos', NULL, p_usuario_id, true),
        (id_plasticos, p_empresa_id, 'Plásticos y Utensilios', NULL, p_usuario_id, true),
        (id_otros, p_empresa_id, 'Otros', NULL, p_usuario_id, true);

    -- 2. INSERTAR SUBCATEGORÍAS

    -- ROPA
    INSERT INTO categoria (id, empresa_id, nombre, categoria_padre_id, usuario_registro_id, estado) VALUES
        (gen_random_uuid(), p_empresa_id, 'Blusa', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Camisa', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Camiseta', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Camisola', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Centro', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Chaleco', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Chaqueta', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Sudadera', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Pantalón', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Short', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Yoger', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Palazo', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Falda', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Enteriso', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Pijama', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Traje', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Traje deportivo', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Vestido', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Sapa', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Licra', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Buso', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Cárdigan', id_ropa, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Manga', id_ropa, p_usuario_id, true);

    -- ROPA INTERIOR Y CALCETERÍA
    INSERT INTO categoria (id, empresa_id, nombre, categoria_padre_id, usuario_registro_id, estado) VALUES
        (gen_random_uuid(), p_empresa_id, 'Boxer', id_ropa_interior, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Blumer', id_ropa_interior, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Calzón', id_ropa_interior, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Corpiño', id_ropa_interior, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Pantaleta', id_ropa_interior, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Tanga', id_ropa_interior, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Brasier', id_ropa_interior, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Justan', id_ropa_interior, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Calceta', id_ropa_interior, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Calcetín', id_ropa_interior, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Tobillera', id_ropa_interior, p_usuario_id, true);

    -- CALZADO
    INSERT INTO categoria (id, empresa_id, nombre, categoria_padre_id, usuario_registro_id, estado) VALUES
        (gen_random_uuid(), p_empresa_id, 'Zapato', id_calzado, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Chinela', id_calzado, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Sandalia', id_calzado, p_usuario_id, true);

    -- ACCESORIOS
    INSERT INTO categoria (id, empresa_id, nombre, categoria_padre_id, usuario_registro_id, estado) VALUES
        (gen_random_uuid(), p_empresa_id, 'Gorra', id_accesorios, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Sombrero', id_accesorios, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Sombrilla', id_accesorios, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Bolso', id_accesorios, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Cartera', id_accesorios, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Mochila', id_accesorios, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Faja', id_accesorios, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Fajon', id_accesorios, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Pañoleta', id_accesorios, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Pasamontañas', id_accesorios, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Pañuelo', id_accesorios, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Pinza', id_accesorios, p_usuario_id, true);

    -- HOGAR Y BLANCOS
    INSERT INTO categoria (id, empresa_id, nombre, categoria_padre_id, usuario_registro_id, estado) VALUES
        (gen_random_uuid(), p_empresa_id, 'Colcha', id_hogar, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Edredón', id_hogar, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Cubre colchón', id_hogar, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Funda de almohada', id_hogar, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Mosquitero', id_hogar, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Toalla', id_hogar, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Mantel', id_hogar, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Jabonera', id_hogar, p_usuario_id, true);

    -- PLÁSTICOS Y UTENSILIOS
    INSERT INTO categoria (id, empresa_id, nombre, categoria_padre_id, usuario_registro_id, estado) VALUES
        (gen_random_uuid(), p_empresa_id, 'Balde', id_plasticos, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Bandeja', id_plasticos, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Pana', id_plasticos, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Set de panas', id_plasticos, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Taza', id_plasticos, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Plato', id_plasticos, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Cuchara', id_plasticos, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Cuchillo', id_plasticos, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Termo', id_plasticos, p_usuario_id, true);

    -- OTROS
    INSERT INTO categoria (id, empresa_id, nombre, categoria_padre_id, usuario_registro_id, estado) VALUES
        (gen_random_uuid(), p_empresa_id, 'Bolsa de regalo', id_otros, p_usuario_id, true),
        (gen_random_uuid(), p_empresa_id, 'Capote', id_otros, p_usuario_id, true);

END $$;
'@

$tempFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tempFile, $query, [System.Text.Encoding]::UTF8)
supabase db query (Get-Content $tempFile -Raw -Encoding UTF8) --linked
Remove-Item $tempFile
