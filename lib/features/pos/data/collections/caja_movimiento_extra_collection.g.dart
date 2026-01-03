// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caja_movimiento_extra_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCajaMovimientoExtraCollectionCollection on Isar {
  IsarCollection<CajaMovimientoExtraCollection>
      get cajaMovimientoExtraCollections => this.collection();
}

const CajaMovimientoExtraCollectionSchema = CollectionSchema(
  name: r'CajaMovimientoExtraCollection',
  id: 103421983455303518,
  properties: {
    r'cajaSesionId': PropertySchema(
      id: 0,
      name: r'cajaSesionId',
      type: IsarType.string,
    ),
    r'estado': PropertySchema(
      id: 1,
      name: r'estado',
      type: IsarType.bool,
    ),
    r'fechaEliminacion': PropertySchema(
      id: 2,
      name: r'fechaEliminacion',
      type: IsarType.dateTime,
    ),
    r'monto': PropertySchema(
      id: 3,
      name: r'monto',
      type: IsarType.double,
    ),
    r'motivo': PropertySchema(
      id: 4,
      name: r'motivo',
      type: IsarType.string,
    ),
    r'referenciaVentaId': PropertySchema(
      id: 5,
      name: r'referenciaVentaId',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 6,
      name: r'serverId',
      type: IsarType.string,
    ),
    r'tipo': PropertySchema(
      id: 7,
      name: r'tipo',
      type: IsarType.byte,
      enumMap: _CajaMovimientoExtraCollectiontipoEnumValueMap,
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
  estimateSize: _cajaMovimientoExtraCollectionEstimateSize,
  serialize: _cajaMovimientoExtraCollectionSerialize,
  deserialize: _cajaMovimientoExtraCollectionDeserialize,
  deserializeProp: _cajaMovimientoExtraCollectionDeserializeProp,
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
    r'cajaSesionId': IndexSchema(
      id: -5266376370989164664,
      name: r'cajaSesionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cajaSesionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cajaMovimientoExtraCollectionGetId,
  getLinks: _cajaMovimientoExtraCollectionGetLinks,
  attach: _cajaMovimientoExtraCollectionAttach,
  version: '3.1.0+1',
);

int _cajaMovimientoExtraCollectionEstimateSize(
  CajaMovimientoExtraCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cajaSesionId.length * 3;
  {
    final value = object.motivo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.referenciaVentaId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.serverId.length * 3;
  {
    final value = object.usuarioRegistroId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _cajaMovimientoExtraCollectionSerialize(
  CajaMovimientoExtraCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cajaSesionId);
  writer.writeBool(offsets[1], object.estado);
  writer.writeDateTime(offsets[2], object.fechaEliminacion);
  writer.writeDouble(offsets[3], object.monto);
  writer.writeString(offsets[4], object.motivo);
  writer.writeString(offsets[5], object.referenciaVentaId);
  writer.writeString(offsets[6], object.serverId);
  writer.writeByte(offsets[7], object.tipo.index);
  writer.writeDateTime(offsets[8], object.ultimaActualizacion);
  writer.writeString(offsets[9], object.usuarioRegistroId);
}

CajaMovimientoExtraCollection _cajaMovimientoExtraCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CajaMovimientoExtraCollection();
  object.cajaSesionId = reader.readString(offsets[0]);
  object.estado = reader.readBool(offsets[1]);
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.monto = reader.readDouble(offsets[3]);
  object.motivo = reader.readStringOrNull(offsets[4]);
  object.referenciaVentaId = reader.readStringOrNull(offsets[5]);
  object.serverId = reader.readString(offsets[6]);
  object.tipo = _CajaMovimientoExtraCollectiontipoValueEnumMap[
          reader.readByteOrNull(offsets[7])] ??
      TipoMovimientoCaja.ingreso;
  object.ultimaActualizacion = reader.readDateTime(offsets[8]);
  object.usuarioRegistroId = reader.readStringOrNull(offsets[9]);
  return object;
}

P _cajaMovimientoExtraCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (_CajaMovimientoExtraCollectiontipoValueEnumMap[
              reader.readByteOrNull(offset)] ??
          TipoMovimientoCaja.ingreso) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CajaMovimientoExtraCollectiontipoEnumValueMap = {
  'ingreso': 0,
  'egreso': 1,
};
const _CajaMovimientoExtraCollectiontipoValueEnumMap = {
  0: TipoMovimientoCaja.ingreso,
  1: TipoMovimientoCaja.egreso,
};

Id _cajaMovimientoExtraCollectionGetId(CajaMovimientoExtraCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cajaMovimientoExtraCollectionGetLinks(
    CajaMovimientoExtraCollection object) {
  return [];
}

void _cajaMovimientoExtraCollectionAttach(
    IsarCollection<dynamic> col, Id id, CajaMovimientoExtraCollection object) {
  object.id = id;
}

extension CajaMovimientoExtraCollectionByIndex
    on IsarCollection<CajaMovimientoExtraCollection> {
  Future<CajaMovimientoExtraCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  CajaMovimientoExtraCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<CajaMovimientoExtraCollection?>> getAllByServerId(
      List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<CajaMovimientoExtraCollection?> getAllByServerIdSync(
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

  Future<Id> putByServerId(CajaMovimientoExtraCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(CajaMovimientoExtraCollection object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(
      List<CajaMovimientoExtraCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<CajaMovimientoExtraCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension CajaMovimientoExtraCollectionQueryWhereSort on QueryBuilder<
    CajaMovimientoExtraCollection, CajaMovimientoExtraCollection, QWhere> {
  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CajaMovimientoExtraCollectionQueryWhere on QueryBuilder<
    CajaMovimientoExtraCollection,
    CajaMovimientoExtraCollection,
    QWhereClause> {
  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterWhereClause> serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterWhereClause> cajaSesionIdEqualTo(String cajaSesionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cajaSesionId',
        value: [cajaSesionId],
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterWhereClause> cajaSesionIdNotEqualTo(String cajaSesionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cajaSesionId',
              lower: [],
              upper: [cajaSesionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cajaSesionId',
              lower: [cajaSesionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cajaSesionId',
              lower: [cajaSesionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cajaSesionId',
              lower: [],
              upper: [cajaSesionId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CajaMovimientoExtraCollectionQueryFilter on QueryBuilder<
    CajaMovimientoExtraCollection,
    CajaMovimientoExtraCollection,
    QFilterCondition> {
  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> cajaSesionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cajaSesionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> cajaSesionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cajaSesionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> cajaSesionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cajaSesionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> cajaSesionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cajaSesionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> cajaSesionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cajaSesionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> cajaSesionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cajaSesionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
          QAfterFilterCondition>
      cajaSesionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cajaSesionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
          QAfterFilterCondition>
      cajaSesionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cajaSesionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> cajaSesionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cajaSesionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> cajaSesionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cajaSesionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> estadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> montoEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> montoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> montoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> montoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> motivoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'motivo',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> motivoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'motivo',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> motivoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> motivoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> motivoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> motivoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motivo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> motivoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> motivoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
          QAfterFilterCondition>
      motivoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'motivo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
          QAfterFilterCondition>
      motivoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'motivo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> motivoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motivo',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> motivoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'motivo',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> referenciaVentaIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'referenciaVentaId',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> referenciaVentaIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'referenciaVentaId',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> referenciaVentaIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenciaVentaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> referenciaVentaIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referenciaVentaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> referenciaVentaIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referenciaVentaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> referenciaVentaIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referenciaVentaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> referenciaVentaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'referenciaVentaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> referenciaVentaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'referenciaVentaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
          QAfterFilterCondition>
      referenciaVentaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'referenciaVentaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
          QAfterFilterCondition>
      referenciaVentaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'referenciaVentaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> referenciaVentaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenciaVentaId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> referenciaVentaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'referenciaVentaId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> tipoEqualTo(TipoMovimientoCaja value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipo',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> tipoGreaterThan(
    TipoMovimientoCaja value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipo',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> tipoLessThan(
    TipoMovimientoCaja value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipo',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> tipoBetween(
    TipoMovimientoCaja lower,
    TipoMovimientoCaja upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> usuarioRegistroIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usuarioRegistroId',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> usuarioRegistroIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usuarioRegistroId',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> usuarioRegistroIdEqualTo(
    String? value, {
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> usuarioRegistroIdGreaterThan(
    String? value, {
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> usuarioRegistroIdLessThan(
    String? value, {
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> usuarioRegistroIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
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

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> usuarioRegistroIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterFilterCondition> usuarioRegistroIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }
}

extension CajaMovimientoExtraCollectionQueryObject on QueryBuilder<
    CajaMovimientoExtraCollection,
    CajaMovimientoExtraCollection,
    QFilterCondition> {}

extension CajaMovimientoExtraCollectionQueryLinks on QueryBuilder<
    CajaMovimientoExtraCollection,
    CajaMovimientoExtraCollection,
    QFilterCondition> {}

extension CajaMovimientoExtraCollectionQuerySortBy on QueryBuilder<
    CajaMovimientoExtraCollection, CajaMovimientoExtraCollection, QSortBy> {
  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByCajaSesionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaSesionId', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByCajaSesionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaSesionId', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByMonto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monto', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByMontoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monto', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByMotivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByMotivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByReferenciaVentaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaVentaId', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByReferenciaVentaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaVentaId', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByTipo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByTipoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> sortByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension CajaMovimientoExtraCollectionQuerySortThenBy on QueryBuilder<
    CajaMovimientoExtraCollection, CajaMovimientoExtraCollection, QSortThenBy> {
  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByCajaSesionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaSesionId', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByCajaSesionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaSesionId', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByMonto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monto', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByMontoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monto', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByMotivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByMotivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motivo', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByReferenciaVentaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaVentaId', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByReferenciaVentaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenciaVentaId', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByTipo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByTipoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QAfterSortBy> thenByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension CajaMovimientoExtraCollectionQueryWhereDistinct on QueryBuilder<
    CajaMovimientoExtraCollection, CajaMovimientoExtraCollection, QDistinct> {
  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QDistinct> distinctByCajaSesionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cajaSesionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QDistinct> distinctByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QDistinct> distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QDistinct> distinctByMonto() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monto');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QDistinct> distinctByMotivo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motivo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QDistinct> distinctByReferenciaVentaId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenciaVentaId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QDistinct> distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QDistinct> distinctByTipo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipo');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QDistinct> distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, CajaMovimientoExtraCollection,
      QDistinct> distinctByUsuarioRegistroId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioRegistroId',
          caseSensitive: caseSensitive);
    });
  }
}

extension CajaMovimientoExtraCollectionQueryProperty on QueryBuilder<
    CajaMovimientoExtraCollection,
    CajaMovimientoExtraCollection,
    QQueryProperty> {
  QueryBuilder<CajaMovimientoExtraCollection, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, String, QQueryOperations>
      cajaSesionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cajaSesionId');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, bool, QQueryOperations>
      estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, double, QQueryOperations>
      montoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monto');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, String?, QQueryOperations>
      motivoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motivo');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, String?, QQueryOperations>
      referenciaVentaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenciaVentaId');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, String, QQueryOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, TipoMovimientoCaja,
      QQueryOperations> tipoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipo');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<CajaMovimientoExtraCollection, String?, QQueryOperations>
      usuarioRegistroIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioRegistroId');
    });
  }
}
