import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:post_it/generated/l10n.dart';
import 'package:post_it/injection_container.dart';
import 'package:post_it/router/app_router.dart';
import 'package:post_it/shared/constants/app_environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.setEnvironment(DevEnvironment());
  await initDependencies();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PuteIt Dev',
      debugShowCheckedModeBanner: true,
      routerConfig: appRouter,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}
