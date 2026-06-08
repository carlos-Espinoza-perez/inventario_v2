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

## 3. Modo automático desde GitHub Issues (Flujo SDD Multi-Agente)

El flujo objetivo del proyecto es permitir que un issue bien documentado pueda iniciar trabajo automático de IA, utilizando **Harness Engineering y Spec Driven Development (SDD)** con roles multi-agente, asegurando siempre revisión humana antes de codificar y antes del merge.

Cuando un issue tenga el label `ai-ready`, el agente (la IA) DEBE adoptar el rol de **Leader** (`.agents/leader.md`) y trabajar bajo estas reglas:

0. **Fase de Especificación Obligatoria:** Antes de tocar código fuente, el agente (adoptando el rol *Spec Author*) debe crear `docs/specs/issue-#N/` copiando las plantillas de `docs/specs/template/` y definir requerimientos, diseño y tareas. Luego debe **DETENERSE** y pedir aprobación humana.
1. Trabajar únicamente el issue que activó el flujo, y sólo iniciar la implementación después de la aprobación explícita de los specs.
2. No tomar otros issues relacionados salvo que el issue principal lo indique explícitamente.
3. No mezclar varios bugs o mejoras en un mismo Pull Request.
4. No cerrar el issue manualmente; el PR debe usar `Closes #N` para que GitHub lo cierre al hacer merge.
5. Si el issue está incompleto, ambiguo o requiere datos no disponibles, comentar en el issue y no modificar código.
6. Si el issue implica sincronización, Drift, Supabase crítico, autenticación, permisos o cambios de base de datos, detenerse y publicar primero un análisis técnico en el issue o PR.
7. Si el issue es visual, de validación simple, formato o UX local, puede proponer cambios directamente siguiendo las reglas de este archivo.
8. El agente debe crear una rama nueva y un Pull Request; nunca debe hacer merge directo.
9. El Pull Request debe quedar listo para que GitHub Actions genere APK y para que Carlos pueda probarlo.
10. Si el APK o las validaciones fallan, el agente debe explicar la causa y proponer el siguiente ajuste.

Labels sugeridos dentro del flujo:

- `ai-ready`: issue validado y listo para IA.
- `ai-working`: la IA está trabajando o ya tomó el issue.
- `ai-needs-info`: falta información para corregir con seguridad.
- `ai-failed`: la IA intentó corregir pero no logró una solución válida.
- `needs-human-review`: requiere revisión manual estricta antes de avanzar.
- `apk-generated`: existe un APK generado para prueba.

Durante la fase inicial, `ai-ready` debe aplicarse de forma consciente. No debe agregarse automáticamente a todos los issues.

## 4. Ciclo de feedback por comentarios

El flujo debe permitir que Carlos pruebe el APK, comente el resultado y que el agente pueda continuar con ajustes sobre el mismo Pull Request.

Flujo esperado:

1. La IA corrige el issue y abre un PR.
2. GitHub Actions genera un APK.
3. Carlos instala el APK y prueba el caso reportado.
4. Carlos comenta en el PR o issue si la solución funciona o si aún falla.
5. Si el comentario indica que falta ajuste, el agente debe continuar sobre la misma rama/PR cuando sea posible.
6. Si el comentario confirma que funciona, el PR queda listo para revisión final humana.
7. La aprobación o merge debe requerir una instrucción explícita de Carlos.

Reglas para interpretar comentarios de feedback:

- Si Carlos indica que el bug persiste, revisar el comentario, ajustar el PR y volver a ejecutar validaciones.
- Si Carlos adjunta nueva captura o explicación, tratarla como evidencia adicional del mismo issue si está relacionada.
- Si la nueva evidencia revela otro bug no relacionado, recomendar crear un issue separado.
- Si Carlos escribe una aprobación general, no hacer merge automáticamente salvo que exista una instrucción explícita como `hacer merge`, `aprobar PR` o equivalente.

## 5. Tamaño máximo y alcance de cambios generados por IA

Para mantener el control del repositorio, los cambios generados por IA deben ser pequeños y revisables.

Reglas de tamaño:

