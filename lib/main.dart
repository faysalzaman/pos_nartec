import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/cubit/auth/auth_cubit.dart';
import 'package:pos/screens/login/login_screen.dart';
import 'package:flutter/services.dart';
import 'package:pos/utils/app_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock orientation for phones, allow rotation for tablets
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          // appbar text and icons will be white
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(color: Colors.white),
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        builder: (context, child) {
          // Check if device is a tablet (based on screen width)
          final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

          if (!isTablet) {
            // Lock to portrait for phones
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
          }
          return child!;
        },
        home: const LoginScreen(),
      ),
    );
  }
}
