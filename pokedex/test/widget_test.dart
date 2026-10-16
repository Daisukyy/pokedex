import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/models/pokemon.dart';

void main() {
  test('Pokemon.fromJson transforma los datos principales', () {
    final pokemon = Pokemon.fromJson({
      'id': 1,
      'name': 'bulbasaur',
      'height': 7,
      'weight': 69,
      'types': [
        {
          'type': {'name': 'grass'},
        },
      ],
      'abilities': [
        {
          'ability': {'name': 'overgrow'},
        },
      ],
      'stats': [
        {
          'base_stat': 45,
          'stat': {'name': 'hp'},
        },
      ],
      'sprites': {
        'front_default': 'fallback.png',
        'other': {
          'official-artwork': {'front_default': 'official.png'},
        },
      },
    });

    expect(pokemon.name, 'Bulbasaur');
    expect(pokemon.types, ['Grass']);
    expect(pokemon.abilities, ['Overgrow']);
    expect(pokemon.stats['HP'], 45);
    expect(pokemon.imageUrl, 'official.png');
  });
}
