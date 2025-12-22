// ===== LEGACY CODE (COMMENTED OUT) =====
// class People {
//   final int id;
//   final String? salutation;
//   final String firstName;
//   final String lastName;
//   final String? middleName;
//   final String? ageGroup;
//   final String? placeOfWork;
//   final String gender;
//   final String civilStatus;
//   final String avatar;
//   final String dateOfBirth;
//   final int contactId;

//   People({
//     required this.id,
//     this.salutation,
//     required this.firstName,
//     required this.lastName,
//     this.middleName,
//     this.ageGroup,
//     this.placeOfWork,
//     required this.gender,
//     required this.civilStatus,
//     required this.avatar,
//     required this.dateOfBirth,
//     required this.contactId,
//   });

//   // Factory constructor to create a People instance from JSON
//   factory People.fromJson(Map<String, dynamic> json) {
//     return People(
//       id: json['id'] as int,
//       salutation: json['salutation'] as String?,
//       firstName: json['firstName'] as String,
//       lastName: json['lastName'] as String,
//       middleName: json['middleName'] as String?,
//       ageGroup: json['ageGroup'] as String?,
//       placeOfWork: json['placeOfWork'] as String?,
//       gender: json['gender'] as String,
//       civilStatus: json['civilStatus'] as String,
//       avatar: json['avatar'] as String,
//       dateOfBirth: json['dateOfBirth'] as String,
//       contactId: json['contactId'] as int,
//     );
//   }

//   // Method to convert a People instance to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'salutation': salutation,
//       'firstName': firstName,
//       'lastName': lastName,
//       'middleName': middleName,
//       'ageGroup': ageGroup,
//       'placeOfWork': placeOfWork,
//       'gender': gender,
//       'civilStatus': civilStatus,
//       'avatar': avatar,
//       'dateOfBirth': dateOfBirth,
//       'contactId': contactId,
//     };
//   }

//   // Helper method to parse a list of People from JSON array
//   static List<People> fromJsonList(List<dynamic> jsonList) {
//     return jsonList.map((json) => People.fromJson(json)).toList();
//   }

//   // CopyWith method for easy object modification
//   People copyWith({
//     int? id,
//     String? salutation,
//     String? firstName,
//     String? lastName,
//     String? middleName,
//     String? ageGroup,
//     String? placeOfWork,
//     String? gender,
//     String? civilStatus,
//     String? avatar,
//     String? dateOfBirth,
//     int? contactId,
//   }) {
//     return People(
//       id: id ?? this.id,
//       salutation: salutation ?? this.salutation,
//       firstName: firstName ?? this.firstName,
//       lastName: lastName ?? this.lastName,
//       middleName: middleName ?? this.middleName,
//       ageGroup: ageGroup ?? this.ageGroup,
//       placeOfWork: placeOfWork ?? this.placeOfWork,
//       gender: gender ?? this.gender,
//       civilStatus: civilStatus ?? this.civilStatus,
//       avatar: avatar ?? this.avatar,
//       dateOfBirth: dateOfBirth ?? this.dateOfBirth,
//       contactId: contactId ?? this.contactId,
//     );
//   }

//   // Override toString for easier debugging
//   @override
//   String toString() {
//     return 'People(id: $id, firstName: $firstName, lastName: $lastName, gender: $gender, civilStatus: $civilStatus)';
//   }
// }

// ===== NEW CONTACT MANAGEMENT MODELS =====

// Contact model for list view
class Contact {
  final int id;
  final String name;
  final String avatar;
  final String? ageGroup;
  final String dateOfBirth;
  final String email;
  final String phone;
  final String? cellGroup;
  final String? location;

