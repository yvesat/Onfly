import 'package:isar/isar.dart';

part 'removed_expense.g.dart';

@collection
class RemovedExpense {
  Id id = Isar.autoIncrement;
  final String deletedExpenseId;

  RemovedExpense(this.deletedExpenseId);
}
