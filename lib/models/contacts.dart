// Contact model for the CRM contacts API
// This model handles both list and detail API responses

class Contact {
  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String? email;
  final String? phone;
  final String? ageGroup;
  final String? gender;
  final String? dateOfBirth;
  final bool isActive;
  final ContactGroup? primaryGroup;

  Contact({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.email,
    this.phone,
    this.ageGroup,
    this.gender,
    this.dateOfBirth,
    required this.isActive,
    this.primaryGroup,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    // Comment out debug prints for production
    // print('Contact.fromJson: Processing contact ${json['id']}');
    // print('Contact.fromJson: Avatar URL: ${json['avatar']}');

    return Contact(
      id: json['id'] as int,
      name: json['name'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      ageGroup: json['ageGroup'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      primaryGroup: json['primaryGroup'] != null
          ? ContactGroup.fromJson(json['primaryGroup'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'email': email,
      'phone': phone,
      'ageGroup': ageGroup,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'isActive': isActive,
      'primaryGroup': primaryGroup?.toJson(),
    };
  }
}

class ContactGroup {
  final int id;
  final String name;
  final String? role;

  ContactGroup({required this.id, required this.name, this.role});

  factory ContactGroup.fromJson(Map<String, dynamic> json) {
    return ContactGroup(
      id: json['id'] as int,
      name: json['name'] as String,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'role': role};
  }
}

// Contact Details model for individual contact API response
// This is for the /api/crm/contacts/{id} endpoint

class ContactDetails {
  final int id;
  final String category;
  final ContactPerson person;
  final List<ContactEmail> emails;
  final List<ContactPhone> phones;
  final List<ContactAddress> addresses;
  final List<GroupMembership> groupMemberships;

  ContactDetails({
    required this.id,
    required this.category,
    required this.person,
    required this.emails,
    required this.phones,
    required this.addresses,
    required this.groupMemberships,
  });

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    // Comment out debug prints for production
    // print('ContactDetails.fromJson: Processing contact details ${json['id']}');
    // print(
    //   'ContactDetails.fromJson: Avatar from person: ${json['person']?['avatar']}',
    // );

    return ContactDetails(
      id: json['id'] as int,
      category: json['category'] as String,
      person: ContactPerson.fromJson(json['person']),
      emails:
          (json['emails'] as List<dynamic>?)
              ?.map((e) => ContactEmail.fromJson(e))
              .toList() ??
          [],
      phones:
          (json['phones'] as List<dynamic>?)
              ?.map((e) => ContactPhone.fromJson(e))
              .toList() ??
          [],
      addresses:
          (json['addresses'] as List<dynamic>?)
              ?.map((e) => ContactAddress.fromJson(e))
              .toList() ??
          [],
      groupMemberships:
          (json['groupMemberships'] as List<dynamic>?)
              ?.map((e) => GroupMembership.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ContactPerson {
  final int id;
  final String firstName;
  final String lastName;
  final String? ageGroup;
  final String? gender;
  final String? civilStatus;
  final String? placeOfWork;
  final String? avatar;
  final String? dateOfBirth;

  ContactPerson({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.ageGroup,
    this.gender,
    this.civilStatus,
    this.placeOfWork,
    this.avatar,
    this.dateOfBirth,
  });

  factory ContactPerson.fromJson(Map<String, dynamic> json) {
    return ContactPerson(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      ageGroup: json['ageGroup'] as String?,
      gender: json['gender'] as String?,
      civilStatus: json['civilStatus'] as String?,
      placeOfWork: json['placeOfWork'] as String?,
      avatar: json['avatar'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
    );
  }
}

class ContactEmail {
  final int id;
  final String category;
  final String value;
  final bool isPrimary;

  ContactEmail({
    required this.id,
    required this.category,
    required this.value,
    required this.isPrimary,
  });

  factory ContactEmail.fromJson(Map<String, dynamic> json) {
    return ContactEmail(
      id: json['id'] as int,
      category: json['category'] as String,
      value: json['value'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

class ContactPhone {
  final int id;
  final String category;
  final String value;
  final bool isPrimary;

  ContactPhone({
    required this.id,
    required this.category,
    required this.value,
    required this.isPrimary,
  });

  factory ContactPhone.fromJson(Map<String, dynamic> json) {
    return ContactPhone(
      id: json['id'] as int,
      category: json['category'] as String,
      value: json['value'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

class ContactAddress {
  final int id;
  final String category;
  final bool isPrimary;
  final String? country;
  final String? district;
  final String? freeForm;

  ContactAddress({
    required this.id,
    required this.category,
    required this.isPrimary,
    this.country,
    this.district,
    this.freeForm,
  });

  factory ContactAddress.fromJson(Map<String, dynamic> json) {
    return ContactAddress(
      id: json['id'] as int,
      category: json['category'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
      country: json['country'] as String?,
      district: json['district'] as String?,
      freeForm: json['freeForm'] as String?,
    );
  }
}

class GroupMembership {
  final int id;
  final int groupId;
  final String role;
  final GroupModel group;

  GroupMembership({
    required this.id,
    required this.groupId,
    required this.role,
    required this.group,
  });

  factory GroupMembership.fromJson(Map<String, dynamic> json) {
    return GroupMembership(
      id: json['id'] as int,
      groupId: json['groupId'] as int,
      role: json['role'] as String,
      group: GroupModel.fromJson(json['group']),
    );
  }
}

class GroupModel {
  final int id;
  final String name;
  final String categoryName;

  GroupModel({
    required this.id,
    required this.name,
    required this.categoryName,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as int,
      name: json['name'] as String,
      categoryName: json['categoryName'] as String,
    );
  }
}
