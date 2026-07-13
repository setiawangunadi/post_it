import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:post_it/features/receipt_scanner/data/datasources/receipt_text_parser.dart';

TextLine _line(
  String text,
  double top, {
  double left = 20,
  double width = 200,
  double height = 16,
}) {
  return TextLine(
    text: text,
    elements: const [],
    boundingBox: Rect.fromLTWH(left, top, width, height),
    recognizedLanguages: const [],
    cornerPoints: const [],
    confidence: null,
    angle: null,
  );
}

void main() {
  test('captures discount, tax (PB1) and grand total from a thermal receipt',
      () {
    // Row spacing (~20px), row height (~16px) and the ~10px label/amount
    // skew below mirror measurements taken off the real photo (subtotal,
    // discount, service charge and tax rows sit only ~20px apart there),
    // which is what exposes the "closer amount steals a neighboring row's
    // label" failure mode this test guards against.
    double y = 0;
    double nextRow() {
      y += 20;
      return y;
    }

    final lines = <TextLine>[
      _line('BLUEWELL COFFEE', nextRow()),
      _line('----------------', nextRow()),
    ];

    void row(String label, String amount) {
      final top = nextRow();
      lines.add(_line(label, top + 10, left: 20, width: 200));
      lines.add(_line(amount, top, left: 550, width: 100));
    }

    lines.add(_line('Nasi Goreng Karage Sambal Matah', nextRow()));
    row('1x @55.000', '55.000');

    // "13 items" sits on the same row as "Subtotal :" on the real receipt
    // (both left of the amount), not on a row of its own.
    {
      final top = nextRow();
      lines.add(_line('13 items', top + 10, left: 20, width: 100));
      lines.add(_line('Subtotal :', top, left: 130, width: 120));
      lines.add(_line('496.000', top, left: 550, width: 100));
    }
    row('Employee Disc :', '-124.000');
    row('Service Charge', '20.460');
    row('PB1', '37.200');
    lines.add(_line('----------------', nextRow()));
    row('Grand Total :', '429.660');
    row('DEBIT CARD BCA :', '429.660');

    final recognized = RecognizedText(
      text: lines.map((l) => l.text).join('\n'),
      blocks: [
        TextBlock(
          text: '',
          lines: lines,
          boundingBox: Rect.zero,
          recognizedLanguages: const [],
          cornerPoints: const [],
        ),
      ],
    );

    final parsed = ReceiptTextParser.parse(recognized);

    expect(parsed.discount, 124000);
    expect(parsed.tax, 37200);
    expect(parsed.serviceCharge, 20460);
    expect(parsed.total, 429660);
    expect(
      parsed.items.map((i) => i.name),
      isNot(contains('DEBIT CARD BCA :')),
    );
    expect(parsed.items.map((i) => i.name), isNot(contains('Grand Total :')));
    // The "1x @55.000" qty/price label must be fully consumed rather than
    // leaking into the item name (the "@"-prefixed price is what this
    // receipt's items all use).
    expect(parsed.items, hasLength(1));
    expect(parsed.items.single.name, 'Nasi Goreng Karage Sambal Matah');
    expect(parsed.items.single.price, 55000);
  });

  test('still parses items/service charge/tax/total on a receipt without '
      'a discount row (regression guard for the global label-matching '
      'rewrite)', () {
    double y = 0;
    double nextRow() {
      y += 20;
      return y;
    }

    void row(List<TextLine> lines, String label, String amount) {
      final top = nextRow();
      lines.add(_line(label, top + 10, left: 20, width: 200));
      lines.add(_line(amount, top, left: 550, width: 100));
    }

    final lines = <TextLine>[
      _line('COFFEE SHOP', nextRow()),
      _line('----------------', nextRow()),
      _line('Fried Rice', nextRow()),
    ];
    row(lines, '1x 28.000', '28.000');
    lines.add(_line('Iced Tea', nextRow()));
    row(lines, '1x 12.000', '12.000');
    row(lines, 'Service Charge', '4.000');
    row(lines, 'Tax', '3.000');
    row(lines, 'Total', '47.000');

    final recognized = RecognizedText(
      text: lines.map((l) => l.text).join('\n'),
      blocks: [
        TextBlock(
          text: '',
          lines: lines,
          boundingBox: Rect.zero,
          recognizedLanguages: const [],
          cornerPoints: const [],
        ),
      ],
    );

    final parsed = ReceiptTextParser.parse(recognized);

    expect(parsed.items, hasLength(2));
    expect(parsed.items[0].name, 'Fried Rice');
    expect(parsed.items[0].price, 28000);
    expect(parsed.items[1].name, 'Iced Tea');
    expect(parsed.items[1].price, 12000);
    expect(parsed.serviceCharge, 4000);
    expect(parsed.tax, 3000);
    expect(parsed.total, 47000);
    expect(parsed.discount, isNull);
  });
}
