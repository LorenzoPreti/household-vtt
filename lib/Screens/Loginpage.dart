import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui'; // Necessario per l'effetto Blur

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final _passController = TextEditingController();
  String? _selezionatoUsername;
  Map<String, String> _utentiMappa = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _caricaUtenti();
  }

  Future<void> _caricaUtenti() async {
    final query = await FirebaseFirestore.instance.collection('account').get();
    setState(() {
      _utentiMappa = {
        for (var doc in query.docs) doc['username'] as String: doc['email'] as String
      };
      _isLoading = false;
    });
  }

  Future<void> _eseguiLogin() async {
    if (_selezionatoUsername == null || _passController.text.isEmpty) return;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _utentiMappa[_selezionatoUsername]!,
        password: _passController.text,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: ${e.message}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: Stack(
        children: [
          // 1. Immagine di sfondo
          Positioned.fill(
            child: Row(
              children: [
                // Immagine 1: occupa sempre il 50% dello schermo
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: OverflowBox(
                    alignment: Alignment.centerRight,
                    maxWidth: double.infinity,
                    child: Image.asset(
                      'assets/Fuori 1.jpg',
                      fit: BoxFit.cover,
                      height: double.infinity,
                    ),
                  ),
                ),
                // Immagine 2: larghezza fissa = 50% dello schermo, esce a destra se lo schermo è stretto
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: double.infinity,
                    child: Image.asset(
                      'assets/Fuori 2.jpg',
                      fit: BoxFit.cover,
                      height: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 2. Filtro Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            //child: Container(color: Colors.white.withOpacity(0.3)),
          ),
          // 3. Form di Login
          Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), // Fondo semi-trasparente bianco
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Benvenuto nella Casa", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selezionatoUsername,
                    hint: const Text("Seleziona utente"),
                    isExpanded: true, // Fondamentale per occupare tutta la larghezza
                    decoration: const InputDecoration(
                      labelText: "Username",
                      labelStyle: TextStyle(color: Colors.green),
                      border: OutlineInputBorder(), // Aggiunge un bordo carino
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    items: _utentiMappa.keys.map((name) {
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                    onChanged: (val) => setState(() => _selezionatoUsername = val),
                  ),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password", labelStyle: TextStyle(color: Colors.green)),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _eseguiLogin,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text("Accedi"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}