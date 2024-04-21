import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistorialRecargasLogic extends StatefulWidget {
  final User user;

  const HistorialRecargasLogic({super.key, required this.user});

  @override
  _HistorialRecargasLogicState createState() => _HistorialRecargasLogicState();
}

class _HistorialRecargasLogicState extends State<HistorialRecargasLogic> {
  late Future<DocumentSnapshot?> userData;
  late Stream<QuerySnapshot> userOrders;

  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    var user = widget.user; // Aquí es donde inicializas la variable con el usuario que pasas al widget
    userOrders = FirebaseFirestore.instance.collection('Users').doc(user.uid).collection('historialrecargas').snapshots();
    userData = userOrders.first.then((querySnapshot) => querySnapshot.docs.first);

    final userRef = FirebaseFirestore.instance.collection('Users').doc(widget.user.uid);
    userData = userRef.get();
  }

  void _toggleCard() {
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot?>(
      future: userData,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && !snapshot.data!.exists) {
          return const Center(child: Text('No se encontraron datos del usuario'));
        } else {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return GestureDetector(
            onTap: _toggleCard,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _showFront ? _buildFrontCard(data) : _buildBackCard(data),
            ),
          );
        }
      },
    );
  }

  Widget _buildFrontCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: _toggleCard,
      child: Tooltip(
        message: 'Haz clic para ver tus datos',
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                width: double.infinity,
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Perfil ID',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: (data['image'] as String).isEmpty
                            ? const Text(
                                'Aún no tienes imagen',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              )
                            : Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2),
                                  image: DecorationImage(
                                    image: NetworkImage(data['image']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.info, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: _toggleCard,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(pi),
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            width: double.infinity,
            height: 200,
            child: Transform(
              transform: Matrix4.identity()..rotateY(pi),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, size: 20, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          '${data['nombre']}',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                    //icono de email
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.email, size: 20, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          widget.user.email != null ? '${widget.user.email}' : 'Email no disponible',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),

                    //icono de fecha de nacimiento
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.cake_rounded, size: 22, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          data['fecha_nacimiento'] != null ? DateFormat('dd/MM/yyyy').format(data['fecha_nacimiento'].toDate()) : 'Fecha de nacimiento no disponible',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),

                    //icono de saldo
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.euro_outlined, size: 20, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          '€${data['saldo']}',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildOrderItem(BuildContext context, DocumentSnapshot order) {
  // Asegúrate de que los datos del pedido sean un Map<String, dynamic>
  if (order.data() is! Map<String, dynamic>) {
    return const Text('Error: los datos del pedido no son válidos');
  }

  final orderData = order.data() as Map<String, dynamic>;
  double total = 0;
  List<Widget> recargaList = [];

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

    // Si el producto es un marcador de posición, no lo añadas a la lista
    if (productData['placeholder'] == true) {
      continue;
    }

    total += productData['precio'];
    recargaList.add(
      ListTile(
        title: Text(productData['nombre']),
        subtitle: Text('Precio: €${productData['precio']}'),
      ),
    );
  }

  return Card(
    child: ExpansionTile(
      title: Text('Recarga ID: ${order.id}'),
      subtitle: Text('Fecha de la recarga: ${orderData['fecha_recarga'].toDate()}'),
      trailing: Text('Total: $total'),
      children: recargaList,
    ),
  );
}
