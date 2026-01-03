// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detalle_venta_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDetalleVentaCollectionCollection on Isar {
  IsarCollection<DetalleVentaCollection> get detalleVentaCollections =>
      this.collection();
}

const DetalleVentaCollectionSchema = CollectionSchema(
  name: r'DetalleVentaCollection',
  id: 4427637532602425489,
  properties: {
    r'cantidad': PropertySchema(
      id: 0,
      name: r'cantidad',
      type: IsarType.double,
    ),
    r'costoHistoricoCompra': PropertySchema(
      id: 1,
      name: r'costoHistoricoCompra',
      type: IsarType.double,
    ),
    r'descuento': PropertySchema(
      id: 2,
      name: r'descuento',
      type: IsarType.double,
    ),
    r'fechaEliminacion': PropertySchema(
      id: 3,
      name: r'fechaEliminacion',
      type: IsarType.dateTime,
    ),
    r'precioUnitario': PropertySchema(
      id: 4,
      name: r'precioUnitario',
      type: IsarType.double,
    ),
    r'productoId': PropertySchema(
      id: 5,
      name: r'productoId',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 6,
      name: r'serverId',
      type: IsarType.string,
    ),
    r'subTotal': PropertySchema(
      id: 7,
      name: r'subTotal',
      type: IsarType.double,
    ),
    r'ultimaActualizacion': PropertySchema(
      id: 8,
      name: r'ultimaActualizacion',
      type: IsarType.dateTime,
    ),
    r'ventaId': PropertySchema(
      id: 9,
      name: r'ventaId',
      type: IsarType.string,
    )
  },
  estimateSize: _detalleVentaCollectionEstimateSize,
  serialize: _detalleVentaCollectionSerialize,
  deserialize: _detalleVentaCollectionDeserialize,
  deserializeProp: _detalleVentaCollectionDeserializeProp,
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
  getId: _detalleVentaCollectionGetId,
  getLinks: _detalleVentaCollectionGetLinks,
  attach: _detalleVentaCollectionAttach,
  version: '3.1.0+1',
);

int _detalleVentaCollectionEstimateSize(
  DetalleVentaCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.productoId.length * 3;
  bytesCount += 3 + object.serverId.length * 3;
  bytesCount += 3 + object.ventaId.length * 3;
  return bytesCount;
}

void _detalleVentaCollectionSerialize(
  DetalleVentaCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cantidad);
  writer.writeDouble(offsets[1], object.costoHistoricoCompra);
  writer.writeDouble(offsets[2], object.descuento);
  writer.writeDateTime(offsets[3], object.fechaEliminacion);
  writer.writeDouble(offsets[4], object.precioUnitario);
  writer.writeString(offsets[5], object.productoId);
  writer.writeString(offsets[6], object.serverId);
  writer.writeDouble(offsets[7], object.subTotal);
  writer.writeDateTime(offsets[8], object.ultimaActualizacion);
  writer.writeString(offsets[9], object.ventaId);
}

DetalleVentaCollection _detalleVentaCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DetalleVentaCollection();
  object.cantidad = reader.readDouble(offsets[0]);
  object.costoHistoricoCompra = reader.readDouble(offsets[1]);
  object.descuento = reader.readDouble(offsets[2]);
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.precioUnitario = reader.readDouble(offsets[4]);
  object.productoId = reader.readString(offsets[5]);
  object.serverId = reader.readString(offsets[6]);
  object.subTotal = reader.readDouble(offsets[7]);
  object.ultimaActualizacion = reader.readDateTime(offsets[8]);
  object.ventaId = reader.readString(offsets[9]);
  return object;
}

