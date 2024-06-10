import 'package:flutter/material.dart';

class QuantitySelectorDialog extends StatelessWidget {
  const QuantitySelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    int selectedQuantity = 1;

    return AlertDialog(
      title: const Text('Selecciona la cantidad'),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Cantidad: $selectedQuantity'),
              Slider(
                min: 1,
                max: 10,
                divisions: 9,
                value: selectedQuantity.toDouble(),
                label: selectedQuantity.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    selectedQuantity = value.round();
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Aceptar'),
          onPressed: () {
            Navigator.of(context).pop(selectedQuantity);
          },
        ),
      ],
    );
  }
}
