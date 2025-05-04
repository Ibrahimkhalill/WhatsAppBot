import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FilterMessagesByPhone extends StatefulWidget {
  const FilterMessagesByPhone({super.key});

  @override
  _FilterMessagesByPhoneState createState() => _FilterMessagesByPhoneState();
}

class _FilterMessagesByPhoneState extends State<FilterMessagesByPhone> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('conversation'); // Your table name here

  List<Map<String, dynamic>> _filteredMessages = [];
  final String _phoneNumberToFilter =
      '8801746185116'; // Replace with desired phone number

  @override
  void initState() {
    super.initState();
    _filterMessagesByPhone();
  }

  void _filterMessagesByPhone() async {
    _databaseReference
        .orderByChild('from')
        .equalTo(_phoneNumberToFilter)
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          _filteredMessages = data.values
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      } else {
        setState(() {
          _filteredMessages = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Messages'),
      ),
      body: _filteredMessages.isEmpty
          ? Center(child: Text('No messages found'))
          : ListView.builder(
              itemCount: _filteredMessages.length,
              itemBuilder: (context, index) {
                final message = _filteredMessages[index];
                return ListTile(
                  title: Text(message['content'] ?? 'No Content'),
                  subtitle: Text('From: ${message['name'] ?? 'Unknown'}'),
                );
              },
            ),
    );
  }
}
