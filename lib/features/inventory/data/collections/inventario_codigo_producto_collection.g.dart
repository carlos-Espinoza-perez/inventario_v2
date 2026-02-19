// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventario_codigo_producto_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInventarioCodigoProductoCollectionCollection on Isar {
  IsarCollection<InventarioCodigoProductoCollection>
      get inventarioCodigoProductoCollections => this.collection();
}

const InventarioCodigoProductoCollectionSchema = CollectionSchema(
  name: r'InventarioCodigoProductoCollection',
  id: -8880811811519772127,
  properties: {
    r'cantidad': PropertySchema(
      id: 0,
      name: r'cantidad',
      type: IsarType.double,
    ),
    r'codigoProductoId': PropertySchema(
      id: 1,
      name: r'codigoProductoId',
      type: IsarType.string,
    ),
    r'estado': PropertySchema(
      id: 2,
      name: r'estado',
      type: IsarType.bool,
    ),
    r'fechaEliminacion': PropertySchema(
      id: 3,
      name: r'fechaEliminacion',
      type: IsarType.dateTime,
    ),
    r'fechaRegistro': PropertySchema(
      id: 4,
      name: r'fechaRegistro',
      type: IsarType.dateTime,
    ),
    r'inventarioId': PropertySchema(
      id: 5,
      name: r'inventarioId',
      type: IsarType.string,
    ),
    r'pendienteSincronizacion': PropertySchema(
      id: 6,
      name: r'pendienteSincronizacion',
      type: IsarType.bool,
    ),
    r'serverId': PropertySchema(
      id: 7,
      name: r'serverId',
      type: IsarType.string,
    ),
    r'ultimaActualizacion': PropertySchema(
      id: 8,
      name: r'ultimaActualizacion',
      type: IsarType.dateTime,
    ),
    r'usuarioRegistroId': PropertySchema(
      id: 9,
      name: r'usuarioRegistroId',
      type: IsarType.string,
    )
  },
  estimateSize: _inventarioCodigoProductoCollectionEstimateSize,
  serialize: _inventarioCodigoProductoCollectionSerialize,
  deserialize: _inventarioCodigoProductoCollectionDeserialize,
  deserializeProp: _inventarioCodigoProductoCollectionDeserializeProp,
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
    r'inventarioId': IndexSchema(
      id: -3782491301918438529,
      name: r'inventarioId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'inventarioId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'codigoProductoId': IndexSchema(
      id: -4680769022254975582,
      name: r'codigoProductoId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'codigoProductoId',
          type: IndexType.hash,
          caseSensitive: true,
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
  getId: _inventarioCodigoProductoCollectionGetId,
  getLinks: _inventarioCodigoProductoCollectionGetLinks,
  attach: _inventarioCodigoProductoCollectionAttach,
  version: '3.1.0+1',
);

int _inventarioCodigoProductoCollectionEstimateSize(
  InventarioCodigoProductoCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.codigoProductoId.length * 3;
  bytesCount += 3 + object.inventarioId.length * 3;
  bytesCount += 3 + object.serverId.length * 3;
  bytesCount += 3 + object.usuarioRegistroId.length * 3;
  return bytesCount;
}

void _inventarioCodigoProductoCollectionSerialize(
  InventarioCodigoProductoCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cantidad);
  writer.writeString(offsets[1], object.codigoProductoId);
  writer.writeBool(offsets[2], object.estado);
  writer.writeDateTime(offsets[3], object.fechaEliminacion);
  writer.writeDateTime(offsets[4], object.fechaRegistro);
  writer.writeString(offsets[5], object.inventarioId);
  writer.writeBool(offsets[6], object.pendienteSincronizacion);
  writer.writeString(offsets[7], object.serverId);
  writer.writeDateTime(offsets[8], object.ultimaActualizacion);
  writer.writeString(offsets[9], object.usuarioRegistroId);
}

InventarioCodigoProductoCollection
    _inventarioCodigoProductoCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InventarioCodigoProductoCollection();
  object.cantidad = reader.readDouble(offsets[0]);
  object.codigoProductoId = reader.readString(offsets[1]);
  object.estado = reader.readBool(offsets[2]);
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[3]);
  object.fechaRegistro = reader.readDateTime(offsets[4]);
  object.id = id;
  object.inventarioId = reader.readString(offsets[5]);
  object.pendienteSincronizacion = reader.readBool(offsets[6]);
  object.serverId = reader.readString(offsets[7]);
  object.ultimaActualizacion = reader.readDateTime(offsets[8]);
  object.usuarioRegistroId = reader.readString(offsets[9]);
  return object;
}

