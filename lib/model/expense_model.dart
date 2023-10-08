import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

part 'expense_model.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;
  final String expenseId;
  final String title;
  final double value;
  final DateTime date;
  final bool isSynchronized;

  Expense({
    required this.expenseId,
    required this.title,
    required this.value,
    required this.date,
    required this.isSynchronized,
  });

  Expense copyWith({
    String? title,
    double? value,
    DateTime? date,
    bool? isSynchronized,
  }) {
    return Expense(
      expenseId: expenseId,
      title: title ?? this.title,
      value: value ?? this.value,
      date: date ?? this.date,
      isSynchronized: isSynchronized ?? this.isSynchronized,
    );
  }
}

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]);

  final Uuid _uuid = const Uuid();

  Expense? getExpenseById(String expenseId) {
    return state.firstWhereOrNull((expense) => expense.expenseId == expenseId);
  }

  void loadExpense(Expense expense) {
    final loadedExpense = Expense(
      expenseId: expense.expenseId,
      title: expense.title,
      date: expense.date,
      value: expense.value,
      isSynchronized: expense.isSynchronized,
    );

    state = [...state, loadedExpense];
  }

  Expense createExpense({required String title, required double value, required DateTime date}) {
    final newExpense = Expense(
      expenseId: _uuid.v4(),
      title: title,
      date: date,
      value: value,
      isSynchronized: false,
    );

    state = [...state, newExpense];

    return newExpense;
  }

  Expense? editExpense(String expenseId, {String? newTitle, double? newValue, DateTime? newDate, bool? newIsSynchronized}) {
    state = [
      for (final expense in state)
        if (expense.expenseId == expenseId) expense.copyWith(title: newTitle, value: newValue, date: newDate, isSynchronized: newIsSynchronized) else expense,
    ];

    return state.firstWhereOrNull((expense) => expense.expenseId == expenseId);
  }

  void removeExpense(Expense expenseToRemove) {
    state = state.where((expense) => expense != expenseToRemove).toList();
  }

  List<Expense> get expensesList => state;

  void clearExpenses() {
    state = [];
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) => ExpenseNotifier());