P _detalleVentaCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _detalleVentaCollectionGetId(DetalleVentaCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _detalleVentaCollectionGetLinks(
    DetalleVentaCollection object) {
  return [];
}

void _detalleVentaCollectionAttach(
    IsarCollection<dynamic> col, Id id, DetalleVentaCollection object) {
  object.id = id;
}

extension DetalleVentaCollectionByIndex
    on IsarCollection<DetalleVentaCollection> {
  Future<DetalleVentaCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  DetalleVentaCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<DetalleVentaCollection?>> getAllByServerId(
      List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<DetalleVentaCollection?> getAllByServerIdSync(
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

  Future<Id> putByServerId(DetalleVentaCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(DetalleVentaCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(List<DetalleVentaCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<DetalleVentaCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension DetalleVentaCollectionQueryWhereSort
    on QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QWhere> {
  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DetalleVentaCollectionQueryWhere on QueryBuilder<
    DetalleVentaCollection, DetalleVentaCollection, QWhereClause> {
  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterWhereClause> serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterWhereClause> ventaIdEqualTo(String ventaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ventaId',
        value: [ventaId],
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterWhereClause> productoIdEqualTo(String productoId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'productoId',
        value: [productoId],
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterWhereClause> productoIdNotEqualTo(String productoId) {
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

extension DetalleVentaCollectionQueryFilter on QueryBuilder<
    DetalleVentaCollection, DetalleVentaCollection, QFilterCondition> {
  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> cantidadEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> cantidadGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cantidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> cantidadLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cantidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> cantidadBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cantidad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> costoHistoricoCompraEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'costoHistoricoCompra',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> costoHistoricoCompraGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'costoHistoricoCompra',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> costoHistoricoCompraLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'costoHistoricoCompra',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> costoHistoricoCompraBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'costoHistoricoCompra',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> descuentoEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descuento',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> descuentoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descuento',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> descuentoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descuento',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> descuentoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descuento',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> precioUnitarioEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precioUnitario',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> precioUnitarioGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precioUnitario',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> precioUnitarioLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precioUnitario',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> precioUnitarioBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precioUnitario',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> productoIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> productoIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> subTotalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> subTotalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> subTotalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> subTotalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
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

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> ventaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaId',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection,
      QAfterFilterCondition> ventaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ventaId',
        value: '',
      ));
    });
  }
}

extension DetalleVentaCollectionQueryObject on QueryBuilder<
    DetalleVentaCollection, DetalleVentaCollection, QFilterCondition> {}

extension DetalleVentaCollectionQueryLinks on QueryBuilder<
    DetalleVentaCollection, DetalleVentaCollection, QFilterCondition> {}

extension DetalleVentaCollectionQuerySortBy
    on QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QSortBy> {
  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByCostoHistoricoCompra() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoHistoricoCompra', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByCostoHistoricoCompraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoHistoricoCompra', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByDescuento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuento', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByDescuentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuento', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByPrecioUnitario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnitario', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByPrecioUnitarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnitario', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortBySubTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subTotal', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortBySubTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subTotal', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByVentaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaId', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      sortByVentaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaId', Sort.desc);
    });
  }
}

extension DetalleVentaCollectionQuerySortThenBy on QueryBuilder<
    DetalleVentaCollection, DetalleVentaCollection, QSortThenBy> {
  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByCostoHistoricoCompra() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoHistoricoCompra', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByCostoHistoricoCompraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoHistoricoCompra', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByDescuento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuento', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByDescuentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuento', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByPrecioUnitario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnitario', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByPrecioUnitarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnitario', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenBySubTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subTotal', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenBySubTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subTotal', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByVentaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaId', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QAfterSortBy>
      thenByVentaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaId', Sort.desc);
    });
  }
}

extension DetalleVentaCollectionQueryWhereDistinct
    on QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QDistinct> {
  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QDistinct>
      distinctByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidad');
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QDistinct>
      distinctByCostoHistoricoCompra() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costoHistoricoCompra');
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QDistinct>
      distinctByDescuento() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descuento');
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QDistinct>
      distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QDistinct>
      distinctByPrecioUnitario() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'precioUnitario');
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QDistinct>
      distinctByProductoId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QDistinct>
      distinctBySubTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subTotal');
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QDistinct>
      distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<DetalleVentaCollection, DetalleVentaCollection, QDistinct>
      distinctByVentaId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ventaId', caseSensitive: caseSensitive);
    });
  }
}

extension DetalleVentaCollectionQueryProperty on QueryBuilder<
    DetalleVentaCollection, DetalleVentaCollection, QQueryProperty> {
  QueryBuilder<DetalleVentaCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DetalleVentaCollection, double, QQueryOperations>
      cantidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidad');
    });
  }

  QueryBuilder<DetalleVentaCollection, double, QQueryOperations>
      costoHistoricoCompraProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costoHistoricoCompra');
    });
  }

  QueryBuilder<DetalleVentaCollection, double, QQueryOperations>
      descuentoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descuento');
    });
  }

  QueryBuilder<DetalleVentaCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<DetalleVentaCollection, double, QQueryOperations>
      precioUnitarioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'precioUnitario');
    });
  }

  QueryBuilder<DetalleVentaCollection, String, QQueryOperations>
      productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }

  QueryBuilder<DetalleVentaCollection, String, QQueryOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<DetalleVentaCollection, double, QQueryOperations>
      subTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subTotal');
    });
  }

  QueryBuilder<DetalleVentaCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<DetalleVentaCollection, String, QQueryOperations>
      ventaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ventaId');
    });
  }
}
