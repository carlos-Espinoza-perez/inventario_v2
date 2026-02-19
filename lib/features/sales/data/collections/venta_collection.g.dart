// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venta_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVentaCollectionCollection on Isar {
  IsarCollection<VentaCollection> get ventaCollections => this.collection();
}

const VentaCollectionSchema = CollectionSchema(
  name: r'VentaCollection',
  id: 7059150551733070945,
  properties: {
    r'cajaSesionId': PropertySchema(
      id: 0,
      name: r'cajaSesionId',
      type: IsarType.string,
    ),
    r'clienteId': PropertySchema(
      id: 1,
      name: r'clienteId',
      type: IsarType.string,
    ),
    r'empresaId': PropertySchema(
      id: 2,
      name: r'empresaId',
      type: IsarType.string,
    ),
    r'estado': PropertySchema(
      id: 3,
      name: r'estado',
      type: IsarType.bool,
    ),
    r'estadoPago': PropertySchema(
      id: 4,
      name: r'estadoPago',
      type: IsarType.byte,
      enumMap: _VentaCollectionestadoPagoEnumValueMap,
    ),
    r'fechaEliminacion': PropertySchema(
      id: 5,
      name: r'fechaEliminacion',
      type: IsarType.dateTime,
    ),
    r'fechaVencimiento': PropertySchema(
      id: 6,
      name: r'fechaVencimiento',
      type: IsarType.dateTime,
    ),
    r'fechaVenta': PropertySchema(
      id: 7,
      name: r'fechaVenta',
      type: IsarType.dateTime,
    ),
    r'pendienteSincronizacion': PropertySchema(
      id: 8,
      name: r'pendienteSincronizacion',
      type: IsarType.bool,
    ),
    r'saldoPendiente': PropertySchema(
      id: 9,
      name: r'saldoPendiente',
      type: IsarType.double,
    ),
    r'serverId': PropertySchema(
      id: 10,
      name: r'serverId',
      type: IsarType.string,
    ),
    r'tipoVenta': PropertySchema(
      id: 11,
      name: r'tipoVenta',
      type: IsarType.byte,
      enumMap: _VentaCollectiontipoVentaEnumValueMap,
    ),
    r'totalPagado': PropertySchema(
      id: 12,
      name: r'totalPagado',
      type: IsarType.double,
    ),
    r'totalVenta': PropertySchema(
      id: 13,
      name: r'totalVenta',
      type: IsarType.double,
    ),
    r'ultimaActualizacion': PropertySchema(
      id: 14,
      name: r'ultimaActualizacion',
      type: IsarType.dateTime,
    ),
    r'usuarioRegistroId': PropertySchema(
      id: 15,
      name: r'usuarioRegistroId',
      type: IsarType.string,
    )
  },
  estimateSize: _ventaCollectionEstimateSize,
  serialize: _ventaCollectionSerialize,
  deserialize: _ventaCollectionDeserialize,
  deserializeProp: _ventaCollectionDeserializeProp,
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
    r'clienteId': IndexSchema(
      id: 8548357859431292524,
      name: r'clienteId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'clienteId',
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
  getId: _ventaCollectionGetId,
  getLinks: _ventaCollectionGetLinks,
  attach: _ventaCollectionAttach,
  version: '3.1.0+1',
);

int _ventaCollectionEstimateSize(
  VentaCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cajaSesionId.length * 3;
  bytesCount += 3 + object.clienteId.length * 3;
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

void _ventaCollectionSerialize(
  VentaCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cajaSesionId);
  writer.writeString(offsets[1], object.clienteId);
  writer.writeString(offsets[2], object.empresaId);
  writer.writeBool(offsets[3], object.estado);
  writer.writeByte(offsets[4], object.estadoPago.index);
  writer.writeDateTime(offsets[5], object.fechaEliminacion);
  writer.writeDateTime(offsets[6], object.fechaVencimiento);
  writer.writeDateTime(offsets[7], object.fechaVenta);
  writer.writeBool(offsets[8], object.pendienteSincronizacion);
  writer.writeDouble(offsets[9], object.saldoPendiente);
  writer.writeString(offsets[10], object.serverId);
  writer.writeByte(offsets[11], object.tipoVenta.index);
  writer.writeDouble(offsets[12], object.totalPagado);
  writer.writeDouble(offsets[13], object.totalVenta);
  writer.writeDateTime(offsets[14], object.ultimaActualizacion);
  writer.writeString(offsets[15], object.usuarioRegistroId);
}

VentaCollection _ventaCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VentaCollection();
  object.cajaSesionId = reader.readString(offsets[0]);
  object.clienteId = reader.readString(offsets[1]);
  object.empresaId = reader.readString(offsets[2]);
  object.estado = reader.readBool(offsets[3]);
  object.estadoPago = _VentaCollectionestadoPagoValueEnumMap[
          reader.readByteOrNull(offsets[4])] ??
      EstadoPago.pagado;
  object.fechaEliminacion = reader.readDateTimeOrNull(offsets[5]);
  object.fechaVencimiento = reader.readDateTimeOrNull(offsets[6]);
  object.fechaVenta = reader.readDateTime(offsets[7]);
  object.id = id;
  object.pendienteSincronizacion = reader.readBool(offsets[8]);
  object.saldoPendiente = reader.readDouble(offsets[9]);
  object.serverId = reader.readString(offsets[10]);
  object.tipoVenta = _VentaCollectiontipoVentaValueEnumMap[
          reader.readByteOrNull(offsets[11])] ??
      TipoVenta.contado;
  object.totalPagado = reader.readDouble(offsets[12]);
  object.totalVenta = reader.readDouble(offsets[13]);
  object.ultimaActualizacion = reader.readDateTime(offsets[14]);
  object.usuarioRegistroId = reader.readStringOrNull(offsets[15]);
  return object;
}

