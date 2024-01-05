import 'package:crackup/consts.dart';
import 'package:crackup/main.dart';
import 'package:crackup/wrapper.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final ValueNotifier<String> themeNotifier = ValueNotifier<String>("0");

  Future<void> setSettings() async {
    String? themeString = await crackUpWrapper.readData(consts.prefs.theme);
    if (themeString == null || themeString == '') {
      themeNotifier.value = "0";
    } else {
      themeNotifier.value = themeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: FutureBuilder(
        future: setSettings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(children: [_graphics()]),
              ),
            );
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }

  Padding _graphics() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Appearance'),
          ),
          const Divider(),
          ValueListenableBuilder(
            valueListenable: themeNotifier,
            builder: (context, value, child) {
              return ListTile(
                title: SegmentedButton<String>(
                  showSelectedIcon: false,
                  selected: <String>{value},
                  onSelectionChanged: (Set<String> newSelection) {
                    themeNotifier.value = newSelection.first;
                    switch (newSelection.first) {
                      case "2":
                        crackUpWrapper.saveData(consts.prefs.theme, "2");
                        NotifyTheme().setTheme(ThemeMode.dark);
                        break;
                      case "1":
                        crackUpWrapper.saveData(consts.prefs.theme, "1");
                        NotifyTheme().setTheme(ThemeMode.light);
                        break;
                      default:
                        crackUpWrapper.saveData(consts.prefs.theme, "0");
                        NotifyTheme().setTheme(ThemeMode.system);
                    }
                  },
                  segments: const [
                    ButtonSegment<String>(
                      value: "0",
                      label: Text("System"),
                      enabled: true,
                    ),
                    ButtonSegment<String>(
                      value: "1",
                      label: Text("Light"),
                    ),
                    ButtonSegment<String>(
                      value: "2",
                      label: Text("Dark"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
