import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_channel_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channels = <CrmChannelEntity>[
    CrmChannelEntity(
      label: 'WhatsApp',
      icon: Icons.chat_outlined,
      color: Color(0xFF1A8754),
      value: '128',
      trend: '12%',
      trendUp: true,
    ),
    CrmChannelEntity(
      label: 'Website',
      icon: Icons.language_rounded,
      color: Color(0xFF2563EB),
      value: '84',
      trend: '8%',
      trendUp: true,
    ),
    CrmChannelEntity(
      label: 'Phone',
      icon: Icons.phone_outlined,
      color: Color(0xFF6D28D9),
      value: '36',
      trend: '3%',
      trendUp: false,
    ),
    CrmChannelEntity(
      label: 'Walk-ins',
      icon: Icons.directions_walk_rounded,
      color: Color(0xFFB7791F),
      value: '22',
      trend: '5%',
      trendUp: true,
    ),
  ];

  for (final size in <Size>[
    const Size(320, 720),
    const Size(390, 844),
    const Size(800, 1024),
    const Size(1440, 900),
  ]) {
    testWidgets('CRM channel grid is overflow-free at ${size.width}px', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: CrmChannelGrid(channels: channels),
            ),
          ),
        ),
      );

      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Walk-ins'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
