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

  test('parses a venue/booking receipt: space-separated qty/price, '
      'per-item "0%" annotations, a bulleted item name and a combined '
      '"TAX & SERV" line, without double-counting the "PAKET/PROMO" / '
      '"FOOD & DRINK" category subtotals as items', () {
    double y = 0;
    double nextRow() {
      y += 20;
      return y;
    }

    final lines = <TextLine>[
      _line('STUDIO FAMILY KARAOKE', nextRow()),
      _line('----------------', nextRow()),
    ];

    // Each item spans two physical rows: name (+ a "0%" annotation to its
    // right, same row) then "qty  price" (space-separated, no "x"/"@")
    // with the line-total amount to its right.
    void itemRow(String name, String qtyPrice, String amount) {
      final nameTop = nextRow();
      lines.add(_line(name, nameTop, left: 20, width: 250));
      lines.add(_line('0%', nameTop, left: 550, width: 60));
      final priceTop = nextRow();
      lines.add(_line(qtyPrice, priceTop + 10, left: 20, width: 150));
      lines.add(_line(amount, priceTop, left: 550, width: 100));
    }

    itemRow('.PAKET FAMILY A', '1  310,000', '310,000');
    itemRow('(D) MIX PLATTER', '2  000', '000');
    itemRow('(D) HOT SPICY CHICKEN WING', '1  000', '000');
    itemRow('(D) LEMON TEA PITCHER', '1  000', '000');
    itemRow('MINERAL WATER', '2  10,000', '20,000');

    lines.add(_line('----------------', nextRow()));

    void row(String label, String amount) {
      final top = nextRow();
      lines.add(_line(label, top + 10, left: 20, width: 200));
      lines.add(_line(amount, top, left: 550, width: 100));
    }

    row('PAKET/PROMO', '310,000');
    row('FOOD & DRINK', '20,000');
    row('SUB TOTAL', '330,000');
    row('TAX & SERV', '66,000');
    row('TOTAL', '396,000');

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

    expect(parsed.merchantName, 'STUDIO FAMILY KARAOKE');
    expect(parsed.tax, 66000);
    expect(parsed.total, 396000);
    // The three package-included ("0" price) items are dropped, same as
    // any other free item — only the two priced items remain.
    expect(parsed.items, hasLength(2));
    expect(parsed.items[0].name, 'PAKET FAMILY A');
    expect(parsed.items[0].quantity, 1);
    expect(parsed.items[0].price, 310000);
    expect(parsed.items[1].name, 'MINERAL WATER');
    expect(parsed.items[1].quantity, 2);
    expect(parsed.items[1].price, 10000);
    // "PAKET/PROMO" and "FOOD & DRINK" are category subtotals, not items —
    // including them would double-count the 330,000 already covered above.
    final itemsTotal =
        parsed.items.fold(0.0, (sum, i) => sum + i.lineTotal);
    expect(itemsTotal, 330000);
  });

  test('gets tax and total right on the karaoke receipt\'s actual (heavily '
      'skewed, OCR-garbled) bounding boxes captured off a real device', () {
    // Exact top/left/height per line as reported by ML Kit on-device for
    // faktur-4.jpeg — including "TOTAL" misread as "TOTA L" (a stray
    // internal space) and the summary block's growing vertical skew,
    // which is what made "TAX & SERV" mismatch with the amount actually
    // belonging to the row below it (Total's) before this fix.
    final lines = [
      _line('STUO FATVIE', 300, left: 227, width: 200, height: 19),
      _line('DATETIME', 345, left: 128, width: 120, height: 16),
      _line('2026-07-12 I 19:53:10', 345, left: 366, width: 220, height: 17),
      _line('ROOM/TABLE', 367, left: 126, width: 150, height: 17),
      _line('R207', 367, left: 368, width: 60, height: 17),
      _line('CUST. NAME :MS PUTRI', 384, left: 123, width: 250, height: 26),
      _line('AMOUNT', 459, left: 587, width: 100, height: 24),
      _line('ITEM NAME', 466, left: 118, width: 150, height: 23),
      _line('0%', 519, left: 631, width: 40, height: 19),
      _line('.PAKET FAMILY A', 524, left: 116, width: 250, height: 27),
      _line('310,000', 546, left: 585, width: 100, height: 29),
      _line('1 310,000', 553, left: 186, width: 150, height: 34),
      _line('0%', 579, left: 639, width: 40, height: 23),
      _line('(D) MIX PLATTER', 585, left: 125, width: 250, height: 41),
      _line('000', 611, left: 600, width: 80, height: 25),
      _line('2 000', 620, left: 174, width: 120, height: 35),
      _line(
        '(D) HOT SPICY CHICKEN WING 0%',
        641,
        left: 126,
        width: 400,
        height: 56,
      ),
      _line('000', 681, left: 605, width: 80, height: 26),
      _line('1 000', 693, left: 177, width: 120, height: 33),
      _line('0%', 715, left: 650, width: 40, height: 25),
      _line('(D) LEMON TEA PITCHER', 719, left: 128, width: 250, height: 52),
      _line('000', 752, left: 609, width: 80, height: 25),
      _line('1 000', 768, left: 181, width: 120, height: 30),
      _line('0%', 786, left: 653, width: 40, height: 25),
      _line('MINERAL WATER', 797, left: 122, width: 250, height: 41),
      _line('20,000', 819, left: 602, width: 100, height: 31),
      _line('2 10,000', 837, left: 182, width: 150, height: 39),
      _line('310,000', 888, left: 610, width: 100, height: 35),
      _line('PAKET/PROMO', 907, left: 127, width: 200, height: 43),
      _line('20,000', 923, left: 619, width: 100, height: 32),
      _line('FOOD & DRINK', 944, left: 129, width: 200, height: 42),
      _line('330,000', 988, left: 611, width: 100, height: 35),
      _line('SUB TOTAL', 1020, left: 133, width: 200, height: 37),
      _line('66,000', 1022, left: 620, width: 100, height: 31),
      _line('TAX & SERV', 1052, left: 133, width: 200, height: 42),
      _line('396,000', 1081, left: 610, width: 100, height: 33),
      _line('TOTA L', 1126, left: 140, width: 150, height: 32),
    ];

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

    expect(parsed.tax, 66000);
    expect(parsed.total, 396000);
    expect(parsed.serviceCharge, isNull);
    expect(parsed.discount, isNull);
    expect(parsed.items.map((i) => i.price), everyElement(greaterThan(0)));
    expect(
      parsed.items.map((i) => i.name),
      isNot(anyElement(contains('PAKET/PROMO'))),
    );
    expect(
      parsed.items.map((i) => i.name),
      isNot(anyElement(contains('FOOD & DRINK'))),
    );
  });
}
