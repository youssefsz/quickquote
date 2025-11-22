import 'package:flutter/cupertino.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ExitDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Exit QuickQuote?'),
      content: const Text('Are you sure you want to exit the app?'),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: false,
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Exit'),
        ),
      ],
    );
  }
}

