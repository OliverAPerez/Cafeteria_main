import 'package:cloud_firestore/cloud_firestore.dart';

class ResumenPedidoLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getOrderDetails(String userId, String orderId) async {
    try {
      DocumentSnapshot orderSnapshot = await _firestore.collection('Users').doc(userId).collection('historialpedidos').doc(orderId).get();
      if (orderSnapshot.exists) {
        print('Detalles del pedido recuperados con éxito: ${orderSnapshot.data()}');
        return orderSnapshot.data() as Map<String, dynamic>;
      } else {
        print('No se encontró el pedido con ID: $orderId');
        return null;
      }
    } catch (e) {
      print('Error al obtener los detalles del pedido: $e');
      return null;
    }
  }
}
