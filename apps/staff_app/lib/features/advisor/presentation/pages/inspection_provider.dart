import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_view_model.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';

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
  final String jobCardId;
  final String bookingId;

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
    this.jobCardId = '',
    this.bookingId = '',
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
    String? jobCardId,
    String? bookingId,
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
      garageRecommendations: garageRecommendations ?? this.garageRecommendations,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      notifyOwnerSmsEmail: notifyOwnerSmsEmail ?? this.notifyOwnerSmsEmail,
      tag: tag ?? this.tag,
      jobCardId: jobCardId ?? this.jobCardId,
      bookingId: bookingId ?? this.bookingId,
    );
  }

  Map<String, dynamic> toPersistableMap() => {
    'statuses': statuses.map((k, v) => MapEntry(k, v.name)),
    'media': media.map((k, v) => MapEntry(k, v.toJson())),
    'preServicePhotos': preServicePhotos,
    'serviceLines': serviceLines.map((e) => e.toJson()).toList(),
    'partLines': partLines.map((e) => e.toJson()).toList(),
    'referenceNumber': referenceNumber,
    'placeOfSupply': placeOfSupply,
    'customerRequests': customerRequests,
    'garageRecommendations': garageRecommendations,
    'estimatedDelivery': estimatedDelivery?.toIso8601String(),
    'notifyOwner': notifyOwner,
    'notifyOwnerSmsEmail': notifyOwnerSmsEmail,
    'tag': tag,
    'jobCardId': jobCardId,
    'bookingId': bookingId,
  };

  factory InspectionState.fromPersistableMap(Map<dynamic, dynamic> rawMap) {
    final map = _deepCastMap(rawMap);
    final statusesRaw = map['statuses'] as Map<String, dynamic>? ?? {};
    final mediaRaw = map['media'] as Map<String, dynamic>? ?? {};
    final serviceLinesRaw = map['serviceLines'] as List<dynamic>? ?? [];
    final partLinesRaw = map['partLines'] as List<dynamic>? ?? [];

    return InspectionState(
      statuses: statusesRaw.map(
        (k, v) => MapEntry(
          k.toString(),
          ItemStatus.values.firstWhere((e) => e.name == v?.toString(), orElse: () => ItemStatus.good),
        ),
      ),
      media: mediaRaw.map(
        (k, v) => MapEntry(k.toString(), v is Map ? ItemMedia.fromJson(_deepCastMap(v)) : const ItemMedia()),
      ),
      preServicePhotos: (map['preServicePhotos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      serviceLines: serviceLinesRaw.whereType<Map>().map((e) => ServiceLineItem.fromJson(_deepCastMap(e))).toList(),
      partLines: partLinesRaw.whereType<Map>().map((e) => PartLineItem.fromJson(_deepCastMap(e))).toList(),
      referenceNumber: map['referenceNumber']?.toString() ?? '',
      placeOfSupply: map['placeOfSupply']?.toString() ?? '',
      customerRequests: map['customerRequests']?.toString() ?? '',
      garageRecommendations: map['garageRecommendations']?.toString() ?? '',
      estimatedDelivery: map['estimatedDelivery'] != null
          ? DateTime.tryParse(map['estimatedDelivery'].toString())
          : null,
      notifyOwnerSmsEmail: map['notifyOwnerSmsEmail'] as bool? ?? false,
      notifyOwner: map['notifyOwner'] as bool? ?? false,
      tag: map['tag']?.toString() ?? '',
      jobCardId: map['jobCardId']?.toString() ?? '',
      bookingId: map['bookingId']?.toString() ?? '',
    );
  }

  static Map<String, dynamic> _deepCastMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _deepCastMap(value));
      } else if (value is List) {
        return MapEntry(key.toString(), value.map((e) => e is Map ? _deepCastMap(e) : e).toList());
      }
      return MapEntry(key.toString(), value);
    });
  }

  int get totalItems => kInspectionSections.fold(0, (sum, s) => sum + s.items.length);

  int get completedCount => statuses.length;

  double get progressPercent => totalItems == 0 ? 0 : completedCount / totalItems;

  double get servicesTotal => serviceLines.fold(0, (sum, s) => sum + s.amount);

  double get partsTotal => partLines.fold(0, (sum, p) => sum + p.amount);

  double get grandTotal => servicesTotal + partsTotal;

  List<InspectionSection> get filteredSections {
    return kInspectionSections.map((sec) {
      final filtered = sec.items.where((item) {
        final g = item.toLowerCase().contains(globalSearch.toLowerCase());
        final s = item.toLowerCase().contains((sectionSearch[sec.id] ?? '').toLowerCase());
        return g && s;
      }).toList();
      return InspectionSection(id: sec.id, label: sec.label, items: filtered);
    }).toList();
  }
}

