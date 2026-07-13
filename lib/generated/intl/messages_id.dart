// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a id locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'id';

  static String m0(name) => "a.n. ${name}";

  static String m1(amount) => "Penyesuaian: ${amount}";

  static String m2(amount) => "Diskon: -${amount}";

  static String m3(merchant) => "untuk ${merchant}";

  static String m4(name) => "Item milik ${name}";

  static String m5(name) => "Hai ${name},";

  static String m6(count) => "Item (${count})";

  static String m7(max) =>
      "Kamu memiliki lebih dari ${max} item — tanyakan ke temanmu untuk detail lengkap.";

  static String m8(amount) => "Menunggak ${amount}";

  static String m9(name) => "Permintaan pembayaran untuk ${name}";

  static String m10(date, count) =>
      "${date} · ${Intl.plural(count, one: '1 item', other: '${count} item')}";

  static String m11(count) =>
      "${Intl.plural(count, one: '1 struk', other: '${count} struk')}";

  static String m12(count) =>
      "${Intl.plural(count, one: '1 struk dipindai', other: '${count} struk dipindai')}";

  static String m13(count) =>
      "${Intl.plural(count, one: '1 struk dipilih', other: '${count} struk dipilih')}";

  static String m14(remaining, total) =>
      "${remaining} dari ${total} belum ditetapkan";

  static String m15(amount) => "Biaya Layanan: ${amount}";

  static String m16(count) => "Dibagi rata untuk ${count} orang";

  static String m17(amount) => "Pajak: ${amount}";

  static String m18(amount) => "Total ${amount}";

  static String m19(amount) => "${amount} belum ditetapkan ke siapa pun";

  static String m20(merchant, amount) =>
      "Bagianmu dari tagihan ${merchant} adalah ${amount}.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accountHolderLabel":
            MessageLookupByLibrary.simpleMessage("Nama Pemilik Rekening"),
        "accountHolderNameFieldLabel":
            MessageLookupByLibrary.simpleMessage("Nama pemilik rekening"),
        "accountHolderPrefix": m0,
        "accountNoLabel": MessageLookupByLibrary.simpleMessage("No. Rekening"),
        "accountNumberFieldLabel":
            MessageLookupByLibrary.simpleMessage("Nomor rekening"),
        "addItemButton": MessageLookupByLibrary.simpleMessage("Tambah item"),
        "adjustmentLabel": MessageLookupByLibrary.simpleMessage("Penyesuaian"),
        "adjustmentLine": m1,
        "allSettled": MessageLookupByLibrary.simpleMessage("Sudah lunas"),
        "appName": MessageLookupByLibrary.simpleMessage("post_it"),
        "assignChipLabel": MessageLookupByLibrary.simpleMessage("Tetapkan"),
        "assignToTitle": MessageLookupByLibrary.simpleMessage("Tetapkan ke"),
        "bankLabel": MessageLookupByLibrary.simpleMessage("Bank"),
        "bankNameFieldLabel":
            MessageLookupByLibrary.simpleMessage("Nama bank / e-wallet"),
        "billedToLabel": MessageLookupByLibrary.simpleMessage("Ditagihkan ke"),
        "breakdownLabel": MessageLookupByLibrary.simpleMessage("Rincian:"),
        "chooseFromGallery":
            MessageLookupByLibrary.simpleMessage("Pilih dari Galeri"),
        "choosePhotoSource":
            MessageLookupByLibrary.simpleMessage("Pilih Sumber Foto"),
        "discountLabel": MessageLookupByLibrary.simpleMessage("Diskon"),
        "discountLine": m2,
        "doneButton": MessageLookupByLibrary.simpleMessage("Selesai"),
        "editReceiptTitle": MessageLookupByLibrary.simpleMessage("Edit Struk"),
        "editReceiptTooltip":
            MessageLookupByLibrary.simpleMessage("Edit struk"),
        "failedToDeleteReceipt":
            MessageLookupByLibrary.simpleMessage("Gagal menghapus struk"),
        "failedToLoadFriends":
            MessageLookupByLibrary.simpleMessage("Gagal memuat daftar teman"),
        "failedToLoadReceiptHistory":
            MessageLookupByLibrary.simpleMessage("Gagal memuat riwayat struk"),
        "failedToRecognizeText": MessageLookupByLibrary.simpleMessage(
            "Gagal mengenali teks dari gambar"),
        "failedToSaveFriend":
            MessageLookupByLibrary.simpleMessage("Gagal menyimpan teman"),
        "failedToSaveReceipt":
            MessageLookupByLibrary.simpleMessage("Gagal menyimpan struk"),
        "forMerchant": m3,
        "friendItemsTitle": m4,
        "greetingHi": m5,
        "historyAction": MessageLookupByLibrary.simpleMessage("Riwayat"),
        "homeEmptyPaymentsHint": MessageLookupByLibrary.simpleMessage(
            "Tetapkan item ke teman pada sebuah struk untuk melacak siapa yang berutang."),
        "homeEmptyReceiptsHint": MessageLookupByLibrary.simpleMessage(
            "Belum ada struk. Pindai satu untuk mulai."),
        "homeRecentReceipts":
            MessageLookupByLibrary.simpleMessage("Struk Terbaru"),
        "homeTagline": MessageLookupByLibrary.simpleMessage(
            "Pindai struk, bagi tagihan bersama teman."),
        "itemFieldLabel": MessageLookupByLibrary.simpleMessage("Item"),
        "itemsCountLabel": m6,
        "itemsLabel": MessageLookupByLibrary.simpleMessage("Item"),
        "itemsSubtotalLabel":
            MessageLookupByLibrary.simpleMessage("Subtotal item"),
        "merchantLabel": MessageLookupByLibrary.simpleMessage("Merchant"),
        "moreItemsHint": m7,
        "newFriendNameLabel":
            MessageLookupByLibrary.simpleMessage("Nama teman baru"),
        "noItemsAssigned": MessageLookupByLibrary.simpleMessage(
            "Belum ada item yang ditetapkan."),
        "noItemsAssignedHint": MessageLookupByLibrary.simpleMessage(
            "Belum ada item yang ditetapkan ke teman, jadi tidak ada yang perlu ditagih. Kembali dan tetapkan item untuk membagi biaya."),
        "noReceiptsScannedYet": MessageLookupByLibrary.simpleMessage(
            "Belum ada struk yang dipindai"),
        "noSplitPaymentsHint": MessageLookupByLibrary.simpleMessage(
            "Belum ada pembagian tagihan. Tetapkan item ke teman saat memindai struk untuk melacak siapa yang berutang."),
        "owesAmount": m8,
        "paidLabel": MessageLookupByLibrary.simpleMessage("Lunas"),
        "paymentInfoDescription": MessageLookupByLibrary.simpleMessage(
            "Info ini disertakan dalam permintaan pembayaran yang kamu bagikan ke teman, agar mereka tahu ke mana harus mengirim uang."),
        "paymentInfoSavedSnackbar":
            MessageLookupByLibrary.simpleMessage("Info pembayaran disimpan"),
        "paymentInfoTitle":
            MessageLookupByLibrary.simpleMessage("Info Pembayaran"),
        "paymentInfoTooltip":
            MessageLookupByLibrary.simpleMessage("Info Pembayaran"),
        "paymentRequestForFriend": m9,
        "paymentsAction": MessageLookupByLibrary.simpleMessage("Pembayaran"),
        "paymentsTitle": MessageLookupByLibrary.simpleMessage("Pembayaran"),
        "pleaseTransferTo":
            MessageLookupByLibrary.simpleMessage("Silakan transfer ke:"),
        "priceFieldLabel": MessageLookupByLibrary.simpleMessage("Harga"),
        "qtyFieldLabel": MessageLookupByLibrary.simpleMessage("Jml"),
        "readerFileTitle": MessageLookupByLibrary.simpleMessage("ReaderFile"),
        "receiptFallbackName": MessageLookupByLibrary.simpleMessage("Struk"),
        "receiptHistoryTitle":
            MessageLookupByLibrary.simpleMessage("Riwayat Struk"),
        "receiptItemsSubtitle": m10,
        "receiptsCountLabel": m11,
        "receiptsScannedCount": m12,
        "receiptsSelectedCount": m13,
        "remainingOfQuantityHint": m14,
        "saveButton": MessageLookupByLibrary.simpleMessage("Simpan"),
        "saveReceiptButton":
            MessageLookupByLibrary.simpleMessage("Simpan Struk"),
        "scanAction": MessageLookupByLibrary.simpleMessage("Pindai"),
        "scanReceiptTitle":
            MessageLookupByLibrary.simpleMessage("Pindai Struk"),
        "seeAll": MessageLookupByLibrary.simpleMessage("Lihat semua"),
        "selectReceiptsToMergeHint": MessageLookupByLibrary.simpleMessage(
            "Pilih 2+ struk untuk digabung jadi satu tagihan"),
        "serviceChargeLabel":
            MessageLookupByLibrary.simpleMessage("Biaya Layanan"),
        "serviceChargeLine": m15,
        "shareAsImage":
            MessageLookupByLibrary.simpleMessage("Bagikan sebagai Gambar"),
        "shareAsText":
            MessageLookupByLibrary.simpleMessage("Bagikan sebagai Teks"),
        "shareMergedButton":
            MessageLookupByLibrary.simpleMessage("Bagikan Gabungan"),
        "sharePaymentRequestTitle": MessageLookupByLibrary.simpleMessage(
            "Bagikan Permintaan Pembayaran"),
        "sharePaymentRequestTooltip": MessageLookupByLibrary.simpleMessage(
            "Bagikan permintaan pembayaran"),
        "splitBillPaymentLabel":
            MessageLookupByLibrary.simpleMessage("PEMBAGIAN TAGIHAN"),
        "splitByFriend":
            MessageLookupByLibrary.simpleMessage("Pembagian per teman"),
        "splitEvenlyAmongHint": m16,
        "takePhoto": MessageLookupByLibrary.simpleMessage("Ambil Foto"),
        "taxLabel": MessageLookupByLibrary.simpleMessage("Pajak"),
        "taxLine": m17,
        "taxWithPpnLabel": MessageLookupByLibrary.simpleMessage("Pajak (PPN)"),
        "thanksClosing": MessageLookupByLibrary.simpleMessage("Terima kasih!"),
        "theReceiptFallbackName":
            MessageLookupByLibrary.simpleMessage("struk ini"),
        "totalLabel": MessageLookupByLibrary.simpleMessage("Total"),
        "totalSpendingLabel":
            MessageLookupByLibrary.simpleMessage("Total Pengeluaran"),
        "totalWithAmount": m18,
        "transferFooterNote": MessageLookupByLibrary.simpleMessage(
            "Silakan transfer sejumlah di atas.\nDibagikan via PuteIt"),
        "unassignedAmountHint": m19,
        "unpaidLabel": MessageLookupByLibrary.simpleMessage("Belum Lunas"),
        "viewItemsTooltip": MessageLookupByLibrary.simpleMessage("Lihat item"),
        "whoOwesWhatTitle":
            MessageLookupByLibrary.simpleMessage("Siapa Berutang Apa"),
        "yourShareMessage": m20
      };
}
