// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historial_pago_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHistorialPagoCollectionCollection on Isar {
  IsarCollection<HistorialPagoCollection> get historialPagoCollections =>
      this.collection();
}

const HistorialPagoCollectionSchema = CollectionSchema(
  name: r'HistorialPagoCollection',
  id: -697161454653766945,
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
    r'fechaRegistro': PropertySchema(
      id: 3,
      name: r'fechaRegistro',
      type: IsarType.dateTime,
    ),
    r'metodoDePago': PropertySchema(
      id: 4,
      name: r'metodoDePago',
      type: IsarType.byte,
      enumMap: _HistorialPagoCollectionmetodoDePagoEnumValueMap,
    ),
    r'montoPagado': PropertySchema(
      id: 5,
      name: r'montoPagado',
      type: IsarType.double,
    ),
    r'pendienteSincronizacion': PropertySchema(
      id: 6,
      name: r'pendienteSincronizacion',
      type: IsarType.bool,
    ),
    r'referencia': PropertySchema(
      id: 7,
      name: r'referencia',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 8,
      name: r'serverId',
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
    ),
    r'ventaId': PropertySchema(
      id: 11,
      name: r'ventaId',
      type: IsarType.string,
    )
  },
  estimateSize: _historialPagoCollectionEstimateSize,
  serialize: _historialPagoCollectionSerialize,
  deserialize: _historialPagoCollectionDeserialize,
  deserializeProp: _historialPagoCollectionDeserializeProp,
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
    r'ventaId': IndexSchema(
      id: -8258295233686175365,
      name: r'ventaId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ventaId',
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
  getId: _historialPagoCollectionGetId,
  getLinks: _historialPagoCollectionGetLinks,
  attach: _historialPagoCollectionAttach,
  version: '3.1.0+1',
);

int _historialPagoCollectionEstimateSize(
  HistorialPagoCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cajaSesionId.length * 3;
  {
    final value = object.referencia;
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
  bytesCount += 3 + object.ventaId.length * 3;
  return bytesCount;
}

void _historialPagoCollectionSerialize(
  HistorialPagoCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cajaSesionId);
  writer.writeBool(offsets[1], object.estado);
  writer.writeDateTime(offsets[2], object.fechaEliminacion);
  writer.writeDateTime(offsets[3], object.fechaRegistro);
  writer.writeByte(offsets[4], object.metodoDePago.index);
  writer.writeDouble(offsets[5], object.montoPagado);
  writer.writeBool(offsets[6], object.pendienteSincronizacion);
  writer.writeString(offsets[7], object.referencia);
  writer.writeString(offsets[8], object.serverId);
  writer.writeDateTime(offsets[9], object.ultimaActualizacion);
  writer.writeString(offsets[10], object.usuarioRegistroId);
  writer.writeString(offsets[11], object.ventaId);
}

HistorialPagoCollection _historialPagoCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HistorialPagoCollection();
  object.cajaSesionId = reader.readString(offsets[0]);
  object.estado = reader.readBool(offsets[1]);
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[2]);
  object.fechaRegistro = reader.readDateTime(offsets[3]);
  object.id = id;
  object.metodoDePago = _HistorialPagoCollectionmetodoDePagoValueEnumMap[
          reader.readByteOrNull(offsets[4])] ??
      MetodoPago.efectivo;
  object.montoPagado = reader.readDouble(offsets[5]);
  object.pendienteSincronizacion = reader.readBool(offsets[6]);
  object.referencia = reader.readStringOrNull(offsets[7]);
  object.serverId = reader.readString(offsets[8]);
  object.ultimaActualizacion = reader.readDateTime(offsets[9]);
  object.usuarioRegistroId = reader.readStringOrNull(offsets[10]);
  object.ventaId = reader.readString(offsets[11]);
  return object;
}

P _historialPagoCollectionDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (_HistorialPagoCollectionmetodoDePagoValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MetodoPago.efectivo) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _HistorialPagoCollectionmetodoDePagoEnumValueMap = {
  'efectivo': 0,
  'tarjeta': 1,
  'transferencia': 2,
};
const _HistorialPagoCollectionmetodoDePagoValueEnumMap = {
  0: MetodoPago.efectivo,
  1: MetodoPago.tarjeta,
  2: MetodoPago.transferencia,
};

