// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cargo_adicional_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCargoAdicionalCollectionCollection on Isar {
  IsarCollection<CargoAdicionalCollection> get cargoAdicionalCollections =>
      this.collection();
}

const CargoAdicionalCollectionSchema = CollectionSchema(
  name: r'CargoAdicionalCollection',
  id: 5488593703902336685,
  properties: {
    r'aplicarAutomatico': PropertySchema(
      id: 0,
      name: r'aplicarAutomatico',
      type: IsarType.bool,
    ),
    r'empresaId': PropertySchema(
      id: 1,
      name: r'empresaId',
      type: IsarType.string,
    ),
    r'esPorcentaje': PropertySchema(
      id: 2,
      name: r'esPorcentaje',
      type: IsarType.bool,
    ),
    r'nombre': PropertySchema(
      id: 3,
      name: r'nombre',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 4,
      name: r'serverId',
      type: IsarType.string,
    ),
    r'ultimaActualizacion': PropertySchema(
      id: 5,
      name: r'ultimaActualizacion',
      type: IsarType.dateTime,
    ),
    r'valor': PropertySchema(
      id: 6,
      name: r'valor',
      type: IsarType.double,
    )
  },
  estimateSize: _cargoAdicionalCollectionEstimateSize,
  serialize: _cargoAdicionalCollectionSerialize,
  deserialize: _cargoAdicionalCollectionDeserialize,
  deserializeProp: _cargoAdicionalCollectionDeserializeProp,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cargoAdicionalCollectionGetId,
  getLinks: _cargoAdicionalCollectionGetLinks,
  attach: _cargoAdicionalCollectionAttach,
  version: '3.1.0+1',
);

int _cargoAdicionalCollectionEstimateSize(
  CargoAdicionalCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.empresaId.length * 3;
  {
    final value = object.nombre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.serverId.length * 3;
  return bytesCount;
}

void _cargoAdicionalCollectionSerialize(
  CargoAdicionalCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.aplicarAutomatico);
  writer.writeString(offsets[1], object.empresaId);
  writer.writeBool(offsets[2], object.esPorcentaje);
  writer.writeString(offsets[3], object.nombre);
  writer.writeString(offsets[4], object.serverId);
  writer.writeDateTime(offsets[5], object.ultimaActualizacion);
  writer.writeDouble(offsets[6], object.valor);
}

CargoAdicionalCollection _cargoAdicionalCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CargoAdicionalCollection();
  object.aplicarAutomatico = reader.readBool(offsets[0]);
  object.empresaId = reader.readString(offsets[1]);
  object.esPorcentaje = reader.readBool(offsets[2]);
  object.id = id;
  object.nombre = reader.readStringOrNull(offsets[3]);
  object.serverId = reader.readString(offsets[4]);
  object.ultimaActualizacion = reader.readDateTime(offsets[5]);
  object.valor = reader.readDouble(offsets[6]);
  return object;
}

