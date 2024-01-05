import 'package:flutter/material.dart';
import 'package:crackuplib/crackuplib.dart';
import 'dart:math';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final CrackUp crackUp = CrackUp();
final Random random = Random();

class CrackUpWrapper {
  static final CrackUpWrapper _singleton = CrackUpWrapper._internal();

  factory CrackUpWrapper() {
    return _singleton;
  }

  CrackUpWrapper._internal();

  ValueNotifier<bool> fullListOfCategoriesNotifier = ValueNotifier(false);
  ValueNotifier<Map<String, List<Joke>>> jokesNotifier = ValueNotifier({});
  ValueNotifier<String> categoryNotifier = ValueNotifier("concrete");
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  ValueNotifier<List<String>> categoryListNotifier = ValueNotifier([]);
  ValueNotifier<PackageInfo> packageInfo = ValueNotifier(PackageInfo(
    appName: "Unknown",
    packageName: "Unknown",
    version: "Unknown",
    buildNumber: "Unknown",
  ));

  final List<String> customCategories = [
    "asphalt",
    "concrete",
    "cement",
    "pavement",
    "rebar",
  ];

  /// Gets initial category list from the website and preloads jokes from [customCategories]
  Future<void> initializeData() async {
    await crackUp.initCrackUp(customCategories);
    for (String category in customCategories) {
      await crackUp.getJokesFromCategory(category);
    }
    packageInfo.value = await PackageInfo.fromPlatform();
    jokesNotifier.value = crackUp.getJokeMap();
    categoryListNotifier.value = crackUp.getCategoryList();
    // checking if we got categories from the website
    if (categoryListNotifier.value.length > customCategories.length) {
      fullListOfCategoriesNotifier.value = true;
    }
  }

  /// Changes the category to a random one when called
  void changeCategory() async {
    isLoadingNotifier.value = true;
    // gets categories from the website if it fails during app start up
    if (!fullListOfCategoriesNotifier.value) {
      await initializeData();
    }
    String category = getRandomCategory();
    while (categoryNotifier.value == category) {
      category = getRandomCategory();
    }
    categoryNotifier.value = category;
    await crackUp.getJokesFromCategory(category);
    jokesNotifier.value = crackUp.getJokeMap();
    isLoadingNotifier.value = false;
  }

  /// Gets random category from the list of categories
  String getRandomCategory() {
    List<String> categories = crackUp.getCategoryList();
    String category = categories[random.nextInt(categories.length)];
    return category;
  }

  /// save data to shared preferences used for storing url, statistics and settings
  Future<void> saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// get data from shared preferences used for storing url, statistics and settings
  Future<String?> readData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}

class NotifyTheme {
  // Private constructor to prevent external instantiation
  NotifyTheme._();

  static final NotifyTheme _instance = NotifyTheme._();

  factory NotifyTheme() {
    return _instance;
  }

  ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  // Method to update the theme mode and notify listeners.
  void setTheme(ThemeMode mode) {
    themeNotifier.value = mode;
  }
}
