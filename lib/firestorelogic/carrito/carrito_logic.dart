import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CarritoLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamController<double> totalController = StreamController<double>();

  Stream<List<QueryDocumentSnapshot>> getCartItems() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]); // Devuelve un stream vacío si no hay usuario autenticado
    }

    final cartRef = _firestore.collection('Carrito').doc(user.uid).collection('Productos');

    // Utiliza el método snapshots() para obtener un Stream de los cambios en la colección del carrito
    return cartRef.snapshots().map((snapshot) => snapshot.docs.toList());
  }

  Future<void> showOrderTicket(BuildContext context, String orderId, List<QueryDocumentSnapshot> cartItems) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe tocar el botón para cerrar el diálogo.
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Cafetería Instituto EPM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tiquet de Pedido',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Hora: ${DateFormat('HH:mm').format(DateTime.now())}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Número de Pedido: $orderId',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      const Divider(thickness: 1),
                      const SizedBox(height: 16),
                      const Text(
                        'Elementos del Pedido:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...cartItems.map((item) {
                        final itemData = item.data() as Map<String, dynamic>;
                        final name = itemData['nombre'] ?? 'Nombre no disponible';
                        final price = (itemData['precio'] as num?)?.toDouble();
                        final quantity = itemData['cantidad'] as int? ?? 1; // Asume 1 si la cantidad no está disponible
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$name x $quantity', // Muestra la cantidad junto al nombre
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '€${(price! * quantity).toStringAsFixed(2)}', // Multiplica el precio por la cantidad
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
                      const Divider(thickness: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '€${calculateTotal(cartItems).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Gracias por su pedido!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  Future<int> getCartItemCount() async {
    final user = _auth.currentUser;
    if (user == null) {
      return 0; // Devuelve 0 si no hay usuario autenticado
    }

    final cartRef = _firestore.collection('Carrito').doc(user.uid).collection('Productos');
    final cartSnapshot = await cartRef.get();
    return cartSnapshot.size;
  }

  double calculateTotal(List<QueryDocumentSnapshot> cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      final data = item.data();
      if (data != null && (data as Map<String, dynamic>).containsKey('precio')) {
        double itemPrice = (data)['precio'].toDouble();
        int quantity = (data)['quantity'] ?? 1; // Asume una cantidad por defecto de 1 si no se especifica
        total += itemPrice * quantity;
      }
    }
    return total;
  }

  Future<void> updateTotal() async {
    Stream<List<QueryDocumentSnapshot>> stream = getCartItems();
    List<QueryDocumentSnapshot> cartItems = await stream.first;
    double total = calculateTotal(cartItems);
    totalController.add(total);
  }

  Widget buildCartItem(BuildContext context, QueryDocumentSnapshot item, {VoidCallback? onQuantityChanged}) {
    final itemData = item.data() as Map<String, dynamic>;
    final name = itemData['nombre'] ?? 'Nombre no disponible';
    final price = (itemData['precio'] as num?)?.toDouble();
    final imageUrl = itemData['image'] as String?;
    int quantity = itemData['quantity'] ?? 1; // Asume una cantidad por defecto de 1

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover) : Container(width: 60, height: 60, color: Colors.grey[300], child: Icon(Icons.image, size: 40, color: Colors.grey[600])),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (price != null) Text('€${price.toStringAsFixed(2)}', style: TextStyle(color: Colors.green.shade700, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.redAccent),
                      onPressed: quantity > 1
                          ? () {
                              item.reference.update({'quantity': quantity - 1}).then((_) {
                                quantity -= 1;
                                onQuantityChanged!();
                                // Aquí se llama a la función para actualizar el total
                                updateTotal();
                                print('Cantidad actualizada a $quantity');
                                print('Total actualizado a ${calculateTotal([item])}');
                              });
                            }
                          : null,
                    ),
                    Text('$quantity', style: const TextStyle(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      onPressed: () {
                        item.reference.update({'quantity': quantity + 1}).then((_) {
                          quantity += 1;
                          onQuantityChanged!();
                          // Aquí se llama a la función para actualizar el total
                          updateTotal();
                          print('Cantidad actualizada a $quantity');
                          print('Total actualizado a ${calculateTotal([item])}');
                        });
                      },
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () async {
                    await item.reference.delete();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto eliminado del carrito')));
                  },
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  label: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createOrder(BuildContext context, List<QueryDocumentSnapshot> cartItems) async {
    try {
      print('Inicio de createOrder');
      User? user = FirebaseAuth.instance.currentUser;
      print('Usuario obtenido: $user');

      if (user != null && cartItems.isNotEmpty) {
        double total = calculateTotal(cartItems);
        print('Total calculado: $total');
        // Verificar si el usuario tiene suficiente saldo para realizar el pedido
        bool hasEnoughBalance = await _checkBalance(total);
        print('Verificación de saldo: $hasEnoughBalance');

        if (hasEnoughBalance) {
          // Mostrar la animación de pago (aquí debes implementar tu propia lógica de animación)
          await _showPaymentAnimation(context);
          print('Animación de pago mostrada');

          // Crear el pedido
          String orderId = await _createOrderDocument(user, cartItems);
          print('Pedido creado con ID: $orderId');
          await showOrderTicket(context, orderId, cartItems);
          print('Ticket de pedido mostrado');
          await _deductFromBalance(total);
          print('Saldo deducido');

          // Vaciar el carrito inmediatamente
          await emptyCart();
          print('Carrito vaciado');

          // Espera un poco antes de navegar a la página de resumen del pedido
          await Future.delayed(const Duration(seconds: 1));
          print('Retraso completado');

          // Navegar a la página de resumen del pedido
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saldo insuficiente, por favor recarga.')));
          print('Saldo insuficiente');
        }
      }
    } catch (e) {
      print('Error en createOrder: $e');
    }
  }

  Future<bool> _checkBalance(double total) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      double saldo = ((userDoc.data() as Map<String, dynamic>?)?['saldo'] as num?)?.toDouble() ?? 0.0;
      print('Saldo del usuario: $saldo');
      print('Total del carrito: $total');
      return saldo >= total;
    }
    return false;
  }

  Future<void> _deductFromBalance(double total) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userRef);
        double saldo = ((userDoc.data() as Map<String, dynamic>?)?['saldo'] as num?)?.toDouble() ?? 0.0;
        double newBalance = saldo - total;
        transaction.update(userRef, {'saldo': newBalance});
      });
    }
  }

  Future<void> _showPaymentAnimation(BuildContext context) async {
    // Muestra un diálogo de progreso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              Text("Procesando pago..."),
            ],
          ),
        );
      },
    );

    // Cierra el diálogo de progreso
    Navigator.pop(context);
  }

  Future<String> _createOrderDocument(User user, List<QueryDocumentSnapshot> cartItems) async {
    String userId = user.uid;

    // Recuperar la información del usuario de Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>? ?? {};

    // Obtén el token de FCM
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    Map<String, dynamic> orderData = {
      'fecha_pedido': Timestamp.now(),
      'productos': cartItems.map((item) => item.data()).toList(), // Lista de productos en el pedido
      'precio total': calculateTotal(cartItems),
      'nombre': userData['nombre'], // Añadir el nombre del usuario
      'id': userId, // Añadir el ID del usuario
      'fcmToken': fcmToken, // Añadir el token de FCM
    };

    // El resto de tu código...

    // Crear un nuevo documento de pedido en la subcolección 'historialpedidos' del usuario
    DocumentReference orderDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).collection('historialpedidos').add(orderData);

    // Crear un nuevo documento de pedido en la subcolección 'PorProcesar' de 'pedidosonline' en la colección 'Pedidos'
    await FirebaseFirestore.instance.collection('Pedidos').doc('pedidosonline').collection('PorProcesar').add(orderData);

    // Devolver el ID del pedido
    return orderDoc.id;
  }

  Future<void> emptyCartAfterDelay() async {
    const cartEmptyTime = Duration(minutes: 3);
    await Future.delayed(cartEmptyTime);

    final user = _auth.currentUser;
    if (user != null) {
      final cartRef = _firestore.collection('Carrito').doc(user.uid).collection('Productos');
      final cartSnapshot = await cartRef.orderBy('timestamp', descending: false).limit(1).get();

      if (cartSnapshot.docs.isNotEmpty) {
        await cartSnapshot.docs.first.reference.delete();
      }

      // Comprueba si el carrito todavía tiene productos antes de vaciarlo
      final cartSnapshotAfterDelete = await cartRef.get();
      if (cartSnapshotAfterDelete.docs.isNotEmpty) {
        await emptyCart();
      }
    }
  }

  Future<void> emptyCart() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Obtener la referencia a la subcolección 'Productos'
      final cartRef = _firestore.collection('Carrito').doc(user.uid).collection('Productos');

      // Obtener todos los documentos de la subcolección 'Productos'
      final cartSnapshot = await cartRef.get();

      // Eliminar cada documento de la subcolección 'Productos'
      for (final doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      // Ahora puedes eliminar el documento del carrito del usuario
      await _firestore.collection('Carrito').doc(user.uid).delete();
    }
  }
}
