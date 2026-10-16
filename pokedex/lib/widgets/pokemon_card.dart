import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models/pokemon.dart';
import '../theme/app_theme.dart';
import 'type_chip.dart';

/// Tarjeta compacta de colección, inspirada en el panel de referencia.
class PokemonCard extends StatefulWidget {
  const PokemonCard({required this.pokemon, required this.onTap, super.key});
  final PokemonListItem pokemon;
  final VoidCallback onTap;
  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);
  bool _hovered = false;
  bool _favorite = false;

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.typeColor(widget.pokemon.types.firstOrNull);
    return Semantics(
      button: true,
      label: '${widget.pokemon.name}, número ${widget.pokemon.id}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: _hovered ? 1.025 : 1,
          duration: const Duration(milliseconds: 180),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: _hovered ? 10 : 2,
            shadowColor: color.withAlpha(90),
            color: color.withAlpha(175),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${widget.pokemon.id.toString().padLeft(3, '0')}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => setState(() => _favorite = !_favorite),
                          child: Icon(
                            _favorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: _favorite
                                ? AppTheme.accent
                                : AppTheme.purple,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 105,
                            height: 105,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withAlpha(105),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _floatController,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(0, -5 * _floatController.value),
                              child: Transform.scale(
                                scale: 1 + (_floatController.value * .035),
                                child: child,
                              ),
                            ),
                            child: Hero(
                              tag: 'pokemon-${widget.pokemon.id}',
                              child: CachedNetworkImage(
                                imageUrl: widget.pokemon.imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (_, _) => Shimmer.fromColors(
                                  baseColor: Colors.white54,
                                  highlightColor: AppTheme.sakura,
                                  child: const CircleAvatar(radius: 38),
                                ),
                                errorWidget: (_, _, _) => const Icon(
                                  Icons.image_not_supported_outlined,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.pokemon.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 2,
                      children: widget.pokemon.types
                          .take(2)
                          .map((type) => TypeChip(type: type))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
