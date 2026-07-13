import 'package:intl/intl.dart';

import '../../../../data/local/user_storage.dart';

final _amountFormat = NumberFormat.decimalPattern('id')
  ..maximumFractionDigits = 0;

String formatRupiah(double amount) => _amountFormat.format(amount);

/// Formats an assigned quantity for display — whole units print as "x2",
/// while a cost-split fraction of a single unit (e.g. one dish shared
/// between two people) prints as a percentage ("50%") since "x0.5" doesn't
/// read naturally as "half of one item".
String formatQty(double qty) {
  if (qty == qty.roundToDouble()) return 'x${qty.toInt()}';
  return '${(qty * 100).round()}%';
}

/// Builds a shareable payment-request message for [friendName], including
/// the user's saved bank/e-wallet details (if any) so the recipient knows
/// where to send money.
Future<String> buildPaymentRequestMessage({
  required String friendName,
  required String merchant,
  required double amount,
  double serviceCharge = 0,
  double tax = 0,
  double adjustment = 0,
  double discount = 0,
}) async {
  final bankName = await UserStorage.getBankName();
  final accountNumber = await UserStorage.getBankAccountNumber();
  final accountHolder = await UserStorage.getBankAccountHolder();

  final buffer = StringBuffer()
    ..writeln('Hi $friendName,')
    ..writeln()
    ..writeln(
      'Your share of the bill from $merchant is Rp${formatRupiah(amount)}.',
    );

  if (serviceCharge != 0 || tax != 0 || adjustment != 0 || discount != 0) {
    buffer
      ..writeln()
      ..writeln('Breakdown:');
    if (serviceCharge != 0) {
      buffer.writeln('Service Charge: Rp${formatRupiah(serviceCharge)}');
    }
    if (tax != 0) buffer.writeln('Tax: Rp${formatRupiah(tax)}');
    if (adjustment != 0) {
      buffer.writeln('Adjustment: Rp${formatRupiah(adjustment)}');
    }
    if (discount != 0) {
      buffer.writeln('Discount: -Rp${formatRupiah(discount)}');
    }
  }

  if ((bankName?.isNotEmpty ?? false) || (accountNumber?.isNotEmpty ?? false)) {
    buffer
      ..writeln()
      ..writeln('Please transfer to:');
    if (bankName?.isNotEmpty ?? false) buffer.writeln(bankName);
    if (accountNumber?.isNotEmpty ?? false) buffer.writeln(accountNumber);
    if (accountHolder?.isNotEmpty ?? false) {
      buffer.writeln('a.n. $accountHolder');
    }
  }

  buffer
    ..writeln()
    ..writeln('Thanks!');

  return buffer.toString();
}
