import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/sakura_petals.dart';
import '../widgets/stat_bar.dart';
import '../widgets/type_chip.dart';

const _types = <String, String>{
  'normal': 'Normal',
  'fire': 'Fuego',
  'water': 'Agua',
  'grass': 'Planta',
  'electric': 'Electrico',
  'ice': 'Hielo',
  'fighting': 'Lucha',
  'poison': 'Veneno',
  'ground': 'Tierra',
  'flying': 'Volador',
  'psychic': 'Psiquico',
  'bug': 'Bicho',
  'rock': 'Roca',
  'ghost': 'Fantasma',
  'dragon': 'Dragon',
  'dark': 'Siniestro',
  'steel': 'Acero',
  'fairy': 'Hada',
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = PokemonService();
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<PokemonListItem> _all = [];
  Set<String> _selectedTypes = {};
  String _query = '';
  int _generation = 1;
  int _tab = 0;
  bool _loading = true;
  String? _error;
  static const _ranges = <int, (int, int)>{
    1: (0, 151),
    2: (151, 100),
    3: (251, 135),
    4: (386, 107),
    5: (493, 156),
  };

  @override
  void initState() {
    super.initState();
    _loadGeneration(1);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGeneration(int generation) async {
    setState(() {
      _loading = true;
      _error = null;
      _generation = generation;
    });
    try {
      final range = _ranges[generation]!;
      final list = await _service.getPokemonList(
        offset: range.$1,
        limit: range.$2,
      );
      final groups = await Future.wait(
        _types.keys.map(_service.getPokemonIdsByType),
      );
      final byId = <int, List<String>>{};
      for (var i = 0; i < groups.length; i++) {
        for (final id in groups[i]) {
          if (list.any((item) => item.id == id)) {
            byId.putIfAbsent(id, () => []).add(_types.values.elementAt(i));
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _all = list
            .map((item) => item.copyWith(types: byId[item.id] ?? const []))
            .toList();
        _loading = false;
      });
    } on DioException {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'No pudimos traer la Pokédex. Revisa tu conexión.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Algo salió mal al preparar la Pokédex.';
        });
      }
    }
  }

  List<PokemonListItem> get _filtered => _all.where((pokemon) {
    final query = _query.toLowerCase();
    final bySearch =
        query.isEmpty ||
        pokemon.name.toLowerCase().contains(query) ||
        pokemon.id.toString() == query;
    final byType =
        _selectedTypes.isEmpty ||
        _selectedTypes.any((type) => pokemon.types.contains(_types[type]));
    return bySearch && byType;
  }).toList();

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => setState(() => _query = value.trim()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.warmWhite,
                    AppTheme.cream,
                    AppTheme.lavender,
                  ],
                ),
              ),
            ),
            const SakuraPetals(),
            SafeArea(
              child: Row(
                children: [
                  if (desktop) _sidebar(),
                  Expanded(
                    child: IndexedStack(
                      index: _tab,
                      children: [
                        _catalog(desktop),
                        _typesScreen(),
                        _simpleScreen(
                          'Favoritos',
                          'Tu colección aparecerá aquí.',
                        ),
                        _randomScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
    bottomNavigationBar: MediaQuery.sizeOf(context).width < 900
        ? _navigationBar()
        : null,
  );

  Widget _sidebar() => Container(
    width: 210,
    margin: const EdgeInsets.fromLTRB(18, 18, 8, 18),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.warmWhite.withAlpha(235),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: [
        BoxShadow(
          color: AppTheme.purple.withAlpha(35),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppTheme.sakura,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Pokédex',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 30),
        _sideItem(Icons.home_rounded, 'Inicio', 0),
        _sideItem(Icons.category_rounded, 'Pokémon', 1),
        _sideItem(Icons.favorite_rounded, 'Favoritos', 2),
        _sideItem(Icons.casino_rounded, 'Descubrir', 3),
        const Spacer(),
        const Divider(),
        _sideItem(Icons.settings_rounded, 'Ajustes', _tab),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.lavender.withAlpha(120),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Tu aventura comienza aquí',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  Widget _sideItem(IconData icon, String label, int index) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: InkWell(
      onTap: () => setState(() => _tab = index),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: _tab == index ? AppTheme.sakura : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: _tab == index ? AppTheme.accent : AppTheme.plum,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: _tab == index ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _catalog(bool desktop) => RefreshIndicator(
    onRefresh: () => _loadGeneration(_generation),
    child: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _header(desktop)),
        if (_loading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          SliverFillRemaining(child: _errorView())
        else if (_filtered.isEmpty)
          SliverFillRemaining(child: _emptyView())
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              desktop ? 28 : 16,
              4,
              desktop ? 28 : 16,
              24,
            ),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final pokemon = _filtered[index];
                return PokemonCard(
                  pokemon: pokemon,
                  onTap: () => _openDetail(pokemon),
                );
              }, childCount: _filtered.length),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _columns(context),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .78,
              ),
            ),
          ),
      ],
    ),
  );

  Widget _header(bool desktop) => Padding(
    padding: EdgeInsets.fromLTRB(desktop ? 28 : 18, 18, desktop ? 28 : 18, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (desktop) _welcomePanel(),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    desktop ? 'Pokémon' : 'Pokédex',
                    style: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const Text(
                    'Explora, captura y descubre algo nuevo.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            const CircleAvatar(
              backgroundColor: AppTheme.peach,
              child: Icon(Icons.person_rounded, size: 19),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: _onSearch,
          decoration: InputDecoration(
            hintText: 'Busca por nombre o número...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? const Icon(Icons.tune_rounded)
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: AppTheme.warmWhite.withAlpha(240),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final generation in _ranges.keys)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('Gen $generation'),
                    selected: generation == _generation,
                    onSelected: (_) => _loadGeneration(generation),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final type in _types.keys)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: TypeChip(
                    type: _types[type]!,
                    selected: _selectedTypes.contains(type),
                    onSelected: () => _toggleType(type),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _stats(),
      ],
    ),
  );

  void _toggleType(String type) => setState(() {
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
    } else {
      _selectedTypes.add(type);
    }
  });
  Widget _welcomePanel() => Container(
    height: 150,
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26),
      gradient: const LinearGradient(
        colors: [Color(0xFF9B82D5), Color(0xFFFFA8C8)],
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.purple.withAlpha(55),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¡Hola, explorador!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tu aventura Pokémon comienza aquí.',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Container(
          width: 180,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white38,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: .62,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  Widget _stats() => Row(
    children: [
      _statCard(
        'Total',
        '${_all.length}',
        Icons.catching_pokemon_rounded,
        AppTheme.sakura,
      ),
      const SizedBox(width: 10),
      _statCard(
        'Vistos',
        '${_filtered.length}',
        Icons.visibility_rounded,
        AppTheme.mint,
      ),
      const SizedBox(width: 10),
      _statCard('Favoritos', '0', Icons.favorite_rounded, AppTheme.peach),
    ],
  );
  Widget _statCard(String label, String value, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.warmWhite.withAlpha(235),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, size: 15, color: AppTheme.plum),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  int _columns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 1300
        ? 5
        : width >= 900
        ? 4
        : width >= 600
        ? 3
        : 2;
  }

  Widget _typesScreen() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Tipos',
        style: Theme.of(context).textTheme.displaySmall
            ?.copyWith(fontWeight: FontWeight.w900),
      ),
      const Text('Elige un tipo para filtrar tu aventura.'),
      const SizedBox(height: 20),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final entry in _types.entries)
            SizedBox(
              width: 150,
              height: 100,
              child: Card(
                color: AppTheme.typeColor(entry.value),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTypes = {entry.key};
                      _tab = 0;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ],
  );
  Widget _simpleScreen(String title, String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Text(message),
      ],
    ),
  );
  Widget _randomScreen() => Center(
    child: FilledButton.icon(
      onPressed: _all.isEmpty
          ? null
          : () {
              final list = [..._all]..shuffle();
              _openDetail(list.first);
            },
      icon: const Text('P'),
      label: const Text('Pokémon al azar'),
    ),
  );
  Widget _navigationBar() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: NavigationBar(
        backgroundColor: AppTheme.warmWhite.withAlpha(245),
        elevation: 8,
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            label: 'Tipos',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            label: 'Azar',
          ),
        ],
      ),
    ),
  );
  Widget _emptyView() => const Center(
    child: Text(
      'No encontramos ese Pokémon... intenta otro.',
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
    ),
  );
  Widget _errorView() => Center(
    child: FilledButton.icon(
      onPressed: () => _loadGeneration(_generation),
      icon: const Icon(Icons.refresh),
      label: const Text('Reintentar'),
    ),
  );

  Future<void> _openDetail(PokemonListItem item) async {
    final pokemon = await _service.getPokemon('${item.id}');
    if (!mounted) return;
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _DetailScreen(pokemon: pokemon),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(.08, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: ScaleTransition(
                  scale: Tween(begin: .96, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
            ),
      ),
    );
  }
}