  Contact({
    required this.id,
    required this.name,
    required this.avatar,
    this.ageGroup,
    required this.dateOfBirth,
    required this.email,
    required this.phone,
    this.cellGroup,
    this.location,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    try {
      // Handle case where the API returns detailed contact structure
      if (json.containsKey('person') &&
          json['person'] is Map<String, dynamic>) {
        final person = json['person'] as Map<String, dynamic>;
        final emails = json['emails'] as List<dynamic>? ?? [];
        final phones = json['phones'] as List<dynamic>? ?? [];

        // Extract primary email and phone
        String primaryEmail = '';
        String primaryPhone = '';

        if (emails.isNotEmpty) {
          final emailData = emails.firstWhere(
            (e) => e['isPrimary'] == true,
            orElse: () => emails.first,
          );
          primaryEmail = emailData['value'] ?? '';
        }

        if (phones.isNotEmpty) {
          final phoneData = phones.firstWhere(
            (p) => p['isPrimary'] == true,
            orElse: () => phones.first,
          );
          primaryPhone = phoneData['value'] ?? '';
        }

        return Contact(
          id: json['id'] as int,
          name:
              '${person['firstName'] ?? ''} ${person['middleName'] ?? ''} ${person['lastName'] ?? ''}'
                  .trim(),
          avatar:
              person['avatar'] as String? ??
              'https://gravatar.com/avatar/default?s=200&d=retro',
          ageGroup: person['ageGroup'] as String?,
          dateOfBirth: person['dateOfBirth'] as String? ?? '',
          email: primaryEmail,
          phone: primaryPhone,
          cellGroup: _extractCellGroupName(json['cellGroup']),
          location: person['placeOfWork'] as String?,
        );
      }

      // Handle simple contact structure
      return Contact(
        id: json['id'] as int,
        name: json['name'] as String,
        avatar:
            json['avatar'] as String? ??
            'https://gravatar.com/avatar/default?s=200&d=retro',
        ageGroup: json['ageGroup'] as String?,
        dateOfBirth: json['dateOfBirth'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        cellGroup: _extractCellGroupName(json['cellGroup']),
        location: json['location'] as String?,
      );
    } catch (e) {
      print('Contact.fromJson ERROR: Failed to parse contact: $e');
      print('Contact.fromJson ERROR: JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'ageGroup': ageGroup,
      'dateOfBirth': dateOfBirth,
      'email': email,
      'phone': phone,
      'cellGroup': cellGroup,
      'location': location,
    };
  }

  static List<Contact> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Contact.fromJson(json)).toList();
  }

  // Helper method to extract cell group name from object or string
  static String? _extractCellGroupName(dynamic cellGroup) {
    if (cellGroup == null) return null;
    if (cellGroup is String) return cellGroup;
    if (cellGroup is Map<String, dynamic>) {
      return cellGroup['name'] as String?;
    }
    return cellGroup.toString();
  }

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email)';
  }
}

// Person model for detailed view
class Person {
  final int id;
  final String? salutation;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? ageGroup;
  final String? placeOfWork;
  final String? gender;
  final String? civilStatus;
  final String avatar;
  final String dateOfBirth;
  final int contactId;

  Person({
    required this.id,
    this.salutation,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.ageGroup,
    this.placeOfWork,
    this.gender,
    this.civilStatus,
    required this.avatar,
    required this.dateOfBirth,
    required this.contactId,
  });

  String get fullName {
    final List<String> nameParts = [];
    if (firstName.isNotEmpty) nameParts.add(firstName);
    if (middleName?.isNotEmpty ?? false) nameParts.add(middleName!);
    if (lastName.isNotEmpty) nameParts.add(lastName);
    return nameParts.join(' ');
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      salutation: json['salutation'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      middleName: json['middleName'] as String?,
      ageGroup: json['ageGroup'] as String?,
      placeOfWork: json['placeOfWork'] as String?,
      gender: json['gender'] as String?,
      civilStatus: json['civilStatus'] as String?,
      avatar: json['avatar'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      contactId: json['contactId'] as int,
    );
  }

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
}

// Email model
class ContactEmail {
  final int id;
  final String category;
  final String value;
  final bool isPrimary;
  final int contactId;

  ContactEmail({
    required this.id,
    required this.category,
    required this.value,
    required this.isPrimary,
    required this.contactId,
  });

  factory ContactEmail.fromJson(Map<String, dynamic> json) {
    return ContactEmail(
      id: json['id'] as int,
      category: json['category'] as String,
      value: json['value'] as String,
      isPrimary: json['isPrimary'] as bool,
      contactId: json['contactId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'value': value,
      'isPrimary': isPrimary,
      'contactId': contactId,
    };
  }
}

// Phone model
class ContactPhone {
  final int id;
  final String category;
  final String value;
  final bool isPrimary;
  final int contactId;

