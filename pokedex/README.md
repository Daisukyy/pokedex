# Pokédex

Aplicación Flutter que consulta datos reales de [PokeAPI](https://pokeapi.co/) y conserva una implementación clara de Dio, `Future` y `Pokemon.fromJson`.

## Fase 1 completada

- Splash de bienvenida de 2 segundos con movimiento de Pokébola.
- Catálogo completo de la generación 1 (1–151) y selector Gen 1 a Gen 5.
- Cuadrícula responsiva con imagen oficial directa, número, nombre y tipos.
- Búsqueda en tiempo real por nombre o número con debounce de 300 ms.
- Filtro múltiple por los 18 tipos mediante `https://pokeapi.co/api/v2/type/{tipo}`.
- Navegación inferior: Inicio, Tipos, Favoritos y Azar.
- Detalle básico al tocar una tarjeta, con Hero y transición fade + slide + escala.
- Pull-to-refresh, shimmer de imágenes, errores con reintento y estado vacío.
- Fondo animado de pétalos y paleta pastel.

## Paquetes

`dio`, `provider`, `google_fonts`, `cached_network_image`, `shimmer`, `flutter_animate`, `shared_preferences`, `audioplayers` y `fl_chart`.

## Ejecutar

Desde `pokedex/`:

```bash
flutter pub get
flutter run
```

Para web o Windows: `flutter run -d chrome` o `flutter run -d windows`.

## Organización

- `lib/models/pokemon.dart`: modelos `Pokemon` y `PokemonListItem`, con `fromJson` comentado en español.
- `lib/services/pokemon_service.dart`: único `PokemonService` con Dio, BaseOptions, timeouts, interceptor y peticiones Future.
- `lib/screens/home_screen.dart`: catálogo, búsqueda, filtros, tipos, navegación y detalle de Fase 1.
- `lib/widgets/`: tarjetas, chips, stats y pétalos.
- `lib/theme/app_theme.dart`: colores, Material 3 y tipografías.

## Capturas descritas

- Inicio: cuadrícula pastel con los 151 Pokémon de la primera generación.
- Tipos: tarjetas grandes para seleccionar cualquiera de los 18 tipos.
- Detalle: imagen oficial ampliada, nombre, tipos, altura, peso y habilidades.
