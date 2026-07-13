import '../../domain/entities/receipt.dart';

class ReceiptItemModel extends ReceiptItem {
  const ReceiptItemModel({
    required super.name,
    required super.quantity,
    required super.price,
    super.assignments,
  });

  factory ReceiptItemModel.fromEntity(ReceiptItem item) => ReceiptItemModel(
        name: item.name,
        quantity: item.quantity,
        price: item.price,
        assignments: item.assignments,
      );

  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity'] as int;
    Map<String, double> assignments;
    if (json['assignments'] is Map) {
      // Values were saved as int before fractional (cost-split) assignments
      // existed — `(value as num).toDouble()` reads both old and new data.
      assignments = (json['assignments'] as Map).map(
        (key, value) => MapEntry(key as String, (value as num).toDouble()),
      );
    } else if (json['assignedTo'] is String) {
      // Migrate receipts saved before per-unit splitting existed, where the
      // whole item was assigned to a single friend.
      assignments = {json['assignedTo'] as String: quantity.toDouble()};
    } else {
      assignments = const {};
    }
    return ReceiptItemModel(
      name: json['name'] as String,
      quantity: quantity,
      price: (json['price'] as num).toDouble(),
      assignments: assignments,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'price': price,
        'assignments': assignments,
      };
}

class ReceiptModel extends Receipt {
  const ReceiptModel({
    required super.id,
    required super.imagePath,
    super.merchantName,
    required super.scannedAt,
    required super.items,
    super.total,
    super.serviceCharge,
    super.tax,
    super.adjustment,
    super.discount,
    super.paidStatus,
    required super.rawText,
  });

  factory ReceiptModel.fromEntity(Receipt receipt) => ReceiptModel(
        id: receipt.id,
        imagePath: receipt.imagePath,
        merchantName: receipt.merchantName,
        scannedAt: receipt.scannedAt,
        items:
            receipt.items.map((e) => ReceiptItemModel.fromEntity(e)).toList(),
        total: receipt.total,
        serviceCharge: receipt.serviceCharge,
        tax: receipt.tax,
        adjustment: receipt.adjustment,
        discount: receipt.discount,
        paidStatus: receipt.paidStatus,
        rawText: receipt.rawText,
      );

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      merchantName: json['merchantName'] as String?,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      items: (json['items'] as List)
          .map((e) => ReceiptItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toDouble(),
      serviceCharge: (json['serviceCharge'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      adjustment: (json['adjustment'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      paidStatus: json['paidStatus'] is Map
          ? (json['paidStatus'] as Map).map(
              (key, value) => MapEntry(key as String, value as bool),
            )
          : const {},
      rawText: json['rawText'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'merchantName': merchantName,
        'scannedAt': scannedAt.toIso8601String(),
        'items':
            items.map((e) => ReceiptItemModel.fromEntity(e).toJson()).toList(),
        'total': total,
        'serviceCharge': serviceCharge,
        'tax': tax,
        'adjustment': adjustment,
        'discount': discount,
        'paidStatus': paidStatus,
        'rawText': rawText,
      };
}
