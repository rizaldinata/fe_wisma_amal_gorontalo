import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/botton/icon_button.dart';

class ResidentTableAction extends StatelessWidget {
  const ResidentTableAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Field
        SizedBox(
          width: 250,
          child: TextFormField(
            decoration: InputDecoration(
              hintText: 'Cari...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Filter Button
        CustomIconButton(
          icon: const Icon(Icons.filter_list, size: 18),
          title: 'Filter',
          borderColor: Colors.grey.shade300,
          backgroundColor: Colors.transparent,
          boxShadow: const [],
          onPressed: () {
            // TODO: Implement Filter logic
          },
        ),
        const SizedBox(width: 12),

        // Sort Button
        CustomIconButton(
          icon: const Icon(Icons.sort, size: 18),
          title: 'Urutkan',
          borderColor: Colors.grey.shade300,
          backgroundColor: Colors.transparent,
          boxShadow: const [],
          onPressed: () {
            // TODO: Implement Sort logic
          },
        ),
      ],
    );
  }
}