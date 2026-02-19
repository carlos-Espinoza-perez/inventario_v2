// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'producto_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProductoCollectionCollection on Isar {
  IsarCollection<ProductoCollection> get productoCollections =>
      this.collection();
}

const ProductoCollectionSchema = CollectionSchema(
  name: r'ProductoCollection',
  id: 313299503316677621,
  properties: {
    r'categoriaId': PropertySchema(
      id: 0,
      name: r'categoriaId',
      type: IsarType.string,
    ),
    r'codigoPersonalizado': PropertySchema(
      id: 1,
      name: r'codigoPersonalizado',
      type: IsarType.string,
    ),
    r'descripcion': PropertySchema(
      id: 2,
      name: r'descripcion',
      type: IsarType.string,
    ),
    r'empresaId': PropertySchema(
      id: 3,
      name: r'empresaId',
      type: IsarType.string,
    ),
    r'especificacionJson': PropertySchema(
      id: 4,
      name: r'especificacionJson',
      type: IsarType.string,
    ),
    r'estado': PropertySchema(
      id: 5,
      name: r'estado',
      type: IsarType.bool,
    ),
    r'fechaEliminacion': PropertySchema(
      id: 6,
      name: r'fechaEliminacion',
      type: IsarType.dateTime,
    ),
    r'fechaRegistro': PropertySchema(
      id: 7,
      name: r'fechaRegistro',
      type: IsarType.dateTime,
    ),
    r'imagenLocal': PropertySchema(
      id: 8,
      name: r'imagenLocal',
      type: IsarType.string,
    ),
    r'imagenUrl': PropertySchema(
      id: 9,
      name: r'imagenUrl',
      type: IsarType.string,
    ),
    r'nombre': PropertySchema(
      id: 10,
      name: r'nombre',
      type: IsarType.string,
    ),
    r'pendienteSincronizacion': PropertySchema(
      id: 11,
      name: r'pendienteSincronizacion',
      type: IsarType.bool,
    ),
    r'precioBase': PropertySchema(
      id: 12,
      name: r'precioBase',
      type: IsarType.double,
    ),
    r'serverId': PropertySchema(
      id: 13,
      name: r'serverId',
      type: IsarType.string,
    ),
    r'ultimaActualizacion': PropertySchema(
      id: 14,
      name: r'ultimaActualizacion',
      type: IsarType.dateTime,
    ),
    r'ultimoCosto': PropertySchema(
      id: 15,
      name: r'ultimoCosto',
      type: IsarType.double,
    ),
    r'ultimoPrecioVenta': PropertySchema(
      id: 16,
      name: r'ultimoPrecioVenta',
      type: IsarType.double,
    ),
    r'usuarioRegistroId': PropertySchema(
      id: 17,
      name: r'usuarioRegistroId',
      type: IsarType.string,
    )
  },
  estimateSize: _productoCollectionEstimateSize,
  serialize: _productoCollectionSerialize,
  deserialize: _productoCollectionDeserialize,
  deserializeProp: _productoCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'serverId': IndexSchema(
      id: -7950187970872907662,
      name: r'serverId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'serverId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'empresaId': IndexSchema(
      id: 4061495233042072508,
      name: r'empresaId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'empresaId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'categoriaId': IndexSchema(
      id: 988530590553896478,
      name: r'categoriaId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'categoriaId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'nombre': IndexSchema(
      id: -8239814765453414572,
      name: r'nombre',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nombre',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    ),
    r'estado': IndexSchema(
      id: -4800696143246816208,
      name: r'estado',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'estado',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'pendienteSincronizacion': IndexSchema(
      id: 3214759188604201326,
      name: r'pendienteSincronizacion',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'pendienteSincronizacion',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _productoCollectionGetId,
  getLinks: _productoCollectionGetLinks,
  attach: _productoCollectionAttach,
  version: '3.1.0+1',
);

int _productoCollectionEstimateSize(
  ProductoCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.categoriaId.length * 3;
  {
    final value = object.codigoPersonalizado;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.descripcion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.empresaId.length * 3;
  {
    final value = object.especificacionJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imagenLocal;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imagenUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.nombre.length * 3;
  bytesCount += 3 + object.serverId.length * 3;
  bytesCount += 3 + object.usuarioRegistroId.length * 3;
  return bytesCount;
}

void _productoCollectionSerialize(
  ProductoCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.categoriaId);
  writer.writeString(offsets[1], object.codigoPersonalizado);
  writer.writeString(offsets[2], object.descripcion);
  writer.writeString(offsets[3], object.empresaId);
  writer.writeString(offsets[4], object.especificacionJson);
  writer.writeBool(offsets[5], object.estado);
  writer.writeDateTime(offsets[6], object.fechaEliminacion);
  writer.writeDateTime(offsets[7], object.fechaRegistro);
  writer.writeString(offsets[8], object.imagenLocal);
  writer.writeString(offsets[9], object.imagenUrl);
  writer.writeString(offsets[10], object.nombre);
  writer.writeBool(offsets[11], object.pendienteSincronizacion);
  writer.writeDouble(offsets[12], object.precioBase);
  writer.writeString(offsets[13], object.serverId);
  writer.writeDateTime(offsets[14], object.ultimaActualizacion);
  writer.writeDouble(offsets[15], object.ultimoCosto);
  writer.writeDouble(offsets[16], object.ultimoPrecioVenta);
  writer.writeString(offsets[17], object.usuarioRegistroId);
}

ProductoCollection _productoCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProductoCollection();
  object.categoriaId = reader.readString(offsets[0]);
  object.codigoPersonalizado = reader.readStringOrNull(offsets[1]);
  object.descripcion = reader.readStringOrNull(offsets[2]);
  object.empresaId = reader.readString(offsets[3]);
  object.especificacionJson = reader.readStringOrNull(offsets[4]);
  object.estado = reader.readBool(offsets[5]);
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[6]);
  object.fechaRegistro = reader.readDateTime(offsets[7]);
  object.id = id;
  object.imagenLocal = reader.readStringOrNull(offsets[8]);
  object.imagenUrl = reader.readStringOrNull(offsets[9]);
  object.nombre = reader.readString(offsets[10]);
  object.pendienteSincronizacion = reader.readBool(offsets[11]);
  object.precioBase = reader.readDoubleOrNull(offsets[12]);
  object.serverId = reader.readString(offsets[13]);
  object.ultimaActualizacion = reader.readDateTime(offsets[14]);
  object.ultimoCosto = reader.readDouble(offsets[15]);
  object.ultimoPrecioVenta = reader.readDouble(offsets[16]);
  object.usuarioRegistroId = reader.readString(offsets[17]);
  return object;
}

P _productoCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readDouble(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _productoCollectionGetId(ProductoCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _productoCollectionGetLinks(
    ProductoCollection object) {
  return [];
}

void _productoCollectionAttach(
    IsarCollection<dynamic> col, Id id, ProductoCollection object) {
  object.id = id;
}

extension ProductoCollectionByIndex on IsarCollection<ProductoCollection> {
  Future<ProductoCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  ProductoCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<ProductoCollection?>> getAllByServerId(
      List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<ProductoCollection?> getAllByServerIdSync(List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'serverId', values);
  }

  Future<int> deleteAllByServerId(List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'serverId', values);
  }

  int deleteAllByServerIdSync(List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'serverId', values);
  }

  Future<Id> putByServerId(ProductoCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(ProductoCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(List<ProductoCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<ProductoCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension ProductoCollectionQueryWhereSort
    on QueryBuilder<ProductoCollection, ProductoCollection, QWhere> {
  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhere>
      anyNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'nombre'),
      );
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhere>
      anyEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'estado'),
      );
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhere>
      anyPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'pendienteSincronizacion'),
      );
    });
  }
}

