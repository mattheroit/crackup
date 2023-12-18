import 'package:crackup/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key, required this.numOfCategories});
  final int numOfCategories;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Builder(
              builder: (context) {
                return ListTile(
                  title: Text(
                    "Categories available: ${numOfCategories.toString()}",
                  ),
                );
              },
            ),
          ),
          ListBody(
            children: [
              ListTile(
                title: const Text("Settings"),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ),
              ),
              ListTile(
                title: const Text("About App"),
                onTap: () async {
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  String year = DateTime.now().year.toString();
                  if (!context.mounted) return;
                  showAboutDialog(
                    context: context,
                    applicationName: packageInfo.appName,
                    applicationVersion: packageInfo.version,
                    applicationLegalese: "© $year Matěj Verhaegen",
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
