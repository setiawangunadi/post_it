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

class _FriendBalanceCard extends StatelessWidget {
  final FriendBalance balance;
  const _FriendBalanceCard({required this.balance});

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
          ),
        ),
      ),
    );
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
        children: balance.contributions.map((contribution) {
          final merchant = contribution.receipt.merchantName?.isNotEmpty == true
              ? contribution.receipt.merchantName!
              : 'Receipt';
          return ListTile(
            leading: Checkbox(
              value: contribution.paid,
              onChanged: (value) =>
                  _togglePaid(context, contribution, value ?? false),
            ),
            title: Text(merchant),
            subtitle: Text(
              DateFormat.yMMMd().format(contribution.receipt.scannedAt),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Rp${formatRupiah(contribution.amount)}'),
                IconButton(
                  icon: const Icon(Icons.receipt_long_outlined),
                  tooltip: 'View items',
                  onPressed: () => _viewItems(context, contribution),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Share payment request',
                  onPressed: () => _share(context, contribution),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