class _DetailScreen extends StatefulWidget {
  const _DetailScreen({required this.pokemon});
  final Pokemon pokemon;
  @override
  State<_DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<_DetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.pokemon.name)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, -8 * _floatController.value),
            child: child,
          ),
          child: Hero(
            tag: 'pokemon-${widget.pokemon.id}',
            child: Image.network(widget.pokemon.imageUrl, height: 260),
          ),
        ),
        Text(
          '#${widget.pokemon.id.toString().padLeft(3, '0')}',
          textAlign: TextAlign.center,
        ),
        Text(
          widget.pokemon.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: widget.pokemon.types
              .map((type) => TypeChip(type: type))
              .toList(),
        ),
        const SizedBox(height: 20),
        Text('Altura: ${(widget.pokemon.height / 10).toStringAsFixed(1)} m'),
        Text('Peso: ${(widget.pokemon.weight / 10).toStringAsFixed(1)} kg'),
        const SizedBox(height: 12),
        const SizedBox(height: 20),
        Text(
          'Habilidades',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.pokemon.abilities
              .map(
                (ability) => Chip(
                  avatar: const Icon(Icons.auto_awesome, size: 16),
                  label: Text(ability),
                  backgroundColor: AppTheme.lavender,
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        Text(
          'Estadísticas base',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        ...widget.pokemon.stats.entries.toList().asMap().entries.map(
          (entry) => StatBar(
            name: entry.value.key,
            value: entry.value.value,
            color: [
              AppTheme.sakura,
              AppTheme.peach,
              AppTheme.mint,
              AppTheme.sky,
              AppTheme.lavender,
              AppTheme.butter,
            ][entry.key % 6],
          ),
        ),
      ],
    ),
  );
}
