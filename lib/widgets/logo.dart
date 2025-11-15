import 'package:flutter/material.dart';

class HeartLogo extends StatelessWidget {
  final double size;

  const HeartLogo({super.key, this.size = 100.0});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.favorite,
      color: Colors.lightGreen[400],
      size: size,
      shadows: const [
        Shadow(
          blurRadius: 10.0,
          color: Color.fromRGBO(0, 0, 0, 0.2),
          offset: Offset(2.0, 2.0),
        ),
      ],
    );
  }
}
