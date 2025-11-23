import 'package:flutter/material.dart';
import '../../../../data/models/user/user.model.dart'; // Import User model

class BirthdayListPage extends StatelessWidget {
  final List<User> birthdays;

  const BirthdayListPage({super.key, required this.birthdays});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tất cả Sinh nhật Hôm nay')),
      body: ListView.builder(
        itemCount: birthdays.length,
        itemBuilder: (context, index) {
          final user = birthdays[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: user.color,
              child: Text(
                user.initials,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user.name),
            subtitle: Text(
              'Sinh nhật: ${user.dateOfBirth.day}/${user.dateOfBirth.month}',
            ),
          );
        },
      ),
    );
  }
}
