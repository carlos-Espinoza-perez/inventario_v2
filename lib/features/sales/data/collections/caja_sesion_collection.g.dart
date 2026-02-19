// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caja_sesion_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCajaSesionCollectionCollection on Isar {
  IsarCollection<CajaSesionCollection> get cajaSesionCollections =>
      this.collection();
}

const CajaSesionCollectionSchema = CollectionSchema(
  name: r'CajaSesionCollection',
  id: 5399972973137555439,
  properties: {
    r'cajaId': PropertySchema(
      id: 0,
      name: r'cajaId',
      type: IsarType.string,
    ),
    r'diferencia': PropertySchema(
      id: 1,
      name: r'diferencia',
      type: IsarType.double,
    ),
    r'estadoSesion': PropertySchema(
      id: 2,
      name: r'estadoSesion',
      type: IsarType.byte,
      enumMap: _CajaSesionCollectionestadoSesionEnumValueMap,
    ),
    r'fechaApertura': PropertySchema(
      id: 3,
      name: r'fechaApertura',
      type: IsarType.dateTime,
    ),
    r'fechaCierre': PropertySchema(
      id: 4,
      name: r'fechaCierre',
      type: IsarType.dateTime,
    ),
    r'fechaEliminacion': PropertySchema(
      id: 5,
      name: r'fechaEliminacion',
      type: IsarType.dateTime,
    ),
    r'montoInicial': PropertySchema(
      id: 6,
      name: r'montoInicial',
      type: IsarType.double,
    ),
    r'pendienteSincronizacion': PropertySchema(
      id: 7,
      name: r'pendienteSincronizacion',
      type: IsarType.bool,
    ),
    r'serverId': PropertySchema(
      id: 8,
      name: r'serverId',
      type: IsarType.string,
    ),
    r'totalEfectivoReal': PropertySchema(
      id: 9,
      name: r'totalEfectivoReal',
      type: IsarType.double,
    ),
    r'totalVentasSistema': PropertySchema(
      id: 10,
      name: r'totalVentasSistema',
      type: IsarType.double,
    ),
    r'ultimaActualizacion': PropertySchema(
      id: 11,
      name: r'ultimaActualizacion',
      type: IsarType.dateTime,
    ),
    r'usuarioAperturaId': PropertySchema(
      id: 12,
      name: r'usuarioAperturaId',
      type: IsarType.string,
    ),
    r'usuarioCierreId': PropertySchema(
      id: 13,
      name: r'usuarioCierreId',
      type: IsarType.string,
    )
  },
  estimateSize: _cajaSesionCollectionEstimateSize,
  serialize: _cajaSesionCollectionSerialize,
  deserialize: _cajaSesionCollectionDeserialize,
  deserializeProp: _cajaSesionCollectionDeserializeProp,
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
    r'cajaId': IndexSchema(
      id: 2408211888535379661,
      name: r'cajaId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cajaId',
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
  getId: _cajaSesionCollectionGetId,
  getLinks: _cajaSesionCollectionGetLinks,
  attach: _cajaSesionCollectionAttach,
  version: '3.1.0+1',
);

int _cajaSesionCollectionEstimateSize(
  CajaSesionCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cajaId.length * 3;
  bytesCount += 3 + object.serverId.length * 3;
  bytesCount += 3 + object.usuarioAperturaId.length * 3;
  {
    final value = object.usuarioCierreId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _cajaSesionCollectionSerialize(
  CajaSesionCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cajaId);
  writer.writeDouble(offsets[1], object.diferencia);
  writer.writeByte(offsets[2], object.estadoSesion.index);
  writer.writeDateTime(offsets[3], object.fechaApertura);
  writer.writeDateTime(offsets[4], object.fechaCierre);
  writer.writeDateTime(offsets[5], object.fechaEliminacion);
  writer.writeDouble(offsets[6], object.montoInicial);
  writer.writeBool(offsets[7], object.pendienteSincronizacion);
  writer.writeString(offsets[8], object.serverId);
  writer.writeDouble(offsets[9], object.totalEfectivoReal);
  writer.writeDouble(offsets[10], object.totalVentasSistema);
  writer.writeDateTime(offsets[11], object.ultimaActualizacion);
  writer.writeString(offsets[12], object.usuarioAperturaId);
  writer.writeString(offsets[13], object.usuarioCierreId);
}

CajaSesionCollection _cajaSesionCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CajaSesionCollection();
  object.cajaId = reader.readString(offsets[0]);
  object.diferencia = reader.readDouble(offsets[1]);
  object.estadoSesion = _CajaSesionCollectionestadoSesionValueEnumMap[
          reader.readByteOrNull(offsets[2])] ??
      EstadoSesion.abierta;
  object.fechaApertura = reader.readDateTime(offsets[3]);
  object.fechaCierre = reader.readDateTimeOrNull(offsets[4]);
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[5]);
  object.id = id;
  object.montoInicial = reader.readDouble(offsets[6]);
  object.pendienteSincronizacion = reader.readBool(offsets[7]);
  object.serverId = reader.readString(offsets[8]);
  object.totalEfectivoReal = reader.readDouble(offsets[9]);
  object.totalVentasSistema = reader.readDouble(offsets[10]);
  object.ultimaActualizacion = reader.readDateTime(offsets[11]);
  object.usuarioAperturaId = reader.readString(offsets[12]);
  object.usuarioCierreId = reader.readStringOrNull(offsets[13]);
  return object;
}

