import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/entities/receipt.dart';

class ParsedReceipt {
  final String? merchantName;
  final List<ReceiptItem> items;
  final double? total;
  final double? serviceCharge;
  final double? tax;
  final double? adjustment;

  /// Amount deducted off the subtotal, stored as a non-negative magnitude
  /// (e.g. a "-124.000" discount line is captured as `124000`) so callers
  /// can uniformly subtract it when computing totals.
  final double? discount;

  const ParsedReceipt({
    this.merchantName,
    required this.items,
    this.total,
    this.serviceCharge,
    this.tax,
    this.adjustment,
    this.discount,
  });
}

enum _ColumnType { description, quantity, price, total }

class _ColumnHeader {
  final _ColumnType type;
  final double center;
  final TextLine line;

  const _ColumnHeader({
    required this.type,
    required this.center,
    required this.line,
  });
}

/// Best-effort heuristic parser that turns ML Kit's recognized text into
/// structured line items.
///
/// Receipts are laid out in two columns (item name/qty on the left, amount
/// right-aligned). ML Kit groups recognized text into spatial blocks rather
/// than visual rows, so the flattened [RecognizedText.text] string
/// interleaves the two columns out of order. Instead, this parser uses each
/// line's bounding box: every amount-shaped line is paired with the single
/// closest text line to its left (its "label", e.g. "1x 28.000" or
/// "Total"), which is far more tolerant of a skewed/crooked photo than
/// trying to bucket lines into strict horizontal rows.
///
/// This is not exact — layouts vary a lot — so the UI lets the user
/// review/edit items before saving.
class ReceiptTextParser {
  ReceiptTextParser._();

  static final _fullAmount = RegExp(
    r'^(?:Rp\.?\s*)?(-?\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{1,2})?)$',
    caseSensitive: false,
  );

  // The unit price is often prefixed with "@" (e.g. "1x @49.000") rather
  // than a bare "1x 49.000" — without tolerating it here, every item on
  // that receipt style fails to match, and its qty/price text leaks into
  // the item name instead of being consumed as a label. Some POS software
  // (e.g. karaoke/venue booking systems) drops the "x"/"@" marker entirely
  // and prints just "1  310,000" — the qty and price separated by
  // whitespace alone — so that's accepted too, but only via an *actual*
  // whitespace gap (never zero-width) so a plain multi-digit amount like
  // "1310.000" can't be misread as qty "1" + price "310.000".
  static final _qtyLabel =
      RegExp(r'^(\d+)(?:\s*[xX]\s*@?\s*|\s+)([\d.,]+)$');

  // OCR on thermal-printer receipts frequently confuses a leading "1" with
  // a lowercase "l" or capital "I" right before the "x" quantity marker
  // (e.g. "lx 34.000" instead of "1x 34.000").
  static String _normalizeQty(String text) =>
      text.replaceFirst(RegExp(r'^[lI](?=\s*[xX])'), '1');

  // Some receipts prefix each item name with a bullet-style character
  // (e.g. ".PAKET FAMILY A"), which isn't part of the actual item name.
  static String _stripLeadingBullet(String text) =>
      text.replaceFirst(RegExp(r'^[.\-*•]\s*'), '');

  // Service charge, tax/PPN, adjustment and discount are captured as their
  // own fields rather than discarded — kept as separate regexes (instead of
  // folding into _summaryLabel) so the parsing logic can branch on them
  // specifically.
  static final _serviceChargeLabel = RegExp(
    r'^service\s*charge\b',
    caseSensitive: false,
  );
  // "PB1" is a common label for restaurant/F&B tax on Indonesian receipts.
  static final _taxLabel =
      RegExp(r'^(tax|ppn|pb\s*1)\b', caseSensitive: false);
  static final _adjustmentLabel =
      RegExp(r'^adjustment\b', caseSensitive: false);

  // Unlike the other summary regexes, this isn't start-anchored: discount
  // labels are often prefixed with a qualifier (e.g. "Employee Disc",
  // "Member Discount") rather than starting with the keyword itself.
  static final _discountLabel = RegExp(
    r'\bdisc(?:ount)?\b|\bdiskon\b',
    caseSensitive: false,
  );

