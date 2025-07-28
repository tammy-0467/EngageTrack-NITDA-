import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gam_project/screen/home_page.dart';
import 'package:gam_project/screen/leader_board_page.dart';
import 'package:gam_project/screen/login_page.dart';
import 'package:gam_project/screen/profile_page.dart';
import 'package:gam_project/screen/registration_page.dart';
import 'package:gam_project/screen/settings.dart';
import 'package:gam_project/screen/spash_screen.dart';
import 'package:gam_project/screen/task_list.dart';
import 'package:gam_project/services/auth_gate.dart';
import 'package:gam_project/services/storage/storage_service.dart';
import 'package:gam_project/theme/theme_provider.dart';
import 'package:flutter/services.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('task_box');

  await Firebase.initializeApp(
      options: FirebaseOptions(
           storageBucket: 'gamifiedeeps.appspot.com',
           apiKey: 'AIzaSyDHXmjh2xa4TGq7tDvzInP4O_6KPdL2hyE',
           appId: '1:514457677887:android:f8d82ca635841c0b90888a',
           messagingSenderId: '514457677887',
           projectId: 'gamifiedeeps'

         // storageBucket: 'gamification-22e17.appspot.com',
         // apiKey: 'AIzaSyAMbIak29e9DYRylOBMw_dsAHXCMhrxKFM',
         // appId: '1:398402472523:android:4169fd7e5750177ac71bce',
         // messagingSenderId: '398402472523',
         // projectId: 'gamification-22e17'
          ));
  // final fcmToken = await FirebaseMessaging.instance.getToken();
  //print('my token is: ${fcmToken}');

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((ftn){
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context)=> ThemeProvider()),
          ChangeNotifierProvider(create: (context)=> StorageService())
        ],
        child: const MyApp(),
      ),
    );
  });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: Provider.of<ThemeProvider>(context).themeData,
      /*ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),*/
      home: SplashScreen(child: AuthGate()),
      routes: {
        '/dashboard': (context) => HomePage(
              userRole: 'CEO',
            ),
        '/login': (context) => LoginPage(),
        '/reg': (context) => RegistrationPage(),
        '/leaderboard': (context) => LeaderBoardPage(),
        '/profile': (context)=> ProfilePage(),
        '/task': (context)=> TaskScreen(),
        '/settings': (context)=> SettingsPage(),
        //'/tasks': (context) => TaskListScreen(),
        //   '/scores': (context) => PerformanceScoresScreen(),
        //  '/leaderboards': (context) => LeaderboardsScreen(),
        //  '/rewards': (context) => RewardsScreen(),
        //  '/profile': (context) => ProfileSettingsScreen(),
      },
    );
  }
}
