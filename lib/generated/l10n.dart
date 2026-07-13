// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `post_it`
  String get appName {
    return Intl.message(
      'post_it',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Struk`
  String get receiptFallbackName {
    return Intl.message(
      'Struk',
      name: 'receiptFallbackName',
      desc: '',
      args: [],
    );
  }

  /// `struk ini`
  String get theReceiptFallbackName {
    return Intl.message(
      'struk ini',
      name: 'theReceiptFallbackName',
      desc: '',
      args: [],
    );
  }

  /// `Sudah lunas`
  String get allSettled {
    return Intl.message(
      'Sudah lunas',
      name: 'allSettled',
      desc: '',
      args: [],
    );
  }

  /// `Lunas`
  String get paidLabel {
    return Intl.message(
      'Lunas',
      name: 'paidLabel',
      desc: '',
      args: [],
    );
  }

  /// `Belum Lunas`
  String get unpaidLabel {
    return Intl.message(
      'Belum Lunas',
      name: 'unpaidLabel',
      desc: '',
      args: [],
    );
  }

  /// `Menunggak {amount}`
  String owesAmount(Object amount) {
    return Intl.message(
      'Menunggak $amount',
      name: 'owesAmount',
      desc: '',
      args: [amount],
    );
  }

  /// `Lihat item`
  String get viewItemsTooltip {
    return Intl.message(
      'Lihat item',
      name: 'viewItemsTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Bagikan permintaan pembayaran`
  String get sharePaymentRequestTooltip {
    return Intl.message(
      'Bagikan permintaan pembayaran',
      name: 'sharePaymentRequestTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Selesai`
  String get doneButton {
    return Intl.message(
      'Selesai',
      name: 'doneButton',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get totalLabel {
    return Intl.message(
      'Total',
      name: 'totalLabel',
      desc: '',
      args: [],
    );
  }

  /// `Biaya Layanan`
  String get serviceChargeLabel {
    return Intl.message(
      'Biaya Layanan',
      name: 'serviceChargeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Pajak (PPN)`
  String get taxWithPpnLabel {
    return Intl.message(
      'Pajak (PPN)',
      name: 'taxWithPpnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Pajak`
  String get taxLabel {
    return Intl.message(
      'Pajak',
      name: 'taxLabel',
      desc: '',
      args: [],
    );
  }

  /// `Penyesuaian`
  String get adjustmentLabel {
    return Intl.message(
      'Penyesuaian',
      name: 'adjustmentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Diskon`
  String get discountLabel {
    return Intl.message(
      'Diskon',
      name: 'discountLabel',
      desc: '',
      args: [],
    );
  }

  /// `Bank`
  String get bankLabel {
    return Intl.message(
      'Bank',
      name: 'bankLabel',
      desc: '',
      args: [],
    );
  }

  /// `Merchant`
  String get merchantLabel {
    return Intl.message(
      'Merchant',
      name: 'merchantLabel',
      desc: '',
      args: [],
    );
  }

  /// `Struk Terbaru`
  String get homeRecentReceipts {
    return Intl.message(
      'Struk Terbaru',
      name: 'homeRecentReceipts',
      desc: '',
      args: [],
    );
  }

  /// `Belum ada struk. Pindai satu untuk mulai.`
  String get homeEmptyReceiptsHint {
    return Intl.message(
      'Belum ada struk. Pindai satu untuk mulai.',
      name: 'homeEmptyReceiptsHint',
      desc: '',
      args: [],
    );
  }

  /// `Pindai struk, bagi tagihan bersama teman.`
  String get homeTagline {
    return Intl.message(
      'Pindai struk, bagi tagihan bersama teman.',
      name: 'homeTagline',
      desc: '',
      args: [],
    );
  }

  /// `Info Pembayaran`
  String get paymentInfoTooltip {
    return Intl.message(
      'Info Pembayaran',
      name: 'paymentInfoTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Total Pengeluaran`
  String get totalSpendingLabel {
    return Intl.message(
      'Total Pengeluaran',
      name: 'totalSpendingLabel',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{1 struk dipindai} other{{count} struk dipindai}}`
  String receiptsScannedCount(num count) {
    return Intl.plural(
      count,
      one: '1 struk dipindai',
      other: '$count struk dipindai',
      name: 'receiptsScannedCount',
      desc: '',
      args: [count],
    );
  }

  /// `Pindai`
  String get scanAction {
    return Intl.message(
      'Pindai',
      name: 'scanAction',
      desc: '',
      args: [],
    );
  }

  /// `Riwayat`
  String get historyAction {
    return Intl.message(
      'Riwayat',
      name: 'historyAction',
      desc: '',
      args: [],
    );
  }

  /// `Pembayaran`
  String get paymentsAction {
    return Intl.message(
      'Pembayaran',
      name: 'paymentsAction',
      desc: '',
      args: [],
    );
  }

  /// `Lihat semua`
  String get seeAll {
    return Intl.message(
      'Lihat semua',
      name: 'seeAll',
      desc: '',
      args: [],
    );
  }

  /// `Tetapkan item ke teman pada sebuah struk untuk melacak siapa yang berutang.`
  String get homeEmptyPaymentsHint {
    return Intl.message(
      'Tetapkan item ke teman pada sebuah struk untuk melacak siapa yang berutang.',
      name: 'homeEmptyPaymentsHint',
      desc: '',
      args: [],
    );
  }

  /// `{date} · {count, plural, one{1 item} other{{count} item}}`
  String receiptItemsSubtitle(Object date, num count) {
    return Intl.message(
      '$date · ${Intl.plural(count, one: '1 item', other: '$count item')}',
      name: 'receiptItemsSubtitle',
      desc: '',
      args: [date, count],
    );
  }

  /// `Siapa Berutang Apa`
  String get whoOwesWhatTitle {
    return Intl.message(
      'Siapa Berutang Apa',
      name: 'whoOwesWhatTitle',
      desc: '',
      args: [],
    );
  }

  /// `Total {amount}`
  String totalWithAmount(Object amount) {
    return Intl.message(
      'Total $amount',
      name: 'totalWithAmount',
      desc: '',
      args: [amount],
    );
  }

  /// `Belum ada item yang ditetapkan ke teman, jadi tidak ada yang perlu ditagih. Kembali dan tetapkan item untuk membagi biaya.`
  String get noItemsAssignedHint {
    return Intl.message(
      'Belum ada item yang ditetapkan ke teman, jadi tidak ada yang perlu ditagih. Kembali dan tetapkan item untuk membagi biaya.',
      name: 'noItemsAssignedHint',
      desc: '',
      args: [],
    );
  }

  /// `{amount} belum ditetapkan ke siapa pun`
  String unassignedAmountHint(Object amount) {
    return Intl.message(
      '$amount belum ditetapkan ke siapa pun',
      name: 'unassignedAmountHint',
      desc: '',
      args: [amount],
    );
  }

  /// `Pembayaran`
  String get paymentsTitle {
    return Intl.message(
      'Pembayaran',
      name: 'paymentsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Belum ada pembagian tagihan. Tetapkan item ke teman saat memindai struk untuk melacak siapa yang berutang.`
  String get noSplitPaymentsHint {
    return Intl.message(
      'Belum ada pembagian tagihan. Tetapkan item ke teman saat memindai struk untuk melacak siapa yang berutang.',
      name: 'noSplitPaymentsHint',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{1 struk dipilih} other{{count} struk dipilih}}`
  String receiptsSelectedCount(num count) {
    return Intl.plural(
      count,
      one: '1 struk dipilih',
      other: '$count struk dipilih',
      name: 'receiptsSelectedCount',
      desc: '',
      args: [count],
    );
  }

  /// `Pilih 2+ struk untuk digabung jadi satu tagihan`
  String get selectReceiptsToMergeHint {
    return Intl.message(
      'Pilih 2+ struk untuk digabung jadi satu tagihan',
      name: 'selectReceiptsToMergeHint',
      desc: '',
      args: [],
    );
  }

  /// `Bagikan Gabungan`
  String get shareMergedButton {
    return Intl.message(
      'Bagikan Gabungan',
      name: 'shareMergedButton',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{1 struk} other{{count} struk}}`
  String receiptsCountLabel(num count) {
    return Intl.plural(
      count,
      one: '1 struk',
      other: '$count struk',
      name: 'receiptsCountLabel',
      desc: '',
      args: [count],
    );
  }

  /// `Riwayat Struk`
  String get receiptHistoryTitle {
    return Intl.message(
      'Riwayat Struk',
      name: 'receiptHistoryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Belum ada struk yang dipindai`
  String get noReceiptsScannedYet {
    return Intl.message(
      'Belum ada struk yang dipindai',
      name: 'noReceiptsScannedYet',
      desc: '',
      args: [],
    );
  }

  /// `Edit struk`
  String get editReceiptTooltip {
    return Intl.message(
      'Edit struk',
      name: 'editReceiptTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Pembagian per teman`
  String get splitByFriend {
    return Intl.message(
      'Pembagian per teman',
      name: 'splitByFriend',
      desc: '',
      args: [],
    );
  }

  /// `Edit Struk`
  String get editReceiptTitle {
    return Intl.message(
      'Edit Struk',
      name: 'editReceiptTitle',
      desc: '',
      args: [],
    );
  }

  /// `Pindai Struk`
  String get scanReceiptTitle {
    return Intl.message(
      'Pindai Struk',
      name: 'scanReceiptTitle',
      desc: '',
      args: [],
    );
  }

  /// `Pilih Sumber Foto`
  String get choosePhotoSource {
    return Intl.message(
      'Pilih Sumber Foto',
      name: 'choosePhotoSource',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get itemsLabel {
    return Intl.message(
      'Item',
      name: 'itemsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Tambah item`
  String get addItemButton {
    return Intl.message(
      'Tambah item',
      name: 'addItemButton',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal item`
  String get itemsSubtotalLabel {
    return Intl.message(
      'Subtotal item',
      name: 'itemsSubtotalLabel',
      desc: '',
      args: [],
    );
  }

  /// `Simpan Struk`
  String get saveReceiptButton {
    return Intl.message(
      'Simpan Struk',
      name: 'saveReceiptButton',
      desc: '',
      args: [],
    );
  }

  /// `Permintaan pembayaran untuk {name}`
  String paymentRequestForFriend(Object name) {
    return Intl.message(
      'Permintaan pembayaran untuk $name',
      name: 'paymentRequestForFriend',
      desc: '',
      args: [name],
    );
  }

  /// `Bagikan Permintaan Pembayaran`
  String get sharePaymentRequestTitle {
    return Intl.message(
      'Bagikan Permintaan Pembayaran',
      name: 'sharePaymentRequestTitle',
      desc: '',
      args: [],
    );
  }

  /// `Bagikan sebagai Gambar`
  String get shareAsImage {
    return Intl.message(
      'Bagikan sebagai Gambar',
      name: 'shareAsImage',
      desc: '',
      args: [],
    );
  }

  /// `Bagikan sebagai Teks`
  String get shareAsText {
    return Intl.message(
      'Bagikan sebagai Teks',
      name: 'shareAsText',
      desc: '',
      args: [],
    );
  }

  /// `Hai {name},`
  String greetingHi(Object name) {
    return Intl.message(
      'Hai $name,',
      name: 'greetingHi',
      desc: '',
      args: [name],
    );
  }

  /// `Bagianmu dari tagihan {merchant} adalah {amount}.`
  String yourShareMessage(Object merchant, Object amount) {
    return Intl.message(
      'Bagianmu dari tagihan $merchant adalah $amount.',
      name: 'yourShareMessage',
      desc: '',
      args: [merchant, amount],
    );
  }

  /// `Rincian:`
  String get breakdownLabel {
    return Intl.message(
      'Rincian:',
      name: 'breakdownLabel',
      desc: '',
      args: [],
    );
  }

  /// `Biaya Layanan: {amount}`
  String serviceChargeLine(Object amount) {
    return Intl.message(
      'Biaya Layanan: $amount',
      name: 'serviceChargeLine',
      desc: '',
      args: [amount],
    );
  }

  /// `Pajak: {amount}`
  String taxLine(Object amount) {
    return Intl.message(
      'Pajak: $amount',
      name: 'taxLine',
      desc: '',
      args: [amount],
    );
  }

  /// `Penyesuaian: {amount}`
  String adjustmentLine(Object amount) {
    return Intl.message(
      'Penyesuaian: $amount',
      name: 'adjustmentLine',
      desc: '',
      args: [amount],
    );
  }

  /// `Diskon: -{amount}`
  String discountLine(Object amount) {
    return Intl.message(
      'Diskon: -$amount',
      name: 'discountLine',
      desc: '',
      args: [amount],
    );
  }

  /// `Silakan transfer ke:`
  String get pleaseTransferTo {
    return Intl.message(
      'Silakan transfer ke:',
      name: 'pleaseTransferTo',
      desc: '',
      args: [],
    );
  }

  /// `a.n. {name}`
  String accountHolderPrefix(Object name) {
    return Intl.message(
      'a.n. $name',
      name: 'accountHolderPrefix',
      desc: '',
      args: [name],
    );
  }

  /// `Terima kasih!`
  String get thanksClosing {
    return Intl.message(
      'Terima kasih!',
      name: 'thanksClosing',
      desc: '',
      args: [],
    );
  }

  /// `Ambil Foto`
  String get takePhoto {
    return Intl.message(
      'Ambil Foto',
      name: 'takePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Pilih dari Galeri`
  String get chooseFromGallery {
    return Intl.message(
      'Pilih dari Galeri',
      name: 'chooseFromGallery',
      desc: '',
      args: [],
    );
  }

  /// `Item milik {name}`
  String friendItemsTitle(Object name) {
    return Intl.message(
      'Item milik $name',
      name: 'friendItemsTitle',
      desc: '',
      args: [name],
    );
  }

  /// `Belum ada item yang ditetapkan.`
  String get noItemsAssigned {
    return Intl.message(
      'Belum ada item yang ditetapkan.',
      name: 'noItemsAssigned',
      desc: '',
      args: [],
    );
  }

  /// `PEMBAGIAN TAGIHAN`
  String get splitBillPaymentLabel {
    return Intl.message(
      'PEMBAGIAN TAGIHAN',
      name: 'splitBillPaymentLabel',
      desc: '',
      args: [],
    );
  }

  /// `untuk {merchant}`
  String forMerchant(Object merchant) {
    return Intl.message(
      'untuk $merchant',
      name: 'forMerchant',
      desc: '',
      args: [merchant],
    );
  }

  /// `Ditagihkan ke`
  String get billedToLabel {
    return Intl.message(
      'Ditagihkan ke',
      name: 'billedToLabel',
      desc: '',
      args: [],
    );
  }

  /// `Item ({count})`
  String itemsCountLabel(Object count) {
    return Intl.message(
      'Item ($count)',
      name: 'itemsCountLabel',
      desc: '',
      args: [count],
    );
  }

  /// `Kamu memiliki lebih dari {max} item — tanyakan ke temanmu untuk detail lengkap.`
  String moreItemsHint(Object max) {
    return Intl.message(
      'Kamu memiliki lebih dari $max item — tanyakan ke temanmu untuk detail lengkap.',
      name: 'moreItemsHint',
      desc: '',
      args: [max],
    );
  }

  /// `No. Rekening`
  String get accountNoLabel {
    return Intl.message(
      'No. Rekening',
      name: 'accountNoLabel',
      desc: '',
      args: [],
    );
  }

  /// `Nama Pemilik Rekening`
  String get accountHolderLabel {
    return Intl.message(
      'Nama Pemilik Rekening',
      name: 'accountHolderLabel',
      desc: '',
      args: [],
    );
  }

  /// `Silakan transfer sejumlah di atas.\nDibagikan via PuteIt`
  String get transferFooterNote {
    return Intl.message(
      'Silakan transfer sejumlah di atas.\nDibagikan via PuteIt',
      name: 'transferFooterNote',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get itemFieldLabel {
    return Intl.message(
      'Item',
      name: 'itemFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Jml`
  String get qtyFieldLabel {
    return Intl.message(
      'Jml',
      name: 'qtyFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Harga`
  String get priceFieldLabel {
    return Intl.message(
      'Harga',
      name: 'priceFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Tetapkan`
  String get assignChipLabel {
    return Intl.message(
      'Tetapkan',
      name: 'assignChipLabel',
      desc: '',
      args: [],
    );
  }

  /// `Tetapkan ke`
  String get assignToTitle {
    return Intl.message(
      'Tetapkan ke',
      name: 'assignToTitle',
      desc: '',
      args: [],
    );
  }

  /// `Dibagi rata untuk {count} orang`
  String splitEvenlyAmongHint(Object count) {
    return Intl.message(
      'Dibagi rata untuk $count orang',
      name: 'splitEvenlyAmongHint',
      desc: '',
      args: [count],
    );
  }

  /// `{remaining} dari {total} belum ditetapkan`
  String remainingOfQuantityHint(Object remaining, Object total) {
    return Intl.message(
      '$remaining dari $total belum ditetapkan',
      name: 'remainingOfQuantityHint',
      desc: '',
      args: [remaining, total],
    );
  }

  /// `Nama teman baru`
  String get newFriendNameLabel {
    return Intl.message(
      'Nama teman baru',
      name: 'newFriendNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Info pembayaran disimpan`
  String get paymentInfoSavedSnackbar {
    return Intl.message(
      'Info pembayaran disimpan',
      name: 'paymentInfoSavedSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `Info Pembayaran`
  String get paymentInfoTitle {
    return Intl.message(
      'Info Pembayaran',
      name: 'paymentInfoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Info ini disertakan dalam permintaan pembayaran yang kamu bagikan ke teman, agar mereka tahu ke mana harus mengirim uang.`
  String get paymentInfoDescription {
    return Intl.message(
      'Info ini disertakan dalam permintaan pembayaran yang kamu bagikan ke teman, agar mereka tahu ke mana harus mengirim uang.',
      name: 'paymentInfoDescription',
      desc: '',
      args: [],
    );
  }

  /// `Nama bank / e-wallet`
  String get bankNameFieldLabel {
    return Intl.message(
      'Nama bank / e-wallet',
      name: 'bankNameFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Nomor rekening`
  String get accountNumberFieldLabel {
    return Intl.message(
      'Nomor rekening',
      name: 'accountNumberFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Nama pemilik rekening`
  String get accountHolderNameFieldLabel {
    return Intl.message(
      'Nama pemilik rekening',
      name: 'accountHolderNameFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Simpan`
  String get saveButton {
    return Intl.message(
      'Simpan',
      name: 'saveButton',
      desc: '',
      args: [],
    );
  }

  /// `Gagal menyimpan struk`
  String get failedToSaveReceipt {
    return Intl.message(
      'Gagal menyimpan struk',
      name: 'failedToSaveReceipt',
      desc: '',
      args: [],
    );
  }

  /// `Gagal memuat riwayat struk`
  String get failedToLoadReceiptHistory {
    return Intl.message(
      'Gagal memuat riwayat struk',
      name: 'failedToLoadReceiptHistory',
      desc: '',
      args: [],
    );
  }

  /// `Gagal menghapus struk`
  String get failedToDeleteReceipt {
    return Intl.message(
      'Gagal menghapus struk',
      name: 'failedToDeleteReceipt',
      desc: '',
      args: [],
    );
  }

  /// `Gagal mengenali teks dari gambar`
  String get failedToRecognizeText {
    return Intl.message(
      'Gagal mengenali teks dari gambar',
      name: 'failedToRecognizeText',
      desc: '',
      args: [],
    );
  }

  /// `Gagal memuat daftar teman`
  String get failedToLoadFriends {
    return Intl.message(
      'Gagal memuat daftar teman',
      name: 'failedToLoadFriends',
      desc: '',
      args: [],
    );
  }

  /// `Gagal menyimpan teman`
  String get failedToSaveFriend {
    return Intl.message(
      'Gagal menyimpan teman',
      name: 'failedToSaveFriend',
      desc: '',
      args: [],
    );
  }

  /// `ReaderFile`
  String get readerFileTitle {
    return Intl.message(
      'ReaderFile',
      name: 'readerFileTitle',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'id'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
