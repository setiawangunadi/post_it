import 'package:intl/intl.dart';

import '../../../../data/local/user_storage.dart';

final _amountFormat = NumberFormat.decimalPattern('id')
  ..maximumFractionDigits = 0;

String formatRupiah(double amount) => _amountFormat.format(amount);

/// Builds a shareable payment-request message for [friendName], including
/// the user's saved bank/e-wallet details (if any) so the recipient knows
/// where to send money.
Future<String> buildPaymentRequestMessage({
  required String friendName,
  required String merchant,
  required double amount,
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
