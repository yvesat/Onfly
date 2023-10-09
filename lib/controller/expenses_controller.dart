import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onfly/model/enums/alert_type.dart';
import 'package:onfly/model/removed_expense.dart';
import 'package:onfly/model/services/expense_service.dart';
import 'package:onfly/model/services/geolocator_service.dart';
import 'package:onfly/model/services/isar_service.dart';
import 'package:onfly/view/widgets/alert.dart';

import '../model/expense_model.dart';

class ExpenseController extends StateNotifier<AsyncValue<void>> {
  ExpenseController() : super(const AsyncValue.data(null));

  final IsarService isarService = IsarService();
  final ExpenseService expenseService = ExpenseService();
  final Alert alertService = Alert();
  final GeolocatorService geolocatorService = GeolocatorService();

  Future<void> loadExpenses(WidgetRef ref) async {
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

  //TODO: Implementar
  Future<void> listExpensesAPI() async {
    // final List<dynamic> expenseData = jsonDecode(response.body);
    // return expenseData.map((data) {
    //   return Expense(
    //     expenseId: data['id'],
    //     description: data['title'],
    //     amount: data['value'].toDouble(),
    //     expenseDate: DateTime.parse(data['date']),
    //     apiId: data['id'],
    //     latitude: data['latitude'],
    //     longitude: data['longitude'],
    //   );
    // }).toList();
  }

  Future<void> createExpense(BuildContext context, ref, String description, String amount, DateTime expenseDate) async {
    try {
      state = const AsyncValue.loading();

      final latLong = await _getLatLong(context);

      double doubleAmount = double.parse(amount.replaceAll(',', '.'));

      final newExpense = ref.read(expenseProvider.notifier).createExpense(description: description, amount: doubleAmount, expenseDate: expenseDate, latLong: latLong);

      await isarService.saveExpenseDB(newExpense);
      final apiId = await expenseService.createExpense(newExpense);

      if (apiId != null) await _updateExpenseSyncStatus(ref, isSynchronized: true, expense: newExpense, apiId: apiId);
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> updateExpense(WidgetRef ref, String expenseId, String? newDescription, String? newAmount, DateTime? newExpenseDate) async {
    try {
      state = const AsyncValue.loading();

      double? doubleAmount;
      if (newAmount != null) doubleAmount = double.parse(newAmount.replaceAll(',', '.'));

      final updatedExpense = ref.read(expenseProvider.notifier).editExpense(expenseId, newDescription: newDescription, newAmount: doubleAmount, newExpenseDate: newExpenseDate);

      await isarService.saveExpenseDB(updatedExpense);
      bool isSynchronized = await expenseService.updateExpense(updatedExpense);
      if (isSynchronized) await _updateExpenseSyncStatus(ref, isSynchronized: isSynchronized, expense: updatedExpense);
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Expense? getExpense(WidgetRef ref, String expenseId) {
    return ref.watch(expenseProvider.notifier).getExpenseById(expenseId);
  }

  List<Expense> getExpenseList(WidgetRef ref) {
    return ref.watch(expenseProvider);
  }

  Future<void> removeExpense(WidgetRef ref, Expense? expense) async {
    if (expense == null) return;

    try {
      state = const AsyncValue.loading();

      final removedExpenseId = expense.apiId;

      await isarService.removeExpenseDB(expense);
      ref.read(expenseProvider.notifier).removeExpense(expense);

      //Guardando apiId para enviar solicitação de remoção a API quando houver internet
      //Caso a despesa não tenha apiId, ignora
      if (removedExpenseId != null) {
        final isRemoved = await expenseService.removeExpense(removedExpenseId);
        if (!isRemoved) {
          final removedExpense = RemovedExpense(removedExpenseId);
          isarService.saveRemovedExpensesDB(removedExpense);
        }
      }
    } catch (e) {
      rethrow;
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  // Atualiza o status de sincronização no estado da aplicação e no banco de dados local, caso a operação de envio para a API seja bem-sucedida.
  Future<void> _updateExpenseSyncStatus(WidgetRef ref, {required bool isSynchronized, required Expense expense, String? apiId}) async {
    if (isSynchronized) {
      final updatedExpense = ref.read(expenseProvider.notifier).editExpense(expense.expenseId, isSynchronized: isSynchronized, apiId: apiId);
      await isarService.saveExpenseDB(updatedExpense);
    }
  }

  //TODO: Criar método para sincronismo automático.
  //TODO: Inserir no main?
  //TODO: Sincronizar: criação, atualização e remoção. Get?
  Future<void> syncLocalExpenses() async {}

  Future<Map<String, String>> _getLatLong(BuildContext context) async {
    try {
      await geolocatorService.checkLocationService();
      await geolocatorService.checkLocationPermission();

      return await geolocatorService.getLatLong();
    } catch (e) {
      await alertService.dialog(context, alertType: AlertType.error, message: e.toString());
      rethrow;
    }
  }
}

final expenseControllerProvider = StateNotifierProvider<ExpenseController, AsyncValue<void>>((ref) => ExpenseController());