P _inventarioCodigoProductoCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inventarioCodigoProductoCollectionGetId(
    InventarioCodigoProductoCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inventarioCodigoProductoCollectionGetLinks(
    InventarioCodigoProductoCollection object) {
  return [];
}

void _inventarioCodigoProductoCollectionAttach(IsarCollection<dynamic> col,
    Id id, InventarioCodigoProductoCollection object) {
  object.id = id;
}

extension InventarioCodigoProductoCollectionByIndex
    on IsarCollection<InventarioCodigoProductoCollection> {
  Future<InventarioCodigoProductoCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  InventarioCodigoProductoCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<InventarioCodigoProductoCollection?>> getAllByServerId(
      List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<InventarioCodigoProductoCollection?> getAllByServerIdSync(
      List<String> serverIdValues) {
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

  Future<Id> putByServerId(InventarioCodigoProductoCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(InventarioCodigoProductoCollection object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(
      List<InventarioCodigoProductoCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(
      List<InventarioCodigoProductoCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension InventarioCodigoProductoCollectionQueryWhereSort on QueryBuilder<
    InventarioCodigoProductoCollection,
    InventarioCodigoProductoCollection,
    QWhere> {
  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterWhere> anyPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'pendienteSincronizacion'),
      );
    });
  }
}

extension InventarioCodigoProductoCollectionQueryWhere on QueryBuilder<
    InventarioCodigoProductoCollection,
    InventarioCodigoProductoCollection,
    QWhereClause> {
  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterWhereClause> idBetween(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterWhereClause> serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterWhereClause> serverIdNotEqualTo(String serverId) {
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterWhereClause> inventarioIdEqualTo(String inventarioId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'inventarioId',
        value: [inventarioId],
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterWhereClause> inventarioIdNotEqualTo(String inventarioId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'inventarioId',
              lower: [],
              upper: [inventarioId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'inventarioId',
              lower: [inventarioId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'inventarioId',
              lower: [inventarioId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'inventarioId',
              lower: [],
              upper: [inventarioId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterWhereClause> codigoProductoIdEqualTo(String codigoProductoId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'codigoProductoId',
        value: [codigoProductoId],
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterWhereClause> codigoProductoIdNotEqualTo(String codigoProductoId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoProductoId',
              lower: [],
              upper: [codigoProductoId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoProductoId',
              lower: [codigoProductoId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoProductoId',
              lower: [codigoProductoId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoProductoId',
              lower: [],
              upper: [codigoProductoId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
          InventarioCodigoProductoCollection, QAfterWhereClause>
      pendienteSincronizacionEqualTo(bool pendienteSincronizacion) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pendienteSincronizacion',
        value: [pendienteSincronizacion],
      ));
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
          InventarioCodigoProductoCollection, QAfterWhereClause>
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

extension InventarioCodigoProductoCollectionQueryFilter on QueryBuilder<
    InventarioCodigoProductoCollection,
    InventarioCodigoProductoCollection,
    QFilterCondition> {
  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> cantidadEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> cantidadGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cantidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> cantidadLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cantidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> cantidadBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cantidad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> codigoProductoIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoProductoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> codigoProductoIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codigoProductoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> codigoProductoIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codigoProductoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> codigoProductoIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codigoProductoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> codigoProductoIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codigoProductoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> codigoProductoIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codigoProductoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
          InventarioCodigoProductoCollection, QAfterFilterCondition>
      codigoProductoIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codigoProductoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
          InventarioCodigoProductoCollection, QAfterFilterCondition>
      codigoProductoIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codigoProductoId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> codigoProductoIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoProductoId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> codigoProductoIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigoProductoId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> estadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> fechaEliminacionGreaterThan(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> fechaEliminacionLessThan(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> fechaEliminacionBetween(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> fechaRegistroEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> fechaRegistroGreaterThan(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> fechaRegistroLessThan(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> fechaRegistroBetween(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterFilterCondition> idBetween(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> inventarioIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inventarioId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> inventarioIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inventarioId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> inventarioIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inventarioId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> inventarioIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inventarioId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> inventarioIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'inventarioId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> inventarioIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'inventarioId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
          InventarioCodigoProductoCollection, QAfterFilterCondition>
      inventarioIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inventarioId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
          InventarioCodigoProductoCollection, QAfterFilterCondition>
      inventarioIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inventarioId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> inventarioIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inventarioId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> inventarioIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inventarioId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> pendienteSincronizacionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendienteSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> serverIdEqualTo(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> serverIdGreaterThan(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> serverIdLessThan(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> serverIdBetween(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> serverIdStartsWith(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> serverIdEndsWith(
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

  QueryBuilder<InventarioCodigoProductoCollection,
          InventarioCodigoProductoCollection, QAfterFilterCondition>
      serverIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
          InventarioCodigoProductoCollection, QAfterFilterCondition>
      serverIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serverId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> ultimaActualizacionGreaterThan(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> ultimaActualizacionLessThan(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> ultimaActualizacionBetween(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdEqualTo(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdGreaterThan(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdLessThan(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdBetween(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdStartsWith(
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

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdEndsWith(
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

  QueryBuilder<InventarioCodigoProductoCollection,
          InventarioCodigoProductoCollection, QAfterFilterCondition>
      usuarioRegistroIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioRegistroId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
          InventarioCodigoProductoCollection, QAfterFilterCondition>
      usuarioRegistroIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioRegistroId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }
}

extension InventarioCodigoProductoCollectionQueryObject on QueryBuilder<
    InventarioCodigoProductoCollection,
    InventarioCodigoProductoCollection,
    QFilterCondition> {}

extension InventarioCodigoProductoCollectionQueryLinks on QueryBuilder<
    InventarioCodigoProductoCollection,
    InventarioCodigoProductoCollection,
    QFilterCondition> {}

extension InventarioCodigoProductoCollectionQuerySortBy on QueryBuilder<
    InventarioCodigoProductoCollection,
    InventarioCodigoProductoCollection,
    QSortBy> {
  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> sortByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> sortByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> sortByCodigoProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoProductoId', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> sortByCodigoProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoProductoId', Sort.desc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> sortByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> sortByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> sortByInventarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventarioId', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> sortByInventarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventarioId', Sort.desc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> sortByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> sortByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> sortByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> sortByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension InventarioCodigoProductoCollectionQuerySortThenBy on QueryBuilder<
    InventarioCodigoProductoCollection,
    InventarioCodigoProductoCollection,
    QSortThenBy> {
  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> thenByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> thenByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> thenByCodigoProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoProductoId', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> thenByCodigoProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoProductoId', Sort.desc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> thenByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> thenByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> thenByInventarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventarioId', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> thenByInventarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventarioId', Sort.desc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> thenByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> thenByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QAfterSortBy> thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> thenByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QAfterSortBy> thenByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension InventarioCodigoProductoCollectionQueryWhereDistinct on QueryBuilder<
    InventarioCodigoProductoCollection,
    InventarioCodigoProductoCollection,
    QDistinct> {
  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QDistinct> distinctByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidad');
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QDistinct> distinctByCodigoProductoId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigoProductoId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QDistinct> distinctByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado');
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QDistinct> distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection, QDistinct> distinctByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaRegistro');
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QDistinct> distinctByInventarioId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inventarioId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QDistinct> distinctByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QDistinct> distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QDistinct> distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<
      InventarioCodigoProductoCollection,
      InventarioCodigoProductoCollection,
      QDistinct> distinctByUsuarioRegistroId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioRegistroId',
          caseSensitive: caseSensitive);
    });
  }
}

extension InventarioCodigoProductoCollectionQueryProperty on QueryBuilder<
    InventarioCodigoProductoCollection,
    InventarioCodigoProductoCollection,
    QQueryProperty> {
  QueryBuilder<InventarioCodigoProductoCollection, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection, double, QQueryOperations>
      cantidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidad');
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection, String, QQueryOperations>
      codigoProductoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigoProductoId');
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection, bool, QQueryOperations>
      estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection, DateTime, QQueryOperations>
      fechaRegistroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaRegistro');
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection, String, QQueryOperations>
      inventarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inventarioId');
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection, bool, QQueryOperations>
      pendienteSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection, String, QQueryOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<InventarioCodigoProductoCollection, String, QQueryOperations>
      usuarioRegistroIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioRegistroId');
    });
  }
}
