# AGENTS.md — Instrucciones para agentes de IA

Este archivo define las reglas de trabajo para agentes de IA como Codex Cloud, Copilot Coding Agent u otras herramientas que trabajen sobre el repositorio `inventario_v2`.

## 1. Contexto del proyecto

`inventario_v2` es una aplicación móvil desarrollada en Flutter para gestión de inventario.

Stack principal:

- Flutter / Dart
- Riverpod para estado
- GoRouter para navegación
- Supabase como backend remoto
- Drift / SQLite para almacenamiento local
- Enfoque offline first
- Sincronización local/remota
- Uso de `.env` mediante `flutter_dotenv`

El proyecto contiene lógica sensible relacionada con inventario, bodegas, productos, variantes, tallas, precios, kardex, traslados, usuarios, permisos y sincronización.

## 2. Principio general de trabajo

Trabajar siempre de forma conservadora.

Reglas generales:

1. Resolver un issue a la vez.
2. No hacer refactorizaciones grandes si el issue no lo solicita.
3. No modificar arquitectura global sin justificarlo explícitamente.
4. No hacer merge directo a `main`.
5. Crear Pull Request para toda corrección.
6. Mantener el estilo visual y patrones existentes del sistema.
7. No introducir paquetes nuevos sin justificación fuerte.
8. No inventar reglas de negocio si el issue no las define.
9. Si falta información crítica, comentar el bloqueo y no realizar cambios especulativos.
10. Priorizar cambios pequeños, verificables y reversibles.

## 3. Zonas sensibles

Evitar modificar estas áreas salvo que el issue lo pida explícitamente:

- Modelos de Drift / SQLite.
- Migraciones locales.
- Lógica de sincronización offline first.
- Repositorios de sincronización con Supabase.
- Esquemas o payloads remotos.
- Manejo de autenticación y sesión.
- Permisos de usuarios y bodegas.
- Archivos de configuración sensible.
- Archivos `.env` o credenciales.
- Configuración de firma Android.

Si el issue toca sincronización, Supabase, Drift, permisos o autenticación, primero realizar análisis y proponer plan antes de modificar.

## 4. Archivos sensibles que no deben modificarse sin autorización explícita

No modificar sin autorización:

- `.env`
- `.env.example` si existiera
- `android/key.properties`
- Archivos de keystore o signing
- Configuración de secretos
- Migraciones de base de datos
- Configuración de CI/CD relacionada con credenciales

Nunca escribir credenciales reales en el repositorio.

## 5. Reglas para bugs visuales

Para issues visuales o de UI:

1. Corregir únicamente la vista o componente afectado.
2. Mantener colores, bordes, espaciados y estilo actual.
3. No crear un nuevo sistema visual.
4. No cambiar modelos de datos para resolver un problema visual.
5. No ocultar errores funcionales detrás de cambios visuales.
6. Validar en pantalla móvil pequeña.
7. Evitar cambios que afecten pantallas no relacionadas.

## 6. Reglas para bugs funcionales simples

Para validaciones de UI, formularios, dropdowns, filtros o botones:

1. Ubicar primero el widget, provider y lógica relacionada.
2. Aplicar validación en UI cuando corresponda.
3. Mantener validación final en la capa de servicio/repositorio si ya existe.
4. Mostrar mensajes amigables al usuario.
5. No mostrar excepciones técnicas, UUIDs ni detalles internos al usuario final.
6. No modificar sincronización si el bug puede resolverse en UI/lógica local.

## 7. Reglas para Supabase, Drift y offline first

Esta app usa enfoque offline first. Cualquier cambio en datos puede afectar sincronización.

Para issues relacionados con Supabase, Drift o sync:

1. No asumir que el esquema local y remoto son iguales.
2. Revisar cómo se serializa el payload antes de enviarlo a Supabase.
3. Revisar qué campos son locales y cuáles remotos.
4. No eliminar campos locales necesarios para offline first.
5. No agregar columnas o migraciones sin justificación.
6. No cambiar modelos de datos sin validar impacto.
7. Mantener compatibilidad con operaciones offline.
8. Documentar claramente cualquier archivo de sincronización modificado.

Para la fase inicial de automatización, evitar issues de sincronización salvo instrucción explícita.

## 8. Reglas para tallas, variantes, precios y kardex

Las tallas, variantes, precios y movimientos de kardex son parte de la lógica de negocio.

Antes de corregir bugs en estas áreas:

1. Identificar la fuente real de datos.
2. Verificar si la información viene de producto, variante, inventario, entrada, movimiento o kardex.
3. No reemplazar datos reales con placeholders como `General` o `N/A` sin validar.
4. No asumir que `General` es siempre correcto.
5. Evitar agrupar variantes si el issue requiere detalle por talla o precio.
6. Mantener compatibilidad con productos sin talla específica.

## 9. Manejo de `.env` y variables

La app actualmente usa `flutter_dotenv` y carga `.env` en tiempo de ejecución.

Reglas:

1. No subir `.env` real al repositorio.
2. Para CI/CD, usar GitHub Secrets.
3. Si se requiere compilar APK en GitHub Actions, crear un `.env` temporal desde secrets durante el workflow.
4. No imprimir secrets en logs.
5. No cambiar el mecanismo de configuración a `--dart-define` salvo que exista un issue específico para esa migración.

## 10. Comandos de validación

Antes de finalizar un cambio, ejecutar cuando sea posible:

```bash
flutter pub get
flutter analyze
flutter test
```

Si `flutter test` falla por pruebas existentes no relacionadas, documentarlo en el Pull Request.

Para cambios que afectan Android/APK:

```bash
flutter build apk --debug
```

## 11. Reglas para Pull Requests

Cada Pull Request debe incluir:

- Issue relacionado.
- Causa encontrada.
- Solución aplicada.
- Archivos modificados.
- Validaciones realizadas.
- Riesgos pendientes.
- Capturas o notas visuales si aplica.

Formato sugerido del resumen:

```md
## Issue relacionado
Closes #N

## Causa encontrada

## Solución aplicada

## Archivos modificados

## Validaciones realizadas
- [ ] flutter pub get
- [ ] flutter analyze
- [ ] flutter test
- [ ] flutter build apk --debug

## Riesgos o pendientes
```

## 12. Flujo esperado para Codex

Cuando Codex trabaje un issue:

1. Leer completo el issue.
2. Revisar este archivo `AGENTS.md`.
3. Identificar archivos relacionados.
4. Hacer cambios mínimos.
5. Ejecutar validaciones.
6. Crear una rama con nombre descriptivo.
7. Abrir Pull Request.
8. No hacer merge.

## 13. Issues recomendados para primera fase

Para validar el flujo de IA, empezar con issues de bajo riesgo:

- `#9` — Traslado no debe permitir misma bodega como destino.
- `#4` — Ocultar código secundario en tarjeta de producto.
- `#11` — Formato numérico y ajuste visual en traslado, con cautela.

Evitar en la primera fase:

- `#2` — Sincronización Supabase.
- `#3` — Gestión de acceso por bodega.
- `#6` — Historial de precios y tallas.
- `#7` — Kardex con datos incorrectos.

Estos últimos requieren más análisis, datos de prueba y validación manual.

## 14. Criterio de seguridad

La IA puede proponer y corregir, pero la aprobación final debe ser humana.

Nunca activar merge automático para cambios generados por IA durante la fase inicial.
