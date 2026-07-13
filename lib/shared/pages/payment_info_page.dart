import 'package:flutter/material.dart';
import '../../data/local/user_storage.dart';
import '../../generated/l10n.dart';

class PaymentInfoPage extends StatefulWidget {
  const PaymentInfoPage({super.key});

  @override
  State<PaymentInfoPage> createState() => _PaymentInfoPageState();
}

class _PaymentInfoPageState extends State<PaymentInfoPage> {
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bankName = await UserStorage.getBankName();
    final accountNumber = await UserStorage.getBankAccountNumber();
    final accountHolder = await UserStorage.getBankAccountHolder();
    if (!mounted) return;
    setState(() {
      _bankNameController.text = bankName ?? '';
      _accountNumberController.text = accountNumber ?? '';
      _accountHolderController.text = accountHolder ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final savedMessage = S.of(context).paymentInfoSavedSnackbar;
    await UserStorage.saveBankName(_bankNameController.text.trim());
    await UserStorage.saveBankAccountNumber(
      _accountNumberController.text.trim(),
    );
    await UserStorage.saveBankAccountHolder(
      _accountHolderController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(savedMessage)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).paymentInfoTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(S.of(context).paymentInfoDescription),
                const SizedBox(height: 16),
                TextField(
                  controller: _bankNameController,
                  decoration: InputDecoration(
                    labelText: S.of(context).bankNameFieldLabel,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _accountNumberController,
                  decoration: InputDecoration(
                    labelText: S.of(context).accountNumberFieldLabel,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _accountHolderController,
                  decoration: InputDecoration(
                    labelText: S.of(context).accountHolderNameFieldLabel,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _save,
                  child: Text(S.of(context).saveButton),
                ),
              ],
            ),
    );
  }
}
