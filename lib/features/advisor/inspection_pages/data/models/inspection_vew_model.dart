class ItemMedia {
  List<String> photoPaths;
  List<String> videoPaths;
  String audioPath;
  String note;

  ItemMedia({
    List<String>? photoPaths,
    List<String>? videoPaths,
    this.audioPath = '',
    this.note = '',
  })  : photoPaths = photoPaths ?? [],
        videoPaths = videoPaths ?? [];

  bool get hasMedia =>
      photoPaths.isNotEmpty ||
      videoPaths.isNotEmpty ||
      audioPath.isNotEmpty ||
      note.isNotEmpty;

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
  int qty;
  double rate;
  double discountPercent;
  double discountAmount;

  ServiceLineItem({
    required this.name,
    this.qty = 1,
    this.rate = 0,
    this.discountPercent = 0,
    this.discountAmount = 0,
  });

  double get amount => (rate * qty) - discountAmount;

  Map<String, dynamic> toJson() => {
        'name': name,
        'qty': qty,
        'rate': rate,
        'discountPercent': discountPercent,
        'discountAmount': discountAmount,
      };

  factory ServiceLineItem.fromJson(Map<String, dynamic> json) =>
      ServiceLineItem(
        name: json['name'] as String,
        qty: json['qty'] as int? ?? 1,
        rate: (json['rate'] as num?)?.toDouble() ?? 0,
        discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
        discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      );
}

class PartLineItem {
  final String name;
  int qty;
  double rate;
  double discountPercent;
  double discountAmount;

  PartLineItem({
    required this.name,
    this.qty = 1,
    this.rate = 0,
    this.discountPercent = 0,
    this.discountAmount = 0,
  });

  double get amount => (rate * qty) - discountAmount;

  Map<String, dynamic> toJson() => {
        'name': name,
        'qty': qty,
        'rate': rate,
        'discountPercent': discountPercent,
        'discountAmount': discountAmount,
      };

  factory PartLineItem.fromJson(Map<String, dynamic> json) => PartLineItem(
        name: json['name'] as String,
        qty: json['qty'] as int? ?? 1,
        rate: (json['rate'] as num?)?.toDouble() ?? 0,
        discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
        discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      );
}
