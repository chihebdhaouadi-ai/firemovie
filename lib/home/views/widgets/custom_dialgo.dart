import 'package:flutter/material.dart';
import '../../../core/widgets/game_button.dart';

class CustomDialog extends StatelessWidget {
  final String message;
  final Color textColor;
  final String buttonText;

  CustomDialog({required this.message, required this.textColor, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color.fromARGB(255, 30, 30, 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        height: 150,
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: TextStyle(color: textColor, fontSize: 20),
              ),
              SizedBox(height: 20),
              GameButton(
                label: buttonText,
                style: GameButtonStyle.dark,
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
