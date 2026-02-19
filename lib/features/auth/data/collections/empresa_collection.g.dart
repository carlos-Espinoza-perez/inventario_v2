// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empresa_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEmpresaCollectionCollection on Isar {
  IsarCollection<EmpresaCollection> get empresaCollections => this.collection();
}

const EmpresaCollectionSchema = CollectionSchema(
  name: r'EmpresaCollection',
  id: -5804461348646656386,
  properties: {
    r'configuracion': PropertySchema(
      id: 0,
      name: r'configuracion',
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
    r'nombreComercial': PropertySchema(
      id: 5,
      name: r'nombreComercial',
      type: IsarType.string,
    ),
    r'pendienteSincronizacion': PropertySchema(
      id: 6,
      name: r'pendienteSincronizacion',
      type: IsarType.bool,
    ),
    r'ruc': PropertySchema(
      id: 7,
      name: r'ruc',
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
    )
  },
  estimateSize: _empresaCollectionEstimateSize,
  serialize: _empresaCollectionSerialize,
  deserialize: _empresaCollectionDeserialize,
  deserializeProp: _empresaCollectionDeserializeProp,
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
  getId: _empresaCollectionGetId,
  getLinks: _empresaCollectionGetLinks,
  attach: _empresaCollectionAttach,
  version: '3.1.0+1',
);

int _empresaCollectionEstimateSize(
  EmpresaCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.configuracion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.nombre.length * 3;
  {
    final value = object.nombreComercial;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ruc;
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

void _empresaCollectionSerialize(
  EmpresaCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.configuracion);
  writer.writeBool(offsets[1], object.estado);
  writer.writeDateTime(offsets[2], object.fechaEliminacion);
  writer.writeDateTime(offsets[3], object.fechaRegistro);
  writer.writeString(offsets[4], object.nombre);
  writer.writeString(offsets[5], object.nombreComercial);
  writer.writeBool(offsets[6], object.pendienteSincronizacion);
  writer.writeString(offsets[7], object.ruc);
  writer.writeString(offsets[8], object.serverId);
  writer.writeDateTime(offsets[9], object.ultimaActualizacion);
  writer.writeString(offsets[10], object.usuarioRegistroId);
}

EmpresaCollection _empresaCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EmpresaCollection();
  object.configuracion = reader.readStringOrNull(offsets[0]);
  object.estado = reader.readBool(offsets[1]);
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[2]);
  object.fechaRegistro = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.nombre = reader.readString(offsets[4]);
  object.nombreComercial = reader.readStringOrNull(offsets[5]);
  object.pendienteSincronizacion = reader.readBool(offsets[6]);
  object.ruc = reader.readStringOrNull(offsets[7]);
  object.serverId = reader.readString(offsets[8]);
  object.ultimaActualizacion = reader.readDateTime(offsets[9]);
  object.usuarioRegistroId = reader.readStringOrNull(offsets[10]);
  return object;
}

