import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

final ProfileSheetData adminProfileData = ProfileSheetData(
  name: 'Admin',
  initials: 'A',
  roleLabel: 'Admin',
  roleBadge: 'Super Admin \u2022 CRM',
  menuItems: [
    ProfileSheetItem(
      icon: Icons.person_outline_rounded,
      label: 'My Profile',
      onTap: () {},
    ),
    ProfileSheetItem(
      icon: Icons.settings_outlined,
      label: 'Settings',
      onTap: () {},
    ),
  ],
);
