import 'package:go_router/go_router.dart';
import 'package:post_it/features/reader_file/presentation/pages/reader_file_page.dart';
import 'package:post_it/features/receipt_scanner/presentation/pages/receipt_history_page.dart';
import 'package:post_it/features/receipt_scanner/presentation/pages/receipt_scanner_page.dart';
import 'package:post_it/shared/pages/home_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
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
      builder: (context, state) => const ReceiptScannerPage(),
    ),
    GoRoute(
      path: '/receipt-history',
      builder: (context, state) => const ReceiptHistoryPage(),
    ),
  ],
);
