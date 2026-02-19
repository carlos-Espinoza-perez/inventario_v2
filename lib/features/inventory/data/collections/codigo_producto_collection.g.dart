// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codigo_producto_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCodigoProductoCollectionCollection on Isar {
  IsarCollection<CodigoProductoCollection> get codigoProductoCollections =>
      this.collection();
}

const CodigoProductoCollectionSchema = CollectionSchema(
  name: r'CodigoProductoCollection',
  id: -543832540076324536,
  properties: {
    r'codigoSku': PropertySchema(
      id: 0,
      name: r'codigoSku',
      type: IsarType.string,
    ),
    r'color': PropertySchema(
      id: 1,
      name: r'color',
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
    r'pendienteSincronizacion': PropertySchema(
      id: 5,
      name: r'pendienteSincronizacion',
      type: IsarType.bool,
    ),
    r'productoId': PropertySchema(
      id: 6,
      name: r'productoId',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 7,
      name: r'serverId',
      type: IsarType.string,
    ),
    r'talla': PropertySchema(
      id: 8,
      name: r'talla',
      type: IsarType.string,
    ),
    r'ultimaActualizacion': PropertySchema(
      id: 9,
      name: r'ultimaActualizacion',
      type: IsarType.dateTime,
    ),
    r'usuarioRegistroId': PropertySchema(
      id: 10,
      name: r'usuarioRegistroId',
      type: IsarType.string,
    )
  },
  estimateSize: _codigoProductoCollectionEstimateSize,
  serialize: _codigoProductoCollectionSerialize,
  deserialize: _codigoProductoCollectionDeserialize,
  deserializeProp: _codigoProductoCollectionDeserializeProp,
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
    r'productoId': IndexSchema(
      id: -5250802555047709916,
      name: r'productoId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'productoId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'talla': IndexSchema(
      id: -5087285982846377204,
      name: r'talla',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'talla',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'codigoSku': IndexSchema(
      id: 1524824689371954761,
      name: r'codigoSku',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'codigoSku',
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
  getId: _codigoProductoCollectionGetId,
  getLinks: _codigoProductoCollectionGetLinks,
  attach: _codigoProductoCollectionAttach,
  version: '3.1.0+1',
);

int _codigoProductoCollectionEstimateSize(
  CodigoProductoCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.codigoSku.length * 3;
  {
    final value = object.color;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.productoId.length * 3;
  bytesCount += 3 + object.serverId.length * 3;
  bytesCount += 3 + object.talla.length * 3;
  bytesCount += 3 + object.usuarioRegistroId.length * 3;
  return bytesCount;
}

void _codigoProductoCollectionSerialize(
  CodigoProductoCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.codigoSku);
  writer.writeString(offsets[1], object.color);
  writer.writeBool(offsets[2], object.estado);
  writer.writeDateTime(offsets[3], object.fechaEliminacion);
  writer.writeDateTime(offsets[4], object.fechaRegistro);
  writer.writeBool(offsets[5], object.pendienteSincronizacion);
  writer.writeString(offsets[6], object.productoId);
  writer.writeString(offsets[7], object.serverId);
  writer.writeString(offsets[8], object.talla);
  writer.writeDateTime(offsets[9], object.ultimaActualizacion);
  writer.writeString(offsets[10], object.usuarioRegistroId);
}

CodigoProductoCollection _codigoProductoCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CodigoProductoCollection();
  object.codigoSku = reader.readString(offsets[0]);
  object.color = reader.readStringOrNull(offsets[1]);
  object.estado = reader.readBool(offsets[2]);
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[3]);
  object.fechaRegistro = reader.readDateTime(offsets[4]);
  object.id = id;
  object.pendienteSincronizacion = reader.readBool(offsets[5]);
  object.productoId = reader.readString(offsets[6]);
  object.serverId = reader.readString(offsets[7]);
  object.talla = reader.readString(offsets[8]);
  object.ultimaActualizacion = reader.readDateTime(offsets[9]);
  object.usuarioRegistroId = reader.readString(offsets[10]);
  return object;
}

P _codigoProductoCollectionDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _codigoProductoCollectionGetId(CodigoProductoCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _codigoProductoCollectionGetLinks(
    CodigoProductoCollection object) {
  return [];
}

void _codigoProductoCollectionAttach(
    IsarCollection<dynamic> col, Id id, CodigoProductoCollection object) {
  object.id = id;
}

extension CodigoProductoCollectionByIndex
    on IsarCollection<CodigoProductoCollection> {
  Future<CodigoProductoCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  CodigoProductoCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<CodigoProductoCollection?>> getAllByServerId(
      List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<CodigoProductoCollection?> getAllByServerIdSync(
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

  Future<Id> putByServerId(CodigoProductoCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(CodigoProductoCollection object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(List<CodigoProductoCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<CodigoProductoCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }

  Future<CodigoProductoCollection?> getByCodigoSku(String codigoSku) {
    return getByIndex(r'codigoSku', [codigoSku]);
  }

  CodigoProductoCollection? getByCodigoSkuSync(String codigoSku) {
    return getByIndexSync(r'codigoSku', [codigoSku]);
  }

  Future<bool> deleteByCodigoSku(String codigoSku) {
    return deleteByIndex(r'codigoSku', [codigoSku]);
  }

  bool deleteByCodigoSkuSync(String codigoSku) {
    return deleteByIndexSync(r'codigoSku', [codigoSku]);
  }

  Future<List<CodigoProductoCollection?>> getAllByCodigoSku(
      List<String> codigoSkuValues) {
    final values = codigoSkuValues.map((e) => [e]).toList();
    return getAllByIndex(r'codigoSku', values);
  }

  List<CodigoProductoCollection?> getAllByCodigoSkuSync(
      List<String> codigoSkuValues) {
    final values = codigoSkuValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'codigoSku', values);
  }

  Future<int> deleteAllByCodigoSku(List<String> codigoSkuValues) {
    final values = codigoSkuValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'codigoSku', values);
  }

  int deleteAllByCodigoSkuSync(List<String> codigoSkuValues) {
    final values = codigoSkuValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'codigoSku', values);
  }

  Future<Id> putByCodigoSku(CodigoProductoCollection object) {
    return putByIndex(r'codigoSku', object);
  }

  Id putByCodigoSkuSync(CodigoProductoCollection object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'codigoSku', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCodigoSku(List<CodigoProductoCollection> objects) {
    return putAllByIndex(r'codigoSku', objects);
  }

  List<Id> putAllByCodigoSkuSync(List<CodigoProductoCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'codigoSku', objects, saveLinks: saveLinks);
  }
}

extension CodigoProductoCollectionQueryWhereSort on QueryBuilder<
    CodigoProductoCollection, CodigoProductoCollection, QWhere> {
  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterWhere>
      anyPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'pendienteSincronizacion'),
      );
    });
  }
}

