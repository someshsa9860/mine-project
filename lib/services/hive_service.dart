import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:gmineapp/models/dashboard_model.dart';
import 'package:gmineapp/models/settings_model.dart';
import 'package:gmineapp/models/vehicle_type_model.dart';
import 'package:gmineapp/utils/api.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/token_model.dart';
import '../models/trip_model.dart';
import '../models/user_model.dart';

class HiveService {
  HiveService._internal();

  static final HiveService instance = HiveService._internal();

  late Box box;

  Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Register your adapters
      Hive.registerAdapter(RoleAdapter());
      Hive.registerAdapter(AdminPermissionAdapter());
      Hive.registerAdapter(UserModelAdapter());
      Hive.registerAdapter(TokenModelAdapter());
      Hive.registerAdapter(VehicleTypeModelAdapter());
      Hive.registerAdapter(TripModelAdapter());
      Hive.registerAdapter(SettingsModelAdapter());
      Hive.registerAdapter(DashboardModelAdapter());

      // AES encryption key
      final key = sha256
          .convert(utf8.encode("super_secret_key_123"))
          .bytes
          .sublist(0, 32);
      final encryptionKey = Uint8List.fromList(key);

      box = await Hive.openBox(
        'gs_rkhvk_sams',
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
    } catch (e, s) {
      CallApi.instance.postData({'e': e, 's': s}, '/bug-report');
    }
  }

  // Generic methods
  void put<T>(String key, T value) => box.put(key, value);

  T? get<T>(String key) => box.get(key);

  Future<void> delete(String key) async => await box.delete(key);

  Future<dynamic> clear() async => await box.clear();

  // Get all tokens
  List<TokenModel> getAllTokens() {
    return box.keys
        .where((k) => k.toString().startsWith('token_'))
        .map((k) => box.get(k) as TokenModel)
        .toList();
  }

  // Get all trips
  List<TripModel> getAllTrips() {
    return box.keys
        .where((k) => k.toString().startsWith('trip_'))
        .map((k) => box.get(k) as TripModel)
        .toList();
  }

  // Add a token with key: "token_<id>"
  void addToken(TokenModel token) {
    box.put('token_${token.id}', token);
  }

  List<String?> deletedTokens = [];

  deleteToken(TokenModel token) async {
    deletedTokens.add(token.id);
    await box.delete('token_${token.id}');
  }

  // Add a trip with key: "trip_<id>"
  void addTrip(TripModel trip) {
    box.put('trip_${trip.id}', trip);
  }

  void updateUser(userData) {
    put<UserModel>('userData', UserModel.fromJson(userData));
  }

  void updateSettings(setting) {
    put<SettingsModel>('settings', SettingsModel.fromJson(setting));
  }

  void putDashboardData(Map<String, dynamic> data) {
    put<DashboardModel>('dashboardUpdate', DashboardModel.fromJson(data));
  }

  DashboardModel? getDashboardData() {
    return get<DashboardModel>('dashboardUpdate');
  }

  void updateDashboardData({
    required bool isToken,
    required bool isTrip,
    bool isTokenDeleted = false,
  }) {
    final DashboardModel? currentData = getDashboardData();

    final data =
        currentData ??
        DashboardModel(openTokens: 0, closedTrips: 0, closedTripsToday: 0);

    // Protect against negative values
    if (!isToken && data.openTokens > 0 && isTrip) {
      data.openTokens -= 1;
    } else if (isToken) {
      if (isTokenDeleted) {
        data.openTokens -= 1;
      } else {
        data.openTokens += 1;
      }
    }

    if (!isToken) {
      data.closedTrips += 1;
      data.closedTripsToday += 1;
    }

    data.save();
  }

  SettingsModel? get settings {
    return get<SettingsModel>('settings');
  }

  void updateTypes(List<dynamic> types) {
    final List<VehicleTypeModel> typeList = types
        .map((e) => VehicleTypeModel.fromJson(e))
        .toList();

    put<List<VehicleTypeModel>>('vehicleTypes', typeList);
  }

  List<VehicleTypeModel>? getTypes() {
    return get<List<VehicleTypeModel>>('vehicleTypes');
  }

  logout() async {
    await clear();
  }
}
