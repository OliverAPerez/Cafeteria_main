import 'package:flutter/material.dart';
import 'package:coffee_shop/firestorelogic/resumenpedido/resumen_pedido_logic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ResumenPedidoPage extends StatelessWidget {
  final ResumenPedidoLogic _resumenPedidoLogic = ResumenPedidoLogic();
  final String userId;
  final String orderId;

  ResumenPedidoPage({required this.userId, required this.orderId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del Pedido'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _resumenPedidoLogic.getOrderDetails(userId, orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No se encontraron detalles del pedido.'));
          }

          Map<String, dynamic>? orderDetails = snapshot.data;
          final date = orderDetails?['fecha_pedido'] is Timestamp ? (orderDetails?['fecha_pedido'] as Timestamp).toDate() : null;
          final formattedDate = date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : 'Fecha no disponible';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID del Pedido: ${orderDetails?['id']}'),
                  const SizedBox(height: 10),
                  Text('Fecha del Pedido: $formattedDate'),
                  const SizedBox(height: 10),
                  Text('Precio Total: ${orderDetails?['precio_total']}'),
                  const SizedBox(height: 20),
                  const Text(
                    'Productos Comprados:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Mostrar la lista de productos comprados
                  _buildProductList(orderDetails?['productos']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList(List<dynamic>? products) {
    if (products == null || products.isEmpty) {
      return const Text('No hay productos en este pedido.');
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductItem(products[index]);
        },
      );
    }
  }

  Widget _buildProductItem(Map<String, dynamic>? product) {
    if (product == null) {
      return const SizedBox.shrink();
    } else {
      return ListTile(
        title: Text(product['nombre'] ?? 'Nombre no disponible'),
        subtitle: Text('Precio: ${product['precio'] ?? 'No disponible'}'),
      );
    }
  }
}
