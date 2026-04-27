import 'package:flutter/material.dart';

class ResidentTableAction extends StatelessWidget {
  const ResidentTableAction({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedStatus,
    required this.selectedPayment,
    required this.onStatusChanged,
    required this.onPaymentChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String selectedStatus;
  final String selectedPayment;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPaymentChanged;

  static const List<String> _statusOptions = <String>['Semua', 'Aktif', 'Pending'];
  static const List<String> _paymentOptions = <String>['Semua', 'Lunas', 'Belum Lunas'];

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
                    controller: searchController,
                    onChanged: onSearchChanged,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF2B2B2B),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Cari nama, kamar, kontak...',
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
        _FilterDropdownButton(
          icon: Icons.filter_list,
          title: 'Status',
          selectedValue: selectedStatus,
          options: _statusOptions,
          onSelected: onStatusChanged,
        ),
        const SizedBox(width: 12),
        _FilterDropdownButton(
          icon: Icons.receipt_long_outlined,
          title: 'Detil Bayar',
          selectedValue: selectedPayment,
          options: _paymentOptions,
          onSelected: onPaymentChanged,
        ),
      ],
    );
  }
}

class _FilterDropdownButton extends StatelessWidget {
  const _FilterDropdownButton({
    required this.icon,
    required this.title,
    required this.selectedValue,
    required this.options,
    required this.onSelected,
  });

  final IconData icon;
  final String title;
  final String selectedValue;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: PopupMenuButton<String>(
        onSelected: onSelected,
        itemBuilder: (context) {
          return options
              .map(
                (option) => PopupMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList();
        },
        offset: const Offset(0, 34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF3D3D3D), width: 1),
            borderRadius: BorderRadius.circular(3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: const Color(0xFF1F1F1F)),
              const SizedBox(width: 8),
              Text(
                selectedValue == 'Semua' ? title : selectedValue,
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
      ),
    );
  }
}
