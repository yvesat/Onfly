import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

// Define the Expense class
@Collection()
class Expense {
  Id id = Isar.autoIncrement;
  final String expenseId;
  final String title;
  final DateTime date;
  final double value;

  Expense({
    required this.expenseId,
    required this.title,
    required this.date,
    required this.value,
  });

  Expense copyWith({
    String? expenseId,
    String? title,
    DateTime? date,
    double? value,
  }) {
    return Expense(
      expenseId: expenseId ?? this.expenseId,
      title: title ?? this.title,
      date: date ?? this.date,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Expense && other.expenseId == expenseId && other.title == title && other.date == date && other.value == value;
  }

  @override
  int get hashCode {
    return title.hashCode ^ date.hashCode ^ value.hashCode;
  }
}

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]);

  final Uuid _uuid = const Uuid();

  Expense? getExpenseById(String id) {
    return state.firstWhereOrNull((expense) => expense.expenseId == id);
  }

  void addExpense(String title, DateTime date, double value) {
    final newExpense = Expense(
      expenseId: _uuid.v4(),
      title: title,
      date: date,
      value: value,
    );

    state = [...state, newExpense];
  }

  void editExpense(Expense editedExpense, {String? title, DateTime? date, double? value}) {
    state = [
      for (final expense in state)
        if (expense == editedExpense) expense.copyWith(title: title, date: date, value: value) else expense,
    ];
  }

  void removeExpense(Expense expenseToRemove) {
    state.removeWhere((element) => expenseToRemove == expenseToRemove);
  }

  List<Expense> get expensesList => state;

  void clearExpenses() {
    state = [];
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) => ExpenseNotifier());
