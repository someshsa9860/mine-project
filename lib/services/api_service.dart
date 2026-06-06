import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gmineapp/models/token_model.dart';
import 'package:gmineapp/models/trip_model.dart';
import 'package:gmineapp/models/vehicle_model.dart';
import 'package:gmineapp/services/hive_service.dart';
import 'package:gmineapp/services/session_service.dart';
import 'package:gmineapp/utils/api.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/endpoints.dart';
import '../utils/loader.dart';
import '../widgets/widgets.dart';

class ApiService {
  static ValueNotifier<String?> reportPath = ValueNotifier<String?>(null);

  static Future<void> downloadStaffReportPdf() async {
    Get.dialog(
      AlertDialog(
        title: Text('Alert'),
        content: Text(
          "Are you sure to download, your tokens and trips will be recorded?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(closeOverlays: true);
              handleDownload();
            },
            child: Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Get.back(closeOverlays: true);
            },
            child: Text("No"),
          ),
        ],
      ),
    );
  }

  static handleDownload() async {
    Loader.instance.show();

    try {
      // Request storage permission on Android
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          // Loader.instance.hide();
          // return 'Storage permission denied';
        }
      }

      final response = await CallApi.instance.getData(EndPoints.reportsPdfApi);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final dir = await getApplicationDocumentsDirectory();
        final filePath =
            "${dir.path}/staff_report_${DateTime.now().millisecondsSinceEpoch}.pdf";

        final file = File(filePath);

        if (!await file.exists()) {
          await file.create(recursive: true);
        }

        await file.writeAsBytes(bytes);

        Loader.instance.hide();
        reportPath.value = filePath;
        await OpenFile.open(filePath, type: "application/pdf");

        return filePath;
      } else {
        Loader.instance.hide();
        final message =
            jsonDecode(response.body)['message'] ?? 'Failed to download report';
        showSnackBar(message);
        return null;
      }
    } catch (e) {
      Loader.instance.hide();
      showSnackBar('Error downloading PDF: $e');
      return null;
    }
  }

  static Future<List<TokenModel>> getRecentActiveTokens() async {
    final response = await CallApi.instance.getData(EndPoints.recentTokenApi);
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
        body['tokens'],
      ).map((e) => TokenModel.fromJson(e)).toList();
    } else {
      showSnackBar(body['message']);
    }
    return [];
  }

  Future<List<TokenModel>> fetchTokensFromServer() async {
    final response = await CallApi.instance.getData(EndPoints.recentTokenApi);
    final data = jsonDecode(response.body)['tokens'];
    var list = (data as List).map((e) => TokenModel.fromJson(e)).toList();
    return list;
  }

  static Future<TripModel?> completeTrip(Map tripData) async {
    try {
      final res = await CallApi.instance.postData(
        tripData,
        EndPoints.exitTripApi,
      );
      var body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        var tripModel = TripModel.fromJson(body['trip']);
        HiveService.instance.addTrip(tripModel);
        HiveService.instance.updateDashboardData(isToken: false, isTrip: true);

        return tripModel;
      } else {
        showSnackBar(body['message']);
      }
    } catch (e, s) {
      print(e);
      print(s);
      showSnackBar(e);
    }
    return null;
  }

  static Future<TokenModel?> createToken(Map tokenData) async {
    try {
      final res = await CallApi.instance.postData(
        tokenData,
        EndPoints.createTokenApi,
      );
      var body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        var tokenModel = TokenModel.fromJson(body['token']);
        HiveService.instance.addToken(tokenModel);
        HiveService.instance.updateDashboardData(
          isToken: tokenModel.vehicleType == "Truck",
          isTrip: false,
        );
        return tokenModel;
      } else {
        showSnackBar(body['message']);
      }
    } catch (e, s) {
      print(e);
      print(s);
      showSnackBar(e);
    }
    return null;
  }

  static refresh() async {
    if (HiveService.instance.get('settings') == null) {
      Loader.instance.show();
    }

    try {
      final res = await CallApi.instance.getData(EndPoints.initDataApi);
      var body = jsonDecode(res.body);
      print(body);
      if (res.statusCode == 200) {
        HiveService.instance.updateUser(body['user']);
        HiveService.instance.updateSettings(body['settings']);

        HiveService.instance.putDashboardData(body);

        // showSnackBar("Data Refreshed");
      } else {
        showSnackBar(body['message']);
      }
    } catch (e, s) {
      showSnackBar("$e");
      print(e);
      print(s);
    } finally {
      Loader.instance.hide();
    }

    Future.delayed(Duration(minutes: 2)).then((v) {
      if (SessionService.instance.currentUser != null) {
        refresh();
      }
    });
  }

  static Future<List<TokenModel>?> getToken(String tokenNumber) async {
    Loader.instance.show();

    try {
      final res = await CallApi.instance.getData(
        EndPoints.getTokenApi,
        body: {'token': tokenNumber},
      );
      var body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        List<TokenModel> tokens = [];
        for (var e in body['tokens']) {
          var token = TokenModel.fromJson(e);
          tokens.add(token);
          HiveService.instance.addToken(token);
        }
        Loader.instance.hide();
        return tokens;
      } else {
        showSnackBar(body['message']);
      }
    } catch (e, s) {
      showSnackBar("$e");
      print(e);
      print(s);
    } finally {
      Loader.instance.hide();
    }
    return null;
  }

  Future<List<TripModel>> fetchTripsFromServer() async {
    final response = await CallApi.instance.getData(EndPoints.getTripsApi);
    final data = jsonDecode(response.body)['trips'];
    return (data as List).map((e) => TripModel.fromJson(e)).toList();
  }

  /// Look up a vehicle for auto-fill (owner/registered no) and blacklist check.
  /// Returns null if not found. Stays silent (no loader/snackbar) since it is
  /// triggered while the user is typing the vehicle number.
  static Future<VehicleModel?> lookupVehicle(String vehicleNumber) async {
    if (vehicleNumber.trim().isEmpty) return null;
    try {
      final res = await CallApi.instance.getData(
        EndPoints.vehicleLookupApi,
        body: {'vehicle_number': vehicleNumber.trim()},
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['vehicle'] == null) return null;
        return VehicleModel.fromJson(Map<String, dynamic>.from(body['vehicle']));
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
    return null;
  }

  /// Blacklist a vehicle. Any staff may do this.
  static Future<bool> blacklistVehicle(
    String vehicleNumber,
    String reason,
  ) async {
    Loader.instance.show();
    try {
      final res = await CallApi.instance.postData(
        {'vehicle_number': vehicleNumber.trim(), 'reason': reason},
        EndPoints.blacklistApi,
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        showSnackBar(body['message'] ?? 'Vehicle blacklisted');
        return true;
      } else {
        showSnackBar(body['message'] ?? 'Failed to blacklist');
      }
    } catch (e, s) {
      showSnackBar("$e");
      print(e);
      print(s);
    } finally {
      Loader.instance.hide();
    }
    return false;
  }

  /// Remove a vehicle from the blacklist. Admin only (server enforces 403).
  static Future<bool> unblacklistVehicle(String vehicleNumber) async {
    Loader.instance.show();
    try {
      final res = await CallApi.instance.postData(
        {'vehicle_number': vehicleNumber.trim()},
        EndPoints.unblacklistApi,
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        showSnackBar(body['message'] ?? 'Removed from blacklist');
        return true;
      } else {
        showSnackBar(body['message'] ?? 'Only admin can remove from blacklist');
      }
    } catch (e, s) {
      showSnackBar("$e");
      print(e);
      print(s);
    } finally {
      Loader.instance.hide();
    }
    return false;
  }

  static Future<void> deleteToken(TokenModel token) async {
    Loader.instance.show();

    try {
      final res = await CallApi.instance.deleteData(
        "${EndPoints.deleteTokenApi}/${token.id}",
      );
      var body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        HiveService.instance.deleteToken(token);
        HiveService.instance.updateDashboardData(
          isToken: true,
          isTokenDeleted: true,
          isTrip: false,
        );
      } else {
        showSnackBar(body['message']);
      }
    } catch (e, s) {
      showSnackBar("$e");
      print(e);
      print(s);
    } finally {
      Loader.instance.hide();
    }
  }
}
