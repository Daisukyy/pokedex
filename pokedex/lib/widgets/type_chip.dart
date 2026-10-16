import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TypeChip extends StatelessWidget {
  const TypeChip({
    required this.type,
    this.selected = false,
    this.onSelected,
    super.key,
  });
  final String type;
  final bool selected;
  final VoidCallback? onSelected;

  static const _icons = {
    'Normal': '◉',
    'Fuego': '🔥',
    'Agua': '💧',
    'Planta': '🌿',
    'Eléctrico': '⚡',
    'Hielo': '❄️',
    'Lucha': '🥊',
    'Veneno': '☠️',
    'Tierra': '⛰️',
    'Volador': '🌬️',
    'Psíquico': '🔮',
    'Bicho': '🐞',
    'Roca': '🪨',
    'Fantasma': '👻',
    'Dragón': '🐉',
    'Siniestro': '🌙',
    'Acero': '⚙️',
    'Hada': '✨',
  };

  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text('${_icons[type] ?? '✦'} $type'),
    selected: selected,
    onSelected: onSelected == null ? null : (_) => onSelected!(),
    backgroundColor: AppTheme.typeColor(type),
    selectedColor: AppTheme.plum.withAlpha(190),
    checkmarkColor: Colors.white,
    side: BorderSide.none,
    labelStyle: TextStyle(
      fontWeight: FontWeight.w800,
      color: selected ? Colors.white : AppTheme.plum,
    ),
  );
}
