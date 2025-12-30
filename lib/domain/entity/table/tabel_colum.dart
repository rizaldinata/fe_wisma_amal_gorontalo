import 'dart:ui';

class TableColumn {
  final String label;
  final int flex;
  final TextAlign align;

  const TableColumn({
    required this.label,
    this.flex = 1,
    this.align = TextAlign.left,
  });
}
