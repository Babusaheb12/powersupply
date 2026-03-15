import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'Api/shared_preference.dart';
import 'Screen/Auth/login/Bloc/login/login_bloc.dart';
import 'Screen/Auth/login/login.dart';
import 'Screen/Dashbord/Dashboard/Dashboard.dart';
import 'Screen/Dashbord/meterReading/Bloc/addmeterReading/addmeter_reading_bloc.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Prefs.initPrefs();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final isLoggedIn = Prefs.isLoggedIn;

    return MultiBlocProvider(

      providers: [

        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(create: (_) => AddmeterReadingBloc()),


      ],

      child: MaterialApp(
        title: 'Power Supply',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        ),

        home: isLoggedIn ? DashboardPage() : MyloginPage(),
      ),
    );
  }
}