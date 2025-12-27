class RoomEntity {
  final int id;
  final String number;
  final String type;
  final double price;
  final String status;
  final String? description;

  RoomEntity({
    required this.id,
    required this.number,
    required this.type,
    required this.price,
    required this.status,
    this.description,
  });
}
