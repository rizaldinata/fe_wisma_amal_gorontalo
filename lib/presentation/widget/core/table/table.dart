import 'package:flutter/material.dart';
import 'package:frontend/domain/entity/table/tabel_colum.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';

class TableCard extends StatelessWidget {
  final String title;
  final List<TableColumn> columns;
  final List<List<dynamic>> rows;
  final Widget? actions;
  final String? emptyMessage;
  final Function(int)? onRowTap;

  const TableCard({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.actions,
    this.emptyMessage,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return BasicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(title: title, actions: actions),
          const SizedBox(height: 16),
          _TableHeader(columns: columns),
          const SizedBox(height: 8),
          if (rows.isEmpty && emptyMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  emptyMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              return _TableRow(
                columns: columns,
                values: row,
                onTap: onRowTap != null ? () => onRowTap!(index) : null,
              );
            }),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final Widget? actions;

  const _Header({required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (actions != null) actions!,
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  final List<TableColumn> columns;

  const _TableHeader({required this.columns});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: columns.map((c) {
          return Expanded(
            flex: c.flex,
            child: Text(
              c.label,
              textAlign: c.align,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final List<TableColumn> columns;
  final List<dynamic> values;
  final VoidCallback? onTap;

  const _TableRow({required this.columns, required this.values, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: List.generate(values.length, (index) {
            final column = columns[index];
            final value = values[index];

            return Expanded(
              flex: column.flex,
              child: value is Widget
                  ? value
                  : Text(
                      value.toString(),
                      textAlign: column.align,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
            );
          }),
        ),
      ),
    );
  }
}
