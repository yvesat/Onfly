import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/expenses_model.dart';

class ExpenseController extends StateNotifier<AsyncValue<void>> {
  ExpenseController() : super(const AsyncValue.data(null));

  String? currentlyExpandedId;

  bool isExpanded(String id) {
    return currentlyExpandedId == id;
  }

  void toggleExpansionState(String id) {
    if (currentlyExpandedId == id) {
      currentlyExpandedId = null;
    } else {
      currentlyExpandedId = id;
    }
  }

  Expense? getExpense(WidgetRef ref, String id) {
    return ref.read(expenseProvider.notifier).getExpenseById(id);
  }

  List<Expense> getExpensesList(WidgetRef ref) {
    return ref.watch(expenseProvider);
  }

  void addExpense(WidgetRef ref, String title, DateTime date, double value) {
    ref.read(expenseProvider.notifier).addExpense(title, date, value);
  }
}

final expenseControllerProvider = StateNotifierProvider<ExpenseController, AsyncValue<void>>((ref) => ExpenseController());
