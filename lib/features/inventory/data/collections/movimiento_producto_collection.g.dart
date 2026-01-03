// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movimiento_producto_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMovimientoProductoCollectionCollection on Isar {
  IsarCollection<MovimientoProductoCollection>
      get movimientoProductoCollections => this.collection();
}

const MovimientoProductoCollectionSchema = CollectionSchema(
  name: r'MovimientoProductoCollection',
  id: 592395788203072761,
  properties: {
    r'bodegaDestinoId': PropertySchema(
      id: 0,
      name: r'bodegaDestinoId',
      type: IsarType.string,
    ),
    r'bodegaOrigenId': PropertySchema(
      id: 1,
      name: r'bodegaOrigenId',
      type: IsarType.string,
    ),
    r'descripcion': PropertySchema(
      id: 2,
      name: r'descripcion',
      type: IsarType.string,
    ),
    r'empresaId': PropertySchema(
      id: 3,
      name: r'empresaId',
      type: IsarType.string,
    ),
    r'estado': PropertySchema(
      id: 4,
      name: r'estado',
      type: IsarType.bool,
    ),
    r'estadoMovimiento': PropertySchema(
      id: 5,
      name: r'estadoMovimiento',
      type: IsarType.byte,
      enumMap: _MovimientoProductoCollectionestadoMovimientoEnumValueMap,
    ),
    r'fechaEliminacion': PropertySchema(
      id: 6,
      name: r'fechaEliminacion',
      type: IsarType.dateTime,
    ),
    r'fechaRegistro': PropertySchema(
      id: 7,
      name: r'fechaRegistro',
      type: IsarType.dateTime,
    ),
    r'serverId': PropertySchema(
      id: 8,
      name: r'serverId',
      type: IsarType.string,
    ),
    r'tipoMovimiento': PropertySchema(
      id: 9,
      name: r'tipoMovimiento',
      type: IsarType.byte,
      enumMap: _MovimientoProductoCollectiontipoMovimientoEnumValueMap,
    ),
    r'ultimaActualizacion': PropertySchema(
      id: 10,
      name: r'ultimaActualizacion',
      type: IsarType.dateTime,
    ),
    r'usuarioRegistroId': PropertySchema(
      id: 11,
      name: r'usuarioRegistroId',
      type: IsarType.string,
    )
  },
  estimateSize: _movimientoProductoCollectionEstimateSize,
  serialize: _movimientoProductoCollectionSerialize,
  deserialize: _movimientoProductoCollectionDeserialize,
  deserializeProp: _movimientoProductoCollectionDeserializeProp,
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
  getId: _movimientoProductoCollectionGetId,
  getLinks: _movimientoProductoCollectionGetLinks,
  attach: _movimientoProductoCollectionAttach,
  version: '3.1.0+1',
);

int _movimientoProductoCollectionEstimateSize(
  MovimientoProductoCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.bodegaDestinoId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.bodegaOrigenId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.descripcion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.empresaId.length * 3;
  bytesCount += 3 + object.serverId.length * 3;
  {
    final value = object.usuarioRegistroId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _movimientoProductoCollectionSerialize(
  MovimientoProductoCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bodegaDestinoId);
  writer.writeString(offsets[1], object.bodegaOrigenId);
  writer.writeString(offsets[2], object.descripcion);
  writer.writeString(offsets[3], object.empresaId);
  writer.writeBool(offsets[4], object.estado);
  writer.writeByte(offsets[5], object.estadoMovimiento.index);
  writer.writeDateTime(offsets[6], object.fechaEliminacion);
  writer.writeDateTime(offsets[7], object.fechaRegistro);
  writer.writeString(offsets[8], object.serverId);
  writer.writeByte(offsets[9], object.tipoMovimiento.index);
  writer.writeDateTime(offsets[10], object.ultimaActualizacion);
  writer.writeString(offsets[11], object.usuarioRegistroId);
}

MovimientoProductoCollection _movimientoProductoCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MovimientoProductoCollection();
  object.bodegaDestinoId = reader.readStringOrNull(offsets[0]);
  object.bodegaOrigenId = reader.readStringOrNull(offsets[1]);
  object.descripcion = reader.readStringOrNull(offsets[2]);
  object.empresaId = reader.readString(offsets[3]);
  object.estado = reader.readBool(offsets[4]);
  object.estadoMovimiento =
      _MovimientoProductoCollectionestadoMovimientoValueEnumMap[
              reader.readByteOrNull(offsets[5])] ??
          EstadoMovimiento.pendiente;
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[6]);
  object.fechaRegistro = reader.readDateTime(offsets[7]);
  object.id = id;
  object.serverId = reader.readString(offsets[8]);
  object.tipoMovimiento =
      _MovimientoProductoCollectiontipoMovimientoValueEnumMap[
              reader.readByteOrNull(offsets[9])] ??
          TipoMovimiento.compra;
  object.ultimaActualizacion = reader.readDateTime(offsets[10]);
  object.usuarioRegistroId = reader.readStringOrNull(offsets[11]);
  return object;
}

