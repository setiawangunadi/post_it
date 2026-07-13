import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/friend_share.dart';
import '../../domain/entities/receipt.dart';
import '../bloc/history/receipt_history_bloc.dart';

class ReceiptHistoryPage extends StatelessWidget {
  const ReceiptHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReceiptHistoryBloc>()..add(const LoadHistory()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Receipt History')),
        body: BlocBuilder<ReceiptHistoryBloc, ReceiptHistoryState>(
          builder: (context, state) {
            return switch (state) {
              HistoryLoading() ||
              HistoryInitial() =>
                const Center(child: CircularProgressIndicator()),
              HistoryError(:final message) => Center(child: Text(message)),
              HistoryLoaded(:final receipts) => receipts.isEmpty
                  ? const Center(child: Text('No receipts scanned yet'))
                  : ListView.builder(
                      itemCount: receipts.length,
                      itemBuilder: (context, index) {
                        final receipt = receipts[index];
                        return _ReceiptTile(receipt: receipt);
                      },
                    ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

class _ReceiptTile extends StatelessWidget {
  final Receipt receipt;
  const _ReceiptTile({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final displayTotal = receipt.total ?? receipt.itemsTotal;
    return Dismissible(
      key: ValueKey(receipt.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => context
          .read<ReceiptHistoryBloc>()
          .add(DeleteHistoryReceipt(receipt.id)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.file(
            File(receipt.imagePath),
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.receipt_long),
          ),
        ),
        title: Text(
          receipt.merchantName?.isNotEmpty == true
              ? receipt.merchantName!
              : 'Receipt',
        ),
        subtitle: Text(
          '${DateFormat.yMMMd().add_Hm().format(receipt.scannedAt)} · ${receipt.items.length} items',
        ),
        trailing: Text(displayTotal.toStringAsFixed(0)),
        onTap: () => showModalBottomSheet(
          context: context,
          builder: (_) => ReceiptDetailSheet(receipt: receipt),
        ),
      ),
    );
  }
}

class ReceiptDetailSheet extends StatelessWidget {
  final Receipt receipt;
  const ReceiptDetailSheet({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              receipt.merchantName ?? 'Receipt',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...receipt.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.assignments.isNotEmpty
                            ? '${item.name} x${item.quantity}  ·  '
                                '${item.assignments.entries.map((e) => '${e.key} x${e.value}').join(', ')}'
                            : '${item.name} x${item.quantity}',
                      ),
                    ),
                    Text(item.lineTotal.toStringAsFixed(0)),
                  ],
                ),
              ),
            ),
            const Divider(),
            if (receipt.serviceCharge != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Service Charge'),
                    Text(receipt.serviceCharge!.toStringAsFixed(0)),
                  ],
                ),
              ),
            if (receipt.tax != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax (PPN)'),
                    Text(receipt.tax!.toStringAsFixed(0)),
                  ],
                ),
              ),
            if (receipt.adjustment != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Adjustment'),
                    Text(receipt.adjustment!.toStringAsFixed(0)),
                  ],
                ),
              ),
            if (receipt.discount != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discount'),
                    Text('-${receipt.discount!.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  (receipt.total ?? receipt.itemsTotal).toStringAsFixed(0),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (receipt.items.any((i) => i.assignments.isNotEmpty)) ...[
              const SizedBox(height: 20),
              Text(
                'Split by friend',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),
              ...calculateFriendShares(
                receipt.items,
                serviceCharge: receipt.serviceCharge,
                tax: receipt.tax,
                adjustment: receipt.adjustment,
                discount: receipt.discount,
              ).map(
                (share) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(share.friendName),
                      Text(share.total.toStringAsFixed(0)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
