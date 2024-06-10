import 'package:flutter/material.dart';

class MenuItem extends StatefulWidget {
  final String name;
  final double? price;
  final String? imageUrl;
  final bool isFavorite;
  final VoidCallback addToCart;
  final VoidCallback toggleFavorite;

  const MenuItem({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.isFavorite,
    required this.addToCart,
    required this.toggleFavorite,
  });

  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    widget.toggleFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(255, 99, 150, 102),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: widget.imageUrl != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(widget.imageUrl!, fit: BoxFit.cover),
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
                        Flexible(
                          child: Text(
                            widget.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
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
                        Text(widget.price != null ? '€${widget.price!.toStringAsFixed(2)}' : '', style: const TextStyle(fontSize: 20)),
                        Card(
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Color.fromARGB(255, 99, 150, 102),
                              size: 30,
                            ),
                            onPressed: widget.addToCart,
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
  }
}