P _movimientoProductoCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (_MovimientoProductoCollectionestadoMovimientoValueEnumMap[
              reader.readByteOrNull(offset)] ??
          EstadoMovimiento.pendiente) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (_MovimientoProductoCollectiontipoMovimientoValueEnumMap[
              reader.readByteOrNull(offset)] ??
          TipoMovimiento.compra) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MovimientoProductoCollectionestadoMovimientoEnumValueMap = {
  'pendiente': 0,
  'aprobado': 1,
  'rechazado': 2,
};
const _MovimientoProductoCollectionestadoMovimientoValueEnumMap = {
  0: EstadoMovimiento.pendiente,
  1: EstadoMovimiento.aprobado,
  2: EstadoMovimiento.rechazado,
};
const _MovimientoProductoCollectiontipoMovimientoEnumValueMap = {
  'compra': 0,
  'traslado': 1,
  'ajuste': 2,
  'solicitud': 3,
};
const _MovimientoProductoCollectiontipoMovimientoValueEnumMap = {
  0: TipoMovimiento.compra,
  1: TipoMovimiento.traslado,
  2: TipoMovimiento.ajuste,
  3: TipoMovimiento.solicitud,
};

Id _movimientoProductoCollectionGetId(MovimientoProductoCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _movimientoProductoCollectionGetLinks(
    MovimientoProductoCollection object) {
  return [];
}

void _movimientoProductoCollectionAttach(
    IsarCollection<dynamic> col, Id id, MovimientoProductoCollection object) {
  object.id = id;
}

extension MovimientoProductoCollectionByIndex
    on IsarCollection<MovimientoProductoCollection> {
  Future<MovimientoProductoCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  MovimientoProductoCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<MovimientoProductoCollection?>> getAllByServerId(
      List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<MovimientoProductoCollection?> getAllByServerIdSync(
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

  Future<Id> putByServerId(MovimientoProductoCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(MovimientoProductoCollection object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(
      List<MovimientoProductoCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<MovimientoProductoCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension MovimientoProductoCollectionQueryWhereSort on QueryBuilder<
    MovimientoProductoCollection, MovimientoProductoCollection, QWhere> {
  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MovimientoProductoCollectionQueryWhere on QueryBuilder<
    MovimientoProductoCollection, MovimientoProductoCollection, QWhereClause> {
  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterWhereClause> serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterWhereClause> empresaIdEqualTo(String empresaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'empresaId',
        value: [empresaId],
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

extension MovimientoProductoCollectionQueryFilter on QueryBuilder<
    MovimientoProductoCollection,
    MovimientoProductoCollection,
    QFilterCondition> {
  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaDestinoIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bodegaDestinoId',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaDestinoIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bodegaDestinoId',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaDestinoIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodegaDestinoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaDestinoIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bodegaDestinoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaDestinoIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bodegaDestinoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaDestinoIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bodegaDestinoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaDestinoIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bodegaDestinoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaDestinoIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bodegaDestinoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
          QAfterFilterCondition>
      bodegaDestinoIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bodegaDestinoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
          QAfterFilterCondition>
      bodegaDestinoIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bodegaDestinoId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaDestinoIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodegaDestinoId',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaDestinoIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bodegaDestinoId',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaOrigenIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bodegaOrigenId',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaOrigenIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bodegaOrigenId',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaOrigenIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodegaOrigenId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaOrigenIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bodegaOrigenId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaOrigenIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bodegaOrigenId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaOrigenIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bodegaOrigenId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaOrigenIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bodegaOrigenId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaOrigenIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bodegaOrigenId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
          QAfterFilterCondition>
      bodegaOrigenIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bodegaOrigenId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
          QAfterFilterCondition>
      bodegaOrigenIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bodegaOrigenId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaOrigenIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodegaOrigenId',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> bodegaOrigenIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bodegaOrigenId',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> descripcionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'descripcion',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> descripcionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'descripcion',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> descripcionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> descripcionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> descripcionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> descripcionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descripcion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> descripcionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> descripcionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
          QAfterFilterCondition>
      descripcionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
          QAfterFilterCondition>
      descripcionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'descripcion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> descripcionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descripcion',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> descripcionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'descripcion',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> empresaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empresaId',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> empresaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'empresaId',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> estadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> estadoMovimientoEqualTo(EstadoMovimiento value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estadoMovimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> estadoMovimientoGreaterThan(
    EstadoMovimiento value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estadoMovimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> estadoMovimientoLessThan(
    EstadoMovimiento value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estadoMovimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> estadoMovimientoBetween(
    EstadoMovimiento lower,
    EstadoMovimiento upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estadoMovimiento',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> fechaRegistroEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> tipoMovimientoEqualTo(TipoMovimiento value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoMovimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> tipoMovimientoGreaterThan(
    TipoMovimiento value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoMovimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> tipoMovimientoLessThan(
    TipoMovimiento value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoMovimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> tipoMovimientoBetween(
    TipoMovimiento lower,
    TipoMovimiento upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoMovimiento',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usuarioRegistroId',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usuarioRegistroId',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
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

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterFilterCondition> usuarioRegistroIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }
}

extension MovimientoProductoCollectionQueryObject on QueryBuilder<
    MovimientoProductoCollection,
    MovimientoProductoCollection,
    QFilterCondition> {}

extension MovimientoProductoCollectionQueryLinks on QueryBuilder<
    MovimientoProductoCollection,
    MovimientoProductoCollection,
    QFilterCondition> {}

extension MovimientoProductoCollectionQuerySortBy on QueryBuilder<
    MovimientoProductoCollection, MovimientoProductoCollection, QSortBy> {
  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByBodegaDestinoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaDestinoId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByBodegaDestinoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaDestinoId', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByBodegaOrigenId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaOrigenId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByBodegaOrigenIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaOrigenId', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByDescripcion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByDescripcionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByEstadoMovimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoMovimiento', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByEstadoMovimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoMovimiento', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByTipoMovimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoMovimiento', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByTipoMovimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoMovimiento', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> sortByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension MovimientoProductoCollectionQuerySortThenBy on QueryBuilder<
    MovimientoProductoCollection, MovimientoProductoCollection, QSortThenBy> {
  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByBodegaDestinoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaDestinoId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByBodegaDestinoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaDestinoId', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByBodegaOrigenId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaOrigenId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByBodegaOrigenIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodegaOrigenId', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByDescripcion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByDescripcionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByEstadoMovimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoMovimiento', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByEstadoMovimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoMovimiento', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByTipoMovimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoMovimiento', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByTipoMovimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoMovimiento', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QAfterSortBy> thenByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension MovimientoProductoCollectionQueryWhereDistinct on QueryBuilder<
    MovimientoProductoCollection, MovimientoProductoCollection, QDistinct> {
  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QDistinct> distinctByBodegaDestinoId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodegaDestinoId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QDistinct> distinctByBodegaOrigenId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodegaOrigenId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QDistinct> distinctByDescripcion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descripcion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QDistinct> distinctByEmpresaId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empresaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QDistinct> distinctByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado');
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QDistinct> distinctByEstadoMovimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estadoMovimiento');
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QDistinct> distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QDistinct> distinctByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaRegistro');
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QDistinct> distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QDistinct> distinctByTipoMovimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoMovimiento');
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QDistinct> distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<MovimientoProductoCollection, MovimientoProductoCollection,
      QDistinct> distinctByUsuarioRegistroId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioRegistroId',
          caseSensitive: caseSensitive);
    });
  }
}

extension MovimientoProductoCollectionQueryProperty on QueryBuilder<
    MovimientoProductoCollection,
    MovimientoProductoCollection,
    QQueryProperty> {
  QueryBuilder<MovimientoProductoCollection, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MovimientoProductoCollection, String?, QQueryOperations>
      bodegaDestinoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodegaDestinoId');
    });
  }

  QueryBuilder<MovimientoProductoCollection, String?, QQueryOperations>
      bodegaOrigenIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodegaOrigenId');
    });
  }

  QueryBuilder<MovimientoProductoCollection, String?, QQueryOperations>
      descripcionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descripcion');
    });
  }

  QueryBuilder<MovimientoProductoCollection, String, QQueryOperations>
      empresaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empresaId');
    });
  }

  QueryBuilder<MovimientoProductoCollection, bool, QQueryOperations>
      estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<MovimientoProductoCollection, EstadoMovimiento, QQueryOperations>
      estadoMovimientoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estadoMovimiento');
    });
  }

  QueryBuilder<MovimientoProductoCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<MovimientoProductoCollection, DateTime, QQueryOperations>
      fechaRegistroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaRegistro');
    });
  }

  QueryBuilder<MovimientoProductoCollection, String, QQueryOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<MovimientoProductoCollection, TipoMovimiento, QQueryOperations>
      tipoMovimientoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoMovimiento');
    });
  }

  QueryBuilder<MovimientoProductoCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<MovimientoProductoCollection, String?, QQueryOperations>
      usuarioRegistroIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioRegistroId');
    });
  }
}
