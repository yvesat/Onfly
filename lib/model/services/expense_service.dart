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
    Token? token = await isarService.getTokenDB();
    token ??= await tokenController.getTokenAPI();
    return token;
  }

  Future<String?> createExpense(Expense expense) async {
    final connection = await InternetConnectionChecker().hasConnection;
    if (!connection) return null;

    final authToken = await _loadToken();
    if (authToken == null) return null;

    final url = Uri.parse('$baseUrl/collections/expense_${ApiConfig.login}/records');
    final body = jsonEncode({
      'description': expense.description,
      'expense_date': expense.expenseDate.toIso8601String(),
      'amount': expense.amount,
      'latitude': expense.latitude,
      'longitude': expense.longitude,
    });

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {
          'Authorization': 'Bearer ${authToken.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        return null;
      }
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      return responseData['id'];
    } catch (e) {
      return null;
    }
  }

  Future<List<Expense>?> getExpense() async {
    final connection = await InternetConnectionChecker().hasConnection;
    if (!connection) return null;
    final authToken = await _loadToken();
    if (authToken == null) return null;

    final url = Uri.parse('$baseUrl/collections/expense_${ApiConfig.login}/records');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${authToken.token}',
        },
      );

      if (response.statusCode == 200) {
        // final List<dynamic> expenseData = jsonDecode(response.body);
        // return expenseData.map((data) {
        //   return Expense(
        //     expenseId: data['id'], //TODO: CORRIGIR
        //     description: data['title'],
        //     amount: data['value'].toDouble(),
        //     expenseDate: DateTime.parse(data['date']),
        //     apiId: data['id'],
        //     latitude: data['latitude'],
        //     longitude: data['longitude'],
        //   );
        // }).toList();
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      throw Exception('Error fetching expenses: $e');
    }
  }

  Future<bool> updateExpense(Expense expense) async {
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

    try {
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
      return false;
    }
  }

  Future<bool> removeExpense(String apiId) async {
    final connection = await InternetConnectionChecker().hasConnection;
    if (!connection) return false;
    final authToken = await _loadToken();
    if (authToken == null) return false;

    final url = Uri.parse('$baseUrl/collections/expense_${ApiConfig.login}/records/$apiId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${authToken.token}',
        },
      );

      if (response.statusCode != 200) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
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
      throw Exception("Error syncing expenses: $e");
    }
  }
}
