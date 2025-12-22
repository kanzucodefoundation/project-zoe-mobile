// class Shepherd {
//   final String id;
//   final String name;
//   final String email;
//   final String phone;
//   final String address;
//   final String churchLocation;
//   final String position;
//   final int yearsOfService;
//   final String emergencyPhone;
//   final String department;

//   Shepherd({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.address,
//     required this.churchLocation,
//     required this.position,
//     required this.yearsOfService,
//     required this.emergencyPhone,
//     required this.department,
//   });

//   factory Shepherd.fromJson(Map<String, dynamic> json) {
//     return Shepherd(
//       id: json['id'] ?? '',
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       phone: json['phone'] ?? '',
//       address: json['address'] ?? '',
//       churchLocation: json['churchLocation'] ?? '',
//       position: json['position'] ?? '',
//       yearsOfService: json['yearsOfService'] ?? 0,
//       emergencyPhone: json['emergencyPhone'] ?? '',
//       department: json['department'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'address': address,
//       'churchLocation': churchLocation,
//       'position': position,
//       'yearsOfService': yearsOfService,
//       'emergencyPhone': emergencyPhone,
//       'department': department,
//     };
//   }
// }
