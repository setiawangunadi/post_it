import 'package:flutter/material.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/friend_share.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/usecases/save_receipt.dart';
import '../utils/payment_message.dart';
import '../widgets/assigned_items_sheet.dart';
import 'share_bill_card_page.dart';

class PaymentSummaryPage extends StatefulWidget {
  final Receipt receipt;
  const PaymentSummaryPage({super.key, required this.receipt});

  @override
  State<PaymentSummaryPage> createState() => _PaymentSummaryPageState();
}

class _PaymentSummaryPageState extends State<PaymentSummaryPage> {
  late Receipt _receipt;

  @override
  void initState() {
    super.initState();
    _receipt = widget.receipt;
  }

  List<FriendShare> get _shares => calculateFriendShares(
        _receipt.items,
        serviceCharge: _receipt.serviceCharge,
        tax: _receipt.tax,
        adjustment: _receipt.adjustment,
      ).where((share) => share.friendName != unassignedFriendName).toList();

  double get _unassignedAmount => calculateFriendShares(
        _receipt.items,
        serviceCharge: _receipt.serviceCharge,
        tax: _receipt.tax,
        adjustment: _receipt.adjustment,
      )
          .where((share) => share.friendName == unassignedFriendName)
          .fold(0.0, (sum, share) => sum + share.total);

  Future<void> _togglePaid(String friendName, bool paid) async {
    final updatedStatus = Map.of(_receipt.paidStatus)..[friendName] = paid;
    final updated = _receipt.copyWith(paidStatus: updatedStatus);
    setState(() => _receipt = updated);
    await sl<SaveReceipt>()(SaveReceiptParams(receipt: updated));
  }

  String get _merchant => _receipt.merchantName?.isNotEmpty == true
      ? _receipt.merchantName!
      : 'the receipt';

  void _share(FriendShare share) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShareBillCardPage(
          data: BillShareData(
            friendName: share.friendName,
            merchant: _merchant,
            amount: share.total,
            date: _receipt.scannedAt,
            items: getAssignedItems(_receipt.items, share.friendName),
          ),
        ),
      ),
    );
  }

  void _viewItems(FriendShare share) {
    showModalBottomSheet(
      context: context,
      builder: (_) => AssignedItemsSheet(
        friendName: share.friendName,
        merchant: _merchant,
        items: getAssignedItems(_receipt.items, share.friendName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Who Owes What')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _receipt.merchantName?.isNotEmpty == true
                ? _receipt.merchantName!
                : 'Receipt',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Total ${formatRupiah(_receipt.total ?? _receipt.itemsTotal)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (_shares.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No items were assigned to a friend, so there\'s no one to '
                'bill. Go back and assign items to split the cost.',
              ),
            )
          else
            ..._shares.map((share) {
              final paid = _receipt.paidStatus[share.friendName] ?? false;
              return Card(
                child: ListTile(
                  leading: Checkbox(
                    value: paid,
                    onChanged: (value) =>
                        _togglePaid(share.friendName, value ?? false),
                  ),
                  title: Text(share.friendName),
                  subtitle: Text(
                    paid ? 'Paid' : 'Owes ${formatRupiah(share.total)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.receipt_long_outlined),
                        tooltip: 'View items',
                        onPressed: () => _viewItems(share),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        tooltip: 'Share payment request',
                        onPressed: () => _share(share),
                      ),
                    ],
                  ),
                ),
              );
            }),
          if (_unassignedAmount > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Rp${formatRupiah(_unassignedAmount)} not assigned to '
              'anyone',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