  // "Subtotal" is deliberately excluded from _isLabelShaped (see below):
  // its value is never used, and on receipts where the label's OCR
  // bounding box is noisy it can otherwise "steal" the amount that
  // actually belongs to the next row (Service Charge), cascading every
  // field after it down by one.
  //
  // The payment-method tokens (cash/card/etc.) aren't start-anchored since
  // they're frequently prefixed (e.g. "DEBIT CARD BCA"), but are still
  // wrapped in \b so they can't match as a substring of an unrelated word
  // (e.g. "card" inside "Postcard").
  static final _summaryLabel = RegExp(
    r'^(sub\s*total|total\s*item)\b|'
    r'\b(tender|change|kembali|cash|tunai|card|kartu|debit|credit|kredit|'
    r'transfer|qris|bayar)\b',
    caseSensitive: false,
  );

  static final _headerSkip = RegExp(
    r'^(date\s*/?\s*time|date|order\s*number|customer(\s*name)?|'
    r'cust\.?\s*name|sales\s*type|user|cashier|instagram|'
    r'tel\.?|telp\.?|npwp|www\.|jl\.|alamat|room\s*/?\s*table|table|'
    r'item\s*name|amount|invoice|receipt|kasir|no\.?\s*(bon|receipt))\b',
    caseSensitive: false,
  );

  // A bare date and/or time value printed as its own OCR line, separate
  // from its label (e.g. "DATE/TIME" and "2026-07-12 / 19:53:10" land as
  // two distinct lines side by side) — dropped the same way the label is,
  // rather than leaking into whichever item name follows.
  static final _dateTimeValueOnly = RegExp(
    r'^\d{4}[-/]\d{1,2}[-/]\d{1,2}\b|^\d{1,2}:\d{2}(?::\d{2})?$',
  );

  // A subtotal broken down by category (e.g. venue/booking receipts that
  // split "PAKET/PROMO" — package deals — from "FOOD & DRINK") rather than
  // one single "Subtotal" line. Discarded the same way subtotal is: the
  // combined items list is already the source of truth, so keeping these
  // would double-count everything they summarize as a bogus extra item.
  static final _categorySubtotalLabel = RegExp(
    r'^(paket\s*/?\s*promo|food\s*&?\s*drink|f\s*&\s*b)\b',
    caseSensitive: false,
  );

  // A bare per-item percentage annotation (e.g. a "0%" discount/tax column
  // printed on its own line above the qty/price row) — not a value this
  // parser tracks per item, so it's dropped outright rather than being
  // folded into the following item's name.
  static final _percentOnly = RegExp(r'^\d+(?:\.\d+)?%$');

  static final _separatorOnly = RegExp(r'^[\-=*_.\s]+$');

  static final _colDescription = RegExp(
    r'^(keterangan|deskripsi|nama\s*barang|item|description)$',
    caseSensitive: false,
  );
  static final _colQuantity = RegExp(
    r'^(jumlah|qty|quantity|banyak)$',
    caseSensitive: false,
  );
  static final _colPrice = RegExp(
    r'^(harga(\s*satuan)?|price|unit\s*price)$',
    caseSensitive: false,
  );
  static final _colTotal = RegExp(r'^(total|subtotal)$', caseSensitive: false);

  // Tolerates a trailing colon (e.g. "Grand Total :"), common on
  // thermal-printer receipts where every row is "Label : value".
  static final _grandTotalLabel = RegExp(
    r'^(total\s*keseluruhan|grand\s*total|total)\s*:?\s*$',
    caseSensitive: false,
  );

  // OCR occasionally splits "TOTAL" into two tokens with a stray space
  // (e.g. "TOTA L"), which fails the strict match above. Checked against a
  // whitespace-collapsed copy of the label as a fallback.
  static final _grandTotalLabelCompact = RegExp(
    r'^(totalkeseluruhan|grandtotal|total):?$',
    caseSensitive: false,
  );
  static bool _isGrandTotalLabel(String label) =>
      _grandTotalLabel.hasMatch(label) ||
      _grandTotalLabelCompact.hasMatch(label.replaceAll(RegExp(r'\s+'), ''));

