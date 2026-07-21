import 'package:flutter/widgets.dart';

class InspectionCallbacks {
  final VoidCallback onBack;
  final VoidCallback onSaveDraft;
  final VoidCallback onPreview;

  const InspectionCallbacks({
    required this.onBack,
    required this.onSaveDraft,
    required this.onPreview,
  });
}
