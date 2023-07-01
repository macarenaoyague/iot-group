import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iot/ui/historic.dart';
import 'package:iot/ui/home.dart';
import 'package:iot/ui/resume.dart';
import 'package:iot/ui/sharing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/mongodb.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.instance.registerSingleton<MongoDB>(MongoDB());
  GetIt.instance.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance());
  runApp(const AppState());
}

class AppState extends StatefulWidget {
  const AppState({super.key});

  @override
  State<AppState> createState() => _AppStateState();
}

class _AppStateState extends State<AppState> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emi',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        'home': (_) => HomePage(),
        'sharing': (_) => SharingPage(),
        'resume': (_) => ResumePage(),
        'historic': (_) => HistoricPage(),
      },
      home: HomePage(),
    );
  }
}
