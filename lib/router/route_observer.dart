import 'package:flutter/widgets.dart';

/// Lets a screen (e.g. Home) know when the user has navigated back to it,
/// so it can refresh data that may have changed on the page they came from
/// (a new receipt scanned, a payment marked as paid, etc.).
final routeObserver = RouteObserver<PageRoute<void>>();