  ContactPhone({
    required this.id,
    required this.category,
    required this.value,
    required this.isPrimary,
    required this.contactId,
  });

  factory ContactPhone.fromJson(Map<String, dynamic> json) {
    return ContactPhone(
      id: json['id'] as int,
      category: json['category'] as String,
      value: json['value'] as String,
      isPrimary: json['isPrimary'] as bool,
      contactId: json['contactId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'value': value,
      'isPrimary': isPrimary,
      'contactId': contactId,
    };
  }
}

// Group membership model
class GroupMembership {
  final int id;
  final int groupId;
  final int contactId;
  final String role;
  final Group group;

  GroupMembership({
    required this.id,
    required this.groupId,
    required this.contactId,
    required this.role,
    required this.group,
  });

  factory GroupMembership.fromJson(Map<String, dynamic> json) {
    return GroupMembership(
      id: json['id'] as int,
      groupId: json['groupId'] as int,
      contactId: json['contactId'] as int,
      role: json['role'] as String,
      group: Group.fromJson(json['group']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'contactId': contactId,
      'role': role,
      'group': group.toJson(),
    };
  }
}

// Group model
class Group {
  final int id;
  final String privacy;
  final String name;
  final String? details;
  final String? metaData;
  final int? parentId;
  final String? address;

  Group({
    required this.id,
    required this.privacy,
    required this.name,
    this.details,
    this.metaData,
    this.parentId,
    this.address,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as int,
      privacy: json['privacy'] as String,
      name: json['name'] as String,
      details: json['details'] as String?,
      metaData: json['metaData'] as String?,
      parentId: json['parentId'] as int?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'privacy': privacy,
      'name': name,
      'details': details,
      'metaData': metaData,
      'parentId': parentId,
      'address': address,
    };
  }
}

// Contact details model for full contact information
class ContactDetails {
  final int id;
  final String category;
  final Person person;
  final List<ContactEmail> emails;
  final List<ContactPhone> phones;
  final List<dynamic> addresses; // Can be expanded later
  final List<dynamic> identifications; // Can be expanded later
  final List<dynamic> requests; // Can be expanded later
  final List<dynamic> relationships; // Can be expanded later
  final List<GroupMembership> groupMemberships;

  ContactDetails({
    required this.id,
    required this.category,
    required this.person,
    required this.emails,
    required this.phones,
    required this.addresses,
    required this.identifications,
    required this.requests,
    required this.relationships,
    required this.groupMemberships,
  });

  // Get primary email
  String get primaryEmail {
    if (emails.isEmpty) return '';
    final primary = emails.firstWhere(
      (email) => email.isPrimary,
      orElse: () => emails.first,
    );
    return primary.value;
  }

  // Get primary phone
  String get primaryPhone {
    if (phones.isEmpty) return '';
    final primary = phones.firstWhere(
      (phone) => phone.isPrimary,
      orElse: () => phones.first,
    );
    return primary.value;
  }

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      id: json['id'] as int,
      category: json['category'] as String,
      person: Person.fromJson(json['person']),
      emails: (json['emails'] as List<dynamic>)
          .map((e) => ContactEmail.fromJson(e))
          .toList(),
      phones: (json['phones'] as List<dynamic>)
          .map((p) => ContactPhone.fromJson(p))
          .toList(),
      addresses: json['addresses'] as List<dynamic>,
      identifications: json['identifications'] as List<dynamic>,
      requests: json['requests'] as List<dynamic>,
      relationships: json['relationships'] as List<dynamic>,
      groupMemberships: (json['groupMemberships'] as List<dynamic>)
          .map((gm) => GroupMembership.fromJson(gm))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'person': person.toJson(),
      'emails': emails.map((e) => e.toJson()).toList(),
      'phones': phones.map((p) => p.toJson()).toList(),
      'addresses': addresses,
      'identifications': identifications,
      'requests': requests,
      'relationships': relationships,
      'groupMemberships': groupMemberships.map((gm) => gm.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'ContactDetails(id: $id, name: ${person.fullName}, category: $category)';
  }
}

// For backward compatibility, create an alias
typedef People = Contact;
