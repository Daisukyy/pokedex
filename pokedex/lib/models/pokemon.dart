/// Modelo de dominio para un Pokémon de PokeAPI.
class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.imageUrl,
  });
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> types;
  final List<String> abilities;
  final Map<String, int> stats;
  final String imageUrl;

  /// Convierte la respuesta JSON de PokeAPI en un objeto de nuestra app.
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = (json['sprites'] as Map<String, dynamic>?) ?? {};
    final other = (sprites['other'] as Map<String, dynamic>?) ?? {};
    final artwork = (other['official-artwork'] as Map<String, dynamic>?) ?? {};
    return Pokemon(
      id: json['id'] as int,
      name: _titleCase(json['name'] as String),
      height: json['height'] as int,
      weight: json['weight'] as int,
      types: (json['types'] as List<dynamic>)
          .map((item) => _titleCase(item['type']['name'] as String))
          .toList(),
      abilities: (json['abilities'] as List<dynamic>)
          .map((item) => _titleCase(item['ability']['name'] as String))
          .toList(),
      stats: {
        for (final item in (json['stats'] as List<dynamic>))
          _statName(item['stat']['name'] as String): item['base_stat'] as int,
      },
      imageUrl:
          artwork['front_default'] as String? ??
          (sprites['front_default'] as String? ?? ''),
    );
  }

  static String _titleCase(String value) => value
      .split('-')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
  static String _statName(String value) {
    const names = {
      'hp': 'HP',
      'attack': 'Ataque',
      'defense': 'Defensa',
      'special-attack': 'At. especial',
      'special-defense': 'Def. especial',
      'speed': 'Velocidad',
    };
    return names[value] ?? _titleCase(value);
  }
}

/// Modelo ligero para la cuadrícula. La imagen se construye con el ID oficial
/// para no pedir los 151 detalles al abrir la pantalla principal.
class PokemonListItem {
  const PokemonListItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
  });

  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  /// Convierte una entrada de /pokemon?limit=... en un elemento de lista.
  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String? ?? '';
    final match = RegExp(r'/pokemon/(\d+)/?$').firstMatch(url);
    final id = int.tryParse(match?.group(1) ?? '') ?? 0;
    return PokemonListItem(
      id: id,
      name: json['name'] as String? ?? '',
      imageUrl: officialArtworkUrl(id),
    );
  }

  PokemonListItem copyWith({List<String>? types}) => PokemonListItem(
    id: id,
    name: name,
    imageUrl: imageUrl,
    types: types ?? this.types,
  );

  static String officialArtworkUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}
