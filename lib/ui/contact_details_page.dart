import 'dart:io';
import 'package:contact_app/models/contact_model.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailPage extends StatelessWidget {
  final Contact contact;

  const ContactDetailPage({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(contact.name)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 60),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.17),
                        offset: Offset(0, 10),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        contact.email,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            contact.phoneNumber,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.red,
                            child: IconButton(
                                tooltip: 'Call',
                                onPressed: () async {
                                  final call =
                                      Uri.parse("tel:${contact.phoneNumber}");
                                  if (await canLaunchUrl(call)) {
                                    launchUrl(call);
                                  } else {
                                    throw 'Could not launch $call';
                                  }
                                },
                                icon: const Icon(Icons.call,
                                    color: Colors.white, size: 20)),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: contact.profilePicPath.isNotEmpty
                        ? FileImage(File(contact.profilePicPath))
                        : null,
                    child: contact.profilePicPath.isEmpty
                        ? const Icon(Icons.person, size: 75)
                        : null,
                  ),
                ),
              ],
            ),
          ]),
        ));
  }
}
