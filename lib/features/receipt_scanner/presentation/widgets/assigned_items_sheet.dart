import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../domain/entities/friend_share.dart';
import '../utils/payment_message.dart';

/// A bottom sheet listing exactly which items (and quantities) a friend was
/// billed for on a receipt — lets the user check the detail before sharing
/// a payment request.
class AssignedItemsSheet extends StatelessWidget {
  final String friendName;
  final String merchant;
  final List<AssignedItemDetail> items;

  const AssignedItemsSheet({
    super.key,
    required this.friendName,
    required this.merchant,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).friendItemsTitle(friendName),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              merchant,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            const Divider(),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(S.of(context).noItemsAssigned),
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${item.name} ${formatQty(item.quantity)}'),
                      ),
                      Text('Rp${formatRupiah(item.amount)}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
