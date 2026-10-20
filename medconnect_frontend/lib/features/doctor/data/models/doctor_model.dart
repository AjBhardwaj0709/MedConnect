class DoctorProfileModel {
  const DoctorProfileModel({
    this.id = '',
    this.name = '',
    this.email = '',
    this.specialization = '',
    this.qualification = '',
    this.registrationNumber = '',
    this.experience = 0,
    this.consultationFee = 0,
    this.bio = '',
    this.languages = const [],
    this.clinicName = '',
    this.clinicAddress = '',
    this.profileImage = '',
    this.verificationStatus = 'pending',
    this.isVerified = false,
    
    
  });

  final String id;
  final String name;
  final String email;
  final String specialization;
  final String qualification;
  final String registrationNumber;
  final int experience;
  final double consultationFee;
  final String bio;
  final List<String> languages;
  final String clinicName;
  final String clinicAddress;
  final String profileImage;
  final String verificationStatus;
  final bool isVerified;


  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['userId'] is Map
        ? Map<String, dynamic>.from(json['userId'] as Map)
        : <String, dynamic>{};

    

    return DoctorProfileModel(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (userJson['email'] ?? json['email'] ?? '').toString(),
      specialization: (json['specialization'] ?? '').toString(),
      qualification: (json['qualification'] ?? '').toString(),
      registrationNumber: (json['registrationNumber'] ?? '').toString(),
      experience: _asInt(json['experience']),
      consultationFee: _asDouble(json['consultationFee']),
      bio: (json['bio'] ?? '').toString(),
     languages: (json['languages'] as List<dynamic>? ?? [])
          .map((language) => language.toString())
          .toList(),
      clinicName: (json['clinicName'] ?? '').toString(),
      clinicAddress: (json['clinicAddress'] ?? json['address'] ?? '')
          .toString(),
      profileImage: (json['profileImage'] ?? '').toString(),
      verificationStatus: (json['verificationStatus'] ?? 'pending').toString(),
      isVerified: json['isVerified'] == true,
    );
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
