import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// On-device job-card PDF (no server round-trip; Hive is truth).
///
/// All figures arrive pre-formatted from the UI layer (the same strings the
/// dossier renders, e.g. `moneyAED`), so totals in the file are identical to
/// the on-screen totals by construction. Latin identifiers (plate, VIN,
/// phone, odometer, money) always render LTR; Arabic labels render with the
/// embedded Arabic font in RTL direction.
class JobCardPdfData {
  final String title;
  final String jobId;
  final String generatedAt;
  final String customerLabel;
  final String customerName;
  final String phone;
  final String vehicleLabel;
  final String vehicleInfo;
  final String plate;
  final String vin;
  final String odometer;
  final String fuelLevel;
  final String broughtByLabel;
  final String broughtBy;
  final String advisorLabel;
  final String advisorName;
  final String statusLabel;
  final String status;
  final String workLabel;
  final List<JobCardPdfLine> lines;
  final String commentsLabel;
  final List<JobCardPdfComment> comments;
  final String totalLabel;
  final List<JobCardPdfAmount> amounts;
  final String totalValue;
  final String signaturesLabel;
  final String customerSigLabel;
  final String advisorSigLabel;
  final String unsignedLabel;
  final Uint8List? customerSignature;
  final Uint8List? advisorSignature;
  final bool rtl;

  const JobCardPdfData({
    required this.title,
    required this.jobId,
    required this.generatedAt,
    required this.customerLabel,
    required this.customerName,
    required this.phone,
    required this.vehicleLabel,
    required this.vehicleInfo,
    required this.plate,
    required this.vin,
    required this.odometer,
    required this.fuelLevel,
    required this.broughtByLabel,
    required this.broughtBy,
    required this.advisorLabel,
    required this.advisorName,
    required this.statusLabel,
    required this.status,
    required this.workLabel,
    this.lines = const [],
    required this.commentsLabel,
    this.comments = const [],
    required this.totalLabel,
    this.amounts = const [],
    required this.totalValue,
    required this.signaturesLabel,
    required this.customerSigLabel,
    required this.advisorSigLabel,
    required this.unsignedLabel,
    this.customerSignature,
    this.advisorSignature,
    this.rtl = false,
  });
}

class JobCardPdfLine {
  final String description;
  final String status;
  const JobCardPdfLine({required this.description, required this.status});
}

class JobCardPdfComment {
  final String author;
  final String at;
  final String text;
  const JobCardPdfComment({
    required this.author,
    required this.at,
    required this.text,
  });
}

class JobCardPdfAmount {
  final String label;
  final String value;
  const JobCardPdfAmount({required this.label, required this.value});
}

Future<ByteData> _defaultArabicRegular() => rootBundle.load(
  'packages/shared_core/assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf',
);

Future<ByteData> _defaultArabicBold() => rootBundle.load(
  'packages/shared_core/assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-Bold.ttf',
);