  // Lines that carry no useful information for this parser and should be
  // dropped outright — never added to an item name, never eligible to be
  // picked as anyone's label.
  static bool _isNoiseLine(String text) =>
      _percentOnly.hasMatch(text) || _dateTimeValueOnly.hasMatch(text);

  static final _documentTitleSkip = RegExp(
    r'^(invoice|tagihan|receipt|struk|nota|faktur|bill)$',
    caseSensitive: false,
  );

  static ParsedReceipt parse(RecognizedText recognizedText) {
    final lines = <TextLine>[
      for (final block in recognizedText.blocks) ...block.lines,
    ]..sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    final headers = _detectTableHeaders(lines);
    if (headers.isNotEmpty) {
      return _parseTable(lines, headers);
    }
    return _parseThermal(lines);
  }

  /// Parses a receipt laid out as a two-column strip (item name/qty on the
  /// left, amount right-aligned) — typical of thermal POS printers.
  static ParsedReceipt _parseThermal(List<TextLine> lines) {
    final amountLines = <TextLine>{};
    final textLines = <TextLine>[];
    for (final line in lines) {
      final text = line.text.trim();
      if (text.isEmpty || _isNoiseLine(text)) continue;
      if (_fullAmountMatch(text) != null) {
        amountLines.add(line);
      } else {
        textLines.add(line);
      }
    }

    final labelForAmount = _pairAmountsWithLabels(amountLines, textLines);
    final usedLabels = labelForAmount.values.whereType<TextLine>().toSet();

    final items = <ReceiptItem>[];
    final nameBuffer = <String>[];
    double? total;
    double? serviceCharge;
    double? tax;
    double? adjustment;
    double? discount;
    String? merchantName;

    for (final line in lines) {
      final text = line.text.trim();
      if (text.isEmpty || _isNoiseLine(text)) continue;

      if (_separatorOnly.hasMatch(text)) {
        nameBuffer.clear();
        continue;
      }

      // The merchant name line is captured once, separately — it must not
      // also leak into the first item's name, which happens on receipts
      // whose header/item-list separator line isn't recognized as text by
      // OCR (so nothing else would otherwise clear the buffer first).
      if (merchantName == null) {
        merchantName = text;
        continue;
      }

      if (amountLines.contains(line)) {
        final amount = _fullAmountMatch(text)!;
        final label = labelForAmount[line]?.text.trim() ?? '';

        if (_isGrandTotalLabel(label)) {
          total = amount;
          nameBuffer.clear();
          continue;
        }
        if (_serviceChargeLabel.hasMatch(label)) {
          serviceCharge = amount;
          nameBuffer.clear();
          continue;
        }
        if (_taxLabel.hasMatch(label)) {
          tax = amount;
          nameBuffer.clear();
          continue;
        }
        if (_adjustmentLabel.hasMatch(label)) {
          adjustment = amount;
          nameBuffer.clear();
          continue;
        }
        if (_discountLabel.hasMatch(label)) {
          // Stored as a positive magnitude regardless of whether the
          // printed value was already negative (e.g. "-124.000").
          discount = amount.abs();
          nameBuffer.clear();
          continue;
        }
        if (_summaryLabel.hasMatch(label) ||
            _headerSkip.hasMatch(label) ||
            _categorySubtotalLabel.hasMatch(label)) {
          nameBuffer.clear();
          continue;
        }

        final qtyMatch = _qtyLabel.firstMatch(_normalizeQty(label));
        if (qtyMatch != null) {
          final qty = int.tryParse(qtyMatch.group(1)!) ?? 1;
          final name = nameBuffer.join(' ').trim();
          nameBuffer.clear();
          if (name.isNotEmpty && amount > 0) {
            // The label ("1x 28.000") and the amount column both encode the
            // unit price — two independent OCR reads of essentially the
            // same digits. When one is corrupted (e.g. amount misread as
            // "28.080" while the label clearly reads "28.000"), prefer
            // whichever reads as a clean round-hundred value, since retail
            // prices on this kind of receipt are never odd amounts.
            final labelPriceRaw = qtyMatch.group(2)!;
            final amountUnitPrice = amount / qty;
            final labelUnitPrice = _parseAmount(labelPriceRaw);
            final unitPrice = _pickCleanerPrice(
              amountUnitPrice,
              text,
              labelUnitPrice,
              labelPriceRaw,
            );
            items.add(ReceiptItem(name: name, quantity: qty, price: unitPrice));
          }
          continue;
        }

        final name = (label.isNotEmpty ? (nameBuffer..add(label)) : nameBuffer)
            .join(' ')
            .trim();
        nameBuffer.clear();
        if (name.isNotEmpty && amount > 0) {
          items.add(ReceiptItem(name: name, quantity: 1, price: amount));
        }
        continue;
      }

      if (usedLabels.contains(line)) continue;

      if (_headerSkip.hasMatch(text) ||
          _summaryLabel.hasMatch(text) ||
          _serviceChargeLabel.hasMatch(text) ||
          _taxLabel.hasMatch(text) ||
          _adjustmentLabel.hasMatch(text) ||
          _discountLabel.hasMatch(text) ||
          _categorySubtotalLabel.hasMatch(text)) {
        nameBuffer.clear();
      } else {
        nameBuffer.add(_stripLeadingBullet(text));
      }
    }

    return ParsedReceipt(
      merchantName: merchantName,
      items: items,
      total: total,
      serviceCharge: serviceCharge,
      tax: tax,
      adjustment: adjustment,
      discount: discount,
    );
  }

