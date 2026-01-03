// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bodega_usuario_colletion.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBodegaUsuarioColletionCollection on Isar {
  IsarCollection<BodegaUsuarioColletion> get bodegaUsuarioColletions =>
      this.collection();
}

const BodegaUsuarioColletionSchema = CollectionSchema(
  name: r'BodegaUsuarioColletion',
  id: -4212074038516471348,
  properties: {
    r'bodegaId': PropertySchema(
      id: 0,
      name: r'bodegaId',
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
    r'uid': PropertySchema(
      id: 4,
      name: r'uid',
      type: IsarType.string,
    ),
    r'ultimaActualizacion': PropertySchema(
      id: 5,
      name: r'ultimaActualizacion',
      type: IsarType.dateTime,
    ),
    r'usuarioId': PropertySchema(
      id: 6,
      name: r'usuarioId',
      type: IsarType.string,
    ),
    r'usuarioRegistroId': PropertySchema(
      id: 7,
      name: r'usuarioRegistroId',
      type: IsarType.string,
    )
  },
  estimateSize: _bodegaUsuarioColletionEstimateSize,
  serialize: _bodegaUsuarioColletionSerialize,
  deserialize: _bodegaUsuarioColletionDeserialize,
  deserializeProp: _bodegaUsuarioColletionDeserializeProp,
  idName: r'id',
  indexes: {
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uid',
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
    r'usuarioId': IndexSchema(
      id: -6806307564427522310,
      name: r'usuarioId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'usuarioId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'estado': IndexSchema(
      id: -4800696143246816208,
      name: r'estado',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'estado',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _bodegaUsuarioColletionGetId,
  getLinks: _bodegaUsuarioColletionGetLinks,
  attach: _bodegaUsuarioColletionAttach,
  version: '3.1.0+1',
);

int _bodegaUsuarioColletionEstimateSize(
  BodegaUsuarioColletion object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bodegaId.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  bytesCount += 3 + object.usuarioId.length * 3;
  bytesCount += 3 + object.usuarioRegistroId.length * 3;
  return bytesCount;
}

void _bodegaUsuarioColletionSerialize(
  BodegaUsuarioColletion object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bodegaId);
  writer.writeBool(offsets[1], object.estado);
  writer.writeDateTime(offsets[2], object.fechaEliminacion);
  writer.writeDateTime(offsets[3], object.fechaRegistro);
  writer.writeString(offsets[4], object.uid);
  writer.writeDateTime(offsets[5], object.ultimaActualizacion);
  writer.writeString(offsets[6], object.usuarioId);
  writer.writeString(offsets[7], object.usuarioRegistroId);
}

BodegaUsuarioColletion _bodegaUsuarioColletionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BodegaUsuarioColletion();
  object.bodegaId = reader.readString(offsets[0]);
  object.estado = reader.readBool(offsets[1]);
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[2]);
  object.fechaRegistro = reader.readDateTime(offsets[3]);
  object.id = id;
  object.uid = reader.readString(offsets[4]);
  object.ultimaActualizacion = reader.readDateTimeOrNull(offsets[5]);
  object.usuarioId = reader.readString(offsets[6]);
  object.usuarioRegistroId = reader.readString(offsets[7]);
  return object;
}

P _bodegaUsuarioColletionDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bodegaUsuarioColletionGetId(BodegaUsuarioColletion object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bodegaUsuarioColletionGetLinks(
    BodegaUsuarioColletion object) {
  return [];
}

void _bodegaUsuarioColletionAttach(
    IsarCollection<dynamic> col, Id id, BodegaUsuarioColletion object) {
  object.id = id;
}

extension BodegaUsuarioColletionByIndex
    on IsarCollection<BodegaUsuarioColletion> {
  Future<BodegaUsuarioColletion?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  BodegaUsuarioColletion? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<BodegaUsuarioColletion?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<BodegaUsuarioColletion?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(BodegaUsuarioColletion object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(BodegaUsuarioColletion object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<BodegaUsuarioColletion> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<BodegaUsuarioColletion> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension BodegaUsuarioColletionQueryWhereSort
    on QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QWhere> {
  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterWhere>
      anyEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'estado'),
      );
    });
  }
}

