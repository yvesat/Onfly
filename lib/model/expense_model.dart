import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

part 'expense_model.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;
  final String expenseId; //id para gerenciamento de estado e dados internos do app
  final String description;
  final double amount;
  final DateTime expenseDate;
  final String? apiId; //id retornado do backend ao sincronizar
  final bool isSynchronized;
  final String latitude;
  final String longitude;

  Expense({
    required this.expenseId,
    required this.description,
    required this.amount,
    required this.expenseDate,
    required this.apiId,
    required this.isSynchronized,
    required this.latitude,
    required this.longitude,
  });

  Expense copyWith({
    String? description,
    double? amount,
    DateTime? expenseDate,
    String? apiId,
    bool? isSynchronized,
  }) {
    return Expense(
      expenseId: expenseId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      apiId: apiId ?? this.apiId,
      isSynchronized: isSynchronized ?? this.isSynchronized,
      latitude: latitude,
      longitude: longitude,
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
      description: expense.description,
      expenseDate: expense.expenseDate,
      amount: expense.amount,
      apiId: expense.apiId,
      latitude: expense.latitude,
      longitude: expense.longitude,
      isSynchronized: expense.isSynchronized,
    );

    state = [...state, loadedExpense];
  }

  Expense createExpense({required String description, required double amount, required DateTime expenseDate, required Map<String, String> latLong, String? apiId, bool? isSynchronized}) {
    final newExpense = Expense(
      expenseId: _uuid.v4(),
      description: description,
      expenseDate: expenseDate,
      amount: amount,
      apiId: apiId,
      isSynchronized: isSynchronized ?? false,
      latitude: latLong["latitude"]!,
      longitude: latLong["longitude"]!,
    );

    state = [...state, newExpense];

    return newExpense;
  }

  Expense editExpense(String expenseId, {String? newDescription, double? newAmount, DateTime? newExpenseDate, bool? isSynchronized, String? apiId}) {
    state = [
      for (final expense in state)
        if (expense.expenseId == expenseId) expense.copyWith(description: newDescription, amount: newAmount, expenseDate: newExpenseDate, apiId: apiId, isSynchronized: isSynchronized) else expense,
    ];

    return state.firstWhere((expense) => expense.expenseId == expenseId);
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
