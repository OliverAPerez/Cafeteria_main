import 'package:flutter/material.dart';

class AccountRecoveryPage extends StatelessWidget {
  const AccountRecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperación de cuenta'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Por favor, ingresa información adicional para recuperar tu cuenta.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                // Controlador para el nombre completo
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Fecha de nacimiento'),
                // Controlador para la fecha de nacimiento
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Lógica para buscar la cuenta y enviar información de recuperación
                },
                child: const Text('Enviar solicitud de recuperación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