class InspectionNotifier extends Notifier<InspectionState> {
  @override
  InspectionState build() {
    try {
      final local = ref.read(advisorLocalDataSourceProvider);
      final draft = local.getDraft();
      if (draft != null) {
        return InspectionState.fromPersistableMap(draft);
      }
    } catch (_) {}

    final box = Hive.box<dynamic>('inspections');
    final intakeBookingId = box.get('intake_booking_id')?.toString() ?? '';
    return InspectionState(bookingId: intakeBookingId);
  }

  void _persistDraft() {
    try {
      final local = ref.read(advisorLocalDataSourceProvider);
      local.saveDraft(state.toPersistableMap());
    } catch (_) {}
  }

  void setStatus(String itemId, ItemStatus? status) {
    final s = Map<String, ItemStatus>.from(state.statuses);
    if (status == null || s[itemId] == status) {
      s.remove(itemId);
    } else {
      s[itemId] = status;
    }
    state = state.copyWith(statuses: s);
    _persistDraft();
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
    final im = state.media[itemId] ?? const ItemMedia();
    state = state.copyWith(
      media: {
        ...state.media,
        itemId: im.copyWith(photoPaths: [...im.photoPaths, path]),
      },
    );
    _persistDraft();
  }

  void addVideo(String itemId, String path) {
    final im = state.media[itemId] ?? const ItemMedia();
    state = state.copyWith(
      media: {
        ...state.media,
        itemId: im.copyWith(videoPaths: [...im.videoPaths, path]),
      },
    );
    _persistDraft();
  }

  void setAudio(String itemId, String path) {
    final im = state.media[itemId] ?? const ItemMedia();
    state = state.copyWith(
      media: {
        ...state.media,
        itemId: im.copyWith(audioPath: path),
      },
    );
    _persistDraft();
  }

  void setNote(String itemId, String note) {
    final im = state.media[itemId] ?? const ItemMedia();
    state = state.copyWith(
      media: {
        ...state.media,
        itemId: im.copyWith(note: note),
      },
    );
    _persistDraft();
  }

  void removePhoto(String itemId, int index) {
    final im = state.media[itemId];
    if (im == null) return;
    final photos = List<String>.from(im.photoPaths);
    if (index >= 0 && index < photos.length) {
      photos.removeAt(index);
    }
    state = state.copyWith(
      media: {
        ...state.media,
        itemId: im.copyWith(photoPaths: photos),
      },
    );
    _persistDraft();
  }

  void setMedia(String itemId, ItemMedia media) {
    state = state.copyWith(media: {...state.media, itemId: media});
    _persistDraft();
  }

  void removeVideo(String itemId, int index) {
    final im = state.media[itemId];
    if (im == null) return;
    final videos = List<String>.from(im.videoPaths);
    if (index >= 0 && index < videos.length) {
      videos.removeAt(index);
    }
    state = state.copyWith(
      media: {
        ...state.media,
        itemId: im.copyWith(videoPaths: videos),
      },
    );
    _persistDraft();
  }

  void addPreServicePhoto(String path) {
    state = state.copyWith(preServicePhotos: [...state.preServicePhotos, path]);
    _persistDraft();
  }

