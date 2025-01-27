import 'package:flutter/material.dart';

class IconWithTextButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const IconWithTextButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: Colors.white,
        ),
        Text(label,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;

  CustomButton({
    required this.label,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160, // Customize the width of the button
        height: 50, // Customize the height of the button
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3), // Soft shadow effect
              blurRadius: 8,
              offset: Offset(0, 4), // Shadow position
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, // Dynamic icon
                color: Colors.white,
                size: 24, // Customize icon size
              ),
              SizedBox(width: 8), // Space between icon and text
              Text(
                label, // Dynamic button text
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Customize font size
                  fontWeight: FontWeight.w600, // Semi-bold font weight
                  letterSpacing: 1.1, // Spacing between letters for better readability
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
