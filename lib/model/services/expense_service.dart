import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:onfly/model/services/isar_service.dart';

import '../expense_model.dart';

class ExpenseService {
  final String baseUrl = "https://go-bd-api-3iyuzyysfa-uc.a.run.app/api";
  //String? authToken;

  final IsarService isarService = IsarService();

  Future<String> _loadToken() async {
    final token = await isarService.getTokenDB();
    return token!.token;
  }

  Future<bool> createExpense(Expense expense) async {
    final connection = await InternetConnectionChecker().hasConnection;
    if (!connection) return false;
    final authToken = await _loadToken();

    final url = Uri.parse('$baseUrl/collections/expense_$authToken/records');
    final body = jsonEncode({
      'title': expense.title,
      'value': expense.value,
      'date': expense.date.toIso8601String(),
    });

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create expense');
      }

      return true;
    } catch (e) {
      throw Exception('Error creating expense: $e');
    }
  }

  Future<List<Expense>?> getExpense() async {
    final connection = await InternetConnectionChecker().hasConnection;
    if (!connection) return null;
    final authToken = await _loadToken();

    final url = Uri.parse('$baseUrl/collections/expense_$authToken/records');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> expenseData = jsonDecode(response.body);
        return expenseData.map((data) {
          return Expense(
            expenseId: data['id'],
            title: data['title'],
            value: data['value'].toDouble(),
            date: DateTime.parse(data['date']),
            isSynchronized: true,
          );
        }).toList();
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

    final url = Uri.parse('$baseUrl/collections/expense_$authToken/records/${expense.expenseId}');
    final body = jsonEncode({
      'title': expense.title,
      'value': expense.value,
      'date': expense.date.toIso8601String(),
    });

    try {
      final response = await http.patch(
        url,
        body: body,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update expense');
      }

      return true;
    } catch (e) {
      throw Exception('Error updating expense: $e');
    }
  }

  Future<bool> createExpenses(List<Expense> expenses) async {
    final connection = await InternetConnectionChecker().hasConnection;
    if (!connection) return false;
    final authToken = await _loadToken();

    final url = Uri.parse('$baseUrl/collections/expense_$authToken/records');

    final List<Map<String, dynamic>> expenseDataList = expenses.map((expense) {
      return {
        'title': expense.title,
        'value': expense.value,
        'date': expense.date.toIso8601String(),
      };
    }).toList();

    final body = jsonEncode(expenseDataList);

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create expenses');
      }

      return true;
    } catch (e) {
      throw Exception('Error creating expenses: $e');
    }
  }

  Future<bool> removeExpense(String id) async {
    final connection = await InternetConnectionChecker().hasConnection;
    if (!connection) return false;
    final authToken = await _loadToken();

    final url = Uri.parse('$baseUrl/collections/expense_$authToken/records/$id');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to remove expense');
      }

      return true;
    } catch (e) {
      throw Exception('Error removing expense: $e');
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