Id _historialPagoCollectionGetId(HistorialPagoCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _historialPagoCollectionGetLinks(
    HistorialPagoCollection object) {
  return [];
}

void _historialPagoCollectionAttach(
    IsarCollection<dynamic> col, Id id, HistorialPagoCollection object) {
  object.id = id;
}

extension HistorialPagoCollectionByIndex
    on IsarCollection<HistorialPagoCollection> {
  Future<HistorialPagoCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  HistorialPagoCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<HistorialPagoCollection?>> getAllByServerId(
      List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<HistorialPagoCollection?> getAllByServerIdSync(
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

  Future<Id> putByServerId(HistorialPagoCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(HistorialPagoCollection object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(List<HistorialPagoCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<HistorialPagoCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension HistorialPagoCollectionQueryWhereSort
    on QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QWhere> {
  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterWhere>
      anyPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'pendienteSincronizacion'),
      );
    });
  }
}

extension HistorialPagoCollectionQueryWhere on QueryBuilder<
    HistorialPagoCollection, HistorialPagoCollection, QWhereClause> {
  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterWhereClause> serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterWhereClause> ventaIdEqualTo(String ventaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ventaId',
        value: [ventaId],
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterWhereClause> ventaIdNotEqualTo(String ventaId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaId',
              lower: [],
              upper: [ventaId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaId',
              lower: [ventaId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaId',
              lower: [ventaId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaId',
              lower: [],
              upper: [ventaId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterWhereClause> cajaSesionIdEqualTo(String cajaSesionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cajaSesionId',
        value: [cajaSesionId],
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
          QAfterWhereClause>
      pendienteSincronizacionEqualTo(bool pendienteSincronizacion) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pendienteSincronizacion',
        value: [pendienteSincronizacion],
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

extension HistorialPagoCollectionQueryFilter on QueryBuilder<
    HistorialPagoCollection, HistorialPagoCollection, QFilterCondition> {
  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> cajaSesionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cajaSesionId',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> cajaSesionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cajaSesionId',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> estadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> fechaRegistroEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> metodoDePagoEqualTo(MetodoPago value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metodoDePago',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> metodoDePagoGreaterThan(
    MetodoPago value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metodoDePago',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> metodoDePagoLessThan(
    MetodoPago value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metodoDePago',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> metodoDePagoBetween(
    MetodoPago lower,
    MetodoPago upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metodoDePago',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> montoPagadoEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'montoPagado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> montoPagadoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'montoPagado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> montoPagadoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'montoPagado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> montoPagadoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'montoPagado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> pendienteSincronizacionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendienteSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> referenciaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'referencia',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> referenciaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'referencia',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> referenciaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> referenciaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> referenciaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> referenciaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referencia',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> referenciaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'referencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> referenciaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'referencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
          QAfterFilterCondition>
      referenciaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'referencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
          QAfterFilterCondition>
      referenciaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'referencia',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> referenciaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referencia',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> referenciaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'referencia',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> usuarioRegistroIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usuarioRegistroId',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> usuarioRegistroIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usuarioRegistroId',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
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

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> usuarioRegistroIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> usuarioRegistroIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> ventaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> ventaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ventaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> ventaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ventaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> ventaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ventaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> ventaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ventaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> ventaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ventaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
          QAfterFilterCondition>
      ventaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ventaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
          QAfterFilterCondition>
      ventaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ventaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> ventaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaId',
        value: '',
      ));
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection,
      QAfterFilterCondition> ventaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ventaId',
        value: '',
      ));
    });
  }
}

extension HistorialPagoCollectionQueryObject on QueryBuilder<
    HistorialPagoCollection, HistorialPagoCollection, QFilterCondition> {}

extension HistorialPagoCollectionQueryLinks on QueryBuilder<
    HistorialPagoCollection, HistorialPagoCollection, QFilterCondition> {}

extension HistorialPagoCollectionQuerySortBy
    on QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QSortBy> {
  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByCajaSesionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaSesionId', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByCajaSesionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaSesionId', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByMetodoDePago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoDePago', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByMetodoDePagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoDePago', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByMontoPagado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoPagado', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByMontoPagadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoPagado', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByReferencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referencia', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByReferenciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referencia', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByVentaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaId', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      sortByVentaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaId', Sort.desc);
    });
  }
}

extension HistorialPagoCollectionQuerySortThenBy on QueryBuilder<
    HistorialPagoCollection, HistorialPagoCollection, QSortThenBy> {
  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByCajaSesionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaSesionId', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByCajaSesionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaSesionId', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByMetodoDePago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoDePago', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByMetodoDePagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoDePago', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByMontoPagado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoPagado', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByMontoPagadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoPagado', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByReferencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referencia', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByReferenciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referencia', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByVentaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaId', Sort.asc);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QAfterSortBy>
      thenByVentaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaId', Sort.desc);
    });
  }
}

extension HistorialPagoCollectionQueryWhereDistinct on QueryBuilder<
    HistorialPagoCollection, HistorialPagoCollection, QDistinct> {
  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QDistinct>
      distinctByCajaSesionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cajaSesionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QDistinct>
      distinctByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado');
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QDistinct>
      distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QDistinct>
      distinctByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaRegistro');
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QDistinct>
      distinctByMetodoDePago() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metodoDePago');
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QDistinct>
      distinctByMontoPagado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'montoPagado');
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QDistinct>
      distinctByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QDistinct>
      distinctByReferencia({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referencia', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QDistinct>
      distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QDistinct>
      distinctByUsuarioRegistroId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioRegistroId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistorialPagoCollection, HistorialPagoCollection, QDistinct>
      distinctByVentaId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ventaId', caseSensitive: caseSensitive);
    });
  }
}

extension HistorialPagoCollectionQueryProperty on QueryBuilder<
    HistorialPagoCollection, HistorialPagoCollection, QQueryProperty> {
  QueryBuilder<HistorialPagoCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HistorialPagoCollection, String, QQueryOperations>
      cajaSesionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cajaSesionId');
    });
  }

  QueryBuilder<HistorialPagoCollection, bool, QQueryOperations>
      estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<HistorialPagoCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<HistorialPagoCollection, DateTime, QQueryOperations>
      fechaRegistroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaRegistro');
    });
  }

  QueryBuilder<HistorialPagoCollection, MetodoPago, QQueryOperations>
      metodoDePagoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metodoDePago');
    });
  }

  QueryBuilder<HistorialPagoCollection, double, QQueryOperations>
      montoPagadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'montoPagado');
    });
  }

  QueryBuilder<HistorialPagoCollection, bool, QQueryOperations>
      pendienteSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<HistorialPagoCollection, String?, QQueryOperations>
      referenciaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referencia');
    });
  }

  QueryBuilder<HistorialPagoCollection, String, QQueryOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<HistorialPagoCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<HistorialPagoCollection, String?, QQueryOperations>
      usuarioRegistroIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioRegistroId');
    });
  }

  QueryBuilder<HistorialPagoCollection, String, QQueryOperations>
      ventaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ventaId');
    });
  }
}
