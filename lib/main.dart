import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/cubit/auth/auth_cubit.dart';
import 'package:pos/cubit/sales/sales_cubit.dart';
import 'package:flutter/services.dart';
import 'package:pos/screens/main_dashboard/main_dashboard_screen.dart';
import 'package:pos/utils/app_preferences.dart';
import 'package:pos/cubit/category/category_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock orientation to landscape by default
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await AppPreferences.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => SalesCubit()),
        BlocProvider(create: (context) => CategoryCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(color: Colors.white),
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        builder: (context, child) {
          // Check if the device is a tablet
          final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

          if (isTablet) {
            // Allow rotation for tablets
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
          }
          return child!;
        },
        home: const MainDashboardScreen(),
      ),
    );
  }
}
