import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../expense_model.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<void> clearDB() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }

  //Order
  Future<void> saveExpenseDB(Expense expense) async {
    final isar = await db;
    await isar.writeTxn(() async => isar.expenses.put(expense));
  }

  Future<Expense?> getExpenseByIdDB(String expenseId) async {
    final isar = await db;
    Expense? expense = await isar.expenses.filter().expenseIdEqualTo(expenseId).findFirst();
    return expense;
  }

  Future<List<Expense>> getExpensesListDB() async {
    final isar = await db;
    return isar.expenses.where().findAll();
  }

  Future<void> removeExpenseDB(Expense expense) async {
    final isar = await db;
    await isar.writeTxn(() async => await isar.expenses.delete(expense.id));
  }

  Future<void> clearExpenseDB() async {
    final isar = await db;
    await isar.writeTxn(() async => await isar.expenses.clear());
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        directory: dir.path,
        [ExpenseSchema],
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}