import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onfly/model/services/isar_service.dart';

import '../model/expense_model.dart';

class ExpenseController extends StateNotifier<AsyncValue<void>> {
  ExpenseController() : super(const AsyncValue.data(null));

  final IsarService isarService = IsarService();

  String createExpense(WidgetRef ref) {
    return ref.read(expenseProvider.notifier).createExpense("", DateTime.now(), 0.0);
  }

  // Future<void> loadExpenseData(WidgetRef ref, String expenseId, String title, String value) async {
  //   final expense = ref.read(expenseProvider.notifier).getExpenseById(expenseId);
  //   title = expense!.title;

  //   final stringValue = expense.value.toStringAsFixed(2).replaceAll('.', ',');
  //   value = stringValue;
  // }

  Future<void> setDate(BuildContext context, WidgetRef ref, Expense expense) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: expense.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != expense.date) ref.read(expenseProvider.notifier).editExpense(expense, date: pickedDate);
  }

  void updateExpense(BuildContext context, WidgetRef ref, Expense expense, String title, String value) {
    final doubleValue = double.parse(value.replaceAll(',', '.'));

    ref.read(expenseProvider.notifier).editExpense(expense, title: title, value: doubleValue);
  }

  Expense? getExpense(WidgetRef ref, String expenseId) {
    return ref.read(expenseProvider.notifier).getExpenseById(expenseId);
  }

  List<Expense> getExpensesList(WidgetRef ref) {
    return ref.watch(expenseProvider);
  }

  Future<void> removeExpense(WidgetRef ref, String expenseId) async {
    final expense = ref.read(expenseProvider.notifier).getExpenseById(expenseId);
    await isarService.removeExpenseDB(expense!);
    ref.read(expenseProvider.notifier).removeExpense(expense);
  }
}

final expenseControllerProvider = StateNotifierProvider<ExpenseController, AsyncValue<void>>((ref) => ExpenseController());
