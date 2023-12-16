import 'package:flutter/material.dart';
import 'package:crackuplib/crackuplib.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CrackUp crackUp = CrackUp();

  final List<String> customCategories = [
    "asphalt",
    "concrete",
    "cement",
    "pavement",
    "rebar",
  ];

  late ValueNotifier<Map<String, List<Joke>>> jokesNotifier =
      ValueNotifier<Map<String, List<Joke>>>({});

  Future<void> _initializeData() async {
    await crackUp.initCrackUp(customCategories);
    for (String category in customCategories) {
      await crackUp.getJokesFromCategory(category);
    }
    if (mounted) {
      jokesNotifier.value = crackUp.getJokeMap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Crack Up"),
      ),
      body: FutureBuilder(
        future: _initializeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ValueListenableBuilder(
              valueListenable: jokesNotifier,
              builder: (ctx, jokes, child) {
                return PageView.builder(
                  itemCount: jokes["concrete"]!.length,
                  itemBuilder: (context, i) {
                    Joke joke = jokes["concrete"]!.elementAt(i);
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
