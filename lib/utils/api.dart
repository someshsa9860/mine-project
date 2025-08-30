import 'dart:convert';
import 'dart:io';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:gmineapp/services/hive_service.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'endpoints.dart';

///Here we are using single class to manage all server related operations
///Interns not allowed to interfere with this class
class CallApi {
  static final CallApi instance = CallApi._constructor();

  CallApi._constructor();

  dynamic ipAddress;

  get token async {
    return HiveService.instance.get('jwtAccessToken');
  }

  Future<http.Response> postData(
    Map<dynamic, dynamic> data0,
    String apiUrl,
  ) async {
    Map data = Map.of(data0);

    var fulUrl = url + apiUrl;

    data.removeWhere(
      (key, value) =>
          key == 'updated_at' || key == 'created_at' || key == 'token',
    );

    return http.post(
      Uri.parse(fulUrl),
      body: jsonEncrypt(data),
      headers: setHeader(data: data, token: await token),
    );
  }

  Future<http.Response> updateData(
    Map<dynamic, dynamic> data0,
    String apiUrl,
  ) async {
    Map data = Map.of(data0);

    data.removeWhere(
      (key, value) =>
          key == 'updated_at' || key == 'created_at' || key == 'token',
    );
    var fulUrl = '${url + apiUrl}/${data['id']}';
    return http.patch(
      Uri.parse(fulUrl),
      body: jsonEncrypt(data),
      headers: setHeader(data: data0, token: await token),
    );
  }

  Future<http.Response> deleteData(String apiUrl) async {
    var fulUrl = url + apiUrl;
    return http.delete(
      Uri.parse(fulUrl),
      headers: setHeader(token: await token),
    );
  }

  String jsonEncrypt(data) {
    final json = jsonEncode(data);

    return json;
  }

  Future<http.Response> getData(String apiUrl, {body}) async {
    var fulUrl = url + apiUrl;

    if (body != null) {
      final uri = Uri.https(domain, '/api$apiUrl', body);
      return http.get(uri, headers: setHeader(token: await token));
    }
    return http.get(Uri.parse(fulUrl), headers: setHeader(token: await token));
  }

  bool sessionExpired = false;

  AndroidDeviceInfo? androidDeviceInfo;

  IosDeviceInfo? iosDeviceInfo;
  MacOsDeviceInfo? macOsDeviceInfo;
  WindowsDeviceInfo? windowsDeviceInfo;
  LinuxDeviceInfo? linuxDeviceInfo;

  Future<void> init() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      ipAddress = await Ipify.ipv4();

      if (Platform.isAndroid) {
        androidDeviceInfo = await deviceInfo.androidInfo;
      } else if (Platform.isIOS) {
        iosDeviceInfo = await deviceInfo.iosInfo;
      } else if (Platform.isMacOS) {
        macOsDeviceInfo = await deviceInfo.macOsInfo;
      } else if (Platform.isWindows) {
        windowsDeviceInfo = await deviceInfo.windowsInfo;
      } else if (Platform.isLinux) {
        linuxDeviceInfo = await deviceInfo.linuxInfo;
      }
      // position = await Geolocator.getCurrentPosition();
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  Map<String, String> setHeader({required token, dynamic data}) {
    final Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'secure': "@3456025AQ%71GbghMi*8N46w%i^j7Gn^2dsdfghcu^w#p&",
      'Authorization': 'Bearer $token',
      'version': version,
      'X-APP-KEY': "t7vQVdmYjaLDXbc8XV6x7IkmbQ6blN7b8u6jblha5mgPyU5CTpJWfMeoSk",

      'ip-address': ipAddress ?? '',
      'platform': Platform.operatingSystem,
      'version-code': '$versionCode',
    };

    try {
      // **Android Headers**
      if (Platform.isAndroid && androidDeviceInfo != null) {
        headers.addAll({
          'device-id': androidDeviceInfo?.id ?? '',
          'android-version': androidDeviceInfo?.version.release ?? '',
          'android-brand': androidDeviceInfo?.brand ?? '',
          'android-device-model': androidDeviceInfo?.model ?? '',
          'android-manufacturer': androidDeviceInfo?.manufacturer ?? '',
          'android-hardware': androidDeviceInfo?.hardware ?? '',
          'android-product': androidDeviceInfo?.product ?? '',
          'android-board': androidDeviceInfo?.board ?? '',
          'android-host': androidDeviceInfo?.host ?? '',
          'android-fingerprint': androidDeviceInfo?.fingerprint ?? '',
        });
      }

      // **iOS Headers**
      if (Platform.isIOS && iosDeviceInfo != null) {
        headers.addAll({
          'device-id': iosDeviceInfo?.identifierForVendor ?? '',
          'ios-system-name': iosDeviceInfo?.systemName ?? '',
          'ios-version': iosDeviceInfo?.systemVersion ?? '',
          'ios-model': iosDeviceInfo?.model ?? '',
          'ios-name': iosDeviceInfo?.name ?? '',
        });
      }

      // **macOS Headers**
      if (Platform.isMacOS && macOsDeviceInfo != null) {
        headers.addAll({
          'device-id': macOsDeviceInfo?.computerName ?? '',
          'macos-version': macOsDeviceInfo?.osRelease ?? '',
          'macos-model': macOsDeviceInfo?.model ?? '',
        });
      }

      // **Windows Headers**
      if (Platform.isWindows && windowsDeviceInfo != null) {
        headers.addAll({
          'device-id': windowsDeviceInfo?.deviceId ?? '',
          'windows-name': windowsDeviceInfo?.computerName ?? '',
          'windows-version': windowsDeviceInfo?.productName ?? '',
          'windows-build': '${windowsDeviceInfo?.buildNumber ?? ''}',
        });
      }

      // **Linux Headers**
      if (Platform.isLinux && linuxDeviceInfo != null) {
        headers.addAll({
          'device-id': linuxDeviceInfo?.id ?? '',
          'linux-name': linuxDeviceInfo?.name ?? '',
          'linux-version': linuxDeviceInfo?.version ?? '',
          'linux-machine-id': linuxDeviceInfo?.machineId ?? '',
        });
      }
    } catch (e, s) {
      print(e);
      print(s);
    }

    return headers;
  }

  Future<http.Response> directPostData(String url, String body) {
    return http.post(Uri.parse(url), body: body);
  }
}
