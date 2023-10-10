import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:onfly/model/enums/alert_type.dart';
import 'package:onfly/model/removed_expense.dart';
import 'package:onfly/model/services/expense_service.dart';
import 'package:onfly/model/services/geolocator_service.dart';
import 'package:onfly/model/services/isar_service.dart';
import 'package:onfly/view/widgets/alert.dart';
import 'package:uuid/uuid.dart';

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
        await _loadExpensesFromAPI(ref);
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

  /// Limpa as despesas do app e insere as da API
  ///
  /// Este trecho de código realiza as seguintes ações:
  /// 1. Limpa todas as despesas existentes no estado do aplicativo e no banco de dados local.
  /// 2. Itera pelas despesas provenientes da API.
  /// 3. Para cada despesa da API, cria despesa no estado e no banco de dados local.
  //TODO: VERIFICAR DUPLICIDADE
  Future<void> _loadExpensesFromAPI(WidgetRef ref) async {
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

  //TODO: VERIFICAR DUPLICIDADE
  Future<List<Expense>?> _listExpensesAPI(WidgetRef ref) async {
    try {
      final expenseListAPI = await expenseService.getExpenseList();

      if (expenseListAPI == null || expenseListAPI.isEmpty) return null;

      const Uuid uuid = Uuid();

      List<Expense> expenseList = [];

      for (final expense in expenseListAPI) {
        final newExpense = Expense(
          expenseId: uuid.v4(),
          description: expense["description"],
          amount: expense["amount"].toDouble(),
          expenseDate: DateTime.parse(expense["expense_date"]),
          apiId: expense["id"],
          isSynchronized: true,
          latitude: expense["latitude"],
          longitude: expense["longitude"],
        );
        expenseList.add(newExpense);
      }
      return expenseList;
    } catch (e) {
      return null;
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
    } catch (e) {
      rethrow;
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
      await _updateExpenseSyncStatus(ref, isSynchronized: isSynchronized, expense: updatedExpense);
    } catch (e) {
      rethrow;
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
      bool isConnected = false;

      while (true) {
        bool isCreatedExpensesSync = false;
        bool isEditedExpensesSync = false;

        isConnected = await checkConnection.hasConnection;

        if (isConnected) {
          final expenseListDB = await isarService.getExpensesListDB();

          List<Expense> unsyncCreatedExp = [];
          List<Expense> unsyncEditedExp = [];

          for (final expense in expenseListDB) {
            if (expense.isSynchronized == false) {
              if (expense.apiId == null) {
                unsyncCreatedExp.add(expense);
              } else {
                unsyncEditedExp.add(expense);
              }
            }
          }

          if (unsyncCreatedExp.isNotEmpty) {
            for (final expense in unsyncCreatedExp) {
              final apiId = await expenseService.createExpense(expense);
              if (apiId != null) {
                await _updateExpenseSyncStatus(ref, isSynchronized: true, expense: expense, apiId: apiId);
                isCreatedExpensesSync = true;
              }
            }
          } else {
            isCreatedExpensesSync = true;
          }

          if (unsyncEditedExp.isNotEmpty) {
            for (final expense in unsyncEditedExp) {
              bool isSynchronized = await expenseService.updateExpense(expense);
              if (isSynchronized) {
                await _updateExpenseSyncStatus(ref, isSynchronized: isSynchronized, expense: expense);
                isEditedExpensesSync = true;
              }
            }
          } else {
            isEditedExpensesSync = true;
          }

          if (isCreatedExpensesSync && isEditedExpensesSync) {
            final expenseListAPI = await _listExpensesAPI(ref);
            final expenseListUpdatedDB = await isarService.getExpensesListDB();

            if (expenseListAPI != null) {
              final areExpenseListsEqual = _synchExpenseAPI(apiList: expenseListAPI, localDataList: expenseListUpdatedDB);

              if (!areExpenseListsEqual) await _loadExpensesFromAPI(ref);
            }
          }
        }
        await Future.delayed(const Duration(seconds: 15));
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Verifica se as listas de despesas da API e locais são iguais.
  ///
  /// Esta função verifica se as duas listas de despesas passadas como argumento são
  /// iguais em termos de tamanho e conteúdo. Ela compara o tamanho das listas e,
  /// em seguida, verifica se cada despesa local tem uma correspondente na lista da API
  /// com base no `apiId`. Além disso, ela verifica se as despesas são iguais usando a função
  /// `_areExpensesEqual`. Se todas as despesas locais tiverem correspondentes na lista da API
  /// e forem iguais, a função retorna `true`, caso contrário, retorna `false`.
  bool _synchExpenseAPI({required List<Expense> apiList, required List<Expense> localDataList}) {
    if (apiList.length != localDataList.length) {
      return false;
    }

    for (final localExpense in localDataList) {
      final apiExpense = apiList.firstWhereOrNull((apiExpense) => apiExpense.apiId == localExpense.apiId);

      if (apiExpense == null) return false;
      if (!_areExpensesEqual(apiExpense, localExpense)) return false;
    }
    return true;
  }

  bool _areExpensesEqual(Expense expense1, Expense expense2) {
    // Compara cada propriedade de cada despesa
    return expense1.description == expense2.description && expense1.amount == expense2.amount && expense1.expenseDate == expense2.expenseDate && expense1.apiId == expense2.apiId && expense1.latitude == expense2.latitude && expense1.longitude == expense2.longitude;
  }

  /// Atualiza o status de sincronização no estado da aplicação e no banco de dados local, caso a operação de envio para a API seja bem-sucedida.
  Future<void> _updateExpenseSyncStatus(WidgetRef ref, {required bool isSynchronized, required Expense expense, String? apiId}) async {
    try {
      final updatedExpense = ref.read(expenseProvider.notifier).editExpense(expense.expenseId, isSynchronized: isSynchronized, apiId: apiId);
      await isarService.saveExpenseDB(updatedExpense);
    } catch (e) {
      rethrow;
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
