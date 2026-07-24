class ItemMedia {
  final List<String> photoPaths;
  final List<String> videoPaths;
  final String audioPath;
  final String note;

  const ItemMedia({
    this.photoPaths = const [],
    this.videoPaths = const [],
    this.audioPath = '',
    this.note = '',
  });

  bool get hasMedia =>
      photoPaths.isNotEmpty ||
      videoPaths.isNotEmpty ||
      audioPath.isNotEmpty ||
      note.isNotEmpty;

  ItemMedia copyWith({
    List<String>? photoPaths,
    List<String>? videoPaths,
    String? audioPath,
    String? note,
  }) {
    return ItemMedia(
      photoPaths: photoPaths ?? this.photoPaths,
      videoPaths: videoPaths ?? this.videoPaths,
      audioPath: audioPath ?? this.audioPath,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
    'photoPaths': photoPaths,
    'videoPaths': videoPaths,
    'audioPath': audioPath,
    'note': note,
  };

  factory ItemMedia.fromJson(Map<String, dynamic> json) => ItemMedia(
    photoPaths: List<String>.from(json['photoPaths'] as List? ?? []),
    videoPaths: List<String>.from(json['videoPaths'] as List? ?? []),
    audioPath: json['audioPath'] as String? ?? '',
    note: json['note'] as String? ?? '',
  );
}

class ServiceLineItem {
  final String name;
  final int qty;
  final double rate;
  final double discountPercent;
  final double discountAmount;

  const ServiceLineItem({
    required this.name,
    this.qty = 1,
    this.rate = 0,
    this.discountPercent = 0,
    this.discountAmount = 0,
  });

  double get amount => (rate * qty) - discountAmount;

  ServiceLineItem copyWith({
    String? name,
    int? qty,
    double? rate,
    double? discountPercent,
    double? discountAmount,
  }) {
    return ServiceLineItem(
      name: name ?? this.name,
      qty: qty ?? this.qty,
      rate: rate ?? this.rate,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'qty': qty,
    'rate': rate,
    'discountPercent': discountPercent,
    'discountAmount': discountAmount,
  };

  factory ServiceLineItem.fromJson(Map<String, dynamic> json) => ServiceLineItem(
    name: json['name'] as String? ?? '',
    qty: json['qty'] as int? ?? 1,
    rate: (json['rate'] as num?)?.toDouble() ?? 0,
    discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
    discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
  );
}

class PartLineItem {
  final String name;
  final int qty;
  final double rate;
  final double discountPercent;
  final double discountAmount;

  const PartLineItem({
    required this.name,
    this.qty = 1,
    this.rate = 0,
    this.discountPercent = 0,
    this.discountAmount = 0,
  });

  double get amount => (rate * qty) - discountAmount;

  PartLineItem copyWith({
    String? name,
    int? qty,
    double? rate,
    double? discountPercent,
    double? discountAmount,
  }) {
    return PartLineItem(
      name: name ?? this.name,
      qty: qty ?? this.qty,
      rate: rate ?? this.rate,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'qty': qty,
    'rate': rate,
    'discountPercent': discountPercent,
    'discountAmount': discountAmount,
  };

  factory PartLineItem.fromJson(Map<String, dynamic> json) => PartLineItem(
    name: json['name'] as String? ?? '',
    qty: json['qty'] as int? ?? 1,
    rate: (json['rate'] as num?)?.toDouble() ?? 0,
    discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
    discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
  );
}
