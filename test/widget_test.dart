import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orientmobileapplication/features/auth/presentation/pages/role_selection_view.dart';

void main() {
  testWidgets('RoleSelectionView renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: const MaterialApp(
          home: RoleSelectionView(),
        ),
      ),
    );

    expect(find.text('Mass Auto Garage ERP'), findsOneWidget);
    expect(find.text('Select your role to continue'), findsOneWidget);
    expect(find.byType(RoleSelectionView), findsOneWidget);
  });
}
