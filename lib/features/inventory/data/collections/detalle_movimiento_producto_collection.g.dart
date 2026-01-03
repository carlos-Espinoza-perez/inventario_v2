// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detalle_movimiento_producto_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDetalleMovimientoProductoCollectionCollection on Isar {
  IsarCollection<DetalleMovimientoProductoCollection>
      get detalleMovimientoProductoCollections => this.collection();
}

const DetalleMovimientoProductoCollectionSchema = CollectionSchema(
  name: r'DetalleMovimientoProductoCollection',
  id: -5756197873935211485,
  properties: {
    r'cantidad': PropertySchema(
      id: 0,
      name: r'cantidad',
      type: IsarType.double,
    ),
    r'cargosAdicionalesJson': PropertySchema(
      id: 1,
      name: r'cargosAdicionalesJson',
      type: IsarType.string,
    ),
    r'costoProveedor': PropertySchema(
      id: 2,
      name: r'costoProveedor',
      type: IsarType.double,
    ),
    r'costoUnitarioFinal': PropertySchema(
      id: 3,
      name: r'costoUnitarioFinal',
      type: IsarType.double,
    ),
    r'fechaEliminacion': PropertySchema(
      id: 4,
      name: r'fechaEliminacion',
      type: IsarType.dateTime,
    ),
    r'movimientoProductoId': PropertySchema(
      id: 5,
      name: r'movimientoProductoId',
      type: IsarType.string,
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
    r'ultimaActualizacion': PropertySchema(
      id: 8,
      name: r'ultimaActualizacion',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _detalleMovimientoProductoCollectionEstimateSize,
  serialize: _detalleMovimientoProductoCollectionSerialize,
  deserialize: _detalleMovimientoProductoCollectionDeserialize,
  deserializeProp: _detalleMovimientoProductoCollectionDeserializeProp,
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
    r'movimientoProductoId': IndexSchema(
      id: 835978472914207240,
      name: r'movimientoProductoId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'movimientoProductoId',
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _detalleMovimientoProductoCollectionGetId,
  getLinks: _detalleMovimientoProductoCollectionGetLinks,
  attach: _detalleMovimientoProductoCollectionAttach,
  version: '3.1.0+1',
);

int _detalleMovimientoProductoCollectionEstimateSize(
  DetalleMovimientoProductoCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.cargosAdicionalesJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.movimientoProductoId.length * 3;
  bytesCount += 3 + object.productoId.length * 3;
  bytesCount += 3 + object.serverId.length * 3;
  return bytesCount;
}

void _detalleMovimientoProductoCollectionSerialize(
  DetalleMovimientoProductoCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cantidad);
  writer.writeString(offsets[1], object.cargosAdicionalesJson);
  writer.writeDouble(offsets[2], object.costoProveedor);
  writer.writeDouble(offsets[3], object.costoUnitarioFinal);
  writer.writeDateTime(offsets[4], object.fechaEliminacion);
  writer.writeString(offsets[5], object.movimientoProductoId);
  writer.writeString(offsets[6], object.productoId);
  writer.writeString(offsets[7], object.serverId);
  writer.writeDateTime(offsets[8], object.ultimaActualizacion);
}

DetalleMovimientoProductoCollection
    _detalleMovimientoProductoCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DetalleMovimientoProductoCollection();
  object.cantidad = reader.readDouble(offsets[0]);
  object.cargosAdicionalesJson = reader.readStringOrNull(offsets[1]);
  object.costoProveedor = reader.readDouble(offsets[2]);
  object.costoUnitarioFinal = reader.readDouble(offsets[3]);
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.movimientoProductoId = reader.readString(offsets[5]);
  object.productoId = reader.readString(offsets[6]);
  object.serverId = reader.readString(offsets[7]);
  object.ultimaActualizacion = reader.readDateTime(offsets[8]);
  return object;
}

P _detalleMovimientoProductoCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _detalleMovimientoProductoCollectionGetId(
    DetalleMovimientoProductoCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _detalleMovimientoProductoCollectionGetLinks(
    DetalleMovimientoProductoCollection object) {
  return [];
}

void _detalleMovimientoProductoCollectionAttach(IsarCollection<dynamic> col,
    Id id, DetalleMovimientoProductoCollection object) {
  object.id = id;
}

extension DetalleMovimientoProductoCollectionByIndex
    on IsarCollection<DetalleMovimientoProductoCollection> {
  Future<DetalleMovimientoProductoCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  DetalleMovimientoProductoCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<DetalleMovimientoProductoCollection?>> getAllByServerId(
      List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<DetalleMovimientoProductoCollection?> getAllByServerIdSync(
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

  Future<Id> putByServerId(DetalleMovimientoProductoCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(DetalleMovimientoProductoCollection object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(
      List<DetalleMovimientoProductoCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(
      List<DetalleMovimientoProductoCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension DetalleMovimientoProductoCollectionQueryWhereSort on QueryBuilder<
    DetalleMovimientoProductoCollection,
    DetalleMovimientoProductoCollection,
    QWhere> {
  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DetalleMovimientoProductoCollectionQueryWhere on QueryBuilder<
    DetalleMovimientoProductoCollection,
    DetalleMovimientoProductoCollection,
    QWhereClause> {
  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterWhereClause> idBetween(
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterWhereClause> serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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

  QueryBuilder<DetalleMovimientoProductoCollection,
          DetalleMovimientoProductoCollection, QAfterWhereClause>
      movimientoProductoIdEqualTo(String movimientoProductoId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'movimientoProductoId',
        value: [movimientoProductoId],
      ));
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
          DetalleMovimientoProductoCollection, QAfterWhereClause>
      movimientoProductoIdNotEqualTo(String movimientoProductoId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'movimientoProductoId',
              lower: [],
              upper: [movimientoProductoId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'movimientoProductoId',
              lower: [movimientoProductoId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'movimientoProductoId',
              lower: [movimientoProductoId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'movimientoProductoId',
              lower: [],
              upper: [movimientoProductoId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterWhereClause> productoIdEqualTo(String productoId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'productoId',
        value: [productoId],
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
}

extension DetalleMovimientoProductoCollectionQueryFilter on QueryBuilder<
    DetalleMovimientoProductoCollection,
    DetalleMovimientoProductoCollection,
    QFilterCondition> {
  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> cargosAdicionalesJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cargosAdicionalesJson',
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> cargosAdicionalesJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cargosAdicionalesJson',
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> cargosAdicionalesJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cargosAdicionalesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> cargosAdicionalesJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cargosAdicionalesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> cargosAdicionalesJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cargosAdicionalesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> cargosAdicionalesJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cargosAdicionalesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> cargosAdicionalesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cargosAdicionalesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> cargosAdicionalesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cargosAdicionalesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
          DetalleMovimientoProductoCollection, QAfterFilterCondition>
      cargosAdicionalesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cargosAdicionalesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
          DetalleMovimientoProductoCollection, QAfterFilterCondition>
      cargosAdicionalesJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cargosAdicionalesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> cargosAdicionalesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cargosAdicionalesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> cargosAdicionalesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cargosAdicionalesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> costoProveedorEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'costoProveedor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> costoProveedorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'costoProveedor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> costoProveedorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'costoProveedor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> costoProveedorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'costoProveedor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> costoUnitarioFinalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'costoUnitarioFinal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> costoUnitarioFinalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'costoUnitarioFinal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> costoUnitarioFinalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'costoUnitarioFinal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> costoUnitarioFinalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'costoUnitarioFinal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterFilterCondition> idBetween(
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> movimientoProductoIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movimientoProductoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> movimientoProductoIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'movimientoProductoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> movimientoProductoIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'movimientoProductoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> movimientoProductoIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'movimientoProductoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> movimientoProductoIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'movimientoProductoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> movimientoProductoIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'movimientoProductoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
          DetalleMovimientoProductoCollection, QAfterFilterCondition>
      movimientoProductoIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'movimientoProductoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
          DetalleMovimientoProductoCollection, QAfterFilterCondition>
      movimientoProductoIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'movimientoProductoId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> movimientoProductoIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movimientoProductoId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> movimientoProductoIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'movimientoProductoId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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

  QueryBuilder<DetalleMovimientoProductoCollection,
          DetalleMovimientoProductoCollection, QAfterFilterCondition>
      productoIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
          DetalleMovimientoProductoCollection, QAfterFilterCondition>
      productoIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productoId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> productoIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> productoIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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

  QueryBuilder<DetalleMovimientoProductoCollection,
          DetalleMovimientoProductoCollection, QAfterFilterCondition>
      serverIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
          DetalleMovimientoProductoCollection, QAfterFilterCondition>
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterFilterCondition> ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
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
}

extension DetalleMovimientoProductoCollectionQueryObject on QueryBuilder<
    DetalleMovimientoProductoCollection,
    DetalleMovimientoProductoCollection,
    QFilterCondition> {}

extension DetalleMovimientoProductoCollectionQueryLinks on QueryBuilder<
    DetalleMovimientoProductoCollection,
    DetalleMovimientoProductoCollection,
    QFilterCondition> {}

extension DetalleMovimientoProductoCollectionQuerySortBy on QueryBuilder<
    DetalleMovimientoProductoCollection,
    DetalleMovimientoProductoCollection,
    QSortBy> {
  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterSortBy> sortByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterSortBy> sortByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> sortByCargosAdicionalesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cargosAdicionalesJson', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> sortByCargosAdicionalesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cargosAdicionalesJson', Sort.desc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> sortByCostoProveedor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoProveedor', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> sortByCostoProveedorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoProveedor', Sort.desc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> sortByCostoUnitarioFinal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoUnitarioFinal', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> sortByCostoUnitarioFinalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoUnitarioFinal', Sort.desc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> sortByMovimientoProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movimientoProductoId', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> sortByMovimientoProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movimientoProductoId', Sort.desc);
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterSortBy> sortByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> sortByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterSortBy> sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterSortBy> sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }
}

extension DetalleMovimientoProductoCollectionQuerySortThenBy on QueryBuilder<
    DetalleMovimientoProductoCollection,
    DetalleMovimientoProductoCollection,
    QSortThenBy> {
  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterSortBy> thenByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterSortBy> thenByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> thenByCargosAdicionalesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cargosAdicionalesJson', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> thenByCargosAdicionalesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cargosAdicionalesJson', Sort.desc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> thenByCostoProveedor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoProveedor', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> thenByCostoProveedorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoProveedor', Sort.desc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> thenByCostoUnitarioFinal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoUnitarioFinal', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> thenByCostoUnitarioFinalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoUnitarioFinal', Sort.desc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> thenByMovimientoProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movimientoProductoId', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> thenByMovimientoProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movimientoProductoId', Sort.desc);
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterSortBy> thenByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> thenByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterSortBy> thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QAfterSortBy> thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QAfterSortBy> thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }
}

extension DetalleMovimientoProductoCollectionQueryWhereDistinct on QueryBuilder<
    DetalleMovimientoProductoCollection,
    DetalleMovimientoProductoCollection,
    QDistinct> {
  QueryBuilder<DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection, QDistinct> distinctByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidad');
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QDistinct> distinctByCargosAdicionalesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cargosAdicionalesJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QDistinct> distinctByCostoProveedor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costoProveedor');
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QDistinct> distinctByCostoUnitarioFinal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costoUnitarioFinal');
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QDistinct> distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QDistinct> distinctByMovimientoProductoId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movimientoProductoId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QDistinct> distinctByProductoId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QDistinct> distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      DetalleMovimientoProductoCollection,
      DetalleMovimientoProductoCollection,
      QDistinct> distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }
}

extension DetalleMovimientoProductoCollectionQueryProperty on QueryBuilder<
    DetalleMovimientoProductoCollection,
    DetalleMovimientoProductoCollection,
    QQueryProperty> {
  QueryBuilder<DetalleMovimientoProductoCollection, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection, double, QQueryOperations>
      cantidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidad');
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection, String?, QQueryOperations>
      cargosAdicionalesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cargosAdicionalesJson');
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection, double, QQueryOperations>
      costoProveedorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costoProveedor');
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection, double, QQueryOperations>
      costoUnitarioFinalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costoUnitarioFinal');
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection, String, QQueryOperations>
      movimientoProductoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movimientoProductoId');
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection, String, QQueryOperations>
      productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection, String, QQueryOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<DetalleMovimientoProductoCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }
}
