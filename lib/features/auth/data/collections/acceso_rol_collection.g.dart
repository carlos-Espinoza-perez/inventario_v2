// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acceso_rol_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAccesoRolCollectionCollection on Isar {
  IsarCollection<AccesoRolCollection> get accesoRolCollections =>
      this.collection();
}

const AccesoRolCollectionSchema = CollectionSchema(
  name: r'AccesoRolCollection',
  id: 4855954258121253478,
  properties: {
    r'codigoAcceso': PropertySchema(
      id: 0,
      name: r'codigoAcceso',
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
    r'pendienteSincronizacion': PropertySchema(
      id: 4,
      name: r'pendienteSincronizacion',
      type: IsarType.bool,
    ),
    r'rolId': PropertySchema(
      id: 5,
      name: r'rolId',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 6,
      name: r'serverId',
      type: IsarType.string,
    ),
    r'ultimaActualizacion': PropertySchema(
      id: 7,
      name: r'ultimaActualizacion',
      type: IsarType.dateTime,
    ),
    r'usuarioRegistroId': PropertySchema(
      id: 8,
      name: r'usuarioRegistroId',
      type: IsarType.string,
    )
  },
  estimateSize: _accesoRolCollectionEstimateSize,
  serialize: _accesoRolCollectionSerialize,
  deserialize: _accesoRolCollectionDeserialize,
  deserializeProp: _accesoRolCollectionDeserializeProp,
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
    r'rolId': IndexSchema(
      id: -1175956456833884482,
      name: r'rolId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'rolId',
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
  getId: _accesoRolCollectionGetId,
  getLinks: _accesoRolCollectionGetLinks,
  attach: _accesoRolCollectionAttach,
  version: '3.1.0+1',
);

int _accesoRolCollectionEstimateSize(
  AccesoRolCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.codigoAcceso.length * 3;
  bytesCount += 3 + object.rolId.length * 3;
  bytesCount += 3 + object.serverId.length * 3;
  bytesCount += 3 + object.usuarioRegistroId.length * 3;
  return bytesCount;
}

void _accesoRolCollectionSerialize(
  AccesoRolCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.codigoAcceso);
  writer.writeBool(offsets[1], object.estado);
  writer.writeDateTime(offsets[2], object.fechaEliminacion);
  writer.writeDateTime(offsets[3], object.fechaRegistro);
  writer.writeBool(offsets[4], object.pendienteSincronizacion);
  writer.writeString(offsets[5], object.rolId);
  writer.writeString(offsets[6], object.serverId);
  writer.writeDateTime(offsets[7], object.ultimaActualizacion);
  writer.writeString(offsets[8], object.usuarioRegistroId);
}

AccesoRolCollection _accesoRolCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AccesoRolCollection();
  object.codigoAcceso = reader.readString(offsets[0]);
  object.estado = reader.readBool(offsets[1]);
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[2]);
  object.fechaRegistro = reader.readDateTime(offsets[3]);
  object.id = id;
  object.pendienteSincronizacion = reader.readBool(offsets[4]);
  object.rolId = reader.readString(offsets[5]);
  object.serverId = reader.readString(offsets[6]);
  object.ultimaActualizacion = reader.readDateTime(offsets[7]);
  object.usuarioRegistroId = reader.readString(offsets[8]);
  return object;
}

