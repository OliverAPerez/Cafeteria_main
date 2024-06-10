import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coffee_shop/firestorelogic/historialpedidos/historial_pedidos_logic.dart';
import 'package:intl/intl.dart';

class HistorialPedidosPage extends StatefulWidget {
  final User user;

  const HistorialPedidosPage({super.key, required this.user});

  @override
  _HistorialPedidosPageState createState() => _HistorialPedidosPageState();
}

class _HistorialPedidosPageState extends State<HistorialPedidosPage> {
  late HistorialPedidosLogic _historialPedidosLogic;

  @override
  void initState() {
    super.initState();
    _historialPedidosLogic = HistorialPedidosLogic(user: widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pedidos'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(widget.user.uid)
                  .collection('historialpedidos')
                  .orderBy('fecha_pedido', descending: true) // Ordena los documentos por 'fecha_pedido' de más reciente a más antiguo
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    return buildOrderItem(context, document);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderItem(BuildContext context, DocumentSnapshot order) {
    if (order.data() is! Map<String, dynamic>) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text(
          'Error: los datos del pedido no son válidos',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final orderData = order.data() as Map<String, dynamic>;
    double total = 0;
    List<Widget> productList = [];

    if (orderData['productos'] is! List) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text(
          'Error: los productos del pedido no son válidos',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    for (var product in orderData['productos']) {
      if (product is! Map<String, dynamic>) {
        continue;
      }

      final productData = product;
      total += productData['precio'];
      productList.add(
        ListTile(
          title: Text(
            productData['nombre'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Precio: €${productData['precio']}',
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                ),
                child: ListTile(
                  title: Text(
                    'Pedido ID: ${order.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    'Fecha del pedido: ${DateFormat('dd-MM-yyyy').format(orderData['fecha_pedido'].toDate())}',
                    style: TextStyle(
                      color: Colors.grey[200],
                    ),
                  ),
                  trailing: Text(
                    'Total: €$total',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Divider(
                height: 0,
                thickness: 1,
                color: Colors.grey[300],
              ),
              Container(
                color: Colors.white,
                child: Column(children: productList),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