P _cajaSesionCollectionDeserializeProp<P>(
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
      return (_CajaSesionCollectionestadoSesionValueEnumMap[
              reader.readByteOrNull(offset)] ??
          EstadoSesion.abierta) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CajaSesionCollectionestadoSesionEnumValueMap = {
  'abierta': 0,
  'cerrada': 1,
  'arqueada': 2,
};
const _CajaSesionCollectionestadoSesionValueEnumMap = {
  0: EstadoSesion.abierta,
  1: EstadoSesion.cerrada,
  2: EstadoSesion.arqueada,
};

Id _cajaSesionCollectionGetId(CajaSesionCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cajaSesionCollectionGetLinks(
    CajaSesionCollection object) {
  return [];
}

void _cajaSesionCollectionAttach(
    IsarCollection<dynamic> col, Id id, CajaSesionCollection object) {
  object.id = id;
}

extension CajaSesionCollectionByIndex on IsarCollection<CajaSesionCollection> {
  Future<CajaSesionCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  CajaSesionCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<CajaSesionCollection?>> getAllByServerId(
      List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<CajaSesionCollection?> getAllByServerIdSync(
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

  Future<Id> putByServerId(CajaSesionCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(CajaSesionCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(List<CajaSesionCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<CajaSesionCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension CajaSesionCollectionQueryWhereSort
    on QueryBuilder<CajaSesionCollection, CajaSesionCollection, QWhere> {
  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterWhere>
      anyPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'pendienteSincronizacion'),
      );
    });
  }
}

extension CajaSesionCollectionQueryWhere
    on QueryBuilder<CajaSesionCollection, CajaSesionCollection, QWhereClause> {
  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterWhereClause>
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterWhereClause>
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterWhereClause>
      serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterWhereClause>
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterWhereClause>
      cajaIdEqualTo(String cajaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cajaId',
        value: [cajaId],
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterWhereClause>
      cajaIdNotEqualTo(String cajaId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cajaId',
              lower: [],
              upper: [cajaId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cajaId',
              lower: [cajaId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cajaId',
              lower: [cajaId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cajaId',
              lower: [],
              upper: [cajaId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterWhereClause>
      pendienteSincronizacionEqualTo(bool pendienteSincronizacion) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pendienteSincronizacion',
        value: [pendienteSincronizacion],
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterWhereClause>
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

extension CajaSesionCollectionQueryFilter on QueryBuilder<CajaSesionCollection,
    CajaSesionCollection, QFilterCondition> {
  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> cajaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cajaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> cajaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cajaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> cajaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cajaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> cajaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cajaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> cajaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cajaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> cajaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cajaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
          QAfterFilterCondition>
      cajaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cajaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
          QAfterFilterCondition>
      cajaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cajaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> cajaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cajaId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> cajaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cajaId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> diferenciaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'diferencia',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> diferenciaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'diferencia',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> diferenciaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'diferencia',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> diferenciaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'diferencia',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> estadoSesionEqualTo(EstadoSesion value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estadoSesion',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> estadoSesionGreaterThan(
    EstadoSesion value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estadoSesion',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> estadoSesionLessThan(
    EstadoSesion value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estadoSesion',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> estadoSesionBetween(
    EstadoSesion lower,
    EstadoSesion upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estadoSesion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> fechaAperturaEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaApertura',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> fechaAperturaGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaApertura',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> fechaAperturaLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaApertura',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> fechaAperturaBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaApertura',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> fechaCierreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaCierre',
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> fechaCierreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaCierre',
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> fechaCierreEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaCierre',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> fechaCierreGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaCierre',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> fechaCierreLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaCierre',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> fechaCierreBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaCierre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> montoInicialEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'montoInicial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> montoInicialGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'montoInicial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> montoInicialLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'montoInicial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> montoInicialBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'montoInicial',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> pendienteSincronizacionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendienteSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> totalEfectivoRealEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalEfectivoReal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> totalEfectivoRealGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalEfectivoReal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> totalEfectivoRealLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalEfectivoReal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> totalEfectivoRealBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalEfectivoReal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> totalVentasSistemaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalVentasSistema',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> totalVentasSistemaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalVentasSistema',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> totalVentasSistemaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalVentasSistema',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> totalVentasSistemaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalVentasSistema',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
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

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioAperturaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioAperturaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioAperturaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usuarioAperturaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioAperturaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usuarioAperturaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioAperturaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usuarioAperturaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioAperturaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'usuarioAperturaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioAperturaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'usuarioAperturaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
          QAfterFilterCondition>
      usuarioAperturaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioAperturaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
          QAfterFilterCondition>
      usuarioAperturaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioAperturaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioAperturaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioAperturaId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioAperturaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioAperturaId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioCierreIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usuarioCierreId',
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioCierreIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usuarioCierreId',
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioCierreIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioCierreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioCierreIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usuarioCierreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioCierreIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usuarioCierreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioCierreIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usuarioCierreId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioCierreIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'usuarioCierreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioCierreIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'usuarioCierreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
          QAfterFilterCondition>
      usuarioCierreIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioCierreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
          QAfterFilterCondition>
      usuarioCierreIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioCierreId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioCierreIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioCierreId',
        value: '',
      ));
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection,
      QAfterFilterCondition> usuarioCierreIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioCierreId',
        value: '',
      ));
    });
  }
}

extension CajaSesionCollectionQueryObject on QueryBuilder<CajaSesionCollection,
    CajaSesionCollection, QFilterCondition> {}

extension CajaSesionCollectionQueryLinks on QueryBuilder<CajaSesionCollection,
    CajaSesionCollection, QFilterCondition> {}

extension CajaSesionCollectionQuerySortBy
    on QueryBuilder<CajaSesionCollection, CajaSesionCollection, QSortBy> {
  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByCajaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaId', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByCajaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaId', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByDiferencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diferencia', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByDiferenciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diferencia', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByEstadoSesion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoSesion', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByEstadoSesionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoSesion', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByFechaApertura() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaApertura', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByFechaAperturaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaApertura', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByFechaCierre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaCierre', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByFechaCierreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaCierre', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByMontoInicial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoInicial', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByMontoInicialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoInicial', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByTotalEfectivoReal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalEfectivoReal', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByTotalEfectivoRealDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalEfectivoReal', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByTotalVentasSistema() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentasSistema', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByTotalVentasSistemaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentasSistema', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByUsuarioAperturaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioAperturaId', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByUsuarioAperturaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioAperturaId', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByUsuarioCierreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioCierreId', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      sortByUsuarioCierreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioCierreId', Sort.desc);
    });
  }
}

