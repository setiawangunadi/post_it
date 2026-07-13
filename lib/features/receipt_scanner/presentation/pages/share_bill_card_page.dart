import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/local/user_storage.dart';
import '../../domain/entities/friend_share.dart';
import '../utils/payment_message.dart';
import '../widgets/bill_share_card.dart';

/// What to render/share — deliberately decoupled from [Receipt]/[FriendShare]
/// so this screen doesn't need to know which flow (single receipt vs.
/// aggregated overview) it was launched from.
class BillShareData {
  final String friendName;
  final String merchant;
  final double amount;
  final DateTime date;
  final List<AssignedItemDetail> items;

  /// This friend's prorated slice of each receipt-level charge. A
  /// [discount] is a non-negative magnitude, already netted out of
  /// [amount].
  final double serviceCharge;
  final double tax;
  final double adjustment;
  final double discount;

  const BillShareData({
    required this.friendName,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.items,
    this.serviceCharge = 0,
    this.tax = 0,
    this.adjustment = 0,
    this.discount = 0,
  });

  double get itemCount => items.fold(0.0, (sum, item) => sum + item.quantity);
}

class ShareBillCardPage extends StatefulWidget {
  final BillShareData data;
  const ShareBillCardPage({super.key, required this.data});

  @override
  State<ShareBillCardPage> createState() => _ShareBillCardPageState();
}

class _ShareBillCardPageState extends State<ShareBillCardPage> {
  final _cardKey = GlobalKey();
  String? _bankName;
  String? _accountNumber;
  String? _accountHolder;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentInfo();
  }

  Future<void> _loadPaymentInfo() async {
    final bankName = await UserStorage.getBankName();
    final accountNumber = await UserStorage.getBankAccountNumber();
    final accountHolder = await UserStorage.getBankAccountHolder();
    if (!mounted) return;
    setState(() {
      _bankName = bankName;
      _accountNumber = accountNumber;
      _accountHolder = accountHolder;
    });
  }

  Future<void> _shareImage() async {
    setState(() => _sharing = true);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/post_it_bill_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Payment request for ${widget.data.friendName}',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _shareText() async {
    final message = await buildPaymentRequestMessage(
      friendName: widget.data.friendName,
      merchant: widget.data.merchant,
      amount: widget.data.amount,
      serviceCharge: widget.data.serviceCharge,
      tax: widget.data.tax,
      adjustment: widget.data.adjustment,
      discount: widget.data.discount,
    );
    await Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Payment Request')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            RepaintBoundary(
              key: _cardKey,
              child: BillShareCard(
                friendName: widget.data.friendName,
                merchant: widget.data.merchant,
                amount: widget.data.amount,
                date: widget.data.date,
                items: widget.data.items,
                serviceCharge: widget.data.serviceCharge,
                tax: widget.data.tax,
                adjustment: widget.data.adjustment,
                discount: widget.data.discount,
                bankName: _bankName,
                accountNumber: _accountNumber,
                accountHolder: _accountHolder,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: _sharing ? null : _shareImage,
                icon: _sharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.image_outlined),
                label: const Text('Share as Image'),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton.icon(
                onPressed: _shareText,
                icon: const Icon(Icons.text_snippet_outlined),
                label: const Text('Share as Text'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
