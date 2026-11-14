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
  static const _interval = Duration(seconds: 8);

  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  /// Auto-advance moves content on its own, so it stays off when the user
  /// asked for less motion or browses with a screen reader (the focused page
  /// would scroll away).
  bool _autoAdvanceAllowed = false;

  /// The user is swiping; a tick must not take the page from under them.
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final allowed =
        !MediaQuery.disableAnimationsOf(context) &&
        !MediaQuery.accessibleNavigationOf(context);
    if (allowed != _autoAdvanceAllowed || _timer == null) {
      _autoAdvanceAllowed = allowed;
      _restartTimer();
    }
  }

  @override
  void didUpdateWidget(FeaturedCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A silent refresh can hand the mounted carousel a different list.
    if (widget.books.length == oldWidget.books.length) return;
    if (_currentPage >= widget.books.length) {
      _currentPage = 0;
      if (_pageController.hasClients) _pageController.jumpToPage(0);
    }
    _restartTimer();
  }

  /// Starts the interval over, so the next step comes a full interval after
  /// the last page change, manual or automatic.
  void _restartTimer() {
    _timer?.cancel();
    _timer = null;
    if (!_autoAdvanceAllowed || _dragging || widget.books.length < 2) return;
    _timer = Timer.periodic(_interval, (_) => _advance());
  }

  void _advance() {
    if (_dragging || !_pageController.hasClients) return;
    _pageController.animateToPage(
      (_currentPage + 1) % widget.books.length,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _dragging = true;
      _restartTimer();
    } else if (notification is ScrollEndNotification && _dragging) {
      _dragging = false;
      _restartTimer();
    }
    return false;
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
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                _restartTimer();
              },
              itemCount: widget.books.length,
              itemBuilder: (context, index) {
                return FeaturedCarouselItem(book: widget.books[index]);
              },
            ),
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
