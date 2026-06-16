import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_spacing.dart';

class SearchAndFilterBar extends StatelessWidget {
  final TextEditingController? searchController;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final List<Widget>? filterChips;
  final Widget? dropdownFilter;
  final VoidCallback? onSortPressed;
  final String? sortLabel;

  const SearchAndFilterBar({
    super.key,
    this.searchController,
    this.searchHint = 'Cari...',
    this.onSearchChanged,
    this.filterChips,
    this.dropdownFilter,
    this.onSortPressed,
    this.sortLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        if (filterChips != null && filterChips!.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.sm,
            children: filterChips!,
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
        if (dropdownFilter != null) ...[
          dropdownFilter!,
          const SizedBox(width: AppSpacing.lg),
        ],
        if (onSortPressed != null) ...[
          OutlinedButton.icon(
            onPressed: onSortPressed,
            icon: const Icon(Icons.sort, size: 18),
            label: Text(sortLabel ?? 'Sort'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(0, 40),
            ),
          ),
        ],
      ],
    );
  }
}
