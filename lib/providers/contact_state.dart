import 'dart:convert';

import 'package:contact_app/models/contact_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, ContactsState>((ref) {
  return ContactsNotifier();
});

class ContactsState {
  final List<Contact> contacts;
  final bool isLoading;

  ContactsState({required this.contacts, required this.isLoading});
}

class ContactsNotifier extends StateNotifier<ContactsState> {
  ContactsNotifier() : super(ContactsState(contacts: [], isLoading: true)) {
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('contacts');
    List<Contact> loadedContacts = [];

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      loadedContacts = jsonList.map((json) => Contact.fromJson(json)).toList();
    }

    state = ContactsState(contacts: loadedContacts, isLoading: false);
  }

  void addContact(Contact contact) {
    final updatedContacts = [contact, ...state.contacts];
    state = ContactsState(contacts: updatedContacts, isLoading: false);
    _saveContacts();
  }

  void removeContact(Contact contact) {
    print('contact id: ${contact.id}');
    final updatedContacts =
        state.contacts.where((element) => element.id != contact.id).toList();
    state = ContactsState(contacts: updatedContacts, isLoading: false);
    _saveContacts();
  }

  void updateContact(Contact contact) {
    final updatedContacts = state.contacts
        .map((element) => element.id == contact.id ? contact : element)
        .toList();
    state = ContactsState(contacts: updatedContacts, isLoading: false);
    _saveContacts();
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        jsonEncode(state.contacts.map((contact) => contact.toJson()).toList());
    prefs.setString('contacts', jsonString);
  }
}
