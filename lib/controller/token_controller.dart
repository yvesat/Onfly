import 'dart:convert';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:onfly/model/services/isar_service.dart';
import 'package:http/http.dart' as http;
import '../model/services/api_config.dart';
import '../model/token_model.dart';

class TokenController {
  final IsarService isarService = IsarService();

  Future<Token?> getTokenAPI() async {
    try {
      final connection = await InternetConnectionChecker().hasConnection;
      if (!connection) return null;

      final url = Uri.parse('${ApiConfig.apiUrl}/collections/users/auth-with-password');

      final body = jsonEncode({
        'identity': ApiConfig.login,
        'password': ApiConfig.password,
      });

      final response = await http.post(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final Token token = Token(responseData['token']);

        await isarService.saveTokenDB(token);

        return token;
      } else {
        throw Exception(responseData['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