1. Un PR generado por IA debe intentar modificar máximo 5 archivos.
2. Si necesita modificar más de 5 archivos, debe justificarlo claramente en el PR.
3. Si el cambio supera aproximadamente 300 líneas modificadas entre agregadas y eliminadas, debe marcarse como `needs-human-review`.
4. Si el cambio requiere refactor amplio, debe detenerse y proponer plan antes de implementar.
5. Si durante la corrección aparece una mejora adicional no solicitada, no implementarla; documentarla como posible issue futuro.
6. Un PR debe resolver un solo objetivo principal.

Estas reglas no buscan limitar correcciones necesarias, sino evitar cambios grandes difíciles de revisar en un flujo automatizado.

## 6. Zonas sensibles

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

## 7. Archivos sensibles que no deben modificarse sin autorización explícita

No modificar sin autorización:

- `.env`
- `.env.example` si existiera
- `android/key.properties`
- Archivos de keystore o signing
- Configuración de secretos
- Migraciones de base de datos
- Configuración de CI/CD relacionada con credenciales

Nunca escribir credenciales reales en el repositorio.

## 8. Reglas para bugs visuales

Para issues visuales o de UI:

1. Corregir únicamente la vista o componente afectado.
2. Mantener colores, bordes, espaciados y estilo actual.
3. No crear un nuevo sistema visual.
4. No cambiar modelos de datos para resolver un problema visual.
5. No ocultar errores funcionales detrás de cambios visuales.
6. Validar en pantalla móvil pequeña.
7. Evitar cambios que afecten pantallas no relacionadas.

## 9. Reglas para bugs funcionales simples

Para validaciones de UI, formularios, dropdowns, filtros o botones:

1. Ubicar primero el widget, provider y lógica relacionada.
2. Aplicar validación en UI cuando corresponda.
3. Mantener validación final en la capa de servicio/repositorio si ya existe.
4. Mostrar mensajes amigables al usuario.
5. No mostrar excepciones técnicas, UUIDs ni detalles internos al usuario final.
6. No modificar sincronización si el bug puede resolverse en UI/lógica local.

## 10. Reglas para Supabase, Drift y offline first

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

## 11. Reglas para tallas, variantes, precios y kardex

Las tallas, variantes, precios y movimientos de kardex son parte de la lógica de negocio.

Antes de corregir bugs en estas áreas:

1. Identificar la fuente real de datos.
2. Verificar si la información viene de producto, variante, inventario, entrada, movimiento o kardex.
3. No reemplazar datos reales con placeholders como `General` o `N/A` sin validar.
4. No asumir que `General` es siempre correcto.
5. Evitar agrupar variantes si el issue requiere detalle por talla o precio.
6. Mantener compatibilidad con productos sin talla específica.

## 12. Manejo de `.env` y variables

La app actualmente usa `flutter_dotenv` y carga `.env` en tiempo de ejecución.

Reglas:

1. No subir `.env` real al repositorio.
2. Para CI/CD, usar GitHub Secrets.
3. Si se requiere compilar APK en GitHub Actions, crear un `.env` temporal desde secrets durante el workflow.
4. No imprimir secrets en logs.
5. No cambiar el mecanismo de configuración a `--dart-define` salvo que exista un issue específico para esa migración.

## 13. Comandos de validación

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

## 14. Reglas para Pull Requests

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

## 15. Flujo esperado para la IA (Harness)

Cuando la IA trabaje un issue:

1. Leer completo el issue y este archivo `AGENTS.md`.
2. Actuar como **Leader** y derivar a **Spec Author** para crear los specs en `docs/specs/issue-#N/`.
3. Pedir revisión humana de los specs.
4. Actuar como **Implementer** ejecutando paso a paso el `tasks.md`.
5. Hacer cambios mínimos y no tocar zonas sensibles sin permiso.
6. Actuar como **Reviewer** para verificar requerimientos y ejecutar validaciones locales (`flutter analyze`).
7. Crear una rama con nombre descriptivo (ej. `feat/issue-N`).
8. Abrir Pull Request con `Closes #N`.
9. No hacer merge automático.

## 16. Issues recomendados para primera fase

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

## 17. Criterio de seguridad

La IA puede proponer y corregir, pero la aprobación final debe ser humana.

Nunca activar merge automático para cambios generados por IA durante la fase inicial.