extension CodigoProductoCollectionQueryWhere on QueryBuilder<
    CodigoProductoCollection, CodigoProductoCollection, QWhereClause> {
  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterWhereClause> serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterWhereClause> productoIdEqualTo(String productoId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'productoId',
        value: [productoId],
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterWhereClause> productoIdNotEqualTo(String productoId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productoId',
              lower: [],
              upper: [productoId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productoId',
              lower: [productoId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productoId',
              lower: [productoId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productoId',
              lower: [],
              upper: [productoId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterWhereClause> tallaEqualTo(String talla) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'talla',
        value: [talla],
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterWhereClause> tallaNotEqualTo(String talla) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'talla',
              lower: [],
              upper: [talla],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'talla',
              lower: [talla],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'talla',
              lower: [talla],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'talla',
              lower: [],
              upper: [talla],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterWhereClause> codigoSkuEqualTo(String codigoSku) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'codigoSku',
        value: [codigoSku],
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterWhereClause> codigoSkuNotEqualTo(String codigoSku) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoSku',
              lower: [],
              upper: [codigoSku],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoSku',
              lower: [codigoSku],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoSku',
              lower: [codigoSku],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoSku',
              lower: [],
              upper: [codigoSku],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterWhereClause>
      pendienteSincronizacionEqualTo(bool pendienteSincronizacion) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pendienteSincronizacion',
        value: [pendienteSincronizacion],
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterWhereClause>
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

extension CodigoProductoCollectionQueryFilter on QueryBuilder<
    CodigoProductoCollection, CodigoProductoCollection, QFilterCondition> {
  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> codigoSkuEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoSku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> codigoSkuGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codigoSku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> codigoSkuLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codigoSku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> codigoSkuBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codigoSku',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> codigoSkuStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codigoSku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> codigoSkuEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codigoSku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterFilterCondition>
      codigoSkuContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codigoSku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterFilterCondition>
      codigoSkuMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codigoSku',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> codigoSkuIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoSku',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> codigoSkuIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigoSku',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> colorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'color',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> colorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'color',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> colorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> colorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> colorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> colorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'color',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> colorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> colorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterFilterCondition>
      colorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterFilterCondition>
      colorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'color',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> colorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'color',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> colorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'color',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> estadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> fechaRegistroEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> pendienteSincronizacionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendienteSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> productoIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> productoIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> productoIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> productoIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> productoIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> productoIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterFilterCondition>
      productoIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterFilterCondition>
      productoIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productoId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> productoIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> productoIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterFilterCondition>
      serverIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterFilterCondition>
      serverIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serverId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> tallaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'talla',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> tallaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'talla',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> tallaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'talla',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> tallaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'talla',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> tallaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'talla',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> tallaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'talla',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterFilterCondition>
      tallaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'talla',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterFilterCondition>
      tallaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'talla',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> tallaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'talla',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> tallaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'talla',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
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

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterFilterCondition>
      usuarioRegistroIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioRegistroId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
          QAfterFilterCondition>
      usuarioRegistroIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioRegistroId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }
}

extension CodigoProductoCollectionQueryObject on QueryBuilder<
    CodigoProductoCollection, CodigoProductoCollection, QFilterCondition> {}

extension CodigoProductoCollectionQueryLinks on QueryBuilder<
    CodigoProductoCollection, CodigoProductoCollection, QFilterCondition> {}

extension CodigoProductoCollectionQuerySortBy on QueryBuilder<
    CodigoProductoCollection, CodigoProductoCollection, QSortBy> {
  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByCodigoSku() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoSku', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByCodigoSkuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoSku', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByTalla() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'talla', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByTallaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'talla', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      sortByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension CodigoProductoCollectionQuerySortThenBy on QueryBuilder<
    CodigoProductoCollection, CodigoProductoCollection, QSortThenBy> {
  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByCodigoSku() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoSku', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByCodigoSkuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoSku', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByTalla() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'talla', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByTallaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'talla', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QAfterSortBy>
      thenByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension CodigoProductoCollectionQueryWhereDistinct on QueryBuilder<
    CodigoProductoCollection, CodigoProductoCollection, QDistinct> {
  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QDistinct>
      distinctByCodigoSku({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigoSku', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QDistinct>
      distinctByColor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'color', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QDistinct>
      distinctByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado');
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QDistinct>
      distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QDistinct>
      distinctByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaRegistro');
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QDistinct>
      distinctByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QDistinct>
      distinctByProductoId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QDistinct>
      distinctByTalla({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'talla', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QDistinct>
      distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<CodigoProductoCollection, CodigoProductoCollection, QDistinct>
      distinctByUsuarioRegistroId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioRegistroId',
          caseSensitive: caseSensitive);
    });
  }
}

extension CodigoProductoCollectionQueryProperty on QueryBuilder<
    CodigoProductoCollection, CodigoProductoCollection, QQueryProperty> {
  QueryBuilder<CodigoProductoCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CodigoProductoCollection, String, QQueryOperations>
      codigoSkuProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigoSku');
    });
  }

  QueryBuilder<CodigoProductoCollection, String?, QQueryOperations>
      colorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'color');
    });
  }

  QueryBuilder<CodigoProductoCollection, bool, QQueryOperations>
      estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<CodigoProductoCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<CodigoProductoCollection, DateTime, QQueryOperations>
      fechaRegistroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaRegistro');
    });
  }

  QueryBuilder<CodigoProductoCollection, bool, QQueryOperations>
      pendienteSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<CodigoProductoCollection, String, QQueryOperations>
      productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }

  QueryBuilder<CodigoProductoCollection, String, QQueryOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<CodigoProductoCollection, String, QQueryOperations>
      tallaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'talla');
    });
  }

  QueryBuilder<CodigoProductoCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<CodigoProductoCollection, String, QQueryOperations>
      usuarioRegistroIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioRegistroId');
    });
  }
}
