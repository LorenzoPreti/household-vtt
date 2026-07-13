import 'package:flutter/material.dart';
import 'package:household_vtt/Screens/Loginpage.dart';
import 'package:household_vtt/Screens/Schedapage.dart';
import 'Screens/Errorpage.dart';
import 'Screens/Homepage.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // ignore: unused_local_variable
    final args = settings.arguments; // Pronto per utilizzi futuri

    switch (settings.name) {
      case "/login":
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const Loginpage(),
        );
      case "/home":
        return MaterialPageRoute(
          settings: settings, // Associa i dati della rotta
          builder: (context) => const Homepage(),
        );
      case '/scheda':
      // Estraiamo gli argomenti passati durante il pushNamed
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => Schedapage(
            docId: args['docId']
          ),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ErrorPage(),
        );
    }
  }
}