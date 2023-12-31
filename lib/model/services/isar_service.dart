import 'package:isar/isar.dart';
import 'package:onfly/model/removed_expense.dart';
import 'package:onfly/model/token_model.dart';
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

  //Expense
  Future<void> saveExpenseDB(Expense expense) async {
    final isar = await db;

    await removeExpenseDB(expense); //Garantindo que a despesa a ser inserida será única
    await isar.writeTxn(() async => await isar.expenses.put(expense));
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

    final expenseToDelete = await isar.expenses.filter().expenseIdEqualTo(expense.expenseId).findFirst();
    if (expenseToDelete != null) await isar.writeTxn(() async => await isar.expenses.delete(expenseToDelete.id));
  }

  Future<void> clearExpenseDB() async {
    final isar = await db;
    await isar.writeTxn(() async => await isar.expenses.clear());
  }

  //Token
  Future<void> saveTokenDB(Token token) async {
    final isar = await db;
    await isar.writeTxn(() async => await isar.tokens.clear());

    await isar.writeTxn(() async => await isar.tokens.put(token));
  }

  Future<Token?> getTokenDB() async {
    final isar = await db;
    return await isar.tokens.where().findFirst();
  }

  //Removed Expenses
  Future<void> saveRemovedExpensesDB(RemovedExpense removedExpense) async {
    final isar = await db;
    await isar.writeTxn(() async => await isar.removedExpenses.put(removedExpense));
  }

  Future<List<RemovedExpense>> getRemovedExpensesListDB() async {
    final isar = await db;
    return isar.removedExpenses.where().findAll();
  }

  Future<void> removeRemovedExpense(RemovedExpense removedExpense) async {
    final isar = await db;

    final expenseToDelete = await isar.removedExpenses.filter().deletedExpenseIdEqualTo(removedExpense.deletedExpenseId).findFirst();
    if (expenseToDelete != null) await isar.writeTxn(() async => await isar.removedExpenses.delete(expenseToDelete.id));
  }

  Future<void> clearRemovedExpensesDB() async {
    final isar = await db;
    await isar.writeTxn(() async => await isar.removedExpenses.clear());
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        directory: dir.path,
        [ExpenseSchema, TokenSchema, RemovedExpenseSchema],
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
