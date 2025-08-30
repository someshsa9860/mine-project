import '../models/user_model.dart';
import 'hive_service.dart';

class SessionService {
  SessionService._internal();
  static final SessionService instance = SessionService._internal();

  final _tokenKey = 'jwt_token';
  final _userKey = 'userData';

  String? get jwtToken => HiveService.instance.get<String>(_tokenKey);
  UserModel? get currentUser => HiveService.instance.get<UserModel>(_userKey);

  void login(String token, UserModel user) {
    HiveService.instance.put(_tokenKey, token);
    HiveService.instance.put(_userKey, user);
  }

  bool get isLoggedIn => jwtToken != null && currentUser != null;
}
