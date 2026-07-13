// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(name) => "a.n. ${name}";

  static String m1(amount) => "Adjustment: ${amount}";

  static String m2(amount) => "Discount: -${amount}";

  static String m3(merchant) => "for ${merchant}";

  static String m4(name) => "${name}\'s items";

  static String m5(name) => "Hi ${name},";

  static String m6(count) => "Items (${count})";

  static String m7(max) =>
      "You have more than ${max} items — ask your friend for the full item details.";

  static String m8(amount) => "Owes ${amount}";

  static String m9(name) => "Payment request for ${name}";

  static String m10(date, count) =>
      "${date} · ${Intl.plural(count, one: '1 item', other: '${count} items')}";

  static String m11(count) =>
      "${Intl.plural(count, one: '1 receipt', other: '${count} receipts')}";

  static String m12(count) =>
      "${Intl.plural(count, one: '1 receipt scanned', other: '${count} receipts scanned')}";

  static String m13(count) =>
      "${Intl.plural(count, one: '1 receipt selected', other: '${count} receipts selected')}";

  static String m14(remaining, total) => "${remaining} of ${total} unassigned";

  static String m15(amount) => "Service Charge: ${amount}";

  static String m16(count) => "Split evenly among ${count} people";

  static String m17(amount) => "Tax: ${amount}";

  static String m18(amount) => "Total ${amount}";

  static String m19(amount) => "${amount} not assigned to anyone";

  static String m20(merchant, amount) =>
      "Your share of the bill from ${merchant} is ${amount}.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accountHolderLabel":
            MessageLookupByLibrary.simpleMessage("Account Holder"),
        "accountHolderNameFieldLabel":
            MessageLookupByLibrary.simpleMessage("Account holder name"),
        "accountHolderPrefix": m0,
        "accountNoLabel": MessageLookupByLibrary.simpleMessage("Account No."),
        "accountNumberFieldLabel":
            MessageLookupByLibrary.simpleMessage("Account number"),
        "addItemButton": MessageLookupByLibrary.simpleMessage("Add item"),
        "adjustmentLabel": MessageLookupByLibrary.simpleMessage("Adjustment"),
        "adjustmentLine": m1,
        "allSettled": MessageLookupByLibrary.simpleMessage("All settled"),
        "appName": MessageLookupByLibrary.simpleMessage("post_it"),
        "assignChipLabel": MessageLookupByLibrary.simpleMessage("Assign"),
        "assignToTitle": MessageLookupByLibrary.simpleMessage("Assign to"),
        "bankLabel": MessageLookupByLibrary.simpleMessage("Bank"),
        "bankNameFieldLabel":
            MessageLookupByLibrary.simpleMessage("Bank / e-wallet name"),
        "billedToLabel": MessageLookupByLibrary.simpleMessage("Billed to"),
        "breakdownLabel": MessageLookupByLibrary.simpleMessage("Breakdown:"),
        "chooseFromGallery":
            MessageLookupByLibrary.simpleMessage("Choose from Gallery"),
        "choosePhotoSource":
            MessageLookupByLibrary.simpleMessage("Choose Photo Source"),
        "discountLabel": MessageLookupByLibrary.simpleMessage("Discount"),
        "discountLine": m2,
        "doneButton": MessageLookupByLibrary.simpleMessage("Done"),
        "editReceiptTitle":
            MessageLookupByLibrary.simpleMessage("Edit Receipt"),
        "editReceiptTooltip":
            MessageLookupByLibrary.simpleMessage("Edit receipt"),
        "failedToDeleteReceipt":
            MessageLookupByLibrary.simpleMessage("Failed to delete receipt"),
        "failedToLoadFriends":
            MessageLookupByLibrary.simpleMessage("Failed to load friends"),
        "failedToLoadReceiptHistory": MessageLookupByLibrary.simpleMessage(
            "Failed to load receipt history"),
        "failedToRecognizeText": MessageLookupByLibrary.simpleMessage(
            "Failed to recognize text from image"),
        "failedToSaveFriend":
            MessageLookupByLibrary.simpleMessage("Failed to save friend"),
        "failedToSaveReceipt":
            MessageLookupByLibrary.simpleMessage("Failed to save receipt"),
        "forMerchant": m3,
        "friendItemsTitle": m4,
        "greetingHi": m5,
        "historyAction": MessageLookupByLibrary.simpleMessage("History"),
        "homeEmptyPaymentsHint": MessageLookupByLibrary.simpleMessage(
            "Assign items to friends on a receipt to track who owes what."),
        "homeEmptyReceiptsHint": MessageLookupByLibrary.simpleMessage(
            "No receipts yet. Scan one to get started."),
        "homeRecentReceipts":
            MessageLookupByLibrary.simpleMessage("Recent Receipts"),
        "homeTagline": MessageLookupByLibrary.simpleMessage(
            "Scan receipts, split the bill with friends."),
        "itemFieldLabel": MessageLookupByLibrary.simpleMessage("Item"),
        "itemsCountLabel": m6,
        "itemsLabel": MessageLookupByLibrary.simpleMessage("Items"),
        "itemsSubtotalLabel":
            MessageLookupByLibrary.simpleMessage("Items subtotal"),
        "merchantLabel": MessageLookupByLibrary.simpleMessage("Merchant"),
        "moreItemsHint": m7,
        "newFriendNameLabel":
            MessageLookupByLibrary.simpleMessage("New friend name"),
        "noItemsAssigned":
            MessageLookupByLibrary.simpleMessage("No items assigned."),
        "noItemsAssignedHint": MessageLookupByLibrary.simpleMessage(
            "No items were assigned to a friend, so there\'s no one to bill. Go back and assign items to split the cost."),
        "noReceiptsScannedYet":
            MessageLookupByLibrary.simpleMessage("No receipts scanned yet"),
        "noSplitPaymentsHint": MessageLookupByLibrary.simpleMessage(
            "No split payments yet. Assign items to friends when scanning a receipt to track who owes what."),
        "owesAmount": m8,
        "paidLabel": MessageLookupByLibrary.simpleMessage("Paid"),
        "paymentInfoDescription": MessageLookupByLibrary.simpleMessage(
            "This is included in payment requests you share with friends, so they know where to send money."),
        "paymentInfoSavedSnackbar":
            MessageLookupByLibrary.simpleMessage("Payment info saved"),
        "paymentInfoTitle":
            MessageLookupByLibrary.simpleMessage("Payment Info"),
        "paymentInfoTooltip":
            MessageLookupByLibrary.simpleMessage("Payment Info"),
        "paymentRequestForFriend": m9,
        "paymentsAction": MessageLookupByLibrary.simpleMessage("Payments"),
        "paymentsTitle": MessageLookupByLibrary.simpleMessage("Payments"),
        "pleaseTransferTo":
            MessageLookupByLibrary.simpleMessage("Please transfer to:"),
        "priceFieldLabel": MessageLookupByLibrary.simpleMessage("Price"),
        "qtyFieldLabel": MessageLookupByLibrary.simpleMessage("Qty"),
        "readerFileTitle": MessageLookupByLibrary.simpleMessage("ReaderFile"),
        "receiptFallbackName": MessageLookupByLibrary.simpleMessage("Receipt"),
        "receiptHistoryTitle":
            MessageLookupByLibrary.simpleMessage("Receipt History"),
        "receiptItemsSubtitle": m10,
        "receiptsCountLabel": m11,
        "receiptsScannedCount": m12,
        "receiptsSelectedCount": m13,
        "remainingOfQuantityHint": m14,
        "saveButton": MessageLookupByLibrary.simpleMessage("Save"),
        "saveReceiptButton":
            MessageLookupByLibrary.simpleMessage("Save Receipt"),
        "scanAction": MessageLookupByLibrary.simpleMessage("Scan"),
        "scanReceiptTitle":
            MessageLookupByLibrary.simpleMessage("Scan Receipt"),
        "seeAll": MessageLookupByLibrary.simpleMessage("See all"),
        "selectReceiptsToMergeHint": MessageLookupByLibrary.simpleMessage(
            "Select 2+ receipts to merge into one share"),
        "serviceChargeLabel":
            MessageLookupByLibrary.simpleMessage("Service Charge"),
        "serviceChargeLine": m15,
        "shareAsImage": MessageLookupByLibrary.simpleMessage("Share as Image"),
        "shareAsText": MessageLookupByLibrary.simpleMessage("Share as Text"),
        "shareMergedButton":
            MessageLookupByLibrary.simpleMessage("Share Merged"),
        "sharePaymentRequestTitle":
            MessageLookupByLibrary.simpleMessage("Share Payment Request"),
        "sharePaymentRequestTooltip":
            MessageLookupByLibrary.simpleMessage("Share payment request"),
        "splitBillPaymentLabel":
            MessageLookupByLibrary.simpleMessage("SPLIT BILL PAYMENT"),
        "splitByFriend":
            MessageLookupByLibrary.simpleMessage("Split by friend"),
        "splitEvenlyAmongHint": m16,
        "takePhoto": MessageLookupByLibrary.simpleMessage("Take Photo"),
        "taxLabel": MessageLookupByLibrary.simpleMessage("Tax"),
        "taxLine": m17,
        "taxWithPpnLabel": MessageLookupByLibrary.simpleMessage("Tax (PPN)"),
        "thanksClosing": MessageLookupByLibrary.simpleMessage("Thanks!"),
        "theReceiptFallbackName":
            MessageLookupByLibrary.simpleMessage("the receipt"),
        "totalLabel": MessageLookupByLibrary.simpleMessage("Total"),
        "totalSpendingLabel":
            MessageLookupByLibrary.simpleMessage("Total Spending"),
        "totalWithAmount": m18,
        "transferFooterNote": MessageLookupByLibrary.simpleMessage(
            "Please transfer the amount above.\nShared via PuteIt"),
        "unassignedAmountHint": m19,
        "unpaidLabel": MessageLookupByLibrary.simpleMessage("Unpaid"),
        "viewItemsTooltip": MessageLookupByLibrary.simpleMessage("View items"),
        "whoOwesWhatTitle":
            MessageLookupByLibrary.simpleMessage("Who Owes What"),
        "yourShareMessage": m20
      };
}
