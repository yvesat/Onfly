// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'removed_expense.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRemovedExpenseCollection on Isar {
  IsarCollection<RemovedExpense> get removedExpenses => this.collection();
}

const RemovedExpenseSchema = CollectionSchema(
  name: r'RemovedExpense',
  id: 5995677924206273552,
  properties: {
    r'deletedExpenseId': PropertySchema(
      id: 0,
      name: r'deletedExpenseId',
      type: IsarType.string,
    )
  },
  estimateSize: _removedExpenseEstimateSize,
  serialize: _removedExpenseSerialize,
  deserialize: _removedExpenseDeserialize,
  deserializeProp: _removedExpenseDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _removedExpenseGetId,
  getLinks: _removedExpenseGetLinks,
  attach: _removedExpenseAttach,
  version: '3.1.0+1',
);

int _removedExpenseEstimateSize(
  RemovedExpense object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deletedExpenseId.length * 3;
  return bytesCount;
}

void _removedExpenseSerialize(
  RemovedExpense object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.deletedExpenseId);
}

RemovedExpense _removedExpenseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RemovedExpense(
    reader.readString(offsets[0]),
  );
  object.id = id;
  return object;
}

P _removedExpenseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _removedExpenseGetId(RemovedExpense object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _removedExpenseGetLinks(RemovedExpense object) {
  return [];
}

void _removedExpenseAttach(
    IsarCollection<dynamic> col, Id id, RemovedExpense object) {
  object.id = id;
}

extension RemovedExpenseQueryWhereSort
    on QueryBuilder<RemovedExpense, RemovedExpense, QWhere> {
  QueryBuilder<RemovedExpense, RemovedExpense, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RemovedExpenseQueryWhere
    on QueryBuilder<RemovedExpense, RemovedExpense, QWhereClause> {
  QueryBuilder<RemovedExpense, RemovedExpense, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterWhereClause> idBetween(
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
}

extension RemovedExpenseQueryFilter
    on QueryBuilder<RemovedExpense, RemovedExpense, QFilterCondition> {
  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition>
      deletedExpenseIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedExpenseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition>
      deletedExpenseIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deletedExpenseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition>
      deletedExpenseIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deletedExpenseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition>
      deletedExpenseIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deletedExpenseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition>
      deletedExpenseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deletedExpenseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition>
      deletedExpenseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deletedExpenseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition>
      deletedExpenseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deletedExpenseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition>
      deletedExpenseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deletedExpenseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition>
      deletedExpenseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedExpenseId',
        value: '',
      ));
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition>
      deletedExpenseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deletedExpenseId',
        value: '',
      ));
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition>
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

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition>
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

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterFilterCondition> idBetween(
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
}

extension RemovedExpenseQueryObject
    on QueryBuilder<RemovedExpense, RemovedExpense, QFilterCondition> {}

extension RemovedExpenseQueryLinks
    on QueryBuilder<RemovedExpense, RemovedExpense, QFilterCondition> {}

extension RemovedExpenseQuerySortBy
    on QueryBuilder<RemovedExpense, RemovedExpense, QSortBy> {
  QueryBuilder<RemovedExpense, RemovedExpense, QAfterSortBy>
      sortByDeletedExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedExpenseId', Sort.asc);
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterSortBy>
      sortByDeletedExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedExpenseId', Sort.desc);
    });
  }
}

extension RemovedExpenseQuerySortThenBy
    on QueryBuilder<RemovedExpense, RemovedExpense, QSortThenBy> {
  QueryBuilder<RemovedExpense, RemovedExpense, QAfterSortBy>
      thenByDeletedExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedExpenseId', Sort.asc);
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterSortBy>
      thenByDeletedExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedExpenseId', Sort.desc);
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RemovedExpense, RemovedExpense, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension RemovedExpenseQueryWhereDistinct
    on QueryBuilder<RemovedExpense, RemovedExpense, QDistinct> {
  QueryBuilder<RemovedExpense, RemovedExpense, QDistinct>
      distinctByDeletedExpenseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedExpenseId',
          caseSensitive: caseSensitive);
    });
  }
}

extension RemovedExpenseQueryProperty
    on QueryBuilder<RemovedExpense, RemovedExpense, QQueryProperty> {
  QueryBuilder<RemovedExpense, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RemovedExpense, String, QQueryOperations>
      deletedExpenseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedExpenseId');
    });
  }
}
