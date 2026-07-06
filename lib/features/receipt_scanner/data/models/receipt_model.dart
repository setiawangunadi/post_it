import '../../domain/entities/receipt.dart';

class ReceiptItemModel extends ReceiptItem {
  const ReceiptItemModel({
    required super.name,
    required super.quantity,
    required super.price,
  });

  factory ReceiptItemModel.fromEntity(ReceiptItem item) => ReceiptItemModel(
        name: item.name,
        quantity: item.quantity,
        price: item.price,
      );

  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) {
    return ReceiptItemModel(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'price': price,
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
        'rawText': rawText,
      };
}
