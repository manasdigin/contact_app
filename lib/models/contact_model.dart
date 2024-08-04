import 'package:uuid/uuid.dart';

class Contact {
  String id;
  String name;
  String email;
  String phoneNumber;
  String profilePicPath;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profilePicPath,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profilePicPath: json['profilePicPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicPath': profilePicPath,
    };
  }

  static Contact create({
    required String name,
    required String email,
    required String phoneNumber,
    required String profilePicPath,
  }) {
    final id = const Uuid().v4(); // Generate a unique id
    return Contact(
      id: id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      profilePicPath: profilePicPath,
    );
  }
}
