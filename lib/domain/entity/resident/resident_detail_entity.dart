class ResidentDetailEntity {
  final String id;
  final String status;
  final String startDate;
  final String endDate;
  final String? finishedAt;
  final String? paymentProofUrl;
  final ResidentDetailRoom room;
  final ResidentDetailPerson resident;

  const ResidentDetailEntity({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.finishedAt,
    required this.paymentProofUrl,
    required this.room,
    required this.resident,
  });
}

class ResidentDetailRoom {
  final int? id;
  final String number;
  final String title;
  final int? price;

  const ResidentDetailRoom({
    required this.id,
    required this.number,
    required this.title,
    required this.price,
  });

  const ResidentDetailRoom.empty()
    : id = null,
      number = '-',
      title = '-',
      price = null;
}

class ResidentDetailPerson {
  final String? id;
  final String name;
  final String email;
  final String idCardNumber;
  final String phoneNumber;
  final String gender;
  final String job;
  final String addressKtp;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String? ktpPhotoUrl;

  const ResidentDetailPerson({
    required this.id,
    required this.name,
    required this.email,
    required this.idCardNumber,
    required this.phoneNumber,
    required this.gender,
    required this.job,
    required this.addressKtp,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.ktpPhotoUrl,
  });

  const ResidentDetailPerson.empty()
    : id = null,
      name = '-',
      email = '-',
      idCardNumber = '-',
      phoneNumber = '-',
      gender = '-',
      job = '-',
      addressKtp = '-',
      emergencyContactName = '-',
      emergencyContactPhone = '-',
      ktpPhotoUrl = null;
}
