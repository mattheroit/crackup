import 'package:flutter/material.dart';
import 'package:crackuplib/crackuplib.dart';
import "dart:math";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CrackUp crackUp = CrackUp();
  final Random random = Random();

  final List<String> customCategories = [
    "asphalt",
    "concrete",
    "cement",
    "pavement",
    "rebar",
  ];

  ValueNotifier<Map<String, List<Joke>>> jokesNotifier = ValueNotifier({});
  ValueNotifier<String> categoryNotifier = ValueNotifier("concrete");

  /// Gets initial category list from the website and preloads jokes from [customCategories]
  Future<void> _initializeData() async {
    await crackUp.initCrackUp(customCategories);
    for (String category in customCategories) {
      await crackUp.getJokesFromCategory(category);
    }
    jokesNotifier.value = crackUp.getJokeMap();
  }

  /// Changes the category to a random one when called
  void changeCategory() async {
    String category = getRandomCategory();
    while (categoryNotifier.value == category) {
      category = getRandomCategory();
    }
    categoryNotifier.value = category;
    await crackUp.getJokesFromCategory(category);
    jokesNotifier.value = crackUp.getJokeMap();
  }

  /// Gets random category from the list of categories
  String getRandomCategory() {
    List<String> categories = crackUp.getCategoryList();
    var category = categories[random.nextInt(categories.length)];
    return category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Crack Up"),
        actions: [
          IconButton(
            onPressed: () => changeCategory(),
            icon: const Icon(
              Icons.refresh_rounded,
              weight: 5,
              size: 30,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initializeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ValueListenableBuilder(
              valueListenable: jokesNotifier,
              builder: (ctx, jokes, child) {
                return PageView.builder(
                  itemCount: jokes[categoryNotifier.value]!.length,
                  itemBuilder: (context, i) {
                    Joke joke = jokes[categoryNotifier.value]!.elementAt(i);
                    return Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.sizeOf(context).height * 0.3,
                      ),
                      child: ListTile(
                        title: Text(joke.title),
                        subtitle: Text(joke.body),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
