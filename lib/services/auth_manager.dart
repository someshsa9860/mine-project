import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gmineapp/services/api_service.dart';
import 'package:gmineapp/utils/auth_wrapper.dart';

import '../models/user_model.dart';
import 'hive_service.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  blocked,
  sessionExpired,
}

class AuthManager {
  // Singleton pattern
  static final AuthManager _instance = AuthManager._internal();

  static AuthManager get instance => _instance;

  AuthManager._internal();

  final ValueNotifier<AuthStatus> authStatus = ValueNotifier(
    AuthStatus.unknown,
  );
  UserModel? _currentUser;
  String? _jwtToken;

  UserModel? get currentUser => _currentUser;

  String? get jwtToken => _jwtToken;

  init() {
    // Restore session if token exists
    _jwtToken = HiveService.instance.get('jwtAccessToken');
    final userJson = HiveService.instance.get<UserModel>('userData');

    if (_jwtToken != null && userJson != null) {
      _currentUser = (userJson);
      authStatus.value = AuthStatus.authenticated;
      Future.delayed(Duration.zero).then((v) {
        ApiService.refresh();
      });
    } else {
      authStatus.value = AuthStatus.unauthenticated;
    }
  }

  Future<void> login({
    required String token,
    required Map<String, dynamic> userJson,
  }) async {
    _jwtToken = token;
    _currentUser = UserModel.fromJson(userJson);

    HiveService.instance.put('jwtAccessToken', token);
    HiveService.instance.updateUser(userJson);

    authStatus.value = AuthStatus.authenticated;
    ApiService.refresh();
  }

  Future<void> logout({bool expired = false}) async {
    _jwtToken = null;
    _currentUser = null;
    await HiveService.instance.logout();
    authStatus.value = expired
        ? AuthStatus.sessionExpired
        : AuthStatus.unauthenticated;
    Get.off(() => AuthWrapper());
  }
}
