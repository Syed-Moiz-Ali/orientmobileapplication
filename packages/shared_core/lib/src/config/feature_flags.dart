import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeatureFlags {
  final bool enableInspections;
  final bool enableReports;
  final bool enableChat;
  final bool enableNotifications;
  final bool enableSync;
  final bool enableOfflineMode;

  const FeatureFlags({
    this.enableInspections = true,
    this.enableReports = true,
    this.enableChat = true,
    this.enableNotifications = true,
    this.enableSync = true,
    this.enableOfflineMode = true,
  });

  static const FeatureFlags all = FeatureFlags();

  static const FeatureFlags minimal = FeatureFlags(
    enableReports: false,
    enableChat: false,
    enableSync: false,
    enableOfflineMode: false,
  );

  FeatureFlags copyWith({
    bool? enableInspections,
    bool? enableReports,
    bool? enableChat,
    bool? enableNotifications,
    bool? enableSync,
    bool? enableOfflineMode,
  }) =>
      FeatureFlags(
        enableInspections: enableInspections ?? this.enableInspections,
        enableReports: enableReports ?? this.enableReports,
        enableChat: enableChat ?? this.enableChat,
        enableNotifications: enableNotifications ?? this.enableNotifications,
        enableSync: enableSync ?? this.enableSync,
        enableOfflineMode: enableOfflineMode ?? this.enableOfflineMode,
      );
}

final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  return FeatureFlags.all;
});
