# 06 - Resolucion de entidades

## Objetivo

Convertir nombres dichos por el usuario en entidades reales del sistema.

Ejemplos:

- "coca" -> producto especifico
- "camisa nike talla m" -> producto + variante
- "maria" -> cliente
- "bodega central" -> bodega permitida

## Orden recomendado

1. busqueda exacta por SKU/codigo
2. busqueda por nombre normalizado
3. busqueda parcial por nombre
4. busqueda por variante, talla o color
5. fallback difuso local
6. embeddings locales solo si hace falta

## MVP sin embeddings

Para la primera version usar:

- `contains` normalizado
- SKU exacto
- ranking simple por coincidencias de palabras

Esto es suficiente para probar valor antes de meter modelos.

## Resultado de resolucion

```dart
enum EntityResolutionStatus {
  resolved,
  ambiguous,
  notFound,
}

class EntityResolution<T> {
  final EntityResolutionStatus status;
  final T? selected;
  final List<T> candidates;
  final String originalQuery;
}
```

## Reglas

Si hay un match claro:

- continuar

Si hay varios candidatos:

- responder con opciones
- no escoger silenciosamente si el riesgo es alto

Si no hay candidatos:

- decir que no se encontro
- sugerir escribir mas detalle o escanear codigo cuando estemos en flujo de accion

## Embeddings

Los embeddings quedan para fase posterior.

Uso recomendado:

- solo matching de productos y clientes
- no generar respuestas financieras
- no reemplazar consultas exactas

Si se implementan:

- versionar embeddings
- guardar `sourceText`
- guardar `sourceHash`
- permitir reconstruir indice
- evitar acoplar toda la logica de negocio a un campo en productos
