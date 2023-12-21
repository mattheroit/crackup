import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:crackuplib/crackuplib.dart';

import '/components/drawer.dart';
import '/wrapper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CrackUpWrapper crackUpWrapper = CrackUpWrapper();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const MainDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Crack Up"),
        actions: [
          // Change category button
          ValueListenableBuilder(
            valueListenable: crackUpWrapper.isLoadingNotifier,
            builder: (context, isLoading, child) {
              return IconButton(
                onPressed:
                    isLoading ? null : () => crackUpWrapper.changeCategory(),
                icon: const Icon(
                  Icons.refresh_rounded,
                  weight: 5,
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
              valueListenable: crackUpWrapper.jokesNotifier,
              builder: (context, value, child) {
                String category = crackUpWrapper.categoryNotifier.value;

                // null-check
                if (crackUpWrapper.jokesNotifier.value[category] != null) {
                  int numOfJokes =
                      crackUpWrapper.jokesNotifier.value[category]!.length;
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
      body: ValueListenableBuilder(
        valueListenable: crackUpWrapper.jokesNotifier,
        builder: (ctx, jokes, child) {
          // null-check
          if (jokes[crackUpWrapper.categoryNotifier.value] != null) {
            if (jokes[crackUpWrapper.categoryNotifier.value]!.isNotEmpty) {
              return PageView.builder(
                itemCount: jokes[crackUpWrapper.categoryNotifier.value]!.length,
                itemBuilder: (context, i) {
                  Joke joke = jokes[crackUpWrapper.categoryNotifier.value]!
                      .elementAt(i);
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
              String line =
                  zeroJokesMessages[random.nextInt(zeroJokesMessages.length)];
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
