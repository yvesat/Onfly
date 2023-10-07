import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/expense_model.dart';

class ExpenseController extends StateNotifier<AsyncValue<void>> {
  ExpenseController() : super(const AsyncValue.data(null));

  String createExpense(WidgetRef ref) {
    return ref.read(expenseProvider.notifier).createExpense("", DateTime.now(), 0.0);
  }

  void setTitle(BuildContext context, WidgetRef ref, Expense expense, String title) {
    ref.read(expenseProvider.notifier).editExpense(expense, title: title);
  }

  Future<void> setDate(BuildContext context, WidgetRef ref, Expense expense) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: expense.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != expense.date) ref.read(expenseProvider.notifier).editExpense(expense, date: pickedDate);
  }

  void setValue(BuildContext context, WidgetRef ref, Expense expense, double value) {
    ref.read(expenseProvider.notifier).editExpense(expense, value: value);
  }

  Expense? getExpense(WidgetRef ref, String id) {
    return ref.read(expenseProvider.notifier).getExpenseById(id);
  }

  List<Expense> getExpensesList(WidgetRef ref) {
    return ref.watch(expenseProvider);
  }
}

final expenseControllerProvider = StateNotifierProvider<ExpenseController, AsyncValue<void>>((ref) => ExpenseController());
