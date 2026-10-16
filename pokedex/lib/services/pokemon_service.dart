import 'package:dio/dio.dart';

import '../models/pokemon.dart';

/// Servicio responsable únicamente de hablar con PokeAPI.
class PokemonService {
  PokemonService({Dio? dio})
    : _dio =
          dio ??
                Dio(
                  BaseOptions(
                    baseUrl: 'https://pokeapi.co/api/v2',
                    connectTimeout: const Duration(seconds: 10),
                    receiveTimeout: const Duration(seconds: 10),
                    sendTimeout: const Duration(seconds: 10),
                  ),
                )
            ..interceptors.add(
              LogInterceptor(requestBody: false, responseBody: false),
            );
  final Dio _dio;

  /// Hace la petición dinámica a /pokemon/{id}/ usando async/await.
  Future<Pokemon> getPokemon(String idOrName) async {
    try {
      final response = await _dio.get('/pokemon/${idOrName.toLowerCase()}/');
      return Pokemon.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      // La pantalla transforma esta excepción en un mensaje tierno.
      rethrow;
    }
  }

  /// Obtiene el catálogo ligero de una generación sin descargar 151 detalles.
  Future<List<PokemonListItem>> getPokemonList({
    int offset = 0,
    int limit = 151,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/pokemon',
      queryParameters: {'offset': offset, 'limit': limit},
    );
    final results = (response.data?['results'] as List<dynamic>? ?? []);
    return results
        .map((item) => PokemonListItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Consulta un tipo completo. Se usa para filtrar sin pedir Pokémon uno a uno.
  Future<Set<int>> getPokemonIdsByType(String type) async {
    final response = await _dio.get<Map<String, dynamic>>('/type/$type');
    final entries = (response.data?['pokemon'] as List<dynamic>? ?? []);
    return entries
        .map((item) => item['pokemon']['url'] as String)
        .map(
          (url) => int.tryParse(
            RegExp(r'/pokemon/(\d+)/?$').firstMatch(url)?.group(1) ?? '',
          ),
        )
        .whereType<int>()
        .toSet();
  }
}