  static _ColumnType? _columnType(String text) {
    if (_colDescription.hasMatch(text)) return _ColumnType.description;
    if (_colQuantity.hasMatch(text)) return _ColumnType.quantity;
    if (_colPrice.hasMatch(text)) return _ColumnType.price;
    if (_colTotal.hasMatch(text)) return _ColumnType.total;
    return null;
  }

  /// Looks for a header row containing at least two recognizable column
  /// titles (e.g. "KETERANGAN", "JUMLAH", "HARGA", "TOTAL") — the signature
  /// of a table-style invoice rather than a thermal-printer strip.
  static List<_ColumnHeader> _detectTableHeaders(List<TextLine> lines) {
    final candidates = <_ColumnHeader>[];
    for (final line in lines) {
      final type = _columnType(line.text.trim());
      if (type == null) continue;
      candidates.add(
        _ColumnHeader(
          type: type,
          center: line.boundingBox.left + line.boundingBox.width / 2,
          line: line,
        ),
      );
    }

    for (var i = 0; i < candidates.length; i++) {
      final anchor = candidates[i].line.boundingBox;
      final group = <_ColumnHeader>[candidates[i]];
      for (var j = 0; j < candidates.length; j++) {
        if (j == i) continue;
        final other = candidates[j].line.boundingBox;
        if ((other.top - anchor.top).abs() < 20) group.add(candidates[j]);
      }
      if (group.map((c) => c.type).toSet().length >= 2) return group;
    }
    return const [];
  }

  static String? _detectMerchantName(List<TextLine> lines, double beforeTop) {
    for (final line in lines) {
      if (line.boundingBox.top >= beforeTop) break;
      final text = line.text.trim();
      if (text.isEmpty || _documentTitleSkip.hasMatch(text)) continue;
      return text;
    }
    return null;
  }

  static List<List<TextLine>> _clusterRows(List<TextLine> sortedLines) {
    final rows = <List<TextLine>>[];
    for (final line in sortedLines) {
      final center = line.boundingBox.top + line.boundingBox.height / 2;
      List<TextLine>? matched;
      for (final row in rows) {
        final anchor = row.first.boundingBox;
        final anchorCenter = anchor.top + anchor.height / 2;
        final avgHeight = (anchor.height + line.boundingBox.height) / 2;
        if (avgHeight > 0 && (center - anchorCenter).abs() < avgHeight * 0.6) {
          matched = row;
          break;
        }
      }
      if (matched != null) {
        matched.add(line);
      } else {
        rows.add([line]);
      }
    }
    return rows;
  }

