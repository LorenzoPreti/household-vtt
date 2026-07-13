import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String errorMessage;

  const ErrorPage({
    super.key,
    this.errorMessage = 'Si è verificato un errore imprevisto.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ops! Qualcosa è andato storto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Qui potrai inserire la logica per riprovare
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}