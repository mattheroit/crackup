import 'package:crackup/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

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
      categoriesAvailable = crackUpWrapper.categoryListNotifier.value.length.toString();
      currentCategory = crackUpWrapper.categoryNotifier.value;
      numberOfJokes = crackUpWrapper.jokesNotifier.value[currentCategory]?.length.toString() ?? "N/A";

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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Categories available: ${info[0]}"),
                        Text("Current category: ${info[1]}"),
                        Text("Number of Jokes: ${info[2]}"),
                      ],
                    ),
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
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: crackUpWrapper.packageInfo,
                builder: (context, packageInfo, child) {
                  String year = DateTime.now().year.toString();
                  return AboutListTile(
                    icon: const Icon(Icons.info_outline_rounded),
                    applicationName: packageInfo.appName,
                    applicationVersion: packageInfo.version,
                    applicationLegalese: "© $year Matěj Verhaegen",
                    aboutBoxChildren: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: ElevatedButton(
                          onPressed: () => launchUrl(
                              Uri.parse(
                                "https://github.com/mattheroit/crackup",
                              ),
                              mode: LaunchMode.externalApplication),
                          child: const Text("Source code"),
                        ),
                      ),
                    ],
                  );
                },
              ),
              ListTile(
                title: const Text('Sdílet Aplikaci'),
                leading: const Icon(Icons.share),
                onTap: () async {
                  final RenderBox? box = context.findRenderObject() as RenderBox?;
                  String text = 'https://github.com/mattheroit/crackup/releases/latest';
                  String subject = 'Crack Up (the joke app)';
                  await Share.share(
                    text,
                    subject: subject,
                    sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
