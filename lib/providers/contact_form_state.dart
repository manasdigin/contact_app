import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactProvider = StateProvider<Contacts>((ref) {
  return Contacts();
});

class Contacts {
  String name;
  String email;
  String phoneNumber;
  String profilePicPath;

  Contacts({
    this.name = '',
    this.email = '',
    this.phoneNumber = '',
    this.profilePicPath = '',
  });
}