P _accesoRolCollectionDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _accesoRolCollectionGetId(AccesoRolCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _accesoRolCollectionGetLinks(
    AccesoRolCollection object) {
  return [];
}

void _accesoRolCollectionAttach(
    IsarCollection<dynamic> col, Id id, AccesoRolCollection object) {
  object.id = id;
}

extension AccesoRolCollectionByIndex on IsarCollection<AccesoRolCollection> {
  Future<AccesoRolCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  AccesoRolCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<AccesoRolCollection?>> getAllByServerId(
      List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<AccesoRolCollection?> getAllByServerIdSync(List<String> serverIdValues) {
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

  Future<Id> putByServerId(AccesoRolCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(AccesoRolCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(List<AccesoRolCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<AccesoRolCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension AccesoRolCollectionQueryWhereSort
    on QueryBuilder<AccesoRolCollection, AccesoRolCollection, QWhere> {
  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterWhere>
      anyPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'pendienteSincronizacion'),
      );
    });
  }
}

extension AccesoRolCollectionQueryWhere
    on QueryBuilder<AccesoRolCollection, AccesoRolCollection, QWhereClause> {
  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterWhereClause>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterWhereClause>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterWhereClause>
      serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterWhereClause>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterWhereClause>
      rolIdEqualTo(String rolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'rolId',
        value: [rolId],
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterWhereClause>
      rolIdNotEqualTo(String rolId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rolId',
              lower: [],
              upper: [rolId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rolId',
              lower: [rolId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rolId',
              lower: [rolId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rolId',
              lower: [],
              upper: [rolId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterWhereClause>
      pendienteSincronizacionEqualTo(bool pendienteSincronizacion) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pendienteSincronizacion',
        value: [pendienteSincronizacion],
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterWhereClause>
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

extension AccesoRolCollectionQueryFilter on QueryBuilder<AccesoRolCollection,
    AccesoRolCollection, QFilterCondition> {
  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      codigoAccesoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoAcceso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      codigoAccesoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codigoAcceso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      codigoAccesoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codigoAcceso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      codigoAccesoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codigoAcceso',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      codigoAccesoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codigoAcceso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      codigoAccesoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codigoAcceso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      codigoAccesoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codigoAcceso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      codigoAccesoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codigoAcceso',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      codigoAccesoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoAcceso',
        value: '',
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      codigoAccesoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigoAcceso',
        value: '',
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      estadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      fechaRegistroEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      pendienteSincronizacionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendienteSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      rolIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      rolIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      rolIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      rolIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rolId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      rolIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      rolIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      rolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      rolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      rolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rolId',
        value: '',
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      rolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rolId',
        value: '',
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      serverIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      serverIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serverId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
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

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      usuarioRegistroIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioRegistroId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      usuarioRegistroIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioRegistroId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      usuarioRegistroIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterFilterCondition>
      usuarioRegistroIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }
}

extension AccesoRolCollectionQueryObject on QueryBuilder<AccesoRolCollection,
    AccesoRolCollection, QFilterCondition> {}

extension AccesoRolCollectionQueryLinks on QueryBuilder<AccesoRolCollection,
    AccesoRolCollection, QFilterCondition> {}

extension AccesoRolCollectionQuerySortBy
    on QueryBuilder<AccesoRolCollection, AccesoRolCollection, QSortBy> {
  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByCodigoAcceso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoAcceso', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByCodigoAccesoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoAcceso', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByRolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolId', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByRolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolId', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      sortByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension AccesoRolCollectionQuerySortThenBy
    on QueryBuilder<AccesoRolCollection, AccesoRolCollection, QSortThenBy> {
  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByCodigoAcceso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoAcceso', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByCodigoAccesoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoAcceso', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByRolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolId', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByRolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolId', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QAfterSortBy>
      thenByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension AccesoRolCollectionQueryWhereDistinct
    on QueryBuilder<AccesoRolCollection, AccesoRolCollection, QDistinct> {
  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QDistinct>
      distinctByCodigoAcceso({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigoAcceso', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QDistinct>
      distinctByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado');
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QDistinct>
      distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QDistinct>
      distinctByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaRegistro');
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QDistinct>
      distinctByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QDistinct>
      distinctByRolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QDistinct>
      distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<AccesoRolCollection, AccesoRolCollection, QDistinct>
      distinctByUsuarioRegistroId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioRegistroId',
          caseSensitive: caseSensitive);
    });
  }
}

extension AccesoRolCollectionQueryProperty
    on QueryBuilder<AccesoRolCollection, AccesoRolCollection, QQueryProperty> {
  QueryBuilder<AccesoRolCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AccesoRolCollection, String, QQueryOperations>
      codigoAccesoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigoAcceso');
    });
  }

  QueryBuilder<AccesoRolCollection, bool, QQueryOperations> estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<AccesoRolCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<AccesoRolCollection, DateTime, QQueryOperations>
      fechaRegistroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaRegistro');
    });
  }

  QueryBuilder<AccesoRolCollection, bool, QQueryOperations>
      pendienteSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<AccesoRolCollection, String, QQueryOperations> rolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rolId');
    });
  }

  QueryBuilder<AccesoRolCollection, String, QQueryOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<AccesoRolCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<AccesoRolCollection, String, QQueryOperations>
      usuarioRegistroIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioRegistroId');
    });
  }
}