P _empresaCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _empresaCollectionGetId(EmpresaCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _empresaCollectionGetLinks(
    EmpresaCollection object) {
  return [];
}

void _empresaCollectionAttach(
    IsarCollection<dynamic> col, Id id, EmpresaCollection object) {
  object.id = id;
}

extension EmpresaCollectionByIndex on IsarCollection<EmpresaCollection> {
  Future<EmpresaCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  EmpresaCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<EmpresaCollection?>> getAllByServerId(
      List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<EmpresaCollection?> getAllByServerIdSync(List<String> serverIdValues) {
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

  Future<Id> putByServerId(EmpresaCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(EmpresaCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(List<EmpresaCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<EmpresaCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension EmpresaCollectionQueryWhereSort
    on QueryBuilder<EmpresaCollection, EmpresaCollection, QWhere> {
  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterWhere>
      anyPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'pendienteSincronizacion'),
      );
    });
  }
}

extension EmpresaCollectionQueryWhere
    on QueryBuilder<EmpresaCollection, EmpresaCollection, QWhereClause> {
  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterWhereClause>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterWhereClause>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterWhereClause>
      serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterWhereClause>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterWhereClause>
      pendienteSincronizacionEqualTo(bool pendienteSincronizacion) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pendienteSincronizacion',
        value: [pendienteSincronizacion],
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterWhereClause>
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

extension EmpresaCollectionQueryFilter
    on QueryBuilder<EmpresaCollection, EmpresaCollection, QFilterCondition> {
  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      configuracionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'configuracion',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      configuracionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'configuracion',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      configuracionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'configuracion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      configuracionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'configuracion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      configuracionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'configuracion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      configuracionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'configuracion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      configuracionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'configuracion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      configuracionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'configuracion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      configuracionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'configuracion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      configuracionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'configuracion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      configuracionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'configuracion',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      configuracionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'configuracion',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      estadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      fechaRegistroIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaRegistro',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      fechaRegistroIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaRegistro',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      fechaRegistroEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreComercialIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nombreComercial',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreComercialIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nombreComercial',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreComercialEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombreComercial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreComercialGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nombreComercial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreComercialLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nombreComercial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreComercialBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nombreComercial',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreComercialStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nombreComercial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreComercialEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nombreComercial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreComercialContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombreComercial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreComercialMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombreComercial',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreComercialIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombreComercial',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      nombreComercialIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombreComercial',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      pendienteSincronizacionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendienteSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      rucIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ruc',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      rucIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ruc',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      rucEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ruc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      rucGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ruc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      rucLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ruc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      rucBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ruc',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      rucStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ruc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      rucEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ruc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      rucContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ruc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      rucMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ruc',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      rucIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ruc',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      rucIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ruc',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      serverIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      serverIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serverId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      usuarioRegistroIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usuarioRegistroId',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      usuarioRegistroIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usuarioRegistroId',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
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

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      usuarioRegistroIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioRegistroId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      usuarioRegistroIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioRegistroId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      usuarioRegistroIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterFilterCondition>
      usuarioRegistroIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }
}

extension EmpresaCollectionQueryObject
    on QueryBuilder<EmpresaCollection, EmpresaCollection, QFilterCondition> {}

extension EmpresaCollectionQueryLinks
    on QueryBuilder<EmpresaCollection, EmpresaCollection, QFilterCondition> {}

extension EmpresaCollectionQuerySortBy
    on QueryBuilder<EmpresaCollection, EmpresaCollection, QSortBy> {
  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByConfiguracion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configuracion', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByConfiguracionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configuracion', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByNombreComercial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreComercial', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByNombreComercialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreComercial', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy> sortByRuc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruc', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByRucDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruc', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      sortByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension EmpresaCollectionQuerySortThenBy
    on QueryBuilder<EmpresaCollection, EmpresaCollection, QSortThenBy> {
  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByConfiguracion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configuracion', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByConfiguracionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configuracion', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByNombreComercial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreComercial', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByNombreComercialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreComercial', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy> thenByRuc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruc', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByRucDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruc', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QAfterSortBy>
      thenByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension EmpresaCollectionQueryWhereDistinct
    on QueryBuilder<EmpresaCollection, EmpresaCollection, QDistinct> {
  QueryBuilder<EmpresaCollection, EmpresaCollection, QDistinct>
      distinctByConfiguracion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'configuracion',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QDistinct>
      distinctByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado');
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QDistinct>
      distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QDistinct>
      distinctByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaRegistro');
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QDistinct>
      distinctByNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QDistinct>
      distinctByNombreComercial({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombreComercial',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QDistinct>
      distinctByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QDistinct> distinctByRuc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ruc', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QDistinct>
      distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<EmpresaCollection, EmpresaCollection, QDistinct>
      distinctByUsuarioRegistroId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioRegistroId',
          caseSensitive: caseSensitive);
    });
  }
}

extension EmpresaCollectionQueryProperty
    on QueryBuilder<EmpresaCollection, EmpresaCollection, QQueryProperty> {
  QueryBuilder<EmpresaCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EmpresaCollection, String?, QQueryOperations>
      configuracionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'configuracion');
    });
  }

  QueryBuilder<EmpresaCollection, bool, QQueryOperations> estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<EmpresaCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<EmpresaCollection, DateTime?, QQueryOperations>
      fechaRegistroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaRegistro');
    });
  }

  QueryBuilder<EmpresaCollection, String, QQueryOperations> nombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombre');
    });
  }

  QueryBuilder<EmpresaCollection, String?, QQueryOperations>
      nombreComercialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombreComercial');
    });
  }

  QueryBuilder<EmpresaCollection, bool, QQueryOperations>
      pendienteSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<EmpresaCollection, String?, QQueryOperations> rucProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ruc');
    });
  }

  QueryBuilder<EmpresaCollection, String, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<EmpresaCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<EmpresaCollection, String?, QQueryOperations>
      usuarioRegistroIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioRegistroId');
    });
  }
}
