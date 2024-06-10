// import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';

import 'package:coffee_shop/widgets/menu/menu_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  final String? category;
  final User user = FirebaseAuth.instance.currentUser!;
  MenuPage({super.key, this.category});

  @override
  State createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String? selectedCategory;
  final List<String> categories = ['Cafe', 'Bebidas', 'Bocadillos', 'Snacks', 'Bolleria'];
  // final List<String> imgList = [
  //   'assets/images/img1.png',
  //   'assets/images/img2.png',
  //   'assets/images/img3.png',
  // ];
  TextEditingController searchController = TextEditingController();
  late Future<List<String>> categoriesFuture;

  @override
  void initState() {
    super.initState();

    selectedCategory = widget.category ?? categories.first;
  }

  Future<List<DocumentSnapshot>> getItems(String category) async {
    var snapshot = await FirebaseFirestore.instance.collection('Productos').doc('tipos').collection(category).get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteModel>(builder: (context, favoriteModel, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 67, 77, 69),
          title: const Text(
            'Menú Cafetería',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white, // Color de fondo del contenedor de búsqueda
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar productos',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    // Manejar la lógica de búsqueda aquí
                  },
                ),
              ),
              DefaultTabController(
                length: categories.length,
                child: Column(
                  children: <Widget>[
                    //MARK: Sección de pestañas
                    Container(
                      constraints: const BoxConstraints.expand(height: 50),
                      child: TabBar(
                        isScrollable: true,
                        tabs: categories.map((String category) => Tab(text: category)).toList(),
                        onTap: (index) {
                          setState(() {
                            selectedCategory = categories[index];
                          });
                        },
                      ),
                    ),

                    // MARK: Sección de contenido de pestañas
                    SizedBox(
                      height: 700, // Ajusta esta altura según tus necesidades
                      child: TabBarView(
                        children: categories.map((String category) {
                          return FutureBuilder<List<DocumentSnapshot>>(
                            future: getItems(category),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GridView.builder(
                                    physics: const ScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 4 / 6,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final itemData = snapshot.data![index].data() as Map<String, dynamic>;
                                      return MenuItem(
                                        name: itemData['nombre'] ?? 'Nombre no disponible',
                                        price: (itemData['precio'] as num?)?.toDouble(),
                                        imageUrl: itemData['image'] as String?,
                                        // isFavorite: itemData['isFavorite'] as bool? ?? false,
                                        isFavorite: favoriteModel._favoriteItems[itemData['nombre']] ?? false,
                                        toggleFavorite: () {
                                          favoriteModel.toggleFavoriteStatus(itemData['nombre']);
                                          unawaited(() async {
                                            try {
                                              // Obtén el usuario actual
                                              final user = FirebaseAuth.instance.currentUser;
                                              if (user != null) {
                                                // Obtén la colección de favoritos del usuario
                                                FirebaseFirestore.instance.collection('Users').doc(user.uid).collection('favoritos').where('nombre', isEqualTo: itemData['nombre']).get().then((snapshot) {
                                                  if (snapshot.docs.isNotEmpty) {
                                                    // Si el producto está en la colección de favoritos, actualiza el estado de isFavorite a true
                                                    setState(() {
                                                      itemData['isFavorite'] = true;
                                                    });
                                                  }
                                                });
                                              }
                                              print('Usuario: $user');
                                              if (user != null) {
                                                final productSnapshot = await FirebaseFirestore.instance.collection('Productos').doc('tipos').collection(category).where('nombre', isEqualTo: itemData['nombre']).get();
                                                print('Producto: ${productSnapshot.docs}');
                                                if (productSnapshot.docs.isNotEmpty) {
                                                  final productData = productSnapshot.docs[0].data();
                                                  print('Datos del producto: $productData');

                                                  final favoriteSnapshot = await FirebaseFirestore.instance.collection('Users').doc(user.uid).collection('favoritos').where('nombre', isEqualTo: itemData['nombre']).get();
                                                  print('Favoritos: ${favoriteSnapshot.docs}');
                                                  if (favoriteSnapshot.docs.isNotEmpty) {
                                                    favoriteSnapshot.docs[0].reference.delete().then((value) => Fluttertoast.showToast(msg: 'Producto eliminado de favoritos')).catchError((error) => Fluttertoast.showToast(msg: 'Error al eliminar el producto de favoritos: $error'));
                                                  } else {
                                                    FirebaseFirestore.instance
                                                        .collection('Users')
                                                        .doc(user.uid)
                                                        .collection('favoritos')
                                                        .add({
                                                          'nombre': productData['nombre'],
                                                          'precio': productData['precio'],
                                                          'image': productData['image'],
                                                          'isFavorite': true,
                                                        })
                                                        .then((value) => Fluttertoast.showToast(msg: 'Producto añadido a favoritos'))
                                                        .catchError((error) => Fluttertoast.showToast(msg: 'Error al añadir el producto a favoritos: $error'));
                                                  }
                                                } else {
                                                  Fluttertoast.showToast(msg: 'Producto no encontrado');
                                                }
                                              } else {
                                                Fluttertoast.showToast(msg: 'Necesitas iniciar sesión para añadir productos a favoritos');
                                              }
                                            } catch (e) {
                                              print('Se produjo un error: $e');
                                            }
                                          }());
                                        },
                                        addToCart: () async {
                                          final user = FirebaseAuth.instance.currentUser;
                                          if (user != null) {
                                            final cartCollection = FirebaseFirestore.instance.collection('Carrito').doc(user.uid).collection('Productos');

                                            final productName = itemData['nombre'];
                                            final productQuery = await cartCollection.where('nombre', isEqualTo: productName).get();

                                            if (productQuery.docs.isEmpty) {
                                              // El producto no está en el carrito, lo agregamos
                                              cartCollection
                                                  .add({
                                                    'nombre': productName,
                                                    'precio': itemData['precio'],
                                                    'image': itemData['image'],
                                                    'isFavorite': itemData['isFavorite'],
                                                    'quantity': 1, // Agregamos un campo de cantidad
                                                  })
                                                  .then((value) => Fluttertoast.showToast(msg: 'Producto añadido al carrito'))
                                                  .catchError((error) => Fluttertoast.showToast(msg: 'Error al añadir el producto: $error'));
                                            } else {
                                              // El producto ya está en el carrito, aumentamos la cantidad
                                              final doc = productQuery.docs.first;
                                              cartCollection
                                                  .doc(doc.id)
                                                  .update({
                                                    'quantity': doc['quantity'] + 1,
                                                  })
                                                  .then((value) => Fluttertoast.showToast(msg: 'Cantidad de producto actualizada'))
                                                  .catchError((error) => Fluttertoast.showToast(msg: 'Error al actualizar la cantidad del producto: $error'));
                                            }
                                          } else {
                                            Fluttertoast.showToast(msg: 'Necesitas iniciar sesión para añadir productos al carrito');
                                          }
                                        },
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class FavoriteModel extends ChangeNotifier {
  final Map<String, bool> _favoriteItems = {};

  Future<bool> isFavorite(String itemId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favoriteSnapshot = await FirebaseFirestore.instance.collection('Users').doc(user.uid).collection('favoritos').where('nombre', isEqualTo: itemId).get();
      if (favoriteSnapshot.docs.isNotEmpty) {
        return true;
      }
    }
    return _favoriteItems[itemId] ?? false;
  }

  void toggleFavoriteStatus(String? itemName) {
    if (itemName != null && _favoriteItems.containsKey(itemName)) {
      _favoriteItems[itemName] = !_favoriteItems[itemName]!;
    } else if (itemName != null) {
      _favoriteItems[itemName] = true;
    }
  }
}
