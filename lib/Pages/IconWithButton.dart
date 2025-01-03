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
