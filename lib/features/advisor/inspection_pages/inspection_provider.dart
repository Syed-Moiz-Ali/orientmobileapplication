import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/data/models/inspection_vew_model.dart';

class InspectionState {
  final Map<String, ItemStatus> statuses;
  final Map<String, bool> collapsed;
  final Map<String, ItemMedia> media;
  final bool notifyOwner;
  final String globalSearch;
  final Map<String, String> sectionSearch;
  final bool showAll;
  final List<String> preServicePhotos;
  final List<ServiceLineItem> serviceLines;
  final List<PartLineItem> partLines;
  final String referenceNumber;
  final String placeOfSupply;
  final String customerRequests;
  final String garageRecommendations;
  final DateTime? estimatedDelivery;
  final bool notifyOwnerSmsEmail;
  final String tag;

  const InspectionState({
    this.statuses = const {},
    this.collapsed = const {},
    this.media = const {},
    this.notifyOwner = false,
    this.globalSearch = '',
    this.sectionSearch = const {},
    this.showAll = true,
    this.preServicePhotos = const [],
    this.serviceLines = const [],
    this.partLines = const [],
    this.referenceNumber = '',
    this.placeOfSupply = '',
    this.customerRequests = '',
    this.garageRecommendations = '',
    this.estimatedDelivery,
    this.notifyOwnerSmsEmail = false,
    this.tag = '',
  });

  InspectionState copyWith({
    Map<String, ItemStatus>? statuses,
    Map<String, bool>? collapsed,
    Map<String, ItemMedia>? media,
    bool? notifyOwner,
    String? globalSearch,
    Map<String, String>? sectionSearch,
    bool? showAll,
    List<String>? preServicePhotos,
    List<ServiceLineItem>? serviceLines,
    List<PartLineItem>? partLines,
    String? referenceNumber,
    String? placeOfSupply,
    String? customerRequests,
    String? garageRecommendations,
    DateTime? estimatedDelivery,
    bool? notifyOwnerSmsEmail,
    String? tag,
  }) {
    return InspectionState(
      statuses: statuses ?? this.statuses,
      collapsed: collapsed ?? this.collapsed,
      media: media ?? this.media,
      notifyOwner: notifyOwner ?? this.notifyOwner,
      globalSearch: globalSearch ?? this.globalSearch,
      sectionSearch: sectionSearch ?? this.sectionSearch,
      showAll: showAll ?? this.showAll,
      preServicePhotos: preServicePhotos ?? this.preServicePhotos,
      serviceLines: serviceLines ?? this.serviceLines,
      partLines: partLines ?? this.partLines,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      customerRequests: customerRequests ?? this.customerRequests,
      garageRecommendations:
          garageRecommendations ?? this.garageRecommendations,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      notifyOwnerSmsEmail: notifyOwnerSmsEmail ?? this.notifyOwnerSmsEmail,
      tag: tag ?? this.tag,
    );
  }

  int get totalItems =>
      kInspectionSections.fold(0, (sum, s) => sum + s.items.length);

  int get completedCount => statuses.length;

  double get progressPercent =>
      totalItems == 0 ? 0 : completedCount / totalItems;

  double get servicesTotal => serviceLines.fold(0, (sum, s) => sum + s.amount);

  double get partsTotal => partLines.fold(0, (sum, p) => sum + p.amount);

  double get grandTotal => servicesTotal + partsTotal;

  List<InspectionSection> get filteredSections {
    return kInspectionSections.map((sec) {
      final filtered = sec.items.where((item) {
        final g = item.toLowerCase().contains(globalSearch.toLowerCase());
        final s = item.toLowerCase().contains(
          (sectionSearch[sec.id] ?? '').toLowerCase(),
        );
        return g && s;
      }).toList();
      return InspectionSection(id: sec.id, label: sec.label, items: filtered);
    }).toList();
  }
}

class InspectionNotifier extends Notifier<InspectionState> {
  @override
  InspectionState build() => const InspectionState();

  void setStatus(String itemId, ItemStatus? status) {
    final s = Map<String, ItemStatus>.from(state.statuses);
    if (status == null) {
      s.remove(itemId);
    } else if (s[itemId] == status) {
      s.remove(itemId);
    } else {
      s[itemId] = status;
    }
    state = state.copyWith(statuses: s);
  }

  void toggleCollapse(String sectionId) {
    final c = Map<String, bool>.from(state.collapsed);
    c[sectionId] = !(c[sectionId] ?? false);
    state = state.copyWith(collapsed: c);
  }

  void setShowAll() {
    state = state.copyWith(showAll: true, collapsed: {});
  }

  void setCollapseAll() {
    final c = <String, bool>{};
    for (final s in kInspectionSections) {
      c[s.id] = true;
    }
    state = state.copyWith(showAll: false, collapsed: c);
  }

  void setGlobalSearch(String q) {
    state = state.copyWith(globalSearch: q);
  }

  void setSectionSearch(String sectionId, String q) {
    final ss = Map<String, String>.from(state.sectionSearch);
    ss[sectionId] = q;
    state = state.copyWith(sectionSearch: ss);
  }

  void toggleNotifyOwner() {
    state = state.copyWith(notifyOwner: !state.notifyOwner);
  }