extension ProductoCollectionQueryWhere
    on QueryBuilder<ProductoCollection, ProductoCollection, QWhereClause> {
  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      serverIdNotEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [],
              upper: [serverId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [serverId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [serverId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [],
              upper: [serverId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      empresaIdEqualTo(String empresaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'empresaId',
        value: [empresaId],
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      empresaIdNotEqualTo(String empresaId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'empresaId',
              lower: [],
              upper: [empresaId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'empresaId',
              lower: [empresaId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'empresaId',
              lower: [empresaId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'empresaId',
              lower: [],
              upper: [empresaId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      categoriaIdEqualTo(String categoriaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'categoriaId',
        value: [categoriaId],
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      categoriaIdNotEqualTo(String categoriaId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoriaId',
              lower: [],
              upper: [categoriaId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoriaId',
              lower: [categoriaId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoriaId',
              lower: [categoriaId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoriaId',
              lower: [],
              upper: [categoriaId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      nombreEqualTo(String nombre) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nombre',
        value: [nombre],
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      nombreNotEqualTo(String nombre) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nombre',
              lower: [],
              upper: [nombre],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nombre',
              lower: [nombre],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nombre',
              lower: [nombre],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nombre',
              lower: [],
              upper: [nombre],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      nombreGreaterThan(
    String nombre, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nombre',
        lower: [nombre],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      nombreLessThan(
    String nombre, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nombre',
        lower: [],
        upper: [nombre],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      nombreBetween(
    String lowerNombre,
    String upperNombre, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nombre',
        lower: [lowerNombre],
        includeLower: includeLower,
        upper: [upperNombre],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      nombreStartsWith(String NombrePrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nombre',
        lower: [NombrePrefix],
        upper: ['$NombrePrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nombre',
        value: [''],
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'nombre',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'nombre',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'nombre',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'nombre',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      estadoEqualTo(bool estado) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'estado',
        value: [estado],
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      estadoNotEqualTo(bool estado) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [],
              upper: [estado],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [estado],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [estado],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [],
              upper: [estado],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      pendienteSincronizacionEqualTo(bool pendienteSincronizacion) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pendienteSincronizacion',
        value: [pendienteSincronizacion],
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterWhereClause>
      pendienteSincronizacionNotEqualTo(bool pendienteSincronizacion) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pendienteSincronizacion',
              lower: [],
              upper: [pendienteSincronizacion],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pendienteSincronizacion',
              lower: [pendienteSincronizacion],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pendienteSincronizacion',
              lower: [pendienteSincronizacion],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pendienteSincronizacion',
              lower: [],
              upper: [pendienteSincronizacion],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProductoCollectionQueryFilter
    on QueryBuilder<ProductoCollection, ProductoCollection, QFilterCondition> {
  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      categoriaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoriaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      categoriaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoriaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      categoriaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoriaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      categoriaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoriaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      categoriaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'categoriaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      categoriaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'categoriaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      categoriaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'categoriaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      categoriaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'categoriaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      categoriaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoriaId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      categoriaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'categoriaId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      codigoPersonalizadoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'codigoPersonalizado',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      codigoPersonalizadoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'codigoPersonalizado',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      codigoPersonalizadoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoPersonalizado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      codigoPersonalizadoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codigoPersonalizado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      codigoPersonalizadoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codigoPersonalizado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      codigoPersonalizadoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codigoPersonalizado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      codigoPersonalizadoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codigoPersonalizado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      codigoPersonalizadoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codigoPersonalizado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      codigoPersonalizadoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codigoPersonalizado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      codigoPersonalizadoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codigoPersonalizado',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      codigoPersonalizadoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoPersonalizado',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      codigoPersonalizadoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigoPersonalizado',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      descripcionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'descripcion',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      descripcionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'descripcion',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      descripcionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      descripcionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      descripcionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      descripcionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descripcion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      descripcionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      descripcionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      descripcionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      descripcionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'descripcion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      descripcionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descripcion',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      descripcionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'descripcion',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      empresaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empresaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      empresaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'empresaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      empresaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'empresaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      empresaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'empresaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      empresaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'empresaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      empresaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'empresaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      empresaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'empresaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      empresaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'empresaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      empresaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empresaId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      empresaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'empresaId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      especificacionJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'especificacionJson',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      especificacionJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'especificacionJson',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      especificacionJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'especificacionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      especificacionJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'especificacionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      especificacionJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'especificacionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      especificacionJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'especificacionJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      especificacionJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'especificacionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      especificacionJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'especificacionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      especificacionJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'especificacionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      especificacionJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'especificacionJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      especificacionJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'especificacionJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      especificacionJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'especificacionJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      estadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      fechaEliminacionGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      fechaEliminacionLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      fechaEliminacionBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaEliminacion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      fechaRegistroEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      fechaRegistroGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      fechaRegistroLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      fechaRegistroBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaRegistro',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenLocalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imagenLocal',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenLocalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imagenLocal',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenLocalEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagenLocal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenLocalGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagenLocal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenLocalLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagenLocal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenLocalBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagenLocal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenLocalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagenLocal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenLocalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagenLocal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenLocalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagenLocal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenLocalMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagenLocal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenLocalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagenLocal',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenLocalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagenLocal',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imagenUrl',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imagenUrl',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagenUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagenUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagenUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagenUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      imagenUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagenUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      nombreEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      nombreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      nombreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      nombreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      nombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      nombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      nombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      nombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      pendienteSincronizacionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendienteSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      precioBaseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'precioBase',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      precioBaseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'precioBase',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      precioBaseEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precioBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      precioBaseGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precioBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      precioBaseLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precioBase',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      precioBaseBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precioBase',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      serverIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      serverIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      serverIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      serverIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serverId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      serverIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      serverIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      serverIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      serverIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serverId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      ultimaActualizacionGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      ultimaActualizacionLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      ultimaActualizacionBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ultimaActualizacion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      ultimoCostoEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimoCosto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      ultimoCostoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ultimoCosto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      ultimoCostoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ultimoCosto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      ultimoCostoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ultimoCosto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      ultimoPrecioVentaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimoPrecioVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      ultimoPrecioVentaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ultimoPrecioVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      ultimoPrecioVentaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ultimoPrecioVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      ultimoPrecioVentaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ultimoPrecioVenta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      usuarioRegistroIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRegistroId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      usuarioRegistroIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usuarioRegistroId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      usuarioRegistroIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usuarioRegistroId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      usuarioRegistroIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usuarioRegistroId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      usuarioRegistroIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'usuarioRegistroId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      usuarioRegistroIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'usuarioRegistroId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      usuarioRegistroIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioRegistroId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      usuarioRegistroIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioRegistroId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      usuarioRegistroIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterFilterCondition>
      usuarioRegistroIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }
}

extension ProductoCollectionQueryObject
    on QueryBuilder<ProductoCollection, ProductoCollection, QFilterCondition> {}

extension ProductoCollectionQueryLinks
    on QueryBuilder<ProductoCollection, ProductoCollection, QFilterCondition> {}

extension ProductoCollectionQuerySortBy
    on QueryBuilder<ProductoCollection, ProductoCollection, QSortBy> {
  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByCategoriaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaId', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByCategoriaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaId', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByCodigoPersonalizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoPersonalizado', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByCodigoPersonalizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoPersonalizado', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByDescripcion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByDescripcionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByEspecificacionJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'especificacionJson', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByEspecificacionJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'especificacionJson', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByImagenLocal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenLocal', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByImagenLocalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenLocal', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByImagenUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenUrl', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByImagenUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenUrl', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByPrecioBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioBase', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByPrecioBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioBase', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByUltimoCosto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimoCosto', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByUltimoCostoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimoCosto', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByUltimoPrecioVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimoPrecioVenta', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByUltimoPrecioVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimoPrecioVenta', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      sortByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension ProductoCollectionQuerySortThenBy
    on QueryBuilder<ProductoCollection, ProductoCollection, QSortThenBy> {
  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByCategoriaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaId', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByCategoriaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaId', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByCodigoPersonalizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoPersonalizado', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByCodigoPersonalizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoPersonalizado', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByDescripcion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByDescripcionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByEspecificacionJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'especificacionJson', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByEspecificacionJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'especificacionJson', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByImagenLocal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenLocal', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByImagenLocalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenLocal', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByImagenUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenUrl', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByImagenUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagenUrl', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByPrecioBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioBase', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByPrecioBaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioBase', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByUltimoCosto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimoCosto', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByUltimoCostoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimoCosto', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByUltimoPrecioVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimoPrecioVenta', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByUltimoPrecioVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimoPrecioVenta', Sort.desc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QAfterSortBy>
      thenByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension ProductoCollectionQueryWhereDistinct
    on QueryBuilder<ProductoCollection, ProductoCollection, QDistinct> {
  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByCategoriaId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoriaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByCodigoPersonalizado({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigoPersonalizado',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByDescripcion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descripcion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByEmpresaId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empresaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByEspecificacionJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'especificacionJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado');
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaRegistro');
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByImagenLocal({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagenLocal', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByImagenUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagenUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByPrecioBase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'precioBase');
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByUltimoCosto() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimoCosto');
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByUltimoPrecioVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimoPrecioVenta');
    });
  }

  QueryBuilder<ProductoCollection, ProductoCollection, QDistinct>
      distinctByUsuarioRegistroId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioRegistroId',
          caseSensitive: caseSensitive);
    });
  }
}

extension ProductoCollectionQueryProperty
    on QueryBuilder<ProductoCollection, ProductoCollection, QQueryProperty> {
  QueryBuilder<ProductoCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProductoCollection, String, QQueryOperations>
      categoriaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoriaId');
    });
  }

  QueryBuilder<ProductoCollection, String?, QQueryOperations>
      codigoPersonalizadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigoPersonalizado');
    });
  }

  QueryBuilder<ProductoCollection, String?, QQueryOperations>
      descripcionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descripcion');
    });
  }

  QueryBuilder<ProductoCollection, String, QQueryOperations>
      empresaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empresaId');
    });
  }

  QueryBuilder<ProductoCollection, String?, QQueryOperations>
      especificacionJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'especificacionJson');
    });
  }

  QueryBuilder<ProductoCollection, bool, QQueryOperations> estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<ProductoCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<ProductoCollection, DateTime, QQueryOperations>
      fechaRegistroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaRegistro');
    });
  }

  QueryBuilder<ProductoCollection, String?, QQueryOperations>
      imagenLocalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagenLocal');
    });
  }

  QueryBuilder<ProductoCollection, String?, QQueryOperations>
      imagenUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagenUrl');
    });
  }

  QueryBuilder<ProductoCollection, String, QQueryOperations> nombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombre');
    });
  }

  QueryBuilder<ProductoCollection, bool, QQueryOperations>
      pendienteSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<ProductoCollection, double?, QQueryOperations>
      precioBaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'precioBase');
    });
  }

  QueryBuilder<ProductoCollection, String, QQueryOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<ProductoCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<ProductoCollection, double, QQueryOperations>
      ultimoCostoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimoCosto');
    });
  }

  QueryBuilder<ProductoCollection, double, QQueryOperations>
      ultimoPrecioVentaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimoPrecioVenta');
    });
  }

  QueryBuilder<ProductoCollection, String, QQueryOperations>
      usuarioRegistroIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioRegistroId');
    });
  }
}
