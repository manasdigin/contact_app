import 'dart:io';
import 'package:contact_app/models/contact_model.dart';
import 'package:contact_app/providers/contact_form_state.dart';
import 'package:contact_app/providers/contact_state.dart';
import 'package:contact_app/ui/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ContactAddPage extends ConsumerStatefulWidget {
  const ContactAddPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContactAddPageState();
}

class _ContactAddPageState extends ConsumerState<ContactAddPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactProvider.notifier).state = Contacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contact = ref.watch(contactProvider);
    final contactNotifier = ref.read(contactProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () => _pickImage(contactNotifier, contact),
                child: Stack(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey.shade300,
                        child: contact.profilePicPath.isNotEmpty
                            ? ClipOval(
                                child: Image.file(
                                  File(contact.profilePicPath),
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.person, size: 100),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomFormField(
                labelText: 'Name',
                validator: _validateName,
                onSaved: (value) => contactNotifier.state.name = value ?? '',
              ),
              const SizedBox(height: 16),
              CustomFormField(
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                onSaved: (value) => contactNotifier.state.email = value ?? '',
              ),
              const SizedBox(height: 16),
              CustomFormField(
                labelText: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                onSaved: (value) =>
                    contactNotifier.state.phoneNumber = value ?? '',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(MediaQuery.of(context).size.width, 60),
                  backgroundColor: Colors.indigo,
                ),
                onPressed: () =>
                    _saveContact(context, contact, contactNotifier),
                child: const Text('Save Contact',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(
      StateController<Contacts> contactNotifier, Contacts contact) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      contactNotifier.state = Contacts(
        name: contact.name,
        email: contact.email,
        phoneNumber: contact.phoneNumber,
        profilePicPath: pickedFile.path,
      );
    }
  }

  String? _validateName(String? value) {
    if (value == null ||
        value.isEmpty ||
        !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Please enter a valid name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  Future<void> _saveContact(BuildContext context, Contacts contact,
      StateController<Contacts> contactNotifier) async {
    if (contact.profilePicPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile picture')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newContact = Contact(
        id: const Uuid().v4(),
        name: contact.name,
        email: contact.email,
        phoneNumber: contact.phoneNumber,
        profilePicPath: contact.profilePicPath,
      );

      ref.read(contactsProvider.notifier).addContact(newContact);
      Navigator.pop(context);
    }
  }
}
