import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../features/receipt_scanner/domain/entities/friend_share.dart';
import '../../features/receipt_scanner/domain/entities/receipt.dart';
import '../../generated/l10n.dart';
import '../../features/receipt_scanner/presentation/bloc/history/receipt_history_bloc.dart';
import '../../features/receipt_scanner/presentation/pages/receipt_history_page.dart';
import '../../features/receipt_scanner/presentation/utils/payment_message.dart';
import '../../features/receipt_scanner/presentation/utils/pick_receipt_image.dart';
import '../../injection_container.dart';
import '../../router/route_observer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReceiptHistoryBloc>()..add(const LoadHistory()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Refreshes the receipt list whenever the user navigates back to Home,
  // since a receipt scan, a payment status change, etc. happen on a
  // separate screen and this page's Bloc instance stays alive underneath.
  @override
  void didPopNext() {
    context.read<ReceiptHistoryBloc>().add(const LoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ReceiptHistoryBloc, ReceiptHistoryState>(
          builder: (context, state) {
            if (state is HistoryInitial || state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final receipts = switch (state) {
              HistoryLoaded(:final receipts) => receipts,
              _ => const <Receipt>[],
            };
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ReceiptHistoryBloc>().add(const LoadHistory());
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  _Header(
                    onPaymentInfoTap: () => context.push('/payment-info'),
                  ),
                  const SizedBox(height: 20),
                  _SpendingCard(receipts: receipts),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: S.of(context).homeRecentReceipts,
                    onSeeAll: () => context.push('/receipt-history'),
                  ),
                  const SizedBox(height: 12),
                  if (receipts.isEmpty)
                    _EmptyHint(
                      icon: Icons.receipt_long_outlined,
                      text: S.of(context).homeEmptyReceiptsHint,
                    )
                  else
                    ...receipts
                        .take(3)
                        .map((r) => _RecentReceiptCard(receipt: r)),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: S.of(context).paymentsAction,
                    onSeeAll: () => context.push('/payments'),
                  ),
                  const SizedBox(height: 12),
                  _PaymentsPreview(receipts: receipts),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onPaymentInfoTap;
  const _Header({required this.onPaymentInfoTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PuteIt',
                style: textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                S.of(context).homeTagline,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onPaymentInfoTap,
          tooltip: S.of(context).paymentInfoTooltip,
          icon: const Icon(Icons.account_balance_outlined),
        ),
      ],
    );
  }
}

class _SpendingCard extends StatelessWidget {
  final List<Receipt> receipts;
  const _SpendingCard({required this.receipts});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final total = calculateTotalSpending(receipts);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.tertiary],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).totalSpendingLabel,
                style:
                    TextStyle(color: colors.onPrimary.withValues(alpha: 0.85)),
              ),
              Icon(
                Icons.shopping_bag_outlined,
                color: colors.onPrimary.withValues(alpha: 0.85),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Rp${formatRupiah(total)}',
            style: TextStyle(
              color: colors.onPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            S.of(context).receiptsScannedCount(receipts.length),
            style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.camera_alt_outlined,
                  label: S.of(context).scanAction,
                  onTap: () async {
                    final imagePath = await pickReceiptImage(context);
                    if (imagePath != null && context.mounted) {
                      context.push('/receipt-scanner', extra: imagePath);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.history,
                  label: S.of(context).historyAction,
                  onTap: () => context.push('/receipt-history'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.people_alt_outlined,
                  label: S.of(context).paymentsAction,
                  onTap: () => context.push('/payments'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: onPrimary.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: onPrimary, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.of(context).seeAll),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentReceiptCard extends StatelessWidget {
  final Receipt receipt;
  const _RecentReceiptCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final total = receipt.total ?? receipt.itemsTotal;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(receipt.imagePath),
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.receipt_long),
          ),
        ),
        title: Text(
          receipt.merchantName?.isNotEmpty == true
              ? receipt.merchantName!
              : S.of(context).receiptFallbackName,
        ),
        subtitle: Text(
          S.of(context).receiptItemsSubtitle(
                DateFormat.yMMMd().format(receipt.scannedAt),
                receipt.items.length,
              ),
        ),
        trailing: Text('Rp${formatRupiah(total)}'),
        onTap: () => showModalBottomSheet(
          context: context,
          builder: (_) => ReceiptDetailSheet(receipt: receipt),
        ),
      ),
    );
  }
}

class _PaymentsPreview extends StatelessWidget {
  final List<Receipt> receipts;
  const _PaymentsPreview({required this.receipts});

  @override
  Widget build(BuildContext context) {
    final balances = calculateFriendBalances(receipts).take(3).toList();
    if (balances.isEmpty) {
      return _EmptyHint(
        icon: Icons.people_outline,
        text: S.of(context).homeEmptyPaymentsHint,
      );
    }
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: balances.map((balance) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(balance.friendName),
            subtitle: Text(
              balance.isSettled
                  ? S.of(context).allSettled
                  : S.of(context).owesAmount('Rp${formatRupiah(balance.totalOwed)}'),
            ),
            trailing: Chip(
              label: Text(
                balance.isSettled ? S.of(context).paidLabel : S.of(context).unpaidLabel,
              ),
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
            onTap: () => context.push('/payments'),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
