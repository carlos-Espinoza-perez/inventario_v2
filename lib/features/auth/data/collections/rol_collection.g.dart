// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rol_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRolCollectionCollection on Isar {
  IsarCollection<RolCollection> get rolCollections => this.collection();
}

const RolCollectionSchema = CollectionSchema(
  name: r'RolCollection',
  id: 4169549729378430224,
  properties: {
    r'empresaId': PropertySchema(
      id: 0,
      name: r'empresaId',
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
    r'nombre': PropertySchema(
      id: 4,
      name: r'nombre',
      type: IsarType.string,
    ),
    r'pendienteSincronizacion': PropertySchema(
      id: 5,
      name: r'pendienteSincronizacion',
      type: IsarType.bool,
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
    r'userAdmin': PropertySchema(
      id: 8,
      name: r'userAdmin',
      type: IsarType.bool,
    ),
    r'usuarioRegistroId': PropertySchema(
      id: 9,
      name: r'usuarioRegistroId',
      type: IsarType.string,
    )
  },
  estimateSize: _rolCollectionEstimateSize,
  serialize: _rolCollectionSerialize,
  deserialize: _rolCollectionDeserialize,
  deserializeProp: _rolCollectionDeserializeProp,
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
  getId: _rolCollectionGetId,
  getLinks: _rolCollectionGetLinks,
  attach: _rolCollectionAttach,
  version: '3.1.0+1',
);

int _rolCollectionEstimateSize(
  RolCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.empresaId.length * 3;
  bytesCount += 3 + object.nombre.length * 3;
  bytesCount += 3 + object.serverId.length * 3;
  {
    final value = object.usuarioRegistroId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _rolCollectionSerialize(
  RolCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.empresaId);
  writer.writeBool(offsets[1], object.estado);
  writer.writeDateTime(offsets[2], object.fechaEliminacion);
  writer.writeDateTime(offsets[3], object.fechaRegistro);
  writer.writeString(offsets[4], object.nombre);
  writer.writeBool(offsets[5], object.pendienteSincronizacion);
  writer.writeString(offsets[6], object.serverId);
  writer.writeDateTime(offsets[7], object.ultimaActualizacion);
  writer.writeBool(offsets[8], object.userAdmin);
  writer.writeString(offsets[9], object.usuarioRegistroId);
}

RolCollection _rolCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RolCollection();
  object.empresaId = reader.readString(offsets[0]);
  object.estado = reader.readBool(offsets[1]);
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[2]);
  object.fechaRegistro = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.nombre = reader.readString(offsets[4]);
  object.pendienteSincronizacion = reader.readBool(offsets[5]);
  object.serverId = reader.readString(offsets[6]);
  object.ultimaActualizacion = reader.readDateTime(offsets[7]);
  object.userAdmin = reader.readBool(offsets[8]);
  object.usuarioRegistroId = reader.readStringOrNull(offsets[9]);
  return object;
}

P _rolCollectionDeserializeProp<P>(
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _rolCollectionGetId(RolCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _rolCollectionGetLinks(RolCollection object) {
  return [];
}

void _rolCollectionAttach(
    IsarCollection<dynamic> col, Id id, RolCollection object) {
  object.id = id;
}

extension RolCollectionByIndex on IsarCollection<RolCollection> {
  Future<RolCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  RolCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<RolCollection?>> getAllByServerId(List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<RolCollection?> getAllByServerIdSync(List<String> serverIdValues) {
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

  Future<Id> putByServerId(RolCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(RolCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(List<RolCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<RolCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension RolCollectionQueryWhereSort
    on QueryBuilder<RolCollection, RolCollection, QWhere> {
  QueryBuilder<RolCollection, RolCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterWhere>
      anyPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'pendienteSincronizacion'),
      );
    });
  }
}

extension RolCollectionQueryWhere
    on QueryBuilder<RolCollection, RolCollection, QWhereClause> {
  QueryBuilder<RolCollection, RolCollection, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<RolCollection, RolCollection, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterWhereClause> idBetween(
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

  QueryBuilder<RolCollection, RolCollection, QAfterWhereClause> serverIdEqualTo(
      String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterWhereClause>
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

  QueryBuilder<RolCollection, RolCollection, QAfterWhereClause>
      empresaIdEqualTo(String empresaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'empresaId',
        value: [empresaId],
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterWhereClause>
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

  QueryBuilder<RolCollection, RolCollection, QAfterWhereClause>
      pendienteSincronizacionEqualTo(bool pendienteSincronizacion) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pendienteSincronizacion',
        value: [pendienteSincronizacion],
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterWhereClause>
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

extension RolCollectionQueryFilter
    on QueryBuilder<RolCollection, RolCollection, QFilterCondition> {
  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      empresaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'empresaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      empresaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'empresaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      empresaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empresaId',
        value: '',
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      empresaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'empresaId',
        value: '',
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      estadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      fechaRegistroIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaRegistro',
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      fechaRegistroIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaRegistro',
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      fechaRegistroEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      fechaRegistroGreaterThan(
    DateTime? value, {
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      fechaRegistroLessThan(
    DateTime? value, {
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      fechaRegistroBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      nombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      nombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      pendienteSincronizacionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendienteSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      serverIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      serverIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serverId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      userAdminEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userAdmin',
        value: value,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      usuarioRegistroIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usuarioRegistroId',
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      usuarioRegistroIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usuarioRegistroId',
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      usuarioRegistroIdEqualTo(
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      usuarioRegistroIdGreaterThan(
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      usuarioRegistroIdLessThan(
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      usuarioRegistroIdBetween(
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
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

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      usuarioRegistroIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioRegistroId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      usuarioRegistroIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioRegistroId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      usuarioRegistroIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterFilterCondition>
      usuarioRegistroIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }
}

extension RolCollectionQueryObject
    on QueryBuilder<RolCollection, RolCollection, QFilterCondition> {}

extension RolCollectionQueryLinks
    on QueryBuilder<RolCollection, RolCollection, QFilterCondition> {}

extension RolCollectionQuerySortBy
    on QueryBuilder<RolCollection, RolCollection, QSortBy> {
  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> sortByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      sortByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      sortByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      sortByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> sortByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> sortByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      sortByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      sortByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> sortByUserAdmin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAdmin', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      sortByUserAdminDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAdmin', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      sortByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      sortByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension RolCollectionQuerySortThenBy
    on QueryBuilder<RolCollection, RolCollection, QSortThenBy> {
  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> thenByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      thenByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      thenByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      thenByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> thenByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> thenByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      thenByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      thenByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy> thenByUserAdmin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAdmin', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      thenByUserAdminDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAdmin', Sort.desc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      thenByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QAfterSortBy>
      thenByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension RolCollectionQueryWhereDistinct
    on QueryBuilder<RolCollection, RolCollection, QDistinct> {
  QueryBuilder<RolCollection, RolCollection, QDistinct> distinctByEmpresaId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empresaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QDistinct> distinctByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado');
    });
  }

  QueryBuilder<RolCollection, RolCollection, QDistinct>
      distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<RolCollection, RolCollection, QDistinct>
      distinctByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaRegistro');
    });
  }

  QueryBuilder<RolCollection, RolCollection, QDistinct> distinctByNombre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QDistinct>
      distinctByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<RolCollection, RolCollection, QDistinct> distinctByServerId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RolCollection, RolCollection, QDistinct>
      distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<RolCollection, RolCollection, QDistinct> distinctByUserAdmin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userAdmin');
    });
  }

  QueryBuilder<RolCollection, RolCollection, QDistinct>
      distinctByUsuarioRegistroId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioRegistroId',
          caseSensitive: caseSensitive);
    });
  }
}

extension RolCollectionQueryProperty
    on QueryBuilder<RolCollection, RolCollection, QQueryProperty> {
  QueryBuilder<RolCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RolCollection, String, QQueryOperations> empresaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empresaId');
    });
  }

  QueryBuilder<RolCollection, bool, QQueryOperations> estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<RolCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<RolCollection, DateTime?, QQueryOperations>
      fechaRegistroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaRegistro');
    });
  }

  QueryBuilder<RolCollection, String, QQueryOperations> nombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombre');
    });
  }

  QueryBuilder<RolCollection, bool, QQueryOperations>
      pendienteSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<RolCollection, String, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<RolCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<RolCollection, bool, QQueryOperations> userAdminProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userAdmin');
    });
  }

  QueryBuilder<RolCollection, String?, QQueryOperations>
      usuarioRegistroIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioRegistroId');
    });
  }
}
