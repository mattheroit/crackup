import 'package:flutter/material.dart';
import 'package:crackuplib/crackuplib.dart';
import 'dart:math';

import 'package:package_info_plus/package_info_plus.dart';

final CrackUp crackUp = CrackUp();
final Random random = Random();

class CrackUpWrapper {
  static final CrackUpWrapper _singleton = CrackUpWrapper._internal();

  factory CrackUpWrapper() {
    return _singleton;
  }

  CrackUpWrapper._internal();

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
  }

  /// Changes the category to a random one when called
  void changeCategory() async {
    isLoadingNotifier.value = true;
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
}
