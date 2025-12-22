class People {
  final int id;
  final String? salutation;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? ageGroup;
  final String? placeOfWork;
  final String gender;
  final String civilStatus;
  final String avatar;
  final String dateOfBirth;
  final int contactId;

  People({
    required this.id,
    this.salutation,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.ageGroup,
    this.placeOfWork,
    required this.gender,
    required this.civilStatus,
    required this.avatar,
    required this.dateOfBirth,
    required this.contactId,
  });

  // Factory constructor to create a People instance from JSON
  factory People.fromJson(Map<String, dynamic> json) {
    return People(
      id: json['id'] as int,
      salutation: json['salutation'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      middleName: json['middleName'] as String?,
      ageGroup: json['ageGroup'] as String?,
      placeOfWork: json['placeOfWork'] as String?,
      gender: json['gender'] as String,
      civilStatus: json['civilStatus'] as String,
      avatar: json['avatar'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      contactId: json['contactId'] as int,
    );
  }

  // Method to convert a People instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salutation': salutation,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'ageGroup': ageGroup,
      'placeOfWork': placeOfWork,
      'gender': gender,
      'civilStatus': civilStatus,
      'avatar': avatar,
      'dateOfBirth': dateOfBirth,
      'contactId': contactId,
    };
  }

  // Helper method to parse a list of People from JSON array
  static List<People> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => People.fromJson(json)).toList();
  }

  // CopyWith method for easy object modification
  People copyWith({
    int? id,
    String? salutation,
    String? firstName,
    String? lastName,
    String? middleName,
    String? ageGroup,
    String? placeOfWork,
    String? gender,
    String? civilStatus,
    String? avatar,
    String? dateOfBirth,
    int? contactId,
  }) {
    return People(
      id: id ?? this.id,
      salutation: salutation ?? this.salutation,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      ageGroup: ageGroup ?? this.ageGroup,
      placeOfWork: placeOfWork ?? this.placeOfWork,
      gender: gender ?? this.gender,
      civilStatus: civilStatus ?? this.civilStatus,
      avatar: avatar ?? this.avatar,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      contactId: contactId ?? this.contactId,
    );
  }

  // Override toString for easier debugging
  @override
  String toString() {
    return 'People(id: $id, firstName: $firstName, lastName: $lastName, gender: $gender, civilStatus: $civilStatus)';
  }
}
