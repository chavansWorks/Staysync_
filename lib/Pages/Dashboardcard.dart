import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final DashboardItem item;

  DashboardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 40, color: Colors.blue),
          SizedBox(height: 8),
          Text(
            item.label,
            textAlign: TextAlign.center, 
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class DashboardItem {
  final IconData icon;
  final String label;

  DashboardItem(this.icon, this.label);
}
