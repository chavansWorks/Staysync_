class ResidentInfo {
  final String userId;
  final String name;
  final String gender;
  final String dob;
  final String mobileNumber;
  final String userType;
  final String buildingId;
  final String wingNo;
  final String flatNo;
  final String floorNo;
  final String residentName;
  final String? residentId;

  ResidentInfo({
    required this.userId,
    required this.name,
    required this.gender,
    required this.dob,
    required this.mobileNumber,
    required this.userType,
    required this.buildingId,
    required this.wingNo,
    required this.flatNo,
    required this.floorNo,
    required this.residentName,
    required this.residentId,
  });

  factory ResidentInfo.fromJson(Map<String, dynamic> json) {
    return ResidentInfo(
      userId: json['userid'] ?? '', // Provide a default value if null
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      userType: json['usertype'] ?? '',
      buildingId: json['building_id'] ?? '',
      wingNo: json['wing_no'] ?? '',
      flatNo: json['flat_no'] ?? '',
      floorNo: json['floor_no'] ?? '',
      residentName: json['resident_name'] ?? '',
      residentId: json['resident_id'],
    );
  }
}