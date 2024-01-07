import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;

// functions
import '../utils/functions/functions.dart';

// colors
import '../utils/constants/colors/colors.dart';

// enums
import '../utils/enums/enums.dart';

class PokemonDetailsPage extends StatefulWidget {
  const PokemonDetailsPage(
    this.url, {
    super.key,
    required this.currentPokemon,
    required this.totalPokemon,
  });

  final String url;
  final int currentPokemon;
  final int totalPokemon;

  @override
  State<PokemonDetailsPage> createState() => _PokemonDetailsPageState();
}

class _PokemonDetailsPageState extends State<PokemonDetailsPage> {
  late Future _future;

  @override
  void initState() {
    super.initState();

    // future to load the details of a pokemon
    _future = http.get(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        // if loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return PokemonDetailsPageShimmer(
            currentPokemon: widget.currentPokemon,
            totalPokemon: widget.totalPokemon,
          );
        }

        // if there is an error
        if (snapshot.hasError) {
          return _buildErrorWidget();
        }

        // grabbing the data
        final Map data = jsonDecode(snapshot.data.body);

        // grabbing the fields we need
        final String image =
            data['sprites']['other']['official-artwork']['front_default'];
        final List stats = data['stats'];
        final String name = data['species']['name'];
        final List types = (data['types'] as List)
            .map((type) => getCapitalizedString(type['type']['name']))
            .toList();
        final int baseXp = data['base_experience'];

        // grabbing the colors as per the first type
        final color = pokemonTypeColors[getPokemonTypeEnum(types[0])];

        return Container(
          color: color!.withOpacity(.2),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                getCapitalizedString(name),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: max(100, MediaQuery.of(context).size.width * .25),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatColumn(
                            title: 'HP',
                            value: stats[0]['base_stat'].toString(),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          _buildStatColumn(
                            title: 'ATK',
                            value: stats[1]['base_stat'].toString(),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          _buildStatColumn(
                            title: 'DEF',
                            value: stats[2]['base_stat'].toString(),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          _buildStatColumn(
                            title: 'SP. ATK.',
                            value: stats[3]['base_stat'].toString(),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          _buildStatColumn(
                            title: 'SP. DEF.',
                            value: stats[4]['base_stat'].toString(),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          _buildStatColumn(
                            title: 'SPEED',
                            value: stats[5]['base_stat'].toString(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Image.network(image),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'Base XP',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            baseXp.toString(),
                            style: const TextStyle(
                              fontSize: 70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(types.join(', ')),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                '${widget.currentPokemon}/${widget.totalPokemon}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                Icons.arrow_downward,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Column _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('An error occurred!'),
        Text('${widget.currentPokemon}/${widget.totalPokemon}'),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            // reassigning future
            setState(() {
              _future = http.get(Uri.parse(widget.url));
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
    );
  }

  Column _buildStatColumn({
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          height: 35,
          width: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// function to get the pokemon type enum from string
PokemonType getPokemonTypeEnum(String type) {
  switch (type.toLowerCase()) {
    case 'normal':
      return PokemonType.normal;
    case 'fire':
      return PokemonType.fire;
    case 'water':
      return PokemonType.water;
    case 'electric':
      return PokemonType.electric;
    case 'grass':
      return PokemonType.grass;
    case 'ice':
      return PokemonType.ice;
    case 'fighting':
      return PokemonType.fighting;
    case 'poison':
      return PokemonType.poison;
    case 'ground':
      return PokemonType.ground;
    case 'flying':
      return PokemonType.flying;
    case 'psychic':
      return PokemonType.psychic;
    case 'bug':
      return PokemonType.bug;
    case 'rock':
      return PokemonType.rock;
    case 'ghost':
      return PokemonType.ghost;
    case 'dragon':
      return PokemonType.dragon;
    case 'dark':
      return PokemonType.dark;
    case 'steel':
      return PokemonType.steel;
    case 'fairy':
      return PokemonType.fairy;
    default:
      return PokemonType.normal;
  }
}

// details page shimmer
class PokemonDetailsPageShimmer extends StatelessWidget {
  const PokemonDetailsPageShimmer({
    super.key,
    required this.currentPokemon,
    required this.totalPokemon,
  });

  final int currentPokemon;
  final int totalPokemon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: kLightBlackColor.withOpacity(.2),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: max(100, MediaQuery.of(context).size.width * .25),
                      decoration: const BoxDecoration(
                        color: kLightBlackColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$currentPokemon/$totalPokemon',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                Icons.arrow_downward,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: kLightBlackColor.withOpacity(.7),
        ).animate(onComplete: (controller) => controller.repeat()).shimmer(
              duration: 500.ms,
              delay: 800.ms,
            ),
      ],
    );
  }
}
