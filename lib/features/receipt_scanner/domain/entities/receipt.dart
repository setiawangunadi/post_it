import 'package:equatable/equatable.dart';

class ReceiptItem extends Equatable {
  final String name;
  final int quantity;
  final double price;

  const ReceiptItem({
    required this.name,
    this.quantity = 1,
    required this.price,
  });

  double get lineTotal => price * quantity;

  ReceiptItem copyWith({String? name, int? quantity, double? price}) {
    return ReceiptItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  @override
  List<Object?> get props => [name, quantity, price];
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
        rawText,
      ];
}
