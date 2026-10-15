/// Phase 09 — display-only estimate projections for the Work Order Studio.
///
/// UI-ONLY CONTRACT: nothing here is serialized, persisted, or sent over the
/// wire, and none of it replaces the frozen math in
/// `inspection_provider.dart` (`ServiceLineItem.amount = rate*qty -
/// discountAmount`, `InspectionState.servicesTotal/partsTotal/grandTotal`).
/// These helpers only *project* the provider totals into the statutory 5% VAT
/// breakdown and classify / decorate lines for presentation, so the studio can
/// never invent a line total that disagrees with the providers.
library;

/// Repair confidence tier used by the studio grouping.
enum RepairTier { mandatory, optional }

/// UAE statutory VAT applied to the estimate base for display only.
const double kUaeVatRate = 0.05;

/// Deterministic safety classifier. A line whose name contains any safety
/// keyword is a mandatory safety repair; everything else is an optional
/// enhancement. Deterministic so goldens and tests stay stable.
const Set<String> kSafetyKeywords = <String>{
  'brake',
  'battery',
  'timing belt',
  'airbag',
  'air bag',
  'tyre',
  'tire',
  'steering',
  'suspension',
  'wheel bearing',
  'headlight',
  'seat belt',
  'abs',
  'radiator',
  'coolant',
};

RepairTier classifyRepairTier(String name) {
  final normalized = name.toLowerCase();
  for (final keyword in kSafetyKeywords) {
    if (normalized.contains(keyword)) return RepairTier.mandatory;
  }
  return RepairTier.optional;
}

/// Statutory VAT projection over the provider-owned parts/labor totals.
class RepairEstimateTotals {
  final double parts;
  final double labor;
  final double vat;

  const RepairEstimateTotals({
    required this.parts,
    required this.labor,
    required this.vat,
  });

  factory RepairEstimateTotals.from({
    required double partsTotal,
    required double laborTotal,
  }) {
    final base = partsTotal + laborTotal;
    return RepairEstimateTotals(
      parts: partsTotal,
      labor: laborTotal,
      vat: base * kUaeVatRate,
    );
  }

  double get subtotal => parts + labor;

  double get total => subtotal + vat;
}

/// Technician speciality surfaced as skill chips (display only).
enum TechSkill { brakes, ac, electrical, engine, suspension }

int _stableHash(String value) {
  var hash = 0;
  for (final unit in value.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}

/// Deterministic on-shelf bay / availability decorations for a parts row.
int stockBayFor(String name) => 1 + _stableHash('bay:$name') % 8;

bool inStockFor(String name) => _stableHash('stock:$name') % 3 != 0;

String orderEtaFor(String name) {
  const options = <String>['2h', '4h', '6h', '24h'];
  return options[_stableHash('eta:$name') % options.length];
}

/// Deterministic technician decorations (load, availability, skills).
int loadForTechnician(String empId) => _stableHash('load:$empId') % 6;

bool isFree(String empId) => loadForTechnician(empId) == 0;

String availabilityFor(String empId) {
  final load = loadForTechnician(empId);
  if (load == 0) return '0';
  final halfHours = ((_stableHash('avail:$empId') % 6) + 1);
  return '${(halfHours * 0.5).toStringAsFixed(1)}h';
}

List<TechSkill> skillsForTechnician(String empId) {
  const pool = TechSkill.values;
  final hash = _stableHash('skills:$empId');
  final first = pool[hash % pool.length];
  final second = pool[(hash ~/ 7) % pool.length];
  return first == second ? <TechSkill>[first] : <TechSkill>[first, second];
}
