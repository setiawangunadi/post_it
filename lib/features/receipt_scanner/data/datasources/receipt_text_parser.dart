import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/entities/receipt.dart';

class ParsedReceipt {
  final String? merchantName;
  final List<ReceiptItem> items;
  final double? total;
  final double? serviceCharge;
  final double? tax;
  final double? adjustment;

  const ParsedReceipt({
    this.merchantName,
    required this.items,
    this.total,
    this.serviceCharge,
    this.tax,
    this.adjustment,
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

  static final _qtyLabel = RegExp(r'^(\d+)\s*[xX]\s*([\d.,]+)$');

  // OCR on thermal-printer receipts frequently confuses a leading "1" with
  // a lowercase "l" or capital "I" right before the "x" quantity marker
  // (e.g. "lx 34.000" instead of "1x 34.000").
  static String _normalizeQty(String text) =>
      text.replaceFirst(RegExp(r'^[lI](?=\s*[xX])'), '1');

  static final _exactTotal = RegExp(r'^total$', caseSensitive: false);

  // Service charge, tax/PPN and adjustment are captured as their own fields
  // rather than discarded — kept as separate regexes (instead of folding
  // into _summaryLabel) so the parsing logic can branch on them
  // specifically.
  static final _serviceChargeLabel = RegExp(
    r'^service\s*charge\b',
    caseSensitive: false,
  );
  static final _taxLabel = RegExp(r'^(tax|ppn)\b', caseSensitive: false);
  static final _adjustmentLabel =
      RegExp(r'^adjustment\b', caseSensitive: false);

  // "Subtotal" is deliberately excluded from _isLabelShaped (see below):
  // its value is never used, and on receipts where the label's OCR
  // bounding box is noisy it can otherwise "steal" the amount that
  // actually belongs to the next row (Service Charge), cascading every
  // field after it down by one.
  static final _summaryLabel = RegExp(
    r'^(sub\s*total|total\s*item|'
    r'tender|change|kembali|cash|tunai|card|kartu|diskon|discount)\b',
    caseSensitive: false,
  );

  static final _headerSkip = RegExp(
    r'^(date|order\s*number|customer|sales\s*type|user|cashier|instagram|'
    r'tel\.?|telp\.?|npwp|www\.|jl\.|alamat|table|invoice|receipt|kasir|'
    r'no\.?\s*(bon|receipt))\b',
    caseSensitive: false,
  );

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

  static final _grandTotalLabel = RegExp(
    r'^(total\s*keseluruhan|grand\s*total|total)$',
    caseSensitive: false,
  );

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
      if (text.isEmpty) continue;
      if (_fullAmountMatch(text) != null) {
        amountLines.add(line);
      } else {
        textLines.add(line);
      }
    }

    final labelForAmount = <TextLine, TextLine?>{};
    final usedLabels = <TextLine>{};
    for (final amount in amountLines) {
      final amountCenter =
          amount.boundingBox.top + amount.boundingBox.height / 2;

      // Pass 1: only consider lines that structurally look like a row
      // label ("1x 28.000", "Total", "Tax", ...). A plain item-name line
      // (e.g. a second line of a wrapped name) can sometimes sit
      // vertically closer to the amount than the real label due to photo
      // skew, so unrestricted nearest-neighbor picks the wrong line —
      // restricting the search to label-shaped text avoids that.
      TextLine? best = _closestCandidate(
        amount,
        amountCenter,
        textLines,
        usedLabels,
        requireLabelShape: true,
      );

      // Pass 2: fall back to the closest text line of any shape, for
      // receipts where the item name and amount share a single row with
      // no separate quantity line.
      best ??= _closestCandidate(
        amount,
        amountCenter,
        textLines,
        usedLabels,
        requireLabelShape: false,
      );

      labelForAmount[amount] = best;
      if (best != null) usedLabels.add(best);
    }

    final items = <ReceiptItem>[];
    final nameBuffer = <String>[];
    double? total;
    double? serviceCharge;
    double? tax;
    double? adjustment;
    String? merchantName;

    for (final line in lines) {
      final text = line.text.trim();
      if (text.isEmpty) continue;

      merchantName ??= _separatorOnly.hasMatch(text) ? null : text;

      if (_separatorOnly.hasMatch(text)) {
        nameBuffer.clear();
        continue;
      }

      if (amountLines.contains(line)) {
        final amount = _fullAmountMatch(text)!;
        final label = labelForAmount[line]?.text.trim() ?? '';

        if (_exactTotal.hasMatch(label)) {
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
        if (_summaryLabel.hasMatch(label) || _headerSkip.hasMatch(label)) {
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
          _adjustmentLabel.hasMatch(text)) {
        nameBuffer.clear();
      } else {
        nameBuffer.add(text);
      }
    }

    return ParsedReceipt(
      merchantName: merchantName,
      items: items,
      total: total,
      serviceCharge: serviceCharge,
      tax: tax,
      adjustment: adjustment,
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

    for (final row in rows) {
      final rowAmounts = row
          .map((l) => _fullAmountMatch(l.text.trim()))
          .whereType<double>()
          .toList();

      if (row.any((l) => _grandTotalLabel.hasMatch(l.text.trim()))) {
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
    );
  }

  static final _subtotalLabel = RegExp(r'^sub\s*total\b', caseSensitive: false);

  static bool _isLabelShaped(String text) {
    if (_subtotalLabel.hasMatch(text)) return false;
    return _qtyLabel.hasMatch(_normalizeQty(text)) ||
        _exactTotal.hasMatch(text) ||
        _summaryLabel.hasMatch(text) ||
        _serviceChargeLabel.hasMatch(text) ||
        _taxLabel.hasMatch(text) ||
        _adjustmentLabel.hasMatch(text);
  }

  static TextLine? _closestCandidate(
    TextLine amount,
    double amountCenter,
    List<TextLine> textLines,
    Set<TextLine> usedLabels, {
    required bool requireLabelShape,
  }) {
    TextLine? best;
    var bestDistance = double.infinity;
    for (final candidate in textLines) {
      if (usedLabels.contains(candidate)) continue;
      if (candidate.boundingBox.left >= amount.boundingBox.left) continue;
      final text = candidate.text.trim();
      if (requireLabelShape && !_isLabelShaped(text)) continue;

      final center =
          candidate.boundingBox.top + candidate.boundingBox.height / 2;
      final distance = (center - amountCenter).abs();
      final avgHeight =
          (candidate.boundingBox.height + amount.boundingBox.height) / 2;
      final threshold = avgHeight * (requireLabelShape ? 2.5 : 0.6);
      if (avgHeight > 0 && distance < threshold && distance < bestDistance) {
        bestDistance = distance;
        best = candidate;
      }
    }
    return best;
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
