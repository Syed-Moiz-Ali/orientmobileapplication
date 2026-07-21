import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';

/// A wrapper widget that intercepts the system back button (via PopScope)
/// and displays a premium exit confirmation dialog.
class ExitConfirmationWrapper extends StatelessWidget {
  final Widget child;

  const ExitConfirmationWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showExitConfirmationDialog(context);
        if (shouldExit) {
          await SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}

/// Shows a premium exit confirmation dialog.
/// Returns true if the user confirmed they want to exit, false otherwise.
Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.s20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(AppDimensions.r16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.dangerBorder,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: AppColors.danger,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Exit Application?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to close the Orient Mobile application?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text3,
                  height: 1.4,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.r10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.text2,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.r10),
                        ),
                      ),
                      child: const Text(
                        'Exit',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
