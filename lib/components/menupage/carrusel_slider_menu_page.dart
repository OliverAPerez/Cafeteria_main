// carousel_slider.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselSliderMenuPage extends StatelessWidget {
  final List<String> imgList;
  final CarouselOptions options;

  const CarouselSliderMenuPage({
    super.key,
    required this.imgList,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: options,
      items: imgList.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: const BoxDecoration(
                color: Colors.amber,
              ),
              child: Image.asset(item, fit: BoxFit.cover),
            );
          },
        );
      }).toList(),
    );
  }
}
