import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class RecargaSaldoPage extends StatefulWidget {
  const RecargaSaldoPage({super.key});

  @override
  _RecargaSaldoPageState createState() => _RecargaSaldoPageState();
}

class _RecargaSaldoPageState extends State<RecargaSaldoPage> {
  double saldo = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recarga de Saldo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            CupertinoTextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  saldo = double.parse(value);
                });
              },
              padding: const EdgeInsets.all(12.0),
              placeholder: 'Cantidad a recargar',
              prefix: const Icon(Icons.euro_symbol_rounded),
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              child: const Text('Recargar'),
              onPressed: () {
                // Implementar la lógica para recargar el saldo del usuario.
                print('Recargado: $saldo');
              },
            ),
          ],
        ),
      ),
    );
  }
}