  /// Parses a receipt laid out as a proper table with column headers (e.g.
  /// "KETERANGAN | JUMLAH | HARGA | TOTAL"), by clustering lines into rows
  /// and assigning each cell to its nearest column by horizontal position.
  static ParsedReceipt _parseTable(
    List<TextLine> lines,
    List<_ColumnHeader> headers,
  ) {
    final headerBottom = headers
        .map((h) => h.line.boundingBox.bottom)
        .reduce((a, b) => a > b ? a : b);
    final headerTop = headers
        .map((h) => h.line.boundingBox.top)
        .reduce((a, b) => a < b ? a : b);
    final headerLines = headers.map((h) => h.line).toSet();

    final merchantName = _detectMerchantName(lines, headerTop);

    final bodyLines = lines
        .where((l) => l.boundingBox.top > headerBottom + 2)
        .where((l) => !headerLines.contains(l))
        .toList();
    final rows = _clusterRows(bodyLines);

    final items = <ReceiptItem>[];
    double? total;
    double? serviceCharge;
    double? tax;
    double? adjustment;
    double? discount;

    for (final row in rows) {
      final rowAmounts = row
          .map((l) => _fullAmountMatch(l.text.trim()))
          .whereType<double>()
          .toList();

      if (row.any((l) => _isGrandTotalLabel(l.text.trim()))) {
        if (rowAmounts.isNotEmpty) total = rowAmounts.last;
        continue;
      }
      if (row.any((l) => _serviceChargeLabel.hasMatch(l.text.trim()))) {
        if (rowAmounts.isNotEmpty) serviceCharge = rowAmounts.last;
        continue;
      }
      if (row.any((l) => _taxLabel.hasMatch(l.text.trim()))) {
        if (rowAmounts.isNotEmpty) tax = rowAmounts.last;
        continue;
      }
      if (row.any((l) => _adjustmentLabel.hasMatch(l.text.trim()))) {
        if (rowAmounts.isNotEmpty) adjustment = rowAmounts.last;
        continue;
      }
      if (row.any((l) => _discountLabel.hasMatch(l.text.trim()))) {
        if (rowAmounts.isNotEmpty) discount = rowAmounts.last.abs();
        continue;
      }
      if (row.any((l) => _categorySubtotalLabel.hasMatch(l.text.trim()))) {
        continue;
      }

      final cells = <_ColumnType, List<TextLine>>{};
      for (final cell in row) {
        final cellCenter = cell.boundingBox.left + cell.boundingBox.width / 2;
        _ColumnHeader? nearest;
        var bestDistance = double.infinity;
        for (final header in headers) {
          final distance = (header.center - cellCenter).abs();
          if (distance < bestDistance) {
            bestDistance = distance;
            nearest = header;
          }
        }
        if (nearest == null) continue;
        cells.putIfAbsent(nearest.type, () => []).add(cell);
      }

      final name = (cells[_ColumnType.description] ?? [])
          .map((l) => l.text.trim())
          .join(' ')
          .trim();
      if (name.isEmpty) continue;

      final qtyText =
          (cells[_ColumnType.quantity] ?? []).map((l) => l.text.trim()).join();
      final qty = int.tryParse(qtyText) ?? 1;

      final priceText =
          (cells[_ColumnType.price] ?? []).map((l) => l.text.trim()).join(' ');
      final totalText =
          (cells[_ColumnType.total] ?? []).map((l) => l.text.trim()).join(' ');
      final unitPriceFromPrice = _fullAmountMatch(priceText);
      final lineTotalFromTotal = _fullAmountMatch(totalText);

      final unitPrice = unitPriceFromPrice ??
          (lineTotalFromTotal != null && qty > 0
              ? lineTotalFromTotal / qty
              : null);
      if (unitPrice == null || unitPrice <= 0) continue;

      items.add(ReceiptItem(name: name, quantity: qty, price: unitPrice));
    }

    return ParsedReceipt(
      merchantName: merchantName,
      items: items,
      total: total,
      serviceCharge: serviceCharge,
      tax: tax,
      adjustment: adjustment,
      discount: discount,
    );
  }

