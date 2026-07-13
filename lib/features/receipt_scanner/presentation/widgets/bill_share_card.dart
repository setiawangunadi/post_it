import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../generated/l10n.dart';
import '../../domain/entities/friend_share.dart';
import '../utils/payment_message.dart';

/// A shareable "payment request" card — same visual language as a bank
/// transfer receipt (rounded card, corner notches, big centered amount,
/// divider-separated detail rows, footer note) so it reads as a proper
/// document when shared as an image, not just a text bubble.
class BillShareCard extends StatelessWidget {
  static const maxItemsShown = 10;

  final String friendName;
  final String merchant;
  final double amount;
  final DateTime date;
  final List<AssignedItemDetail> items;
  final double serviceCharge;
  final double tax;
  final double adjustment;
  final double discount;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolder;

  const BillShareCard({
    super.key,
    required this.friendName,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.items,
    this.serviceCharge = 0,
    this.tax = 0,
    this.adjustment = 0,
    this.discount = 0,
    this.bankName,
    this.accountNumber,
    this.accountHolder,
  });

  static const _backgroundColor = Color(0xFFF3EEF8);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final greyText = TextStyle(color: Colors.grey.shade600, fontSize: 13);

    return Container(
      width: double.infinity,
      color: _backgroundColor,
      padding: const EdgeInsets.all(28),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 320,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    color: colors.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).splitBillPaymentLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    fontSize: 13,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Rp${formatRupiah(amount)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(S.of(context).forMerchant(merchant), style: greyText),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 13,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat.yMMMd().add_Hm().format(date),
                      style: greyText,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 14),
                _DetailRow(S.of(context).billedToLabel, friendName),
                _DetailRow(S.of(context).merchantLabel, merchant),
                if (items.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      S.of(context).itemsCountLabel(
                            _formatCount(
                              items.fold(0.0, (sum, i) => sum + i.quantity),
                            ),
                          ),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...items
                      .take(maxItemsShown)
                      .map((item) => _ItemRow(item: item)),
                  if (items.length > maxItemsShown)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        S.of(context).moreItemsHint(maxItemsShown),
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                ],
                if (serviceCharge != 0 ||
                    tax != 0 ||
                    adjustment != 0 ||
                    discount != 0) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  if (serviceCharge != 0)
                    _DetailRow(
                      S.of(context).serviceChargeLabel,
                      'Rp${formatRupiah(serviceCharge)}',
                    ),
                  if (tax != 0)
                    _DetailRow(S.of(context).taxLabel, 'Rp${formatRupiah(tax)}'),
                  if (adjustment != 0)
                    _DetailRow(
                      S.of(context).adjustmentLabel,
                      'Rp${formatRupiah(adjustment)}',
                    ),
                  if (discount != 0)
                    _DetailRow(
                      S.of(context).discountLabel,
                      '-Rp${formatRupiah(discount)}',
                    ),
                ],
                if (bankName?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 10),
                  _DetailRow(S.of(context).bankLabel, bankName!),
                ],
                if (accountNumber?.isNotEmpty ?? false)
                  _DetailRow(S.of(context).accountNoLabel, accountNumber!),
                if (accountHolder?.isNotEmpty ?? false)
                  _DetailRow(S.of(context).accountHolderLabel, accountHolder!),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 14),
                Text(
                  S.of(context).transferFooterNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const Positioned(top: -10, left: 44, child: _CornerNotch()),
          const Positioned(top: -10, right: 44, child: _CornerNotch()),
          const Positioned(bottom: -10, left: 44, child: _CornerNotch()),
          const Positioned(bottom: -10, right: 44, child: _CornerNotch()),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final AssignedItemDetail item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.name} ${formatQty(item.quantity)}',
              style: const TextStyle(fontSize: 12.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rp${formatRupiah(item.amount)}',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// A total across items can be fractional (e.g. 2.5 when one of the items
// is a shared half-unit) — shown with one decimal rather than a raw double.
String _formatCount(double count) =>
    count == count.roundToDouble() ? count.toInt().toString() : count.toStringAsFixed(1);

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerNotch extends StatelessWidget {
  const _CornerNotch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: BillShareCard._backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
    );
  }
}
