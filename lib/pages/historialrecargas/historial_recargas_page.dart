import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:coffee_shop/firestorelogic/historialrecargas/historial_recargas_logic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistorialRecargasPage extends StatefulWidget {
  const HistorialRecargasPage({super.key});

  @override
  State<HistorialRecargasPage> createState() => _HistorialRecargasPageState();
}

class _HistorialRecargasPageState extends State<HistorialRecargasPage> {
  late HistorialRecargasLogic _historialRecargasLogic;

  @override
  void initState() {
    super.initState();
    // _historialRecargasLogic = HistorialRecargasLogic(user: widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Recargas'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 230,
            child: _historialRecargasLogic,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // stream: FirebaseFirestore.instance.collection('Users').doc(widget.user!.uid).collection('historialrecargas').snapshots(),
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
              stream: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderItem(BuildContext context, DocumentSnapshot order) {
    // Asegúrate de que los datos del pedido sean un Map<String, dynamic>
    if (order.data() is! Map<String, dynamic>) {
      return const Text('Error: los datos de la recarga no son válidos');
    }

    final orderData = order.data() as Map<String, dynamic>;
    double total = 0;
    List<Widget> productList = [];

    // Asegúrate de que 'productos' sea una lista
    if (orderData['recargas'] is! List) {
      return const Text('Error: los productos del pedido no son válidos');
    }

    for (var product in orderData['recargas']) {
      // Asegúrate de que cada producto sea un Map<String, dynamic>
      if (product is! Map<String, dynamic>) {
        continue;
      }

      final productData = product;
      total += productData['precio'];
      productList.add(
        ListTile(
          title: Text(productData['nombre']),
          subtitle: Text('Precio: ${productData['precio']}'),
        ),
      );
    }

    return Card(
      child: ExpansionTile(
        title: Text('Recarga ID: ${order.id}'),
        subtitle: Text('Fecha de la recarga: ${DateFormat('dd-MM-yyyy').format(orderData['fecha_pedido'].toDate())}'),
        trailing: Text('Total: $total'),
        children: productList,
      ),
    );
  }
}
