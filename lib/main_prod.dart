import 'package:flutter/material.dart';
import 'package:post_it/injection_container.dart';
import 'package:post_it/router/app_router.dart';
import 'package:post_it/shared/constants/app_environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.setEnvironment(ProdEnvironment());
  await initDependencies();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'post_it',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