  void addServices(List<String> names) {
    final existing = state.serviceLines.map((s) => s.name).toSet();
    final lines = List<ServiceLineItem>.from(state.serviceLines);
    for (final n in names) {
      if (!existing.contains(n)) lines.add(ServiceLineItem(name: n));
    }
    lines.removeWhere((s) => !names.contains(s.name));
    state = state.copyWith(serviceLines: lines);
    _persistDraft();
  }

  void addParts(List<String> names) {
    final existing = state.partLines.map((p) => p.name).toSet();
    final lines = List<PartLineItem>.from(state.partLines);
    for (final n in names) {
      if (!existing.contains(n)) lines.add(PartLineItem(name: n));
    }
    lines.removeWhere((p) => !names.contains(p.name));
    state = state.copyWith(partLines: lines);
    _persistDraft();
  }

  void updateServiceLine(int index, {int? qty, double? rate, double? discountPct, double? discountAmt}) {
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
    _persistDraft();
  }

  void updatePartLine(int index, {int? qty, double? rate, double? discountPct, double? discountAmt}) {
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
    _persistDraft();
  }

  void setReferenceNumber(String v) {
    state = state.copyWith(referenceNumber: v);
    _persistDraft();
  }

  void setPlaceOfSupply(String v) {
    state = state.copyWith(placeOfSupply: v);
    _persistDraft();
  }

  void setCustomerRequests(String v) {
    state = state.copyWith(customerRequests: v);
    _persistDraft();
  }

  void setGarageRecommendations(String v) {
    state = state.copyWith(garageRecommendations: v);
    _persistDraft();
  }

  void setEstimatedDelivery(DateTime dt) {
    state = state.copyWith(estimatedDelivery: dt);
    _persistDraft();
  }

  void toggleNotifyOwnerSmsEmail() {
    state = state.copyWith(notifyOwnerSmsEmail: !state.notifyOwnerSmsEmail);
    _persistDraft();
  }

  void setJobCardId(String v) {
    state = state.copyWith(jobCardId: v);
    _persistDraft();
  }

  void setTag(String v) {
    state = state.copyWith(tag: v);
    _persistDraft();
  }

  Future<Result<void>> submitInspection() async {
    final local = ref.read(advisorLocalDataSourceProvider);
    final queue = ref.read(syncQueueProvider);
    final id = await IdGenerator.nextId('INS');

    final payload = state.toPersistableMap();
    await local.saveInspection(id, payload);

    final operation = SyncOperation(
      id: id,
      entityType: 'inspection',
      entityId: id,
      changeType: ChangeType.create,
      payload: payload,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await queue.enqueue(operation);

    await uploadInspectionMedia(id);
    await ref.read(syncEngineProvider).syncAll();

    await local.deleteDraft();
    Hive.box<dynamic>('inspections').delete('intake_booking_id');
    state = const InspectionState();

    return const Success(null);
  }

  Future<void> uploadInspectionMedia(String recordId) async {
    final paths = <String>[];
    for (final m in state.media.values) {
      paths.addAll(m.photoPaths);
      paths.addAll(m.videoPaths);
      if (m.audioPath.isNotEmpty) paths.add(m.audioPath);
    }
    paths.addAll(state.preServicePhotos);
    if (paths.isEmpty || kIsWeb) return;

    final mediaClient = MediaClient(ref.read(dioClientProvider));
    final pending = MediaUploadQueue(Hive.box<dynamic>('pending_media'));
    for (final path in paths) {
      try {
        await mediaClient.uploadMedia(recordId, path);
      } catch (_) {
        final pendingId = await IdGenerator.nextId('MED');
        await pending.enqueue(
          PendingMediaUpload(
            id: pendingId,
            recordId: recordId,
            filePath: path,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    }
  }

  void reset() {
    state = const InspectionState();
  }

  void res() {
    state = state.copyWith(statuses: {}, globalSearch: '', showAll: true, tag: '', customerRequests: '');
    _persistDraft();
  }
}

final inspectionProvider = NotifierProvider<InspectionNotifier, InspectionState>(InspectionNotifier.new);
