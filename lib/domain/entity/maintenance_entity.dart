import 'package:flutter/material.dart';

// ─── Tipe Perawatan ───

enum MaintenanceType {
  pembersihan,
  perawatan;

  String get displayName {
    switch (this) {
      case MaintenanceType.pembersihan:
        return 'Pembersihan';
      case MaintenanceType.perawatan:
        return 'Perawatan';
    }
  }

  static MaintenanceType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pembersihan':
        return MaintenanceType.pembersihan;
      case 'perawatan':
        return MaintenanceType.perawatan;
      default:
        throw ArgumentError('Invalid maintenance type: $value');
    }
  }

  static List<String> get displayNames =>
      MaintenanceType.values.map((e) => e.displayName).toList();
}

// ─── Subtipe Perawatan ───

enum MaintenanceSubtype {
  rutin,
  deepCleaning,
  darurat,
  perbaikan,
  maintenance;

  String get displayName {
    switch (this) {
      case MaintenanceSubtype.rutin:
        return 'Rutin';
      case MaintenanceSubtype.deepCleaning:
        return 'Deep Cleaning';
      case MaintenanceSubtype.darurat:
        return 'Darurat';
      case MaintenanceSubtype.perbaikan:
        return 'Perbaikan';
      case MaintenanceSubtype.maintenance:
        return 'Maintanance';
    }
  }

  static MaintenanceSubtype fromString(String value) {
    switch (value.toLowerCase()) {
      case 'rutin':
        return MaintenanceSubtype.rutin;
      case 'deep cleaning':
        return MaintenanceSubtype.deepCleaning;
      case 'darurat':
        return MaintenanceSubtype.darurat;
      case 'perbaikan':
        return MaintenanceSubtype.perbaikan;
      case 'maintanance':
      case 'maintenance':
        return MaintenanceSubtype.maintenance;
      default:
        throw ArgumentError('Invalid maintenance subtype: $value');
    }
  }

  static List<String> get displayNames =>
      MaintenanceSubtype.values.map((e) => e.displayName).toList();
}

// ─── Status Perawatan ───

enum MaintenanceStatus {
  inProgress,
  done,
  cancelled;

  String get displayName {
    switch (this) {
      case MaintenanceStatus.inProgress:
        return 'In Progress';
      case MaintenanceStatus.done:
        return 'Done';
      case MaintenanceStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case MaintenanceStatus.inProgress:
        return Colors.orange;
      case MaintenanceStatus.done:
        return Colors.green;
      case MaintenanceStatus.cancelled:
        return Colors.red;
    }
  }

  static MaintenanceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'in progress':
      case 'in_progress':
        return MaintenanceStatus.inProgress;
      case 'done':
        return MaintenanceStatus.done;
      case 'cancelled':
        return MaintenanceStatus.cancelled;
      default:
        throw ArgumentError('Invalid maintenance status: $value');
    }
  }

  static List<String> get displayNames =>
      MaintenanceStatus.values.map((e) => e.displayName).toList();
}

// ─── Entity ───

class MaintenanceEntity {
  final int? id;
  final String namaTeknisi;
  final String ruangan;
  final MaintenanceType tipe;
  final MaintenanceSubtype subtipe;
  final DateTime waktuMulai;
  final DateTime? waktuSelesai;
  final MaintenanceStatus status;

  const MaintenanceEntity({
    this.id,
    required this.namaTeknisi,
    required this.ruangan,
    required this.tipe,
    required this.subtipe,
    required this.waktuMulai,
    this.waktuSelesai,
    required this.status,
  });

  MaintenanceEntity copyWith({
    int? id,
    String? namaTeknisi,
    String? ruangan,
    MaintenanceType? tipe,
    MaintenanceSubtype? subtipe,
    DateTime? waktuMulai,
    DateTime? waktuSelesai,
    MaintenanceStatus? status,
  }) {
    return MaintenanceEntity(
      id: id ?? this.id,
      namaTeknisi: namaTeknisi ?? this.namaTeknisi,
      ruangan: ruangan ?? this.ruangan,
      tipe: tipe ?? this.tipe,
      subtipe: subtipe ?? this.subtipe,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      waktuSelesai: waktuSelesai ?? this.waktuSelesai,
      status: status ?? this.status,
    );
  }

  /// Helper untuk format tanggal ke string tampilan
  static String formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final d = dt.day;
    final m = months[dt.month - 1];
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d $m $y $h:$min';
  }

  /// Minggu ke-berapa dalam bulan (1-based)
  static int weekOfMonth(DateTime dt) {
    final firstDay = DateTime(dt.year, dt.month, 1);
    return ((dt.day + firstDay.weekday - 1) / 7).ceil();
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama_teknisi': namaTeknisi,
      'ruangan': ruangan,
      'tipe': tipe.displayName,
      'subtipe': subtipe.displayName,
      'waktu_mulai': waktuMulai.toIso8601String(),
      'waktu_selesai': waktuSelesai?.toIso8601String(),
      'status': status.displayName,
    };
  }

  factory MaintenanceEntity.fromMap(Map<String, dynamic> map) {
    return MaintenanceEntity(
      id: map['id'] as int?,
      namaTeknisi: map['nama_teknisi'] as String? ?? '',
      ruangan: map['ruangan'] as String? ?? '',
      tipe: MaintenanceType.fromString(map['tipe'] as String? ?? 'Pembersihan'),
      subtipe: MaintenanceSubtype.fromString(
        map['subtipe'] as String? ?? 'Rutin',
      ),
      waktuMulai:
          DateTime.tryParse(map['waktu_mulai'] as String? ?? '') ??
          DateTime.now(),
      waktuSelesai: map['waktu_selesai'] != null
          ? DateTime.tryParse(map['waktu_selesai'] as String)
          : null,
      status: MaintenanceStatus.fromString(
        map['status'] as String? ?? 'In Progress',
      ),
    );
  }

  MaintenanceEntity.empty()
    : this(
        id: null,
        namaTeknisi: '',
        ruangan: '',
        tipe: MaintenanceType.pembersihan,
        subtipe: MaintenanceSubtype.rutin,
        waktuMulai: DateTime.now(),
        waktuSelesai: null,
        status: MaintenanceStatus.inProgress,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaintenanceEntity &&
        other.id == id &&
        other.namaTeknisi == namaTeknisi &&
        other.ruangan == ruangan &&
        other.tipe == tipe &&
        other.subtipe == subtipe &&
        other.waktuMulai == waktuMulai &&
        other.waktuSelesai == waktuSelesai &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(
    id,
    namaTeknisi,
    ruangan,
    tipe,
    subtipe,
    waktuMulai,
    waktuSelesai,
    status,
  );

  @override
  String toString() =>
      'MaintenanceEntity(id: $id, teknisi: $namaTeknisi, ruangan: $ruangan, tipe: ${tipe.displayName}, status: ${status.displayName})';
}
