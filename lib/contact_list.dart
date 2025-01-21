import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:whatapp/chat.dart';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() {
      _isLoading = true;
    });

    // Request permission to access contacts
    if (await FlutterContacts.requestPermission()) {
      try {
        // Fetch contacts
        List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true, // Include phone numbers and emails
        );

        // Sort contacts alphabetically by display name
        contacts.sort(
            (a, b) => (a.displayName ?? '').compareTo(b.displayName ?? ''));

        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      } catch (e) {
        print('Error fetching contacts: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching contacts!')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission denied!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: const Color(0xff0F0F0F),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? const Center(
                  child: Text(
                    'No Contacts Found',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];

                    // Ensure the contact has at least one phone number
                    if (contact.phones.isEmpty) {
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          contact.displayName ?? 'No Name',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'No Number',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Chat(
                              userId: contact.phones.first.number,
                              userName: contact.displayName ?? 'Unknown',
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Text(
                            contact.displayName?.isNotEmpty == true
                                ? contact.displayName![0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          contact.displayName ?? 'No Name',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          contact.phones.first.number,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
      backgroundColor: Colors.black,
    );
  }
}
