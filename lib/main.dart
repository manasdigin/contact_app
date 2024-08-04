import 'dart:io';

import 'package:contact_app/models/contact_model.dart';
import 'package:contact_app/providers/contact_state.dart';
import 'package:contact_app/ui/contact_add_page.dart';
import 'package:contact_app/ui/contact_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ContactListPage(),
    );
  }
}

class ContactListPage extends ConsumerStatefulWidget {
  const ContactListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ContactListPageState();
}

class _ContactListPageState extends ConsumerState<ContactListPage> {
  late FocusNode _focusNode;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  void _unfocus() {
    // Explicitly unfocus the TextFormField
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  List<Contact> _filterContacts(List<Contact> contacts, String query) {
    query = query.toLowerCase();
    return contacts.where((contact) {
      return contact.name.toLowerCase().contains(query) ||
          contact.email.toLowerCase().contains(query) ||
          contact.phoneNumber.contains(query);
    }).toList();
  }

  String toTitleCase(String name) {
    return name.split(' ').map((str) {
      if (str.isEmpty) return '';
      return str[0].toUpperCase() + str.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contactsProvider);

    final filteredContacts = _filterContacts(state.contacts, _searchQuery);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact List'),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextFormField(
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Search by name, email, or phone',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: filteredContacts.isEmpty
                    ? const Center(child: Text('No contacts found'))
                    : ListView.builder(
                        itemCount: filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = filteredContacts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Card(
                              child: ListTile(
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    ref
                                        .read(contactsProvider.notifier)
                                        .removeContact(contact);
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          ContactDetailPage(
                                        contact: contact,
                                      ),
                                      transitionsBuilder: (_, a, __, c) =>
                                          FadeTransition(opacity: a, child: c),
                                    ),
                                  ).then((_) {
                                    // Unfocus the TextFormField when returning from details page
                                    _unfocus();
                                  });
                                },
                                tileColor: Colors.white70,
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: contact
                                          .profilePicPath.isNotEmpty
                                      ? FileImage(File(contact.profilePicPath))
                                      : null,
                                  child: contact.profilePicPath.isEmpty
                                      ? const Icon(Icons.person, size: 30)
                                      : null,
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(contact.phoneNumber,
                                        style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      toTitleCase(
                                        contact.name,
                                      ),
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      contact.email,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return const ContactAddPage();
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end);
              var offsetAnimation =
                  animation.drive(tween.chain(CurveTween(curve: curve)));

              return SlideTransition(position: offsetAnimation, child: child);
            },
          ))
              .then((_) {
            _unfocus();
          });
        },
        tooltip: 'Add Contact',
        child: const Icon(Icons.add),
      ),
    );
  }
}
