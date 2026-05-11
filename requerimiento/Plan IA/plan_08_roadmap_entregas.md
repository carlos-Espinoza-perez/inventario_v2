# Plan 08 - Roadmap de entregas
**Origen:** `requerimiento/Add IA/08_roadmap_de_entregas.md`

---

## Objetivo

Tabla de referencia que mapea cada entrega al plan técnico correspondiente, con las dependencias reales del proyecto incorporadas.

---

## Tabla de entregas

| Entrega | Objetivo | Plan técnico | Criterio para avanzar |
|---|---|---|---|
| **1** | Módulo Secretario: estructura, pantalla mock, ruta en ShellRoute, botón "IA" conectado | `plan_00` | Pantalla compila, mock responde, botón "IA" navega a `/assistant` con layout completo |
| **2** | Parser por reglas: 7 intents + unsupported | `plan_02` | Tests unitarios del parser pasan; `normalizeText` en archivo compartido |
| **3** | Contexto operativo: empresa, usuario, permisos, bodega, caja | `plan_03` | Contexto real desde providers; permisos validan con `authorizationStateProvider.future` |
| **4** | Resolución de entidades: productos y clientes | `plan_06` | `searchProductoByCodeOrName` integrado; ambigüedad devuelve candidatos; `EntityResolver` en `data/` |
| **5** | Consultas de productos: stock y precio con datos reales | `plan_04` (parcial) | "cuanto hay de X" y "cuanto cuesta X" responden con datos de Drift |
| **6** | Consultas comerciales: deudas, ventas, caja, última venta | `plan_04` (completo) + `plan_01` | Las 7 consultas del MVP funcionan; flujo real ensamblado |
| **7** | Borrador de entrada | `plan_05` (entrada) | Entrada preparada, editable (costo + cantidad), confirmada con `RegistrarEntradaUseCase` |
| **8** | Borrador de venta | `plan_05` (venta) | Venta asistida sin duplicar lógica del POS |
| **9** | Salidas, ajustes y abonos | `plan_05` (salida + abono) + crear `RegistrarSalidaUseCase` | Operaciones principales cubiertas |
| **10** | Voz push-to-talk + transcripción | `plan_07` (Fase 1 + 2) | Texto y voz alimentan el mismo parser |
| **11** | TTS y feedback auditivo | `plan_07` (Fase 3) | Respuestas habladas, experiencia tipo secretario |
| **12** | Sesión acumulativa con input mixto | `plan_09` | 3+ ítems acumulados, scanner funciona, `pendingProduct` tipado, cancelación descarta todo |

> La numeración de entregas difiere del roadmap original porque se separó "consultas de productos" de "consultas comerciales" y se agregó la creación de `RegistrarSalidaUseCase` como prerequisito explícito de la Entrega 9.

---

## Dependencias técnicas críticas

### Antes de Entrega 3:
- Entrega 2 completa (parser detecta intents)

### Antes de Entrega 4:
- Entrega 3 completa (contexto operativo real)
- Confirmar que `searchProductoByCodeOrName` filtra por empresa

### Antes de Entrega 5:
- Entrega 4 completa (`EntityResolver` con productos)
- Verificar tipo de retorno de `getStockRealPorBodega` y `getPreciosProductoPorBodega`

### Antes de Entrega 6 (flujo ensamblado):
- Verificar tipo de retorno de `getVentasDelDia`, `getReceivablesReport`, `getGananciaSesion`

### Antes de Entrega 7 (acciones):
- Entregas 1–6 completas
- Leer `RegistrarEntradaUseCase.ejecutar()` para confirmar parámetros exactos (`OrderLine`, tipos)

### Antes de Entrega 9 (salidas y abonos):
- Crear `RegistrarSalidaUseCase` en `lib/features/inventory/domain/use_cases/`
- Exponer flujo de abono como Use Case reutilizable (actualmente en `SalesDao.registrarAbonoVenta`)

### Antes de Entrega 10 (voz):
- Entregas 1–6 estables y confiables por texto
- Resolución de productos funcionando bien en producción

### Antes de Entrega 12 (sesión acumulativa):
- Entregas 7 y 8 completas (borradores en flujo de un turno)
- Scanner estable en la app (`/barcode-scanner` retorna código correctamente)
- Voz básica (Entrega 10) recomendada pero no obligatoria

---

## Checklist de avance

```
[ ] Entrega 1  — Pantalla mock compila, botón "IA" conectado
[ ] Entrega 2  — Parser detecta 7 intents + tests pasan
[ ] Entrega 3  — Contexto real desde providers del proyecto
[ ] Entrega 4  — EntityResolver con searchProductoByCodeOrName
[ ] Entrega 5  — Stock y precio desde Drift
[ ] Entrega 6  — Las 7 consultas del MVP con datos reales
[ ] Entrega 7  — Borrador de entrada con RegistrarEntradaUseCase
[ ] Entrega 8  — Borrador de venta con RegistrarVentaUseCase
[ ] Entrega 9  — Salidas/ajustes/abonos (requiere RegistrarSalidaUseCase)
[ ] Entrega 10 — Voz push-to-talk + transcripción
[ ] Entrega 11 — TTS y feedback auditivo
[ ] Entrega 12 — Sesión acumulativa con scanner
```

---

## Valor de negocio por etapa

- **Entregas 1–6:** El Secretario es útil para consultas sin modificar datos. Valor inmediato para personal de bodega y supervisores.
- **Entregas 7–9:** Operaciones asistidas. Reduce tiempo en pantallas manuales.
- **Entregas 10–12:** Experiencia diferenciada. Útil en ambientes de trabajo físico (bodega, tienda).
