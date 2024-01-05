import 'package:crackup/consts.dart';
import 'package:crackup/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/wrapper.dart';

CrackUpWrapper crackUpWrapper = CrackUpWrapper();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await crackUpWrapper.initializeData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Ensure the status bar is always visible
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

    return FutureBuilder(
      future: crackUpWrapper.readData(consts.prefs.theme),
      initialData: ThemeMode.system,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          switch (snapshot.data) {
            case "2":
              NotifyTheme().setTheme(ThemeMode.dark);
              break;
            case "1":
              NotifyTheme().setTheme(ThemeMode.light);
              break;
            default:
              NotifyTheme().setTheme(ThemeMode.system);
          }
        }

        return ValueListenableBuilder(
          valueListenable: NotifyTheme().themeNotifier,
          builder: (context, themeMode, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              //debugShowMaterialGrid: true,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: themeMode,
              home: const HomePage(),
            );
          },
        );
      },
    );
  }
}
