chcp 65001
$query = @'
DO $$
BEGIN
    -- Ropa (Padre e hijos generales)
    UPDATE categoria 
    SET especificacion = jsonb_build_object('tallas_permitidas', jsonb_build_array('XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'))
    WHERE empresa_id = '5cb78293-e533-40be-959c-99d6894bb5d9' 
      AND (nombre IN ('Ropa', 'Blusa', 'Camisa', 'Camiseta', 'Camisola', 'Centro', 'Chaleco', 'Chaqueta', 'Sudadera', 'Falda', 'Enteriso', 'Pijama', 'Traje', 'Traje deportivo', 'Vestido', 'Sapa', 'Licra', 'Buso', 'C' || chr(225) || 'rdigan', 'Manga'));

    -- Pantalones y Shorts
    UPDATE categoria 
    SET especificacion = jsonb_build_object('tallas_permitidas', jsonb_build_array('28', '30', '32', '34', '36', '38', '40', '42', '44'))
    WHERE empresa_id = '5cb78293-e533-40be-959c-99d6894bb5d9' 
      AND nombre IN ('Pantal' || chr(243) || 'n', 'Short', 'Yoger', 'Palazo');

    -- Ropa Interior
    UPDATE categoria 
    SET especificacion = jsonb_build_object('tallas_permitidas', jsonb_build_array('S', 'M', 'L', 'XL', '32', '34', '36', '38', '40'))
    WHERE empresa_id = '5cb78293-e533-40be-959c-99d6894bb5d9' 
      AND (nombre IN ('Ropa Interior y Calceter' || chr(237) || 'a', 'Boxer', 'Blumer', 'Calz' || chr(243) || 'n', 'Corpi' || chr(241) || 'o', 'Pantaleta', 'Tanga', 'Brasier', 'Justan'));

    -- Calceteria
    UPDATE categoria 
    SET especificacion = jsonb_build_object('tallas_permitidas', jsonb_build_array('General', 'Adulto', 'Niño'))
    WHERE empresa_id = '5cb78293-e533-40be-959c-99d6894bb5d9' 
      AND nombre IN ('Calceta', 'Calcet' || chr(237) || 'n', 'Tobillera');

    -- Calzado
    UPDATE categoria 
    SET especificacion = jsonb_build_object('tallas_permitidas', jsonb_build_array('20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44'))
    WHERE empresa_id = '5cb78293-e533-40be-959c-99d6894bb5d9' 
      AND nombre IN ('Calzado', 'Zapato', 'Chinela', 'Sandalia');

    -- Hogar y Blancos (Ropa de Cama)
    UPDATE categoria 
    SET especificacion = jsonb_build_object('tallas_permitidas', jsonb_build_array('Unipersonal', 'Matrimonial', 'Queen', 'King', 'General'))
    WHERE empresa_id = '5cb78293-e533-40be-959c-99d6894bb5d9' 
      AND nombre IN ('Colcha', 'Edred' || chr(243) || 'n', 'Cubre colch' || chr(243) || 'n', 'Hogar y Blancos');

    -- Plásticos (Tamaños)
    UPDATE categoria 
    SET especificacion = jsonb_build_object('tallas_permitidas', jsonb_build_array('Pequeño', 'Mediano', 'Grande', 'General'))
    WHERE empresa_id = '5cb78293-e533-40be-959c-99d6894bb5d9' 
      AND nombre IN ('Pl' || chr(225) || 'sticos y Utensilios', 'Balde', 'Bandeja', 'Pana', 'Set de panas');

END $$;
'@
$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding
$tempFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tempFile, $query, [System.Text.Encoding]::UTF8)
supabase db query (Get-Content $tempFile -Raw -Encoding UTF8) --linked
Remove-Item $tempFile
