import 'package:flutter/material.dart';

class JournalCard extends StatelessWidget {
  const JournalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.menu_book),

        title: const Text("Today's Journal"),

        subtitle: const Text(
          "Write your thoughts...",
        ),

        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}