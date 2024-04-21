import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:coffee_shop/firestorelogic/carrito/carrito_logic.dart';

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  _CarritoPageState createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  final CarritoLogic _carritoLogic = CarritoLogic(); // Instancia de CarritoLogic

  @override
  void initState() {
    super.initState();
    _carritoLogic.emptyCartAfterDelay(); // Inicia el temporizador para vaciar el carrito
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: Color.fromRGBO(5, 116, 38, 1),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _carritoLogic.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('El carrito está vacío'));
          }

          final cartItems = snapshot.data!;
          double total = _carritoLogic.calculateTotal(cartItems);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) => _carritoLogic.buildCartItem(context, cartItems[index]),
                ),
              ),
              Container(
                color: Color.fromRGBO(5, 116, 38, 1),
                child: ListTile(
                  title: Text('Total', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: const Color.fromARGB(255, 255, 255, 255))),
                  trailing: Text('€${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 255, 255))),
                  subtitle: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Mostrar CircularProgressIndicator mientras se procesa el pago
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                              // Mostrar un círculo de progreso en el centro de la pantalla
                              child: CircularProgressIndicator(),
                            );
                          },
                        );

                        try {
                          // Procesar el pago
                          await _carritoLogic.createOrder(context, cartItems);
                        } catch (error) {
                          // Manejar errores aquí, como mostrar un mensaje de error al usuario
                          print('Error al procesar el pago: $error');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al procesar el pago: $error')));
                        } finally {
                          // Cerrar el diálogo después de un breve retraso para asegurarse de que se cierre el diálogo
                          if (Navigator.canPop(context)) {
                            Navigator.of(context, rootNavigator: true).pop(); // Cierra el diálogo
                          }
                        }
                      },
                      child: const Text('Pagar', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Color.fromRGBO(51, 51, 51, 1), // foreground
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
