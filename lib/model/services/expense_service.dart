import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:onfly/model/services/isar_service.dart';

import '../../controller/token_controller.dart';
import '../expense_model.dart';
import '../token_model.dart';
import 'api_config.dart';

class ExpenseService {
  final String baseUrl = ApiConfig.apiUrl;

  final IsarService isarService = IsarService();
  final TokenController tokenController = TokenController();

  //Verifica e retorna se há token disponível.
  //Caso não tenha, solicita novo token. Retorna token ou nulo
  Future<Token?> _loadToken() async {
    try {
      Token? token = await isarService.getTokenDB();
      token ??= await tokenController.getTokenAPI();
      return token;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>?> getExpenseList() async {
    try {
      final connection = await InternetConnectionChecker().hasConnection;
      if (!connection) return null;
      final authToken = await _loadToken();

      final url = Uri.parse('$baseUrl/collections/expense_${ApiConfig.login}/records');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${authToken!.token}',
        },
      );

      final expensesMap = await jsonDecode(response.body);

      if (response.statusCode == 200) {
        return expensesMap["items"];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> createExpense(Expense expense) async {
    try {
      final connection = await InternetConnectionChecker().hasConnection;
      if (!connection) return null;

      final authToken = await _loadToken();

      final url = Uri.parse('$baseUrl/collections/expense_${ApiConfig.login}/records');
      final body = jsonEncode({
        'description': expense.description,
        'expense_date': expense.expenseDate.toIso8601String(),
        'amount': expense.amount,
        'latitude': expense.latitude,
        'longitude': expense.longitude,
      });

      final response = await http.post(
        url,
        body: body,
        headers: {
          'Authorization': 'Bearer ${authToken!.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        return null;
      }
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      return responseData['id'];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    try {
      final connection = await InternetConnectionChecker().hasConnection;
      if (!connection) return false;

      final authToken = await _loadToken();
      if (authToken == null) return false;

      final url = Uri.parse('$baseUrl/collections/expense_${ApiConfig.login}/records/${expense.apiId}');
      final body = jsonEncode({
        'description': expense.description,
        'amount': expense.amount,
        'expense_date': expense.expenseDate.toIso8601String(),
        'latitude': expense.latitude,
        'longitude': expense.longitude,
      });

      final response = await http.patch(
        url,
        body: body,
        headers: {
          'Authorization': 'Bearer ${authToken.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update expense');
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> removeExpense(String apiId) async {
    try {
      final connection = await InternetConnectionChecker().hasConnection;
      if (!connection) return false;
      final authToken = await _loadToken();
      if (authToken == null) return false;

      final url = Uri.parse('$baseUrl/collections/expense_${ApiConfig.login}/records/$apiId');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${authToken.token}',
        },
      );

      if (response.statusCode != 204) {
        return false;
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> syncLocalExpenses(List<Expense> locallyCreatedExpense, List<Expense> locallyUpdatedExpense) async {
    try {
      Timer.periodic(const Duration(seconds: 5), (_) async {
        if (locallyCreatedExpense.isNotEmpty) {
          for (final expense in locallyCreatedExpense) {
            await createExpense(expense);
          }
        }
        if (locallyUpdatedExpense.isNotEmpty) {
          for (final expense in locallyUpdatedExpense) {
            await updateExpense(
              expense,
            );
          }
        }
      });
    } catch (e) {
      rethrow;
    }
  }
}
