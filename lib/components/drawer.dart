import 'package:crackup/pages/settings.dart';
import 'package:flutter/material.dart';
import '/wrapper.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final CrackUpWrapper crackUpWrapper = CrackUpWrapper();
  final ValueNotifier<List<String>> infoNotifier = ValueNotifier([]);

  String categoriesAvailable = "N/A";
  String currentCategory = "N/A";
  String numberOfJokes = "N/A";

  void checkLoadingStatus() {
    if (!crackUpWrapper.isLoadingNotifier.value) {
      // Loading is complete, update the data
      categoriesAvailable =
          crackUpWrapper.categoryListNotifier.value.length.toString();
      currentCategory = crackUpWrapper.categoryNotifier.value;
      numberOfJokes = crackUpWrapper
          .jokesNotifier.value[currentCategory]!.length
          .toString();

      infoNotifier.value = [
        categoriesAvailable,
        currentCategory.toUpperCase(),
        numberOfJokes,
      ];
    } else {
      // Schedule another callback to check loading status after 50 milliseconds
      Future.delayed(const Duration(milliseconds: 50), () {
        checkLoadingStatus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    checkLoadingStatus();

    infoNotifier.value = [
      categoriesAvailable,
      currentCategory.toUpperCase(),
      numberOfJokes,
    ];

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: ValueListenableBuilder(
              valueListenable: infoNotifier,
              builder: (context, info, child) {
                return SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.65,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        "Categories available: ${info[0]}",
                      ),
                      const SizedBox(height: 20),
                      Text("Current category: ${info[1]}"),
                      Text("Number of Jokes: ${info[2]}"),
                    ],
                  ),
                );
              },
            ),
          ),
          ListBody(
            children: [
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ),
              ),
              ValueListenableBuilder(
                  valueListenable: crackUpWrapper.packageInfo,
                  builder: (context, packageInfo, child) {
                    return ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: const Text("About App"),
                      onTap: () {
                        String year = DateTime.now().year.toString();
                        if (!context.mounted) return;
                        showAboutDialog(
                          context: context,
                          applicationName: packageInfo.appName,
                          applicationVersion: packageInfo.version,
                          applicationLegalese: "© $year Matěj Verhaegen",
                        );
                      },
                    );
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
