import 'package:flutter/material.dart';

class HeadlineCustom extends StatelessWidget {
  const HeadlineCustom({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.teal),
        ),

        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
        ),
        Text(subtitle, style: TextStyle(fontSize: 16)),
        const SizedBox(height: 22),
      ],
    );
  }
}
