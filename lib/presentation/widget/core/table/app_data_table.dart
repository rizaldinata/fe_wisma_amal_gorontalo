import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';

class AppDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool showCheckboxColumn;
  final double? dataRowMaxHeight;
  final double? dataRowMinHeight;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showCheckboxColumn = false,
    this.dataRowMaxHeight,
    this.dataRowMinHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final surfaceColor = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final surfaceVariantColor = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final borderLightColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final primaryLightColor = isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight;
    final textSecondaryColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: borderLightColor,
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(surfaceVariantColor),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return primaryLightColor.withOpacity(0.3);
            }
            return surfaceColor;
          }),
          headingTextStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textSecondaryColor,
            letterSpacing: 0.5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderLightColor),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DataTable(
          columns: columns.map((col) {
            // Apply uppercase to header text if it's a Text widget
            if (col.label is Text) {
              final textWidget = col.label as Text;
              return DataColumn(
                label: Text(
                  textWidget.data?.toUpperCase() ?? '',
                  style: textWidget.style,
                ),
                tooltip: col.tooltip,
                numeric: col.numeric,
                onSort: col.onSort,
              );
            }
            return col;
          }).toList(),
          rows: rows,
          showCheckboxColumn: showCheckboxColumn,
          dataRowMinHeight: dataRowMinHeight ?? 56,
          dataRowMaxHeight: dataRowMaxHeight ?? double.infinity,
          horizontalMargin: 16,
          columnSpacing: 24,
          headingRowHeight: 48,
        ),
      ),
    );
  }
}