extension BodegaUsuarioColletionQueryWhere on QueryBuilder<
    BodegaUsuarioColletion, BodegaUsuarioColletion, QWhereClause> {
  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterWhereClause> uidEqualTo(String uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uid',
        value: [uid],
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterWhereClause> uidNotEqualTo(String uid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterWhereClause> bodegaIdEqualTo(String bodegaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bodegaId',
        value: [bodegaId],
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterWhereClause> bodegaIdNotEqualTo(String bodegaId) {
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterWhereClause> usuarioIdEqualTo(String usuarioId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'usuarioId',
        value: [usuarioId],
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterWhereClause> usuarioIdNotEqualTo(String usuarioId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [],
              upper: [usuarioId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [usuarioId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [usuarioId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [],
              upper: [usuarioId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterWhereClause> estadoEqualTo(bool estado) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'estado',
        value: [estado],
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterWhereClause> estadoNotEqualTo(bool estado) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [],
              upper: [estado],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [estado],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [estado],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [],
              upper: [estado],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BodegaUsuarioColletionQueryFilter on QueryBuilder<
    BodegaUsuarioColletion, BodegaUsuarioColletion, QFilterCondition> {
  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> bodegaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodegaId',
        value: '',
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> bodegaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bodegaId',
        value: '',
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> estadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> fechaRegistroEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
          QAfterFilterCondition>
      uidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
          QAfterFilterCondition>
      uidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> ultimaActualizacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ultimaActualizacion',
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> ultimaActualizacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ultimaActualizacion',
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> ultimaActualizacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> ultimaActualizacionGreaterThan(
    DateTime? value, {
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> ultimaActualizacionLessThan(
    DateTime? value, {
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> ultimaActualizacionBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> usuarioIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> usuarioIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usuarioId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> usuarioIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usuarioId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> usuarioIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usuarioId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> usuarioIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'usuarioId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> usuarioIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'usuarioId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
          QAfterFilterCondition>
      usuarioIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
          QAfterFilterCondition>
      usuarioIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> usuarioIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioId',
        value: '',
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> usuarioIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioId',
        value: '',
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
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

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> usuarioRegistroIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion,
      QAfterFilterCondition> usuarioRegistroIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }
}

extension BodegaUsuarioColletionQueryObject on QueryBuilder<
    BodegaUsuarioColletion, BodegaUsuarioColletion, QFilterCondition> {}

extension BodegaUsuarioColletionQueryLinks on QueryBuilder<
    BodegaUsuarioColletion, BodegaUsuarioColletion, QFilterCondition> {}

extension BodegaUsuarioColletionQuerySortBy
    on QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QSortBy> {
  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByBodegaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaId', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByBodegaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaId', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      sortByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension BodegaUsuarioColletionQuerySortThenBy on QueryBuilder<
    BodegaUsuarioColletion, BodegaUsuarioColletion, QSortThenBy> {
  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByBodegaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaId', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByBodegaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaId', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QAfterSortBy>
      thenByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension BodegaUsuarioColletionQueryWhereDistinct
    on QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QDistinct> {
  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QDistinct>
      distinctByBodegaId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodegaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QDistinct>
      distinctByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado');
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QDistinct>
      distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QDistinct>
      distinctByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaRegistro');
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QDistinct>
      distinctByUid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QDistinct>
      distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QDistinct>
      distinctByUsuarioId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BodegaUsuarioColletion, BodegaUsuarioColletion, QDistinct>
      distinctByUsuarioRegistroId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioRegistroId',
          caseSensitive: caseSensitive);
    });
  }
}

extension BodegaUsuarioColletionQueryProperty on QueryBuilder<
    BodegaUsuarioColletion, BodegaUsuarioColletion, QQueryProperty> {
  QueryBuilder<BodegaUsuarioColletion, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BodegaUsuarioColletion, String, QQueryOperations>
      bodegaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodegaId');
    });
  }

  QueryBuilder<BodegaUsuarioColletion, bool, QQueryOperations>
      estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<BodegaUsuarioColletion, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<BodegaUsuarioColletion, DateTime, QQueryOperations>
      fechaRegistroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaRegistro');
    });
  }

  QueryBuilder<BodegaUsuarioColletion, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<BodegaUsuarioColletion, DateTime?, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<BodegaUsuarioColletion, String, QQueryOperations>
      usuarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioId');
    });
  }

  QueryBuilder<BodegaUsuarioColletion, String, QQueryOperations>
      usuarioRegistroIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioRegistroId');
    });
  }
}