P _ventaCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (_VentaCollectionestadoPagoValueEnumMap[
              reader.readByteOrNull(offset)] ??
          EstadoPago.pagado) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (_VentaCollectiontipoVentaValueEnumMap[
              reader.readByteOrNull(offset)] ??
          TipoVenta.contado) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _VentaCollectionestadoPagoEnumValueMap = {
  'pagado': 0,
  'pendiente': 1,
  'parcial': 2,
  'anulado': 3,
};
const _VentaCollectionestadoPagoValueEnumMap = {
  0: EstadoPago.pagado,
  1: EstadoPago.pendiente,
  2: EstadoPago.parcial,
  3: EstadoPago.anulado,
};
const _VentaCollectiontipoVentaEnumValueMap = {
  'contado': 0,
  'credito': 1,
};
const _VentaCollectiontipoVentaValueEnumMap = {
  0: TipoVenta.contado,
  1: TipoVenta.credito,
};

Id _ventaCollectionGetId(VentaCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ventaCollectionGetLinks(VentaCollection object) {
  return [];
}

void _ventaCollectionAttach(
    IsarCollection<dynamic> col, Id id, VentaCollection object) {
  object.id = id;
}

extension VentaCollectionByIndex on IsarCollection<VentaCollection> {
  Future<VentaCollection?> getByServerId(String serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  VentaCollection? getByServerIdSync(String serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<VentaCollection?>> getAllByServerId(List<String> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<VentaCollection?> getAllByServerIdSync(List<String> serverIdValues) {
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

  Future<Id> putByServerId(VentaCollection object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(VentaCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(List<VentaCollection> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<VentaCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension VentaCollectionQueryWhereSort
    on QueryBuilder<VentaCollection, VentaCollection, QWhere> {
  QueryBuilder<VentaCollection, VentaCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhere> anyEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'estado'),
      );
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhere>
      anyPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'pendienteSincronizacion'),
      );
    });
  }
}

extension VentaCollectionQueryWhere
    on QueryBuilder<VentaCollection, VentaCollection, QWhereClause> {
  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause> idBetween(
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause>
      serverIdEqualTo(String serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause>
      empresaIdEqualTo(String empresaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'empresaId',
        value: [empresaId],
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause>
      clienteIdEqualTo(String clienteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'clienteId',
        value: [clienteId],
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause>
      clienteIdNotEqualTo(String clienteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clienteId',
              lower: [],
              upper: [clienteId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clienteId',
              lower: [clienteId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clienteId',
              lower: [clienteId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clienteId',
              lower: [],
              upper: [clienteId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause>
      estadoEqualTo(bool estado) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'estado',
        value: [estado],
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause>
      estadoNotEqualTo(bool estado) {
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause>
      pendienteSincronizacionEqualTo(bool pendienteSincronizacion) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pendienteSincronizacion',
        value: [pendienteSincronizacion],
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterWhereClause>
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

extension VentaCollectionQueryFilter
    on QueryBuilder<VentaCollection, VentaCollection, QFilterCondition> {
  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      cajaSesionIdEqualTo(
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      cajaSesionIdGreaterThan(
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      cajaSesionIdLessThan(
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      cajaSesionIdBetween(
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      cajaSesionIdStartsWith(
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      cajaSesionIdEndsWith(
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      cajaSesionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cajaSesionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      cajaSesionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cajaSesionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      cajaSesionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cajaSesionId',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      cajaSesionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cajaSesionId',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      clienteIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      clienteIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clienteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      clienteIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clienteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      clienteIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clienteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      clienteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clienteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      clienteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clienteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      clienteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clienteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      clienteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clienteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      clienteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteId',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      clienteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clienteId',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      empresaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'empresaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      empresaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'empresaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      empresaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empresaId',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      empresaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'empresaId',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      estadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      estadoPagoEqualTo(EstadoPago value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estadoPago',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      estadoPagoGreaterThan(
    EstadoPago value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estadoPago',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      estadoPagoLessThan(
    EstadoPago value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estadoPago',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      estadoPagoBetween(
    EstadoPago lower,
    EstadoPago upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estadoPago',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      fechaEliminacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      fechaEliminacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaEliminacion',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      fechaEliminacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEliminacion',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      fechaVencimientoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaVencimiento',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      fechaVencimientoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaVencimiento',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      fechaVencimientoEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaVencimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      fechaVencimientoGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaVencimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      fechaVencimientoLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaVencimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      fechaVencimientoBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaVencimiento',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      fechaVentaEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaVenta',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      fechaVentaGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaVenta',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      fechaVentaLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaVenta',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      fechaVentaBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaVenta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      pendienteSincronizacionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendienteSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      saldoPendienteEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saldoPendiente',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      saldoPendienteGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saldoPendiente',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      saldoPendienteLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saldoPendiente',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      saldoPendienteBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saldoPendiente',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      serverIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      serverIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serverId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      tipoVentaEqualTo(TipoVenta value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoVenta',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      tipoVentaGreaterThan(
    TipoVenta value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoVenta',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      tipoVentaLessThan(
    TipoVenta value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoVenta',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      tipoVentaBetween(
    TipoVenta lower,
    TipoVenta upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoVenta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      totalPagadoEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPagado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      totalPagadoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPagado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      totalPagadoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPagado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      totalPagadoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPagado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      totalVentaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      totalVentaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      totalVentaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalVenta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      totalVentaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalVenta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      ultimaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaActualizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      usuarioRegistroIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usuarioRegistroId',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      usuarioRegistroIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usuarioRegistroId',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
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

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      usuarioRegistroIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioRegistroId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      usuarioRegistroIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioRegistroId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      usuarioRegistroIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterFilterCondition>
      usuarioRegistroIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioRegistroId',
        value: '',
      ));
    });
  }
}

extension VentaCollectionQueryObject
    on QueryBuilder<VentaCollection, VentaCollection, QFilterCondition> {}

extension VentaCollectionQueryLinks
    on QueryBuilder<VentaCollection, VentaCollection, QFilterCondition> {}

extension VentaCollectionQuerySortBy
    on QueryBuilder<VentaCollection, VentaCollection, QSortBy> {
  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByCajaSesionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaSesionId', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByCajaSesionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaSesionId', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByClienteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByClienteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy> sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByEstadoPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoPago', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByEstadoPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoPago', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByFechaVencimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVencimiento', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByFechaVencimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVencimiento', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByFechaVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVenta', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByFechaVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVenta', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortBySaldoPendiente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldoPendiente', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortBySaldoPendienteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldoPendiente', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByTipoVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoVenta', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByTipoVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoVenta', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByTotalPagado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPagado', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByTotalPagadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPagado', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByTotalVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVenta', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByTotalVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVenta', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      sortByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension VentaCollectionQuerySortThenBy
    on QueryBuilder<VentaCollection, VentaCollection, QSortThenBy> {
  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByCajaSesionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaSesionId', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByCajaSesionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaSesionId', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByClienteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByClienteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByEmpresaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByEmpresaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empresaId', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy> thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByEstadoPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoPago', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByEstadoPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoPago', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByFechaEliminacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEliminacion', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByFechaVencimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVencimiento', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByFechaVencimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVencimiento', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByFechaVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVenta', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByFechaVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVenta', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByPendienteSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendienteSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenBySaldoPendiente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldoPendiente', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenBySaldoPendienteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldoPendiente', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByTipoVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoVenta', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByTipoVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoVenta', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByTotalPagado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPagado', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByTotalPagadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPagado', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByTotalVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVenta', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByTotalVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalVenta', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByUltimaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByUsuarioRegistroId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.asc);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QAfterSortBy>
      thenByUsuarioRegistroIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRegistroId', Sort.desc);
    });
  }
}

extension VentaCollectionQueryWhereDistinct
    on QueryBuilder<VentaCollection, VentaCollection, QDistinct> {
  QueryBuilder<VentaCollection, VentaCollection, QDistinct>
      distinctByCajaSesionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cajaSesionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct> distinctByClienteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct> distinctByEmpresaId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empresaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct> distinctByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado');
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct>
      distinctByEstadoPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estadoPago');
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct>
      distinctByFechaEliminacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEliminacion');
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct>
      distinctByFechaVencimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaVencimiento');
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct>
      distinctByFechaVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaVenta');
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct>
      distinctByPendienteSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct>
      distinctBySaldoPendiente() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saldoPendiente');
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct> distinctByServerId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct>
      distinctByTipoVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoVenta');
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct>
      distinctByTotalPagado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPagado');
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct>
      distinctByTotalVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalVenta');
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct>
      distinctByUltimaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaActualizacion');
    });
  }

  QueryBuilder<VentaCollection, VentaCollection, QDistinct>
      distinctByUsuarioRegistroId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioRegistroId',
          caseSensitive: caseSensitive);
    });
  }
}

extension VentaCollectionQueryProperty
    on QueryBuilder<VentaCollection, VentaCollection, QQueryProperty> {
  QueryBuilder<VentaCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VentaCollection, String, QQueryOperations>
      cajaSesionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cajaSesionId');
    });
  }

  QueryBuilder<VentaCollection, String, QQueryOperations> clienteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteId');
    });
  }

  QueryBuilder<VentaCollection, String, QQueryOperations> empresaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empresaId');
    });
  }

  QueryBuilder<VentaCollection, bool, QQueryOperations> estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<VentaCollection, EstadoPago, QQueryOperations>
      estadoPagoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estadoPago');
    });
  }

  QueryBuilder<VentaCollection, DateTime?, QQueryOperations>
      fechaEliminacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEliminacion');
    });
  }

  QueryBuilder<VentaCollection, DateTime?, QQueryOperations>
      fechaVencimientoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaVencimiento');
    });
  }

  QueryBuilder<VentaCollection, DateTime, QQueryOperations>
      fechaVentaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaVenta');
    });
  }

  QueryBuilder<VentaCollection, bool, QQueryOperations>
      pendienteSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendienteSincronizacion');
    });
  }

  QueryBuilder<VentaCollection, double, QQueryOperations>
      saldoPendienteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saldoPendiente');
    });
  }

  QueryBuilder<VentaCollection, String, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<VentaCollection, TipoVenta, QQueryOperations>
      tipoVentaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoVenta');
    });
  }

  QueryBuilder<VentaCollection, double, QQueryOperations>
      totalPagadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPagado');
    });
  }

  QueryBuilder<VentaCollection, double, QQueryOperations> totalVentaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalVenta');
    });
  }

  QueryBuilder<VentaCollection, DateTime, QQueryOperations>
      ultimaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaActualizacion');
    });
  }

  QueryBuilder<VentaCollection, String?, QQueryOperations>
      usuarioRegistroIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioRegistroId');
    });
  }
}
