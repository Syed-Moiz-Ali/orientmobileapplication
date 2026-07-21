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
}
