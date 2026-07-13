import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/friend_share.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/usecases/save_receipt.dart';
import '../bloc/history/receipt_history_bloc.dart';
import '../utils/payment_message.dart';
import '../widgets/assigned_items_sheet.dart';
import 'share_bill_card_page.dart';

class PaymentsOverviewPage extends StatelessWidget {
  const PaymentsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReceiptHistoryBloc>()..add(const LoadHistory()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Payments')),
        body: BlocBuilder<ReceiptHistoryBloc, ReceiptHistoryState>(
          builder: (context, state) {
            return switch (state) {
              HistoryLoading() ||
              HistoryInitial() =>
                const Center(child: CircularProgressIndicator()),
              HistoryError(:final message) => Center(child: Text(message)),
              HistoryLoaded(:final receipts) =>
                _PaymentsBody(receipts: receipts),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

class _PaymentsBody extends StatelessWidget {
  final List<Receipt> receipts;
  const _PaymentsBody({required this.receipts});

  @override
  Widget build(BuildContext context) {
    final balances = calculateFriendBalances(receipts);
    if (balances.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No split payments yet. Assign items to friends when scanning '
            'a receipt to track who owes what.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: balances.length,
      itemBuilder: (context, index) =>
          _FriendBalanceCard(balance: balances[index]),
    );
  }
}

/// Computes [friendName]'s prorated share of [receipt], falling back to a
/// zero-extras share (using the already-known [fallbackAmount]/
/// [fallbackItemCount]) if the receipt's assignments were edited away since
/// the balance was aggregated.
FriendShare _shareFor(
  Receipt receipt,
  String friendName, {
  required double fallbackAmount,
  required double fallbackItemCount,
}) {
  return calculateFriendShares(
    receipt.items,
    serviceCharge: receipt.serviceCharge,
    tax: receipt.tax,
    adjustment: receipt.adjustment,
    discount: receipt.discount,
  ).firstWhere(
    (s) => s.friendName == friendName,
    orElse: () => FriendShare(
      friendName: friendName,
      itemsTotal: fallbackAmount,
      proratedExtra: 0,
      itemCount: fallbackItemCount,
    ),
  );
}

class _FriendBalanceCard extends StatefulWidget {
  final FriendBalance balance;
  const _FriendBalanceCard({required this.balance});

  @override
  State<_FriendBalanceCard> createState() => _FriendBalanceCardState();
}

class _FriendBalanceCardState extends State<_FriendBalanceCard> {
  final Set<String> _selectedReceiptIds = {};

  FriendBalance get balance => widget.balance;

  Future<void> _togglePaid(
    BuildContext context,
    FriendReceiptContribution contribution,
    bool paid,
  ) async {
    final updatedStatus = Map.of(contribution.receipt.paidStatus)
      ..[balance.friendName] = paid;
    final updated = contribution.receipt.copyWith(paidStatus: updatedStatus);
    await sl<SaveReceipt>()(SaveReceiptParams(receipt: updated));
    if (context.mounted) {
      context.read<ReceiptHistoryBloc>().add(const LoadHistory());
    }
  }

  void _share(BuildContext context, FriendReceiptContribution contribution) {
    final merchant = contribution.receipt.merchantName?.isNotEmpty == true
        ? contribution.receipt.merchantName!
        : 'the receipt';
    final share = _shareFor(
      contribution.receipt,
      balance.friendName,
      fallbackAmount: contribution.amount,
      fallbackItemCount: contribution.itemCount,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShareBillCardPage(
          data: BillShareData(
            friendName: balance.friendName,
            merchant: merchant,
            amount: contribution.amount,
            date: contribution.receipt.scannedAt,
            items: getAssignedItems(
              contribution.receipt.items,
              balance.friendName,
            ),
            serviceCharge: share.proratedServiceCharge,
            tax: share.proratedTax,
            adjustment: share.proratedAdjustment,
            discount: share.proratedDiscount,
          ),
        ),
      ),
    );
  }

  /// Combines every selected receipt's share for this friend into a single
  /// payment request — one shared amount/breakdown instead of asking the
  /// friend to pay each receipt separately.
  void _shareMerged(BuildContext context) {
    final selected = balance.contributions
        .where((c) => _selectedReceiptIds.contains(c.receipt.id))
        .toList();
    if (selected.length < 2) return;

    double amount = 0;
    double serviceCharge = 0;
    double tax = 0;
    double adjustment = 0;
    double discount = 0;
    final items = <AssignedItemDetail>[];
    final merchants = <String>{};
    DateTime latestDate = selected.first.receipt.scannedAt;
    // Multiple different merchants: prefix each item with its receipt's
    // merchant so the recipient can tell which bill it came from.
    final prefixItems = !_sameMerchant(selected);

    for (final contribution in selected) {
      final receipt = contribution.receipt;
      final merchant = receipt.merchantName?.isNotEmpty == true
          ? receipt.merchantName!
          : 'Receipt';
      merchants.add(merchant);
      if (receipt.scannedAt.isAfter(latestDate)) latestDate = receipt.scannedAt;

      final share = _shareFor(
        receipt,
        balance.friendName,
        fallbackAmount: contribution.amount,
        fallbackItemCount: contribution.itemCount,
      );
      amount += contribution.amount;
      serviceCharge += share.proratedServiceCharge;
      tax += share.proratedTax;
      adjustment += share.proratedAdjustment;
      discount += share.proratedDiscount;

      final receiptItems = getAssignedItems(receipt.items, balance.friendName);
      items.addAll(
        prefixItems
            ? receiptItems.map(
                (i) => AssignedItemDetail(
                  name: '$merchant · ${i.name}',
                  quantity: i.quantity,
                  amount: i.amount,
                ),
              )
            : receiptItems,
      );
    }

    final merchantLabel = merchants.length == 1
        ? merchants.first
        : (merchants.length <= 3
            ? merchants.join(' & ')
            : '${selected.length} receipts');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShareBillCardPage(
          data: BillShareData(
            friendName: balance.friendName,
            merchant: merchantLabel,
            amount: amount,
            date: latestDate,
            items: items,
            serviceCharge: serviceCharge,
            tax: tax,
            adjustment: adjustment,
            discount: discount,
          ),
        ),
      ),
    );
  }

  bool _sameMerchant(List<FriendReceiptContribution> contributions) {
    final names = contributions
        .map(
          (c) => c.receipt.merchantName?.isNotEmpty == true
              ? c.receipt.merchantName!
              : 'Receipt',
        )
        .toSet();
    return names.length <= 1;
  }

  void _viewItems(
    BuildContext context,
    FriendReceiptContribution contribution,
  ) {
    final merchant = contribution.receipt.merchantName?.isNotEmpty == true
        ? contribution.receipt.merchantName!
        : 'the receipt';
    showModalBottomSheet(
      context: context,
      builder: (_) => AssignedItemsSheet(
        friendName: balance.friendName,
        merchant: merchant,
        items: getAssignedItems(contribution.receipt.items, balance.friendName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canMergeShare = balance.contributions.length >= 2;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(balance.friendName),
        subtitle: Text(
          balance.isSettled
              ? 'All settled'
              : 'Owes Rp${formatRupiah(balance.totalOwed)}',
        ),
        trailing: Chip(
          label: Text(balance.isSettled ? 'Paid' : 'Unpaid'),
          backgroundColor: balance.isSettled
              ? colors.tertiaryContainer
              : colors.errorContainer,
          labelStyle: TextStyle(
            color: balance.isSettled
                ? colors.onTertiaryContainer
                : colors.onErrorContainer,
          ),
          side: BorderSide.none,
        ),
        children: [
          if (canMergeShare)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedReceiptIds.length >= 2
                          ? '${_selectedReceiptIds.length} receipts selected'
                          : 'Select 2+ receipts to merge into one share',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _selectedReceiptIds.length >= 2
                        ? () => _shareMerged(context)
                        : null,
                    icon: const Icon(Icons.merge_type, size: 18),
                    label: const Text('Share Merged'),
                  ),
                ],
              ),
            ),
          ...balance.contributions.map((contribution) {
            final merchant = contribution.receipt.merchantName?.isNotEmpty == true
                ? contribution.receipt.merchantName!
                : 'Receipt';
            final receiptId = contribution.receipt.id;
            return ListTile(
              contentPadding: const EdgeInsets.only(left: 16, right: 8),
              leading: Checkbox(
                value: contribution.paid,
                onChanged: (value) =>
                    _togglePaid(context, contribution, value ?? false),
              ),
              title: Text(
                merchant,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                DateFormat.yMMMd().format(contribution.receipt.scannedAt),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canMergeShare)
                    Checkbox(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: _selectedReceiptIds.contains(receiptId),
                      onChanged: (value) => setState(() {
                        if (value ?? false) {
                          _selectedReceiptIds.add(receiptId);
                        } else {
                          _selectedReceiptIds.remove(receiptId);
                        }
                      }),
                    ),
                  Text('Rp${formatRupiah(contribution.amount)}'),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.receipt_long_outlined),
                    tooltip: 'View items',
                    onPressed: () => _viewItems(context, contribution),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.share),
                    tooltip: 'Share payment request',
                    onPressed: () => _share(context, contribution),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
