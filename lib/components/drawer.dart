import 'package:crackup/pages/settings.dart';
import 'package:flutter/material.dart';

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
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: "Crack Up",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "© 2023 Matěj Verhaegen",
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
