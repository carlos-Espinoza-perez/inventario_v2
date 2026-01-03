// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventario_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInventarioCollectionCollection on Isar {
  IsarCollection<InventarioCollection> get inventarioCollections =>
      this.collection();
}

const InventarioCollectionSchema = CollectionSchema(
  name: r'InventarioCollection',
  id: -4830012789523032182,
  properties: {
    r'bodegaId': PropertySchema(
      id: 0,
      name: r'bodegaId',
      type: IsarType.string,
    ),
    r'cantidadActual': PropertySchema(
      id: 1,
      name: r'cantidadActual',
      type: IsarType.double,
    ),
    r'cantidadReservada': PropertySchema(
      id: 2,
      name: r'cantidadReservada',
      type: IsarType.double,
    ),
    r'fechaEliminacion': PropertySchema(
      id: 3,
      name: r'fechaEliminacion',
      type: IsarType.dateTime,
    ),
    r'productoId': PropertySchema(
      id: 4,
      name: r'productoId',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 5,
      name: r'serverId',
      type: IsarType.string,
    ),
    r'ubicacionPasillo': PropertySchema(
      id: 6,
      name: r'ubicacionPasillo',
      type: IsarType.string,
    ),
    r'ultimaActualizacion': PropertySchema(
      id: 7,
      name: r'ultimaActualizacion',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _inventarioCollectionEstimateSize,
  serialize: _inventarioCollectionSerialize,
  deserialize: _inventarioCollectionDeserialize,
  deserializeProp: _inventarioCollectionDeserializeProp,
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
    r'bodegaId': IndexSchema(
      id: -5394319041530448034,
      name: r'bodegaId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bodegaId',
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
  getId: _inventarioCollectionGetId,
  getLinks: _inventarioCollectionGetLinks,
  attach: _inventarioCollectionAttach,
  version: '3.1.0+1',
);

int _inventarioCollectionEstimateSize(
  InventarioCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bodegaId.length * 3;
  bytesCount += 3 + object.productoId.length * 3;
  bytesCount += 3 + object.serverId.length * 3;
  {
    final value = object.ubicacionPasillo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _inventarioCollectionSerialize(
  InventarioCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bodegaId);
  writer.writeDouble(offsets[1], object.cantidadActual);
  writer.writeDouble(offsets[2], object.cantidadReservada);
  writer.writeDateTime(offsets[3], object.fechaEliminacion);
  writer.writeString(offsets[4], object.productoId);
  writer.writeString(offsets[5], object.serverId);
  writer.writeString(offsets[6], object.ubicacionPasillo);
  writer.writeDateTime(offsets[7], object.ultimaActualizacion);
}

InventarioCollection _inventarioCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InventarioCollection();
  object.bodegaId = reader.readString(offsets[0]);
  object.cantidadActual = reader.readDouble(offsets[1]);
  object.cantidadReservada = reader.readDouble(offsets[2]);
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.productoId = reader.readString(offsets[4]);
  object.serverId = reader.readString(offsets[5]);
  object.ubicacionPasillo = reader.readStringOrNull(offsets[6]);
  object.ultimaActualizacion = reader.readDateTime(offsets[7]);
  return object;
}

P _inventarioCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inventarioCollectionGetId(InventarioCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inventarioCollectionGetLinks(
    InventarioCollection object) {
  return [];
}

void _inventarioCollectionAttach(
    IsarCollection<dynamic> col, Id id, InventarioCollection object) {
  object.id = id;
}

extension InventarioCollectionByIndex on IsarCollection<InventarioCollection> {
  Future<InventarioCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  InventarioCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<InventarioCollection?>> getAllByServerId(
      List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<InventarioCollection?> getAllByServerIdSync(
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

  Future<Id> putByServerId(InventarioCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(InventarioCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(List<InventarioCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<InventarioCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension InventarioCollectionQueryWhereSort
    on QueryBuilder<InventarioCollection, InventarioCollection, QWhere> {
  QueryBuilder<InventarioCollection, InventarioCollection, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InventarioCollectionQueryWhere
    on QueryBuilder<InventarioCollection, InventarioCollection, QWhereClause> {
  QueryBuilder<InventarioCollection, InventarioCollection, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterWhereClause>
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

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterWhereClause>
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

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterWhereClause>
      serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterWhereClause>
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

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterWhereClause>
      bodegaIdEqualTo(String bodegaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bodegaId',
        value: [bodegaId],
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterWhereClause>
      bodegaIdNotEqualTo(String bodegaId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bodegaId',
              lower: [],
              upper: [bodegaId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bodegaId',
              lower: [bodegaId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bodegaId',
              lower: [bodegaId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bodegaId',
              lower: [],
              upper: [bodegaId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterWhereClause>
      productoIdEqualTo(String productoId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'productoId',
        value: [productoId],
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterWhereClause>
      productoIdNotEqualTo(String productoId) {
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

extension InventarioCollectionQueryFilter on QueryBuilder<InventarioCollection,
    InventarioCollection, QFilterCondition> {
  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> bodegaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodegaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> bodegaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bodegaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> bodegaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bodegaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> bodegaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bodegaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> bodegaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bodegaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> bodegaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bodegaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
          QAfterFilterCondition>
      bodegaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bodegaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
          QAfterFilterCondition>
      bodegaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bodegaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> bodegaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodegaId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> bodegaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bodegaId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> cantidadActualEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidadActual',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> cantidadActualGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cantidadActual',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> cantidadActualLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cantidadActual',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> cantidadActualBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cantidadActual',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> cantidadReservadaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidadReservada',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> cantidadReservadaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cantidadReservada',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> cantidadReservadaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cantidadReservada',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> cantidadReservadaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cantidadReservada',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> productoIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> productoIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> ubicacionPasilloIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ubicacionPasillo',
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> ubicacionPasilloIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ubicacionPasillo',
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> ubicacionPasilloEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ubicacionPasillo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> ubicacionPasilloGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ubicacionPasillo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> ubicacionPasilloLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ubicacionPasillo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> ubicacionPasilloBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ubicacionPasillo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> ubicacionPasilloStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ubicacionPasillo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> ubicacionPasilloEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ubicacionPasillo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
          QAfterFilterCondition>
      ubicacionPasilloContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ubicacionPasillo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
          QAfterFilterCondition>
      ubicacionPasilloMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ubicacionPasillo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> ubicacionPasilloIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ubicacionPasillo',
        value: '',
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> ubicacionPasilloIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ubicacionPasillo',
        value: '',
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
      QAfterFilterCondition> ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

  QueryBuilder<InventarioCollection, InventarioCollection,
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

extension InventarioCollectionQueryObject on QueryBuilder<InventarioCollection,
    InventarioCollection, QFilterCondition> {}

extension InventarioCollectionQueryLinks on QueryBuilder<InventarioCollection,
    InventarioCollection, QFilterCondition> {}

extension InventarioCollectionQuerySortBy
    on QueryBuilder<InventarioCollection, InventarioCollection, QSortBy> {
  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByBodegaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaId', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByBodegaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaId', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByCantidadActual() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadActual', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByCantidadActualDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadActual', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByCantidadReservada() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadReservada', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByCantidadReservadaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadReservada', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByUbicacionPasillo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ubicacionPasillo', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByUbicacionPasilloDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ubicacionPasillo', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }
}

extension InventarioCollectionQuerySortThenBy
    on QueryBuilder<InventarioCollection, InventarioCollection, QSortThenBy> {
  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByBodegaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaId', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByBodegaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaId', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByCantidadActual() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadActual', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByCantidadActualDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadActual', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByCantidadReservada() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadReservada', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByCantidadReservadaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadReservada', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByUbicacionPasillo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ubicacionPasillo', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByUbicacionPasilloDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ubicacionPasillo', Sort.desc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QAfterSortBy>
      thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }
}

extension InventarioCollectionQueryWhereDistinct
    on QueryBuilder<InventarioCollection, InventarioCollection, QDistinct> {
  QueryBuilder<InventarioCollection, InventarioCollection, QDistinct>
      distinctByBodegaId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodegaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QDistinct>
      distinctByCantidadActual() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidadActual');
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QDistinct>
      distinctByCantidadReservada() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidadReservada');
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QDistinct>
      distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QDistinct>
      distinctByProductoId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QDistinct>
      distinctByUbicacionPasillo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ubicacionPasillo',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventarioCollection, InventarioCollection, QDistinct>
      distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }
}

extension InventarioCollectionQueryProperty on QueryBuilder<
    InventarioCollection, InventarioCollection, QQueryProperty> {
  QueryBuilder<InventarioCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InventarioCollection, String, QQueryOperations>
      bodegaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodegaId');
    });
  }

  QueryBuilder<InventarioCollection, double, QQueryOperations>
      cantidadActualProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidadActual');
    });
  }

  QueryBuilder<InventarioCollection, double, QQueryOperations>
      cantidadReservadaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidadReservada');
    });
  }

  QueryBuilder<InventarioCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<InventarioCollection, String, QQueryOperations>
      productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }

  QueryBuilder<InventarioCollection, String, QQueryOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<InventarioCollection, String?, QQueryOperations>
      ubicacionPasilloProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ubicacionPasillo');
    });
  }

  QueryBuilder<InventarioCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }
}
