class UserInfo {
  final String userid;
  final String name;
  final String gender;
  final String dob;
  final String mobileNumber;
  final String usertype;
  final String buildingId;
  final String residentName;
  final int noOfFlats;
  final String address;
  final String addressProof;
  final String secretaryId;
  final String secretaryName;
  final String createdAt;
  final String updatedAt;

  // Constructor
  UserInfo({
    required this.userid,
    required this.name,
    required this.gender,
    required this.dob,
    required this.mobileNumber,
    required this.usertype,
    required this.buildingId,
    required this.residentName,
    required this.noOfFlats,
    required this.address,
    required this.addressProof,
    required this.secretaryId,
    required this.secretaryName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a UserInfo object from JSON
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userid: json['userid'],
      name: json['name'],
      gender: json['gender'],
      dob: json['dob'],
      mobileNumber: json['mobile_number'],
      usertype: json['usertype'],
      buildingId: json['building_id'],
      residentName: json['resident_name'],
      noOfFlats: json['no_of_flats'],
      address: json['address'],
      addressProof: json['address_proof'],
      secretaryId: json['secretary_id'],
      secretaryName: json['secretary_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Method to convert UserInfo object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'userid': userid,
      'name': name,
      'gender': gender,
      'dob': dob,
      'mobile_number': mobileNumber,
      'usertype': usertype,
      'building_id': buildingId,
      'resident_name': residentName,
      'no_of_flats': noOfFlats,
      'address': address,
      'address_proof': addressProof,
      'secretary_id': secretaryId,
      'secretary_name': secretaryName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
