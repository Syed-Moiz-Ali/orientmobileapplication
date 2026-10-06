import 'package:flutter/material.dart';

/// Renders the lightweight markdown used for job descriptions and customer
/// requests: `**bold**`, `*italic*` and `• bullet` lines. Anything else is
/// rendered as plain text, so unexpected input is never lost.
class AppMarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const AppMarkdownText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
  });

  static final RegExp _inline = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final lines = text.split('\n');
    final spans = <InlineSpan>[];
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      final bullet = line.startsWith('• ') || line.startsWith('- ');
      if (bullet) {
        line = line.substring(2);
        spans.add(
          TextSpan(
            text: '•  ',
            style: base.copyWith(fontWeight: FontWeight.w800),
          ),
        );
      }
      spans.addAll(_inlineSpans(line, base));
      if (i != lines.length - 1) spans.add(const TextSpan(text: '\n'));
    }
    return Text.rich(
      TextSpan(style: base, children: spans),
      textAlign: textAlign,
    );
  }

  List<InlineSpan> _inlineSpans(String text, TextStyle base) {
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _inline.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final bold = match.group(1) != null;
      final inner = (bold ? match.group(1) : match.group(2)) ?? '';
      spans.add(
        TextSpan(
          text: inner,
          style: bold
              ? base.copyWith(fontWeight: FontWeight.w800)
              : base.copyWith(fontStyle: FontStyle.italic),
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return spans;
  }
}
