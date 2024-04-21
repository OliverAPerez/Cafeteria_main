import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@override
class HistorialPage extends StatelessWidget {
  const HistorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pedidos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').doc(userId).collection('historialpedidos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No se encontraron pedidos.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> orderData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildOrderSummary(context, orderData);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, Map<String, dynamic> orderData) {
    final orderId = orderData['orderId'] ?? '';
    final date = (orderData['fecha_pedido'] as Timestamp).toDate();
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
    final total = orderData['precio_total'] ?? 0.0;
    final products = orderData['productos'] as List<dynamic>?;

    return ListTile(
      title: Text('Pedido #$orderId'),
      subtitle: Text('Fecha: $formattedDate - Total: €$total'),
      onTap: () {
        // Aquí puedes manejar el toque en el resumen del pedido, por ejemplo, para abrir una página de detalles del pedido
      },
    );
  }
}