  static final _subtotalLabel = RegExp(r'^sub\s*total\b', caseSensitive: false);

  static bool _isLabelShaped(String text) {
    if (_subtotalLabel.hasMatch(text)) return false;
    return _qtyLabel.hasMatch(_normalizeQty(text)) ||
        _isGrandTotalLabel(text) ||
        _summaryLabel.hasMatch(text) ||
        _serviceChargeLabel.hasMatch(text) ||
        _taxLabel.hasMatch(text) ||
        _adjustmentLabel.hasMatch(text) ||
        _discountLabel.hasMatch(text) ||
        _categorySubtotalLabel.hasMatch(text);
  }

  /// Pairs each amount line with the row label it belongs to (e.g. "1x
  /// 28.000" or "Total") by proximity, using a *global* greedy match:
  /// every eligible (amount, label) pair is considered in ascending
  /// distance order, so a label always goes to whichever amount is
  /// genuinely closest to it rather than to whichever amount happens to
  /// be visited first. This matters on receipts with tightly packed
  /// summary rows (subtotal, discount, service charge, tax only a few
  /// pixels apart) — a naive per-amount nearest-neighbor search lets an
  /// earlier amount "steal" a nearby row's label before that row's own
  /// (closer) amount gets a chance to claim it, cascading every field
  /// after it down by one.
  static Map<TextLine, TextLine?> _pairAmountsWithLabels(
    Set<TextLine> amountLines,
    List<TextLine> textLines,
  ) {
    final labelForAmount = <TextLine, TextLine?>{};
    final usedLabels = <TextLine>{};
    final unmatched = amountLines.toSet();

    // Pass 1: only pair with lines that structurally look like a row
    // label ("1x 28.000", "Total", "Tax", ...). A plain item-name line
    // (e.g. a second line of a wrapped name) can sometimes sit vertically
    // closer to an amount than the real label due to photo skew, so
    // unrestricted nearest-neighbor picks the wrong line — restricting
    // the search to label-shaped text avoids that.
    //
    // Pass 2: fall back to the closest text line of any shape, for
    // amounts still unmatched — receipts where the item name and amount
    // share a single row with no separate quantity line.
    for (final requireLabelShape in [true, false]) {
      final candidates = <(TextLine, TextLine, double)>[];
      for (final amount in unmatched) {
        final amountCenter =
            amount.boundingBox.top + amount.boundingBox.height / 2;
        for (final label in textLines) {
          if (usedLabels.contains(label)) continue;
          if (label.boundingBox.left >= amount.boundingBox.left) continue;
          final text = label.text.trim();
          if (requireLabelShape && !_isLabelShaped(text)) continue;

          final center = label.boundingBox.top + label.boundingBox.height / 2;
          final distance = (center - amountCenter).abs();
          final avgHeight =
              (label.boundingBox.height + amount.boundingBox.height) / 2;
          final threshold = avgHeight * (requireLabelShape ? 2.5 : 0.6);
          if (avgHeight > 0 && distance < threshold) {
            // Handheld-camera perspective on these receipts consistently
            // skews the two columns so a row's label sits slightly *below*
            // its own amount, not above (and the skew often grows further
            // down the photo). Deprioritizing the opposite direction (but
            // not excluding it outright) stops a nearby wrong neighbor
            // above an amount from narrowly outranking the receipt's own
            // label below it — the failure mode that mismatched "TAX &
            // SERV" with the *next* row's (Total's) amount on a tightly
            // packed, heavily skewed summary block.
            final score = center >= amountCenter ? distance : distance * 3;
            candidates.add((amount, label, score));
          }
        }
      }
      candidates.sort((a, b) => a.$3.compareTo(b.$3));

      for (final (amount, label, _) in candidates) {
        if (!unmatched.contains(amount) || usedLabels.contains(label)) {
          continue;
        }
        labelForAmount[amount] = label;
        usedLabels.add(label);
        unmatched.remove(amount);
      }
    }

    for (final amount in unmatched) {
      labelForAmount[amount] = null;
    }
    return labelForAmount;
  }