extension CajaSesionCollectionQuerySortThenBy
    on QueryBuilder<CajaSesionCollection, CajaSesionCollection, QSortThenBy> {
  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByCajaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaId', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByCajaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaId', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByDiferencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diferencia', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByDiferenciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diferencia', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByEstadoSesion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoSesion', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByEstadoSesionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoSesion', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByFechaApertura() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaApertura', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByFechaAperturaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaApertura', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByFechaCierre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaCierre', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByFechaCierreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaCierre', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByMontoInicial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoInicial', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByMontoInicialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoInicial', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByTotalEfectivoReal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalEfectivoReal', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByTotalEfectivoRealDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalEfectivoReal', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByTotalVentasSistema() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentasSistema', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByTotalVentasSistemaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVentasSistema', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByUsuarioAperturaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioAperturaId', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByUsuarioAperturaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioAperturaId', Sort.desc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByUsuarioCierreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioCierreId', Sort.asc);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QAfterSortBy>
      thenByUsuarioCierreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioCierreId', Sort.desc);
    });
  }
}

extension CajaSesionCollectionQueryWhereDistinct
    on QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct> {
  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByCajaId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cajaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByDiferencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diferencia');
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByEstadoSesion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estadoSesion');
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByFechaApertura() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaApertura');
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByFechaCierre() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaCierre');
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByMontoInicial() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'montoInicial');
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByTotalEfectivoReal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalEfectivoReal');
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByTotalVentasSistema() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalVentasSistema');
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByUsuarioAperturaId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioAperturaId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CajaSesionCollection, CajaSesionCollection, QDistinct>
      distinctByUsuarioCierreId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioCierreId',
          caseSensitive: caseSensitive);
    });
  }
}