P _cargoAdicionalCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cargoAdicionalCollectionGetId(CargoAdicionalCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cargoAdicionalCollectionGetLinks(
    CargoAdicionalCollection object) {
  return [];
}

void _cargoAdicionalCollectionAttach(
    IsarCollection<dynamic> col, Id id, CargoAdicionalCollection object) {
  object.id = id;
}

extension CargoAdicionalCollectionByIndex
    on IsarCollection<CargoAdicionalCollection> {
  Future<CargoAdicionalCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  CargoAdicionalCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<CargoAdicionalCollection?>> getAllByServerId(
      List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<CargoAdicionalCollection?> getAllByServerIdSync(
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

  Future<Id> putByServerId(CargoAdicionalCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(CargoAdicionalCollection object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(List<CargoAdicionalCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<CargoAdicionalCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension CargoAdicionalCollectionQueryWhereSort on QueryBuilder<
    CargoAdicionalCollection, CargoAdicionalCollection, QWhere> {
  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CargoAdicionalCollectionQueryWhere on QueryBuilder<
    CargoAdicionalCollection, CargoAdicionalCollection, QWhereClause> {
  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterWhereClause> serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterWhereClause> empresaIdEqualTo(String empresaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'empresaId',
        value: [empresaId],
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterWhereClause> empresaIdNotEqualTo(String empresaId) {
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
}

extension CargoAdicionalCollectionQueryFilter on QueryBuilder<
    CargoAdicionalCollection, CargoAdicionalCollection, QFilterCondition> {
  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> aplicarAutomaticoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aplicarAutomatico',
        value: value,
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> empresaIdEqualTo(
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> empresaIdGreaterThan(
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> empresaIdLessThan(
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> empresaIdBetween(
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> empresaIdStartsWith(
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> empresaIdEndsWith(
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
          QAfterFilterCondition>
      empresaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'empresaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
          QAfterFilterCondition>
      empresaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'empresaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> empresaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empresaId',
        value: '',
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> empresaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'empresaId',
        value: '',
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> esPorcentajeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'esPorcentaje',
        value: value,
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> nombreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nombre',
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> nombreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nombre',
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> nombreEqualTo(
    String? value, {
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> nombreGreaterThan(
    String? value, {
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> nombreLessThan(
    String? value, {
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> nombreBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> nombreStartsWith(
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> nombreEndsWith(
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
          QAfterFilterCondition>
      nombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
          QAfterFilterCondition>
      nombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
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

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> valorEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'valor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> valorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'valor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> valorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'valor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection,
      QAfterFilterCondition> valorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'valor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension CargoAdicionalCollectionQueryObject on QueryBuilder<
    CargoAdicionalCollection, CargoAdicionalCollection, QFilterCondition> {}

extension CargoAdicionalCollectionQueryLinks on QueryBuilder<
    CargoAdicionalCollection, CargoAdicionalCollection, QFilterCondition> {}

extension CargoAdicionalCollectionQuerySortBy on QueryBuilder<
    CargoAdicionalCollection, CargoAdicionalCollection, QSortBy> {
  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByAplicarAutomatico() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aplicarAutomatico', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByAplicarAutomaticoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aplicarAutomatico', Sort.desc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByEsPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esPorcentaje', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByEsPorcentajeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esPorcentaje', Sort.desc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByValor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valor', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      sortByValorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valor', Sort.desc);
    });
  }
}

extension CargoAdicionalCollectionQuerySortThenBy on QueryBuilder<
    CargoAdicionalCollection, CargoAdicionalCollection, QSortThenBy> {
  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByAplicarAutomatico() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aplicarAutomatico', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByAplicarAutomaticoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aplicarAutomatico', Sort.desc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByEsPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esPorcentaje', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByEsPorcentajeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esPorcentaje', Sort.desc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByValor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valor', Sort.asc);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QAfterSortBy>
      thenByValorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valor', Sort.desc);
    });
  }
}

extension CargoAdicionalCollectionQueryWhereDistinct on QueryBuilder<
    CargoAdicionalCollection, CargoAdicionalCollection, QDistinct> {
  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QDistinct>
      distinctByAplicarAutomatico() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aplicarAutomatico');
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QDistinct>
      distinctByEmpresaId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empresaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QDistinct>
      distinctByEsPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'esPorcentaje');
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QDistinct>
      distinctByNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QDistinct>
      distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<CargoAdicionalCollection, CargoAdicionalCollection, QDistinct>
      distinctByValor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'valor');
    });
  }
}

extension CargoAdicionalCollectionQueryProperty on QueryBuilder<
    CargoAdicionalCollection, CargoAdicionalCollection, QQueryProperty> {
  QueryBuilder<CargoAdicionalCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CargoAdicionalCollection, bool, QQueryOperations>
      aplicarAutomaticoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aplicarAutomatico');
    });
  }

  QueryBuilder<CargoAdicionalCollection, String, QQueryOperations>
      empresaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empresaId');
    });
  }

  QueryBuilder<CargoAdicionalCollection, bool, QQueryOperations>
      esPorcentajeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'esPorcentaje');
    });
  }

  QueryBuilder<CargoAdicionalCollection, String?, QQueryOperations>
      nombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombre');
    });
  }

  QueryBuilder<CargoAdicionalCollection, String, QQueryOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<CargoAdicionalCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<CargoAdicionalCollection, double, QQueryOperations>
      valorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'valor');
    });
  }
}