/// Builds the job-card PDF. [fontRegular]/[fontBold] override the bundled
/// Arabic fonts (used by tests). Throws nothing for missing optional data —
/// empty sections are omitted, never invented.
Future<Uint8List> buildJobCardPdf(
  JobCardPdfData data, {
  Future<ByteData> Function()? fontRegular,
  Future<ByteData> Function()? fontBold,
}) async {
  final regular = pw.Font.ttf(
    await (fontRegular ?? _defaultArabicRegular)(),
  );
  final bold = pw.Font.ttf(await (fontBold ?? _defaultArabicBold)());
  final baseStyle = pw.TextStyle(font: regular, fontSize: 10);
  final labelStyle = pw.TextStyle(
    font: bold,
    fontSize: 10,
    color: PdfColors.grey700,
  );
  final titleStyle = pw.TextStyle(
    font: bold,
    fontSize: 20,
    color: PdfColors.white,
  );
  final sectionStyle = pw.TextStyle(font: bold, fontSize: 13);
  final ltr = pw.TextDirection.ltr;
  final dir = data.rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

  pw.Widget fact(String label, String value, {bool valueLtr = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style: labelStyle,
              textDirection: dir,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value.isEmpty ? '-' : value,
              style: baseStyle,
              textDirection: valueLtr ? ltr : dir,
            ),
          ),
        ],
      ),
    );
  }

  final doc = pw.Document(
    title: '${data.title} ${data.jobId}',
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      header: (context) => pw.Container(
        color: PdfColors.blue900,
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '${data.title} ${data.jobId}',
              style: titleStyle,
              textDirection: ltr,
            ),
            pw.Text(
              data.generatedAt,
              style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.white),
              textDirection: ltr,
            ),
          ],
        ),
      ),
      build: (context) => [
        pw.SizedBox(height: 12),
        fact(data.customerLabel, data.customerName),
        if (data.phone.isNotEmpty)
          fact('Phone', data.phone, valueLtr: true),
        fact(data.vehicleLabel, data.vehicleInfo),
        if (data.plate.isNotEmpty) fact('Plate', data.plate, valueLtr: true),
        if (data.vin.isNotEmpty) fact('VIN', data.vin, valueLtr: true),
        if (data.odometer.isNotEmpty)
          fact('Odometer', data.odometer, valueLtr: true),
        if (data.fuelLevel.isNotEmpty) fact('Fuel', data.fuelLevel),
        if (data.broughtBy.isNotEmpty)
          fact(data.broughtByLabel, data.broughtBy),
        fact(data.advisorLabel, data.advisorName),
        fact(data.statusLabel, data.status),
        if (data.lines.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text(data.workLabel, style: sectionStyle, textDirection: dir),
          pw.SizedBox(height: 6),
          for (var i = 0; i < data.lines.length; i++)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Row(
                children: [
                  pw.Text(
                    '${i + 1}. ',
                    style: baseStyle,
                    textDirection: ltr,
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      data.lines[i].description,
                      style: baseStyle,
                      textDirection: dir,
                    ),
                  ),
                  pw.Text(
                    data.lines[i].status,
                    style: labelStyle,
                    textDirection: dir,
                  ),
                ],
              ),
            ),
        ],
        if (data.comments.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text(data.commentsLabel, style: sectionStyle, textDirection: dir),
          pw.SizedBox(height: 6),
          for (final c in data.comments)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${c.author} · ${c.at}',
                    style: labelStyle,
                    textDirection: ltr,
                  ),
                  pw.Text(c.text, style: baseStyle, textDirection: dir),
                ],
              ),
            ),
        ],
        if (data.amounts.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text(data.totalLabel, style: sectionStyle, textDirection: dir),
          pw.SizedBox(height: 6),
          for (final a in data.amounts)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(a.label, style: baseStyle, textDirection: dir),
                pw.Text(a.value, style: baseStyle, textDirection: ltr),
              ],
            ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(data.totalLabel, style: sectionStyle, textDirection: dir),
              pw.Text(
                data.totalValue,
                style: pw.TextStyle(font: bold, fontSize: 12),
                textDirection: ltr,
              ),
            ],
          ),
        ],
        pw.SizedBox(height: 12),
        pw.Text(data.signaturesLabel, style: sectionStyle, textDirection: dir),
        pw.SizedBox(height: 6),
        pw.Row(
          children: [
            pw.Expanded(child: _sigBox(data.customerSigLabel, data.customerSignature, data.unsignedLabel, regular, bold)),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _sigBox(data.advisorSigLabel, data.advisorSignature, data.unsignedLabel, regular, bold)),
          ],
        ),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _sigBox(
  String label,
  Uint8List? image,
  String unsignedLabel,
  pw.Font regular,
  pw.Font bold,
) {
  return pw.Container(
    height: 120,
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(font: bold, fontSize: 10)),
        pw.SizedBox(height: 4),
        pw.Expanded(
          child: image != null && image.isNotEmpty
              ? pw.Image(pw.MemoryImage(image), fit: pw.BoxFit.contain)
              : pw.Center(
                  child: pw.Text(
                    unsignedLabel,
                    style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.grey600),
                  ),
                ),
        ),
      ],
    ),
  );
}
