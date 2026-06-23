import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';

class FasilitasChipInput extends StatefulWidget {
  final List<String> initialValues;
  final ValueChanged<List<String>> onChanged;

  const FasilitasChipInput({
    required this.initialValues,
    required this.onChanged,
    super.key,
  });

  @override
  State<FasilitasChipInput> createState() => _FasilitasChipInputState();
}

class _FasilitasChipInputState extends State<FasilitasChipInput> {
  late List<String> _items;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialValues);
  }

  @override
  void didUpdateWidget(covariant FasilitasChipInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValues != oldWidget.initialValues) {
      _items = List.from(widget.initialValues);
    }
  }

  void _addItem() {
    final val = _controller.text.trim();
    if (val.isEmpty) return;
    if (_items.any((e) => e.toLowerCase() == val.toLowerCase())) {
      _controller.clear();
      return;
    }
    setState(() => _items.add(val));
    widget.onChanged(_items);
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _removeItem(String item) {
    setState(() => _items.remove(item));
    widget.onChanged(_items);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Fasilitas',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            if (_items.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: c.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_items.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: c.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_items.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _items.map((item) => _buildChip(item, c)).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter) {
                    _addItem();
                  }
                },
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: TextStyle(fontSize: 14, color: c.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Contoh: WiFi Cepat, Parkir Luas...',
                    hintStyle: TextStyle(color: c.textHint, fontSize: 13),
                    filled: true,
                    fillColor: c.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 2,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: c.borderLight),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: c.borderLight),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: c.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: const Icon(Icons.add, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Ketik nama fasilitas lalu tekan Enter atau klik +',
          style: TextStyle(fontSize: 11, color: c.textHint),
        ),
      ],
    );
  }

  Widget _buildChip(String label, AppColorPalette c) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: c.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: c.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: () => _removeItem(label),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 10, color: c.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
