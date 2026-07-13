import 'package:equatable/equatable.dart';
import 'receipt.dart';

/// The unassigned bucket uses this as its display name.
const unassignedFriendName = 'Unassigned';

class FriendShare extends Equatable {
  final String friendName;
  final double itemsTotal;
  final double proratedExtra;

  /// This friend's proportional slice of each receipt-level charge —
  /// broken out from [proratedExtra] so callers (e.g. the share card) can
  /// show a line-item breakdown rather than just the combined total.
  /// [proratedDiscount] is a non-negative magnitude, already subtracted
  /// out of [proratedExtra] and [total].
  final double proratedServiceCharge;
  final double proratedTax;
  final double proratedAdjustment;
  final double proratedDiscount;

  /// Number of item *units* assigned to this friend (a qty-2 item split
  /// 1/1 between two friends counts as 1 unit each) — not the receipt's
  /// total item count.
  final int itemCount;

  const FriendShare({
    required this.friendName,
    required this.itemsTotal,
    required this.proratedExtra,
    this.proratedServiceCharge = 0,
    this.proratedTax = 0,
    this.proratedAdjustment = 0,
    this.proratedDiscount = 0,
    required this.itemCount,
  });

  double get total => itemsTotal + proratedExtra;

  @override
  List<Object?> get props => [
        friendName,
        itemsTotal,
        proratedExtra,
        proratedServiceCharge,
        proratedTax,
        proratedAdjustment,
        proratedDiscount,
        itemCount,
      ];
}

/// Splits [items] by [ReceiptItem.assignments] (per-unit friend shares of
/// each item's quantity), then prorates [serviceCharge], [tax],
/// [adjustment] and [discount] across friends in proportion to each
/// friend's share of the items subtotal — so someone who ordered a pricier
/// dish (or more units of a shared one) also carries a proportionally
/// larger slice of the shared service charge/tax (and a proportionally
/// larger slice of the discount) rather than an even split.
List<FriendShare> calculateFriendShares(
  List<ReceiptItem> items, {
  double? serviceCharge,
  double? tax,
  double? adjustment,
  double? discount,
}) {
  final itemsTotal = items.fold(0.0, (sum, item) => sum + item.lineTotal);
  final extra =
      (serviceCharge ?? 0) + (tax ?? 0) + (adjustment ?? 0) - (discount ?? 0);

  final totalsByFriend = <String, double>{};
  final itemCountByFriend = <String, int>{};
  for (final item in items) {
    for (final entry in item.assignments.entries) {
      final name = entry.key.trim();
      if (name.isEmpty || entry.value <= 0) continue;
      totalsByFriend[name] =
          (totalsByFriend[name] ?? 0) + item.price * entry.value;
      itemCountByFriend[name] = (itemCountByFriend[name] ?? 0) + entry.value;
    }
    if (item.unassignedQuantity > 0) {
      totalsByFriend[unassignedFriendName] =
          (totalsByFriend[unassignedFriendName] ?? 0) +
              item.price * item.unassignedQuantity;
      itemCountByFriend[unassignedFriendName] =
          (itemCountByFriend[unassignedFriendName] ?? 0) +
              item.unassignedQuantity;
    }
  }

  final shares = totalsByFriend.entries.map((entry) {
    final ratio = itemsTotal > 0 ? entry.value / itemsTotal : 0.0;
    return FriendShare(
      friendName: entry.key,
      itemsTotal: entry.value,
      proratedExtra: ratio * extra,
      proratedServiceCharge: ratio * (serviceCharge ?? 0),
      proratedTax: ratio * (tax ?? 0),
      proratedAdjustment: ratio * (adjustment ?? 0),
      proratedDiscount: ratio * (discount ?? 0),
      itemCount: itemCountByFriend[entry.key] ?? 0,
    );
  }).toList();

  shares.sort((a, b) {
    if (a.friendName == unassignedFriendName) return 1;
    if (b.friendName == unassignedFriendName) return -1;
    return a.friendName.toLowerCase().compareTo(b.friendName.toLowerCase());
  });
  return shares;
}

/// One item (or partial quantity of one) assigned to a specific friend.
class AssignedItemDetail extends Equatable {
  final String name;
  final int quantity;
  final double amount;

  const AssignedItemDetail({
    required this.name,
    required this.quantity,
    required this.amount,
  });

  @override
  List<Object?> get props => [name, quantity, amount];
}

/// The individual items (and assigned quantities) billed to [friendName] on
/// this receipt — used to show/share exactly what someone is being asked to
/// pay for, rather than just a total.
List<AssignedItemDetail> getAssignedItems(
  List<ReceiptItem> items,
  String friendName,
) {
  final result = <AssignedItemDetail>[];
  for (final item in items) {
    final qty = item.assignments[friendName] ?? 0;
    if (qty <= 0) continue;
    result.add(
      AssignedItemDetail(
        name: item.name,
        quantity: qty,
        amount: item.price * qty,
      ),
    );
  }
  return result;
}

/// A single receipt's contribution to a friend's running balance.
class FriendReceiptContribution extends Equatable {
  final Receipt receipt;
  final double amount;
  final bool paid;
  final int itemCount;

  const FriendReceiptContribution({
    required this.receipt,
    required this.amount,
    required this.paid,
    required this.itemCount,
  });

  @override
  List<Object?> get props => [receipt, amount, paid, itemCount];
}

/// A friend's balance across every receipt they've been assigned items on.
class FriendBalance extends Equatable {
  final String friendName;
  final List<FriendReceiptContribution> contributions;

  const FriendBalance({
    required this.friendName,
    required this.contributions,
  });

  double get totalOwed =>
      contributions.where((c) => !c.paid).fold(0.0, (sum, c) => sum + c.amount);

  double get totalPaid =>
      contributions.where((c) => c.paid).fold(0.0, (sum, c) => sum + c.amount);

  double get total => totalOwed + totalPaid;

  bool get isSettled => totalOwed <= 0.01;

  @override
  List<Object?> get props => [friendName, contributions];
}

/// Sum of every receipt's grand total — used for an at-a-glance "total
/// spent" figure across all scanned receipts.
double calculateTotalSpending(List<Receipt> receipts) {
  return receipts.fold(0.0, (sum, r) => sum + (r.total ?? r.itemsTotal));
}

/// Aggregates each friend's balance across every receipt, using the same
/// per-receipt [calculateFriendShares] split and each receipt's own
/// [Receipt.paidStatus] to separate what's still owed from what's settled.
/// Sorted with the largest outstanding balance first.
List<FriendBalance> calculateFriendBalances(List<Receipt> receipts) {
  final byFriend = <String, List<FriendReceiptContribution>>{};

  for (final receipt in receipts) {
    final shares = calculateFriendShares(
      receipt.items,
      serviceCharge: receipt.serviceCharge,
      tax: receipt.tax,
      adjustment: receipt.adjustment,
      discount: receipt.discount,
    ).where((s) => s.friendName != unassignedFriendName);

    for (final share in shares) {
      final paid = receipt.paidStatus[share.friendName] ?? false;
      byFriend.putIfAbsent(share.friendName, () => []).add(
            FriendReceiptContribution(
              receipt: receipt,
              amount: share.total,
              paid: paid,
              itemCount: share.itemCount,
            ),
          );
    }
  }

  final balances = byFriend.entries
      .map((e) => FriendBalance(friendName: e.key, contributions: e.value))
      .toList();

  balances.sort((a, b) => b.totalOwed.compareTo(a.totalOwed));
  return balances;
}
