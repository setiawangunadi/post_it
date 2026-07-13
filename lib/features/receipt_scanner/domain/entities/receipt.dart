import 'package:equatable/equatable.dart';

class ReceiptItem extends Equatable {
  final String name;
  final int quantity;
  final double price;

  /// How many units of [quantity] each friend is assigned, e.g. a qty-2 item
  /// split as `{'Budi': 1, 'Sinta': 1}`. Units not covered by any entry here
  /// are unassigned. Values sum to at most [quantity].
  final Map<String, int> assignments;

  const ReceiptItem({
    required this.name,
    this.quantity = 1,
    required this.price,
    this.assignments = const {},
  });

  double get lineTotal => price * quantity;

  int get assignedQuantity =>
      assignments.values.fold(0, (sum, qty) => sum + qty);

  int get unassignedQuantity =>
      (quantity - assignedQuantity).clamp(0, quantity);

  ReceiptItem copyWith({
    String? name,
    int? quantity,
    double? price,
    Map<String, int>? assignments,
  }) {
    return ReceiptItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      assignments: assignments ?? this.assignments,
    );
  }

  @override
  List<Object?> get props => [name, quantity, price, assignments];
}

class Receipt extends Equatable {
  final String id;
  final String imagePath;
  final String? merchantName;
  final DateTime scannedAt;
  final List<ReceiptItem> items;
  final double? total;
  final double? serviceCharge;
  final double? tax;
  final double? adjustment;

  /// Amount deducted off the items subtotal, stored as a non-negative
  /// magnitude (subtracted when computing totals, never added).
  final double? discount;

  /// Whether each friend (by name, matching [ReceiptItem.assignments] keys)
  /// has paid their share of this receipt.
  final Map<String, bool> paidStatus;
  final String rawText;

  const Receipt({
    required this.id,
    required this.imagePath,
    this.merchantName,
    required this.scannedAt,
    required this.items,
    this.total,
    this.serviceCharge,
    this.tax,
    this.adjustment,
    this.discount,
    this.paidStatus = const {},
    required this.rawText,
  });

  double get itemsTotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  Receipt copyWith({
    String? imagePath,
    String? merchantName,
    List<ReceiptItem>? items,
    double? total,
    double? serviceCharge,
    double? tax,
    double? adjustment,
    double? discount,
    Map<String, bool>? paidStatus,
    String? rawText,
  }) {
    return Receipt(
      id: id,
      imagePath: imagePath ?? this.imagePath,
      merchantName: merchantName ?? this.merchantName,
      scannedAt: scannedAt,
      items: items ?? this.items,
      total: total ?? this.total,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      tax: tax ?? this.tax,
      adjustment: adjustment ?? this.adjustment,
      discount: discount ?? this.discount,
      paidStatus: paidStatus ?? this.paidStatus,
      rawText: rawText ?? this.rawText,
    );
  }

  @override
  List<Object?> get props => [
        id,
        imagePath,
        merchantName,
        scannedAt,
        items,
        total,
        serviceCharge,
        tax,
        adjustment,
        discount,
        paidStatus,
        rawText,
      ];
}
