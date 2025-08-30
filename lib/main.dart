import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:gmineapp/bloc/bluetooth_status/bluetooth_status_bloc.dart';
import 'package:gmineapp/providers/app_providers.dart';
import 'package:gmineapp/services/hive_service.dart';
import 'package:gmineapp/utils/auth_wrapper.dart';
import 'package:provider/provider.dart';

import 'theme/theme_cubit.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.instance.init();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: getProviders(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => BluetoothStatusBloc()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Mining Dashboard',
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.brown,
                  brightness: Brightness.light,
                  surface: Colors.white,
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepOrange,
                  brightness: Brightness.dark,
                ),
              ),
              themeMode: themeMode,
              home: AuthWrapper(),
            );
          },
        ),
      ),
    );
  }
}
