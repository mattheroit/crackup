import 'package:flutter/material.dart';
import 'package:crackuplib/crackuplib.dart';
import "dart:math";
import 'package:material_symbols_icons/symbols.dart';
import '/components/drawer.dart';

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

  final List<String> zeroJokesMessages = [
    "This category's jokes took a vacation – maybe they're off to find some humor!",
    "Uh-oh, this category is drier than a desert when it comes to jokes! Must be on a laughter diet.",
    "Uh-oh, this category is drier than a desert without a punchline oasis. Time to spice it up or call in the comedy rescue squad!",
    "Category so dry, even the crickets left. Paging the joke hydrant!",
    "Category so empty, even the crickets left. Time to recruit a joke DJ!",
    "Oops! This category's jokes took a vacation. They must be on a comedy cruise, leaving us in a sea of silence...",
    "Looks like our concrete joke mixer is on a lunch break – probably enjoying some solid humor with a side of gravel.",
    "Looks like the jokes decided to set themselves in stone for a moment. They're probably having a solid meeting about improving their mix of humor.",
    "This category is so exclusive; even the jokes need a VIP pass to get in!",
    "We checked under the joke couch, but all we found were lost coins and a remote. No jokes.",
    "Breaking news: This category has declared a temporary joke shortage. Experts suspect it's due to an unexpected outbreak of seriousness. Stand by for further pun-formation.",
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
    String category = categories[random.nextInt(categories.length)];
    return category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: MainDrawer(numOfCategories: crackUp.getCategoryList().length),
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
                  // We do this so that oeverything stays the same
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
                  if (jokes[categoryNotifier.value]!.isNotEmpty) {
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
                    String line = zeroJokesMessages[
                        random.nextInt(zeroJokesMessages.length)];
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.sizeOf(context).width * 0.1,
                        ),
                        child: Text(
                          line,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
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

  /// Content that displays when no jokes are provided
  Padding noJokesPageContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.1,
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