  static bool _looksRounded(double value) => (value % 100).abs() < 0.5;

  // True for a raw OCR number like "28.000" (a 3-digit group after the
  // separator) as opposed to "28.00" or "28.5", which read as a decimal
  // fraction. Retail prices on this kind of receipt are always thousands,
  // so a 3-digit group is a strong signal the reading's *magnitude* is
  // right even if a trailing digit was misrecognized.
  static bool _isThousandsShaped(String raw) {
    final value = raw.trim();
    final hasDot = value.contains('.');
    final hasComma = value.contains(',');
    if (hasDot && hasComma) return true;
    if (!hasDot && !hasComma) return false;
    final parts = value.split(hasDot ? '.' : ',');
    return parts.length == 2 && parts.last.length == 3;
  }

  static double _roundToNearest100(double value) => (value / 100).round() * 100;

  static double _pickCleanerPrice(
    double amountUnitPrice,
    String amountRaw,
    double? labelUnitPrice,
    String? labelRaw,
  ) {
    if (_looksRounded(amountUnitPrice)) return amountUnitPrice;
    if (labelUnitPrice != null &&
        labelUnitPrice > 0 &&
        _looksRounded(labelUnitPrice)) {
      return labelUnitPrice;
    }

    // Neither reading is already a clean round-hundred value. Prefer
    // whichever raw text has the thousands-group shape — a dropped digit
    // that turned "32.000" into "32.00" corrupts the *magnitude*, which is
    // far worse than a single wrong trailing digit — then snap it to the
    // nearest hundred to clean up that trailing noise.
    final amountShaped = _isThousandsShaped(amountRaw);
    final labelShaped = labelRaw != null && _isThousandsShaped(labelRaw);

    if (labelShaped &&
        !amountShaped &&
        labelUnitPrice != null &&
        labelUnitPrice > 0) {
      return _roundToNearest100(labelUnitPrice);
    }
    if (amountShaped) return _roundToNearest100(amountUnitPrice);
    if (labelUnitPrice != null && labelUnitPrice > 0) {
      return _roundToNearest100(labelUnitPrice);
    }
    return amountUnitPrice;
  }

  // OCR occasionally reads a digit inside a monetary string as a
  // similar-looking letter/diacritic (e.g. "Rp120.000,00" -> "Rpl20.000,00",
  // "Rp60.000,00" -> "Rpó0.000,00"), which breaks the strict numeric regex
  // entirely. This is only ever applied as a fallback once the strict match
  // has already failed, so it can't corrupt an otherwise-valid amount.
  static String _normalizeAmountDigits(String text) {
    return text
        .replaceAll(RegExp('[lI|]'), '1')
        .replaceAll(RegExp('[óòôöõ]', caseSensitive: false), '6');
  }

  static double? _fullAmountMatch(String text) {
    final trimmed = text.trim();
    final match = _fullAmount.firstMatch(trimmed) ??
        _fullAmount.firstMatch(_normalizeAmountDigits(trimmed));
    if (match == null) return null;
    return _parseAmount(match.group(1)!);
  }

  static double? _parseAmount(String raw) {
    var value = raw.trim();
    final hasDot = value.contains('.');
    final hasComma = value.contains(',');

    if (hasDot && hasComma) {
      final lastDot = value.lastIndexOf('.');
      final lastComma = value.lastIndexOf(',');
      final decimalSeparator = lastDot > lastComma ? '.' : ',';
      final thousandsSeparator = decimalSeparator == '.' ? ',' : '.';
      value = value.replaceAll(thousandsSeparator, '');
      value = value.replaceAll(decimalSeparator, '.');
    } else if (hasDot || hasComma) {
      final separator = hasDot ? '.' : ',';
      final parts = value.split(separator);
      final lastPart = parts.last;
      if (parts.length == 2 && lastPart.length == 3) {
        // Thousands separator, e.g. "15.000" -> 15000
        value = parts.join();
      } else {
        // Decimal separator, e.g. "15.50" -> 15.50
        value = value.replaceAll(separator, '.');
      }
    }

    return double.tryParse(value);
  }
}
