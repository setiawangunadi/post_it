import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../generated/l10n.dart';
import '../../../../injection_container.dart';
import '../../../friends/domain/entities/friend.dart';
import '../../../friends/presentation/bloc/friends_bloc.dart';
import '../../domain/entities/friend_share.dart';
import '../../domain/entities/receipt.dart';
import '../bloc/scanner/receipt_scanner_bloc.dart';
import '../utils/pick_receipt_image.dart';
import '../widgets/receipt_item_tile.dart';

class ReceiptScannerPage extends StatelessWidget {
  /// Image already picked (e.g. via the Home page's Scan button, which shows
  /// the camera/gallery sheet before navigating here). When present, scanning
  /// starts immediately instead of prompting for a source again.
  final String? imagePath;

  /// An already-saved receipt to edit — when present, this takes priority
  /// over [imagePath] and skips OCR entirely, going straight to the review
  /// screen pre-filled with its existing data (items, assignments, charges).
  final Receipt? existingReceipt;

  const ReceiptScannerPage({super.key, this.imagePath, this.existingReceipt});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ReceiptScannerBloc>()),
        BlocProvider(
          create: (_) => sl<FriendsBloc>()..add(const LoadFriends()),
        ),
      ],
      child: _ReceiptScannerView(
        imagePath: imagePath,
        existingReceipt: existingReceipt,
      ),
    );
  }
}

class _ReceiptScannerView extends StatefulWidget {
  final String? imagePath;
  final Receipt? existingReceipt;
  const _ReceiptScannerView({this.imagePath, this.existingReceipt});

  @override
  State<_ReceiptScannerView> createState() => _ReceiptScannerViewState();
}

class _ReceiptScannerViewState extends State<_ReceiptScannerView> {
  final _merchantController = TextEditingController();
  final _serviceChargeController = TextEditingController();
  final _taxController = TextEditingController();
  final _adjustmentController = TextEditingController();
  final _discountController = TextEditingController();

  Receipt? _draft;
  List<ReceiptItem> _editableItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.existingReceipt != null) {
        context
            .read<ReceiptScannerBloc>()
            .add(EditReceiptRequested(widget.existingReceipt!));
      } else if (widget.imagePath != null) {
        context
            .read<ReceiptScannerBloc>()
            .add(ScanReceiptRequested(widget.imagePath!));
      } else {
        _pickAndScan();
      }
    });
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _serviceChargeController.dispose();
    _taxController.dispose();
    _adjustmentController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickAndScan() async {
    final imagePath = await pickReceiptImage(context);
    if (imagePath == null || !mounted) return;
    context.read<ReceiptScannerBloc>().add(ScanReceiptRequested(imagePath));
  }

  double get _itemsTotal =>
      _editableItems.fold(0, (sum, item) => sum + item.lineTotal);

  double get _grandTotal =>
      _itemsTotal +
      (double.tryParse(_serviceChargeController.text) ?? 0) +
      (double.tryParse(_taxController.text) ?? 0) +
      (double.tryParse(_adjustmentController.text) ?? 0) -
      (double.tryParse(_discountController.text) ?? 0);

  void _save() {
    if (_draft == null) return;
    final receipt = _draft!.copyWith(
      merchantName: _merchantController.text,
      items: _editableItems,
      serviceCharge: double.tryParse(_serviceChargeController.text),
      tax: double.tryParse(_taxController.text),
      adjustment: double.tryParse(_adjustmentController.text),
      discount: double.tryParse(_discountController.text),
    );
    context.read<ReceiptScannerBloc>().add(SaveReceiptRequested(receipt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingReceipt != null
              ? S.of(context).editReceiptTitle
              : S.of(context).scanReceiptTitle,
        ),
      ),
      body: BlocConsumer<ReceiptScannerBloc, ReceiptScannerState>(
        listener: (context, state) {
          if (state is ScannerReview) {
            setState(() {
              _draft = state.receipt;
              _editableItems = List.of(state.receipt.items);
              _merchantController.text = state.receipt.merchantName ?? '';
              _serviceChargeController.text =
                  state.receipt.serviceCharge?.toStringAsFixed(0) ?? '';
              _taxController.text = state.receipt.tax?.toStringAsFixed(0) ?? '';
              _adjustmentController.text =
                  state.receipt.adjustment?.toStringAsFixed(0) ?? '';
              _discountController.text =
                  state.receipt.discount?.toStringAsFixed(0) ?? '';
            });
          } else if (state is ScannerSaved) {
            context.pushReplacement('/payment-summary', extra: state.receipt);
          } else if (state is ScannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ScannerProcessing) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ScannerReview ||
              (_draft != null && state is! ScannerInitial)) {
            return _buildReview();
          }
          return _buildPickPrompt(context);
        },
      ),
    );
  }

  Widget _buildPickPrompt(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _pickAndScan,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(S.of(context).choosePhotoSource),
      ),
    );
  }

  Widget _buildReview() {
    final draft = _draft!;
    final friends = switch (context.watch<FriendsBloc>().state) {
      FriendsLoaded(:final friends) => friends,
      _ => <Friend>[],
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              Image.file(File(draft.imagePath), height: 180, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _merchantController,
          decoration: InputDecoration(labelText: S.of(context).merchantLabel),
        ),
        const SizedBox(height: 16),
        Text(S.of(context).itemsLabel, style: Theme.of(context).textTheme.titleMedium),
        const Divider(),
        ..._editableItems.asMap().entries.map((entry) {
          final index = entry.key;
          return ReceiptItemTile(
            key: ValueKey(index),
            item: entry.value,
            friends: friends,
            onAddFriend: (name) =>
                context.read<FriendsBloc>().add(AddFriendRequested(name)),
            onChanged: (updated) =>
                setState(() => _editableItems[index] = updated),
            onDelete: () => setState(() => _editableItems.removeAt(index)),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(
            () => _editableItems
                .add(const ReceiptItem(name: '', quantity: 1, price: 0)),
          ),
          icon: const Icon(Icons.add),
          label: Text(S.of(context).addItemButton),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(S.of(context).itemsSubtotalLabel),
            Text(_itemsTotal.toStringAsFixed(0)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _serviceChargeController,
                decoration:
                    InputDecoration(labelText: S.of(context).serviceChargeLabel),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _taxController,
                decoration: InputDecoration(labelText: S.of(context).taxWithPpnLabel),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _adjustmentController,
                decoration:
                    InputDecoration(labelText: S.of(context).adjustmentLabel),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _discountController,
                decoration: InputDecoration(labelText: S.of(context).discountLabel),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).totalLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              _grandTotal.toStringAsFixed(0),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (_editableItems.any((i) => i.assignments.isNotEmpty)) ...[
          const SizedBox(height: 24),
          Text(
            S.of(context).splitByFriend,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(),
          ...calculateFriendShares(
            _editableItems,
            serviceCharge: double.tryParse(_serviceChargeController.text),
            tax: double.tryParse(_taxController.text),
            adjustment: double.tryParse(_adjustmentController.text),
            discount: double.tryParse(_discountController.text),
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
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _save,
          child: Text(S.of(context).saveReceiptButton),
        ),
      ],
    );
  }
}