  void addPhoto(String itemId, String path) {
    final m = _updatedMediaWith(
      itemId,
      (im) => im.photoPaths = [...im.photoPaths, path],
    );
    state = state.copyWith(media: m);
  }

  void addVideo(String itemId, String path) {
    final m = _updatedMediaWith(
      itemId,
      (im) => im.videoPaths = [...im.videoPaths, path],
    );
    state = state.copyWith(media: m);
  }

  void setAudio(String itemId, String path) {
    final m = _updatedMediaWith(itemId, (im) => im.audioPath = path);
    state = state.copyWith(media: m);
  }

  void setNote(String itemId, String note) {
    final m = _updatedMediaWith(itemId, (im) => im.note = note);
    state = state.copyWith(media: m);
  }

  void removePhoto(String itemId, int index) {
    final im = state.media[itemId];
    if (im == null) return;
    final photos = List<String>.from(im.photoPaths)..removeAt(index);
    final m = _updatedMediaWith(itemId, (im2) => im2.photoPaths = photos);
    state = state.copyWith(media: m);
  }

  void removeVideo(String itemId, int index) {
    final im = state.media[itemId];
    if (im == null) return;
    final videos = List<String>.from(im.videoPaths)..removeAt(index);
    final m = _updatedMediaWith(itemId, (im2) => im2.videoPaths = videos);
    state = state.copyWith(media: m);
  }

  void addPreServicePhoto(String path) {
    state = state.copyWith(preServicePhotos: [...state.preServicePhotos, path]);
  }

  Map<String, ItemMedia> _updatedMediaWith(
    String itemId,
    void Function(ItemMedia) update,
  ) {
    final existing = state.media[itemId] ?? ItemMedia();
    final updated = ItemMedia(
      photoPaths: List<String>.from(existing.photoPaths),
      videoPaths: List<String>.from(existing.videoPaths),
      audioPath: existing.audioPath,
      note: existing.note,
    );
    update(updated);
    final m = Map<String, ItemMedia>.from(state.media);
    m[itemId] = updated;
    return m;
  }

  void addServices(List<String> names) {
    final existing = state.serviceLines.map((s) => s.name).toSet();
    final lines = List<ServiceLineItem>.from(state.serviceLines);
    for (final n in names) {
      if (!existing.contains(n)) lines.add(ServiceLineItem(name: n));
    }
    lines.removeWhere((s) => !names.contains(s.name));
    state = state.copyWith(serviceLines: lines);
  }

  void addParts(List<String> names) {
    final existing = state.partLines.map((p) => p.name).toSet();
    final lines = List<PartLineItem>.from(state.partLines);
    for (final n in names) {
      if (!existing.contains(n)) lines.add(PartLineItem(name: n));
    }
    lines.removeWhere((p) => !names.contains(p.name));
    state = state.copyWith(partLines: lines);
  }

  void updateServiceLine(
    int index, {
    int? qty,
    double? rate,
    double? discountPct,
    double? discountAmt,
  }) {
    if (index < 0 || index >= state.serviceLines.length) return;
    final lines = List<ServiceLineItem>.from(state.serviceLines);
    final s = lines[index];
    lines[index] = ServiceLineItem(
      name: s.name,
      qty: qty ?? s.qty,
      rate: rate ?? s.rate,
      discountPercent: discountPct ?? s.discountPercent,
      discountAmount: discountAmt ?? s.discountAmount,
    );
    state = state.copyWith(serviceLines: lines);
  }

  void updatePartLine(
    int index, {
    int? qty,
    double? rate,
    double? discountPct,
    double? discountAmt,
  }) {
    if (index < 0 || index >= state.partLines.length) return;
    final lines = List<PartLineItem>.from(state.partLines);
    final p = lines[index];
    lines[index] = PartLineItem(
      name: p.name,
      qty: qty ?? p.qty,
      rate: rate ?? p.rate,
      discountPercent: discountPct ?? p.discountPercent,
      discountAmount: discountAmt ?? p.discountAmount,
    );
    state = state.copyWith(partLines: lines);
  }

  void setReferenceNumber(String v) =>
      state = state.copyWith(referenceNumber: v);
  void setPlaceOfSupply(String v) => state = state.copyWith(placeOfSupply: v);
  void setCustomerRequests(String v) =>
      state = state.copyWith(customerRequests: v);
  void setGarageRecommendations(String v) =>
      state = state.copyWith(garageRecommendations: v);
  void setEstimatedDelivery(DateTime dt) =>
      state = state.copyWith(estimatedDelivery: dt);
  void toggleNotifyOwnerSmsEmail() =>
      state = state.copyWith(notifyOwnerSmsEmail: !state.notifyOwnerSmsEmail);
  void setTag(String v) => state = state.copyWith(tag: v);

  void reset() {
    state = const InspectionState();
  }

  void res() {
    state = state.copyWith(
      statuses: {},
      globalSearch: '',
      showAll: true,
      tag: '',
      estimatedDelivery: null,
      customerRequests: '',
    );
  }
}

final inspectionProvider =
    NotifierProvider<InspectionNotifier, InspectionState>(
      InspectionNotifier.new,
    );
