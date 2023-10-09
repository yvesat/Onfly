import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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
  final InternetConnectionChecker checkConnection = InternetConnectionChecker();

  /// Carrega despesas do banco de dados local.
  ///
  /// Esta função carrega despesas do banco de dados local e atualiza o estado do
  /// aplicativo com elas. Se não houver conexão com a internet e não houver
  /// despesas locais, ela tenta buscar despesas do backend. Ela trata erros e
  /// atualiza o estado do aplicativo após o carregamento das despesas.
  Future<void> loadExpenses(WidgetRef ref) async {
    try {
      state = const AsyncValue.loading();

      final isConnected = await checkConnection.hasConnection;
      final expenseListDB = await isarService.getExpensesListDB();

      if (isConnected && expenseListDB.isEmpty) {
        await listExpensesAPI(ref);
      } else {
        for (final expense in expenseListDB) {
          ref.read(expenseProvider.notifier).loadExpense(expense);
        }
      }

      _syncLocalExpenses(ref);
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

  Future<void> listExpensesAPI(WidgetRef ref) async {
    try {
      final expenseListAPI = await expenseService.getExpenseList();

      if (expenseListAPI == null || expenseListAPI.isEmpty) return;

      ref.read(expenseProvider.notifier).clearExpenses();
      await isarService.clearExpenseDB();

      for (final expense in expenseListAPI) {
        final newExpense = ref.read(expenseProvider.notifier).createExpense(
          description: expense["description"],
          amount: expense["amount"].toDouble(),
          expenseDate: DateTime.parse(expense["expense_date"]),
          apiId: expense["id"],
          isSynchronized: true,
          latLong: {
            "latitude": expense["latitude"],
            "longitude": expense["longitude"],
          },
        );
        await isarService.saveExpenseDB(newExpense);
      }
    } catch (e) {
      rethrow;
    }
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

  Expense? getExpenseById(WidgetRef ref, String expenseId) {
    return ref.watch(expenseProvider.notifier).getExpenseById(expenseId);
  }

  List<Expense> getExpenseState(WidgetRef ref) {
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

  /// Sincroniza periodicamente despesas locais com o backend.
  ///
  /// Esta função é executada periodicamente para enviar despesas recém-criadas
  /// e editadas para o backend. Ela verifica a conexão com a internet, envia
  /// despesas não sincronizadas e atualiza o status de sincronização delas.
  /// Por fim, ela atualiza o estado do aplicativo com despesas do backend.
  Future<void> _syncLocalExpenses(WidgetRef ref) async {
    try {
      Timer.periodic(
        const Duration(seconds: 15),
        (_) async {
          bool isConnected = await InternetConnectionChecker().hasConnection;

          bool isCreatedExpensesSync = false;
          bool isEditedExpensesSync = false;

          if (isConnected) {
            //Enviando despesas criadas que não foram sincronizadas
            final unsyncCreatedExp = await isarService.getUnsyncedEditedExpListDB();
            if (unsyncCreatedExp.isNotEmpty) {
              for (final expense in unsyncCreatedExp) {
                await isarService.saveExpenseDB(expense);
                final apiId = await expenseService.createExpense(expense);
                if (apiId != null) isCreatedExpensesSync = await _updateExpenseSyncStatus(ref, isSynchronized: true, expense: expense, apiId: apiId);
              }
            }
          }

          isConnected = await InternetConnectionChecker().hasConnection;

          if (isConnected) {
            //Enviando despesas editadas que não foram sincronizadas
            final unsyncEditedExp = await isarService.getUnsyncedEditedExpListDB();
            if (unsyncEditedExp.isNotEmpty) {
              for (final expense in unsyncEditedExp) {
                await isarService.saveExpenseDB(expense);
                bool isSynchronized = await expenseService.updateExpense(expense);
                if (isSynchronized) isEditedExpensesSync = await _updateExpenseSyncStatus(ref, isSynchronized: isSynchronized, expense: expense);
              }
            }
          }

          isConnected = await InternetConnectionChecker().hasConnection;

          if (isConnected && isCreatedExpensesSync && isEditedExpensesSync) {
            await listExpensesAPI(ref);
          }
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Atualiza o status de sincronização no estado da aplicação e no banco de dados local, caso a operação de envio para a API seja bem-sucedida.
  Future<bool> _updateExpenseSyncStatus(WidgetRef ref, {required bool isSynchronized, required Expense expense, String? apiId}) async {
    try {
      if (isSynchronized) {
        final updatedExpense = ref.read(expenseProvider.notifier).editExpense(expense.expenseId, isSynchronized: isSynchronized, apiId: apiId);
        await isarService.saveExpenseDB(updatedExpense);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

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
