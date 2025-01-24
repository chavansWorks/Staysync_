class Resident {
  String? userId;
  String name;
  String gender;
  String mobileNumber;
  String? loginId;
  String? userType;
  String? residentId;
  String? buildingId;

  String dob;
  String wingNo;
  String flatNo;
  int floorNo;
  String? createdAt;
  String? updatedAt;

  // Constructor
  Resident({
    this.userId,
    required this.name,
    required this.gender,
    required this.mobileNumber,
    this.loginId,
    this.userType,
    this.residentId,
    this.buildingId,
    required this.dob,
    required this.wingNo,
    required this.flatNo,
    required this.floorNo,
    this.createdAt,
    this.updatedAt,
  });

  // Convert the object to JSON format for database storage
  Map<String, dynamic> toJson() {
    return {
      'userid': userId,
      'resident_name': name,
      'user_gender': gender,
      'mobile_number': mobileNumber,
      'login_id': loginId,
      'usertype': userType,
      'resident_id': residentId,
      'building_id': buildingId,
      'user_dob': dob,
      'wing_no': wingNo,
      'flat_no': flatNo,
      'floor_no': floorNo,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Override toString method to print all data
  @override
  String toString() {
    return 'Resident {'
        'userId: $userId, '
        'name: $name, '
        'gender: $gender, '
        'mobileNumber: $mobileNumber, '
        'loginId: $loginId, '
        'userType: $userType, '
        'residentId: $residentId, '
        'buildingId: $buildingId, '
        'dob: $dob, '
        'wingNo: $wingNo, '
        'flatNo: $flatNo, '
        'floorNo: $floorNo, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        '}';
  }

  factory Resident.fromJson(Map<String, dynamic> json) {
    return Resident(
      userId: json['userid'] as String?,
      name: json['resident_name'] as String,
      gender: json['user_gender'] as String,
      mobileNumber: json['mobile_number'] as String,
      loginId: json['login_id'] as String?,
      userType: json['usertype'] as String?,
      residentId: json['resident_id'] as String?,
      buildingId: json['building_id'] as String?,
      dob: json['user_dob'] as String,
      wingNo: json['wing_no'] as String,
      flatNo: json['flat_no'] as String,
      floorNo: json['floor_no'] as int,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
