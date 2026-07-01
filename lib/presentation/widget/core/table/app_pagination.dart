import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/domain/entity/pagination_meta.dart';

class AppPagination extends StatelessWidget {
  final PaginationMeta meta;
  final int currentLength;
  final Function(int page, int perPage) onChanged;
  final List<int> perPageOptions;

  const AppPagination({
    super.key,
    required this.meta,
    required this.currentLength,
    required this.onChanged,
    this.perPageOptions = const [10, 20, 50, 100],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int startItem = meta.total == 0
        ? 0
        : ((meta.currentPage - 1) * meta.perPage) + 1;
    final int endItem = ((meta.currentPage - 1) * meta.perPage) + currentLength;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Menampilkan $startItem - $endItem dari ${meta.total} data',
                style: TextStyle(
                  color: isDark
                      ? AppColorsDark.textSecondary
                      : AppColorsLight.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AppColorsDark.borderLight
                        : AppColorsLight.borderLight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: meta.perPage,
                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                    style: TextStyle(
                      color: isDark
                          ? AppColorsDark.textPrimary
                          : AppColorsLight.textPrimary,
                      fontSize: 13,
                    ),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        onChanged(
                          1,
                          newValue,
                        ); // Reset to page 1 on per_page change
                      }
                    },
                    items: perPageOptions.map<DropdownMenuItem<int>>((
                      int value,
                    ) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value / halaman'),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: meta.currentPage > 1
                    ? () => onChanged(meta.currentPage - 1, meta.perPage)
                    : null,
                // icon: const Icon(Icons.chevron_left, size: 18),
                // label: const Text('Sebelumnya'),
                child: Row(
                  children: [
                    const Icon(Icons.chevron_left, size: 18),
                    const Text('Sebelumnya'),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('Halaman ${meta.currentPage} dari ${meta.lastPage}'),
              const SizedBox(width: AppSpacing.md),
              TextButton(
                onPressed: meta.currentPage < meta.lastPage
                    ? () => onChanged(meta.currentPage + 1, meta.perPage)
                    : null,
                child: Row(
                  children: [
                    const Text('Selanjutnya'),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
