import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onfly/model/removed_expense.dart';
import 'package:onfly/model/services/expense_service.dart';
import 'package:onfly/model/services/isar_service.dart';

import '../model/expense_model.dart';

class ExpenseController extends StateNotifier<AsyncValue<void>> {
  ExpenseController() : super(const AsyncValue.data(null));

  final IsarService isarService = IsarService();
  final ExpenseService expenseService = ExpenseService();

  Future<void> loadExpeneState(WidgetRef ref) async {
    try {
      state = const AsyncValue.loading();
      final expenseListDB = await isarService.getExpensesListDB();
      for (final expense in expenseListDB) {
        ref.read(expenseProvider.notifier).loadExpense(expense);
      }
    } catch (_) {
      rethrow;
    } finally {
      state = const AsyncValue.data(null);
    }
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

  Future<void> createExpense(WidgetRef ref, String title, String value, DateTime date) async {
    double doubleValue = double.parse(value.replaceAll(',', '.'));

    final newExpense = ref.read(expenseProvider.notifier).createExpense(title: title, value: doubleValue, date: date);
    await isarService.saveExpenseDB(newExpense);
    final bool isSynchronized = await expenseService.createExpense(newExpense);

    await updateExpenseSyncStatus(ref, isSynchronized, newExpense);
  }

  Future<void> updateExpense(WidgetRef ref, String? expenseId, String? newTitle, String? newValue, DateTime? newDate) async {
    if (expenseId == null) return;

    double? doubleValue;
    if (newValue != null) doubleValue = double.parse(newValue.replaceAll(',', '.'));

    final updatedExpense = ref.read(expenseProvider.notifier).editExpense(expenseId, newTitle: newTitle, newValue: doubleValue, newDate: newDate);
    if (updatedExpense != null) {
      await isarService.saveExpenseDB(updatedExpense);
      bool isSynchronized = await expenseService.updateExpense(updatedExpense);
      await updateExpenseSyncStatus(ref, isSynchronized, updatedExpense);
    }
  }

  Expense? getExpense(WidgetRef ref, String expenseId) {
    return ref.read(expenseProvider.notifier).getExpenseById(expenseId);
  }

  List<Expense> getExpenseList(WidgetRef ref) {
    return ref.watch(expenseProvider);
  }

  Future<void> removeExpense(WidgetRef ref, String expenseId) async {
    try {
      final expense = ref.read(expenseProvider.notifier).getExpenseById(expenseId);
      if (expense != null) throw Exception("Falha ao encontrar despesa");

      final removedExpenseId = expense!.expenseId;

      await isarService.removeExpenseDB(expense);
      ref.read(expenseProvider.notifier).removeExpense(expense);

      final isRemoved = await expenseService.removeExpense(removedExpenseId);
      if (!isRemoved) {
        final removedExpense = RemovedExpense(removedExpenseId);
        isarService.saveRemovedExpensesDB(removedExpense);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Atualiza o status de sincronização no estado da aplicação e no banco de dados local, caso a operação de envio para a API seja bem-sucedida.
  Future<void> updateExpenseSyncStatus(WidgetRef ref, bool isSynchronized, Expense expense) async {
    if (!isSynchronized) {
      final updatedExpense = ref.read(expenseProvider.notifier).editExpense(expense.expenseId, newIsSynchronized: isSynchronized);
      if (updatedExpense != null) await isarService.saveExpenseDB(updatedExpense);
    }
  }

  //TODO: Criar método para sincronismo automático.
  //TODO: Inserir no main?
  //TODO: Sincronizar: criação, atualização e remoção. Get?
  Future<void> syncLocalExpenses() async {}
}

final expenseControllerProvider = StateNotifierProvider<ExpenseController, AsyncValue<void>>((ref) => ExpenseController());
