import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onfly/model/services/isar_service.dart';

import '../model/expense_model.dart';

class ExpenseController extends StateNotifier<AsyncValue<void>> {
  ExpenseController() : super(const AsyncValue.data(null));

  final IsarService isarService = IsarService();

  Future<void> createExpense(WidgetRef ref, String title, String value, DateTime date) async {
    double doubleValue = double.parse(value.replaceAll(',', '.'));

    final newExpense = ref.read(expenseProvider.notifier).createExpense(title, doubleValue, date);
    await isarService.saveExpenseDB(newExpense);
  }

  Future<DateTime?> setDate(BuildContext context, WidgetRef ref, DateTime currentDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != currentDate) {
      return pickedDate;
    } else {
      return null;
    }
  }

  Future<void> updateExpense(WidgetRef ref, String? expenseId, String? newTitle, String? newValue, DateTime? newDate) async {
    if (expenseId == null) return;

    double? doubleValue;
    if (newValue != null) doubleValue = double.parse(newValue.replaceAll(',', '.'));

    final updatedExpense = ref.read(expenseProvider.notifier).editExpense(expenseId, newTitle: newTitle, newValue: doubleValue, newDate: newDate);
    if (updatedExpense != null) await isarService.saveExpenseDB(updatedExpense);
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
