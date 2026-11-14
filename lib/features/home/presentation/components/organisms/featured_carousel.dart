import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../books/domain/entities/book.dart';
import '../molecules/featured_carousel_item.dart';
import '../molecules/carousel_indicator.dart';

/// The hero carousel of the home screen. Expects at least one book; the
/// parent leaves it out while the list is empty.
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
  /// would scroll away), and while the home is hidden behind another tab or
  /// route (its muted slide would play on return).
  late bool _autoAdvanceAllowed;

  /// Fingers on the carousel. A tick must not take the page from under a
  /// swipe, or from a reader holding the hero.
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Runs on mount and whenever one of these flips; showing the home
    // again starts a fresh interval.
    _autoAdvanceAllowed =
        !MediaQuery.disableAnimationsOf(context) &&
        !MediaQuery.accessibleNavigationOf(context) &&
        TickerMode.valuesOf(context).enabled;
    _restartTimer();
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
    if (!_autoAdvanceAllowed || _pointers > 0 || widget.books.length < 2) {
      return;
    }
    _timer = Timer.periodic(_interval, (_) => _advance());
  }

  void _advance() {
    if (_pointers > 0 || !_pageController.hasClients) return;
    _pageController.animateToPage(
      (_currentPage + 1) % widget.books.length,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  void _onPointerDown(PointerDownEvent _) {
    _pointers++;
    _restartTimer();
  }

  void _onPointerUp(PointerEvent _) {
    if (_pointers > 0) _pointers--;
    _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          Listener(
            onPointerDown: _onPointerDown,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerUp,
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
