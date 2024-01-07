import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// pages
import './pages.dart';

// colors
import '../utils/constants/colors/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future _future;

  // images list to show while the home data is loading
  final List<String> images = [
    'assets/images/pokemon/raticate.png',
    'assets/images/pokemon/charizard.png',
    'assets/images/pokemon/bulbasaur.png',
    'assets/images/pokemon/pikachu.png',
  ];

  // active image index
  int activeImageIndex = 0;

  // state of whether the data is loading or not
  late bool isLoading;

  // to hold the Timer reference that will be used to change the images
  late Timer timer;

  @override
  void initState() {
    super.initState();

    // initializing stuff
    initialize();
  }

  @override
  void dispose() {
    super.dispose();

    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isLoading ? const Color(0xFF2F2F2F) : null,
      body: SafeArea(
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            // if loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(images[activeImageIndex]),
                    const SizedBox(
                      height: 10,
                    ),
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ],
                ),
              );
            }

            // setting up the state
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              setState(() {
                isLoading = false;
              });
            });

            // if there is an error
            if (snapshot.hasError) {
              return _buildErrorWidget();
            }

            // grabbing the data
            final Map body = jsonDecode(snapshot.data.body);

            // grabbing the results
            final List results = body['results'];

            return PageView(
              scrollDirection: Axis.vertical,
              children: results
                  .asMap()
                  .keys
                  .map(
                    (index) => PokemonDetailsPage(
                      results[index]['url'],
                      totalPokemon: results.length,
                      currentPokemon: index + 1,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  // method to initialize data
  void initialize() {
    // setting is loading to true
    isLoading = true;

    // future to get all the pokemon
    _future = http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=100000&offset=0'));

    // setting up a periodic timer for some time that changes the image
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // if it is no longer loading, then cancel the timer
      if (!isLoading) {
        timer.cancel();
      }

      // getting the new image
      setState(() {
        activeImageIndex = (activeImageIndex + 1) % images.length;
      });
    });
  }

  SizedBox _buildErrorWidget() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('An error occurred!'),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              // initializing the data again
              setState(() {
                initialize();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: kLightBlackColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                'Reload',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
