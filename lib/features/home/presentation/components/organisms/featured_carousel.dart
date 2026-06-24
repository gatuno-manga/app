import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../books/domain/entities/book.dart';
import '../molecules/featured_carousel_item.dart';
import '../molecules/carousel_indicator.dart';

class FeaturedCarousel extends StatefulWidget {
  final List<Book> books;

  const FeaturedCarousel({super.key, required this.books});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    if (widget.books.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
        if (_pageController.hasClients) {
          final nextPage = (_currentPage + 1) % widget.books.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.books.length,
            itemBuilder: (context, index) {
              return FeaturedCarouselItem(book: widget.books[index]);
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: CarouselIndicator(
              itemCount: widget.books.length,
              currentIndex: _currentPage,
            ),
          ),
        ],
      ),
    );
  }
}
