import 'package:crackup/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:crackuplib/crackuplib.dart';

class MainDrawer extends StatelessWidget {
  MainDrawer({super.key});
  final CrackUp crackUp = CrackUp();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Builder(
              builder: (context) {
                int numOfCategories = crackUp.getCategoryList().length;
                return ListTile(
                  title: Text("Categories available: $numOfCategories"),
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
