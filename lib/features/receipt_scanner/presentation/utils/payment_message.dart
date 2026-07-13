import 'package:intl/intl.dart';

import '../../../../data/local/user_storage.dart';
import '../../../../generated/l10n.dart';

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
/// where to send money. [l10n] is passed in (rather than read via
/// `S.current`) since this can be called from a widget with a `BuildContext`
/// on hand — `S.of(context)` is the more reliable source of the active
/// locale than a global fallback.
Future<String> buildPaymentRequestMessage({
  required S l10n,
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
    ..writeln(l10n.greetingHi(friendName))
    ..writeln()
    ..writeln(l10n.yourShareMessage(merchant, 'Rp${formatRupiah(amount)}'));

  if (serviceCharge != 0 || tax != 0 || adjustment != 0 || discount != 0) {
    buffer
      ..writeln()
      ..writeln(l10n.breakdownLabel);
    if (serviceCharge != 0) {
      buffer.writeln(l10n.serviceChargeLine('Rp${formatRupiah(serviceCharge)}'));
    }
    if (tax != 0) buffer.writeln(l10n.taxLine('Rp${formatRupiah(tax)}'));
    if (adjustment != 0) {
      buffer.writeln(l10n.adjustmentLine('Rp${formatRupiah(adjustment)}'));
    }
    if (discount != 0) {
      buffer.writeln(l10n.discountLine('Rp${formatRupiah(discount)}'));
    }
  }

  if ((bankName?.isNotEmpty ?? false) || (accountNumber?.isNotEmpty ?? false)) {
    buffer
      ..writeln()
      ..writeln(l10n.pleaseTransferTo);
    if (bankName?.isNotEmpty ?? false) buffer.writeln(bankName);
    if (accountNumber?.isNotEmpty ?? false) buffer.writeln(accountNumber);
    if (accountHolder?.isNotEmpty ?? false) {
      buffer.writeln(l10n.accountHolderPrefix(accountHolder!));
    }
  }

  buffer
    ..writeln()
    ..writeln(l10n.thanksClosing);

  return buffer.toString();
}
