import 'package:isar/isar.dart';

part 'token_model.g.dart';

@collection
class Token {
  Id id = Isar.autoIncrement;
  String token = "";

  Token(this.token);
}
