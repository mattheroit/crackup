import 'package:flutter/material.dart';
import 'package:crackuplib/crackuplib.dart';
import "dart:math";
import 'package:material_symbols_icons/symbols.dart';

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
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

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
          // Change category button
          ValueListenableBuilder(
            valueListenable: isLoadingNotifier,
            builder: (context, isLoading, child) {
              return IconButton(
                onPressed: isLoading ? null : () => changeCategory(),
                icon: const Icon(
                  Icons.refresh_rounded,
                  weight: 5,
                  size: 30,
                ),
              );
            },
          ),
        ],
        // Category name & number of jokes
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ValueListenableBuilder(
              valueListenable: jokesNotifier,
              builder: (context, value, child) {
                String category = categoryNotifier.value;

                // null-check
                if (jokesNotifier.value[category] != null) {
                  int numOfJokes = jokesNotifier.value[category]!.length;
                  category = category.toUpperCase();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Number of jokes: $numOfJokes"),
                      Text("Category: $category"),
                    ],
                  );
                } else {
                  return const Row(children: [Text("")]);
                }
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _initializeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ValueListenableBuilder(
              valueListenable: jokesNotifier,
              builder: (ctx, jokes, child) {
                // null-check
                if (jokes[categoryNotifier.value] != null) {
                  return PageView.builder(
                    itemCount: jokes[categoryNotifier.value]!.length,
                    itemBuilder: (context, i) {
                      Joke joke = jokes[categoryNotifier.value]!.elementAt(i);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ListTile(
                            title: Text(joke.title),
                            subtitle: Text(joke.body),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  return noJokesPageContent(context);
                }
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

  Padding noJokesPageContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width * 0.1),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Icon(
                Symbols.sentiment_sad,
                size: 250,
                color: Colors.grey,
              ),
              Text(
                "Why did the jokes fail to load?",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Bad connection – the bits and giggles got stuck in the cloud!",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(),
        ],
      ),
    );
  }
}
