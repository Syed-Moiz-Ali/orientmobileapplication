import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/src/widgets/app_confirmation_dialog.dart';

class ExitConfirmationWrapper extends StatelessWidget {
  final Widget child;

  const ExitConfirmationWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showExitConfirmationDialog(context);
        if (shouldExit) await SystemNavigator.pop();
      },
      child: child,
    );
  }
}

Future<bool> showExitConfirmationDialog(BuildContext context) {
  return showAppConfirmationDialog(
    context,
    title: 'Exit Orient Workshop?',
    message: 'Your current work is saved. Close the application now?',
    confirmLabel: 'Exit',
    icon: Icons.exit_to_app_rounded,
    destructive: true,
  );
}
