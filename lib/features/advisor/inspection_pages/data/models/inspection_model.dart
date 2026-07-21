enum ItemStatus { good, fair, poor }

extension ItemStatusExt on ItemStatus {
  String get label {
    switch (this) {
      case ItemStatus.good: return 'Good';
      case ItemStatus.fair: return 'Fair';
      case ItemStatus.poor: return 'Poor';
    }
  }
}

class InspectionSection {
  final String id;
  final String label;
  final List<String> items;
  const InspectionSection({required this.id, required this.label, required this.items});
}

const List<InspectionSection> kInspectionSections = [
  InspectionSection(
    id: 'interior_exterior',
    label: '01. INTERIOR/EXTERIOR',
    items: [
      'Head Light / Tail Light / Turn Signals',
      'Wiper Blade',
      'Mirror',
      'Emergency Brake Adjustment',
      'Horn Operation',
      'Fuel Tank Cap Gasket',
      'A/C Filter',
      'Seat Belts',
      'Dashboard Lights',
      'Clutch Operation',
    ],
  ),
  InspectionSection(
    id: 'under_vehicle',
    label: '02. UNDER VEHICLE',
    items: [
      'Shock Absorbers / Suspension',
      'Steering Gear Box',
      'Exhaust Pipes',
      'Engine Oil / Fluid Leaks',
      'Brake Lines',
      'U-Joints',
      'Fuel Lines',
      'Inspect Nuts and Bolts on Body Chassis',
    ],
  ),
  InspectionSection(
    id: 'under_hood',
    label: '03. UNDER HOOD',
    items: [
      'Fluid Level: Oil / Battery / Power Steering',
      'Engine Air Filter',
      'Drive Belts',
      'Engine Coolant Protection',
      'Cooling System Hoses / Heater Hoses',
      'Radiator Core',
    ],
  ),
  InspectionSection(
    id: 'battery',
    label: '04. BATTERY PERFORMANCE',
    items: [
      'Battery Terminal / Cables / Mounting',
      'Storage Capacity Test',
    ],
  ),
];

const List<String> kServiceList = [
  'A/c Overhauling',
  'Air filter blocked inspection',
  'Air filter replacement',
  'Alloy wheel damage/bent inspection',
  'Alternator overhauling',
  'Battery electrolyte inspection',
  'Battery voltage inspection',
  'Brake caliper pin kit inspection',
  'Brake disc wear inspection',
  'Brake drum inspection',
  'Brake fluid flush',
  'Clutch adjustment',
  'Cooling system flush',
  'Engine oil change',
  'Fuel filter replacement',
  'Power steering fluid change',
  'Radiator flush',
  'Spark plug replacement',
  'Timing belt replacement',
  'Wheel alignment',
];

const List<String> kPartList = [
  'A/C heater core',
  'Alloy wheel',
  'Alternator end cover',
  'Alternator one way clutch',
  'Brake booster',
  'Clutch cable',
  'Compact torque angle sensor',
  'Engine air filter',
  'Fuel filter',
  'Oil filter',
  'Spark plug',
  'Wiper blade',
  'Brake pad set',
  'Radiator cap',
  'Drive belt',
];
