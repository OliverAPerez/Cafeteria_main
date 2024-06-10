import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirestoreMenu extends StatefulWidget {
  final String category;

  const FirestoreMenu({super.key, required this.category});

  @override
  _FirestoreMenuState createState() => _FirestoreMenuState();
}

class _FirestoreMenuState extends State<FirestoreMenu> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _cartRef;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _cartRef = _firestore.collection('Carrito').doc(user.uid).collection('Productos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Productos').doc('tipos').collection(widget.category).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay elementos disponibles'));
        }

        final menuItems = snapshot.data!.docs;
        return SizedBox(
          height: 600, // Ajusta este valor según tus necesidades
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 7 / 7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: menuItems.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildMenuItem(menuItems[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(QueryDocumentSnapshot item) {
    final itemData = item.data() as Map<String, dynamic>;
    final name = itemData['nombre'] ?? 'Nombre no disponible';
    final price = (itemData['precio'] as num?)?.toDouble();
    final imageUrl = itemData['image'] as String?;

    return FavoriteIconToggle(
      builder: (isFavorite, toggleFavorite) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color.fromARGB(255, 99, 150, 102),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: imageUrl != null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(imageUrl, fit: BoxFit.cover),
                        ),
                      )
                    : Container(),
              ),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.white,
                                size: 30,
                              ),
                              onPressed: toggleFavorite,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(price != null ? '€${price.toStringAsFixed(2)}' : '', style: const TextStyle(fontSize: 20)),
                            Card(
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Color.fromARGB(255, 99, 150, 102),
                                  size: 30,
                                ),
                                onPressed: () {
                                  _addToCart(name, price, imageUrl);
                                  Fluttertoast.showToast(
                                    msg: "Producto agregado al carrito",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addToCart(String name, double? price, String? imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _cartRef.add({
          'nombre': name,
          'precio': price,
          'imagen': imageUrl,
          'timestamp': Timestamp.now(),
        });
        print('Producto agregado al carrito con éxito.');
      } catch (e) {
        print('Error al agregar producto al carrito: $e');
      }
    }
  }
}

class FavoriteIconToggle extends StatefulWidget {
  final Widget Function(bool isFavorite, VoidCallback toggleFavorite) builder;

  const FavoriteIconToggle({super.key, required this.builder});

  @override
  _FavoriteIconToggleState createState() => _FavoriteIconToggleState();
}

class _FavoriteIconToggleState extends State<FavoriteIconToggle> {
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_isFavorite, _toggleFavorite);
  }
}
