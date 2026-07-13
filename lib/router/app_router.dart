import 'package:go_router/go_router.dart';
import 'package:post_it/features/reader_file/presentation/pages/reader_file_page.dart';
import 'package:post_it/features/receipt_scanner/domain/entities/receipt.dart';
import 'package:post_it/features/receipt_scanner/presentation/pages/payment_summary_page.dart';
import 'package:post_it/features/receipt_scanner/presentation/pages/payments_overview_page.dart';
import 'package:post_it/features/receipt_scanner/presentation/pages/receipt_history_page.dart';
import 'package:post_it/features/receipt_scanner/presentation/pages/receipt_scanner_page.dart';
import 'package:post_it/shared/pages/home_page.dart';
import 'package:post_it/shared/pages/payment_info_page.dart';

import 'route_observer.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  observers: [routeObserver],
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/reader_file/:id',
      builder: (context, state) => ReaderFilePage(
        id: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/receipt-scanner',
      builder: (context, state) {
        final extra = state.extra;
        return extra is Receipt
            ? ReceiptScannerPage(existingReceipt: extra)
            : ReceiptScannerPage(imagePath: extra as String?);
      },
    ),
    GoRoute(
      path: '/receipt-history',
      builder: (context, state) => const ReceiptHistoryPage(),
    ),
    GoRoute(
      path: '/payment-info',
      builder: (context, state) => const PaymentInfoPage(),
    ),
    GoRoute(
      path: '/payment-summary',
      builder: (context, state) =>
          PaymentSummaryPage(receipt: state.extra! as Receipt),
    ),
    GoRoute(
      path: '/payments',
      builder: (context, state) => const PaymentsOverviewPage(),
    ),
  ],
);
