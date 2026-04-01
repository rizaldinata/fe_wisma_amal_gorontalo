import 'package:flutter/material.dart';

class ResidentTableAction extends StatelessWidget {
  const ResidentTableAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 250,
          height: 32,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3D3D3D), width: 1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(Icons.search, size: 16, color: Color(0xFF2B2B2B)),
                const SizedBox(width: 8),
                Container(width: 1, height: 16, color: const Color(0xFFBDBDBD)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF2B2B2B),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Cari...',
                      hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: const Color(0xFF7A7A7A),
                          ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _TableActionButton(
          icon: Icons.filter_list,
          title: 'Filter',
          onPressed: () {},
        ),
        const SizedBox(width: 12),
        _TableActionButton(
          icon: Icons.sort,
          title: 'Urutkan',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _TableActionButton extends StatelessWidget {
  const _TableActionButton({
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF3D3D3D), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF1F1F1F)),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: const Color(0xFF1F1F1F),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Color(0xFF1F1F1F),
            ),
          ],
        ),
      ),
    );
  }
}
