import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'views/login_view.dart';
import 'views/home_view.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter POC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginView(),
      routes: {
        '/home': (context) => const HomeView(),
        // No need to add EndpointView to routes since it's pushed directly
      },
    );
  }
}
