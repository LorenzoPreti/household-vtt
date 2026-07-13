import 'package:firebase_auth/firebase_auth.dart';
import 'package:household_vtt/RouteGenerator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa la libreria
import 'package:household_vtt/Screens/Loginpage.dart';
import 'Screens/Homepage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Household VTT',
      debugShowCheckedModeBanner: false,
      // Nel tuo main.dart
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        // EB Garamond con peso medio per evitare l'effetto "sottile"
        textTheme: GoogleFonts.ebGaramondTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const Homepage();
          }
          return const Loginpage();
        },
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}