extension CajaSesionCollectionQueryProperty on QueryBuilder<
    CajaSesionCollection, CajaSesionCollection, QQueryProperty> {
  QueryBuilder<CajaSesionCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CajaSesionCollection, String, QQueryOperations>
      cajaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cajaId');
    });
  }

  QueryBuilder<CajaSesionCollection, double, QQueryOperations>
      diferenciaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diferencia');
    });
  }

  QueryBuilder<CajaSesionCollection, EstadoSesion, QQueryOperations>
      estadoSesionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estadoSesion');
    });
  }

  QueryBuilder<CajaSesionCollection, DateTime, QQueryOperations>
      fechaAperturaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaApertura');
    });
  }

  QueryBuilder<CajaSesionCollection, DateTime?, QQueryOperations>
      fechaCierreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaCierre');
    });
  }

  QueryBuilder<CajaSesionCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<CajaSesionCollection, double, QQueryOperations>
      montoInicialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'montoInicial');
    });
  }

  QueryBuilder<CajaSesionCollection, bool, QQueryOperations>
      pendienteSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<CajaSesionCollection, String, QQueryOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<CajaSesionCollection, double, QQueryOperations>
      totalEfectivoRealProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalEfectivoReal');
    });
  }

  QueryBuilder<CajaSesionCollection, double, QQueryOperations>
      totalVentasSistemaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalVentasSistema');
    });
  }

  QueryBuilder<CajaSesionCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<CajaSesionCollection, String, QQueryOperations>
      usuarioAperturaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioAperturaId');
    });
  }

  QueryBuilder<CajaSesionCollection, String?, QQueryOperations>
      usuarioCierreIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioCierreId');
    });
  }
}
