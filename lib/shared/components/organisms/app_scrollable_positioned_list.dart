import 'package:flutter/material.dart';

class AppScrollablePositionedList extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final int initialIndex;
  final void Function(int index)? onVisibleIndexChanged;
  final ScrollController? controller;

  const AppScrollablePositionedList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.initialIndex = 0,
    this.onVisibleIndexChanged,
    this.controller,
  });

  @override
  State<AppScrollablePositionedList> createState() =>
      _AppScrollablePositionedListState();
}

class _AppScrollablePositionedListState
    extends State<AppScrollablePositionedList> {
  late final ScrollController _scrollController;
  final Map<int, GlobalKey> _itemKeys = {};
  final Set<int> _mountedIndices = {};
  int _lastReportedIndex = -1;
  bool _isInitialScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _lastReportedIndex = widget.initialIndex;

    if (widget.initialIndex > 0) {
      _isInitialScrolling = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(widget.initialIndex);
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(AppScrollablePositionedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex &&
        widget.initialIndex != _lastReportedIndex) {
      _isInitialScrolling = true;
      _scrollToIndex(widget.initialIndex);
    }
  }

  GlobalKey _getKey(int index) {
    return _itemKeys.putIfAbsent(index, () => GlobalKey());
  }

  Future<void> _scrollToIndex(int targetIndex) async {
    if (!_scrollController.hasClients) {
      _isInitialScrolling = false;
      return;
    }

    try {
      int maxAttempts = 100;
      int attempts = 0;

      while (attempts < maxAttempts) {
        attempts++;
        if (!_scrollController.hasClients) break;

        final key = _itemKeys[targetIndex];
        if (key != null && key.currentContext != null) {
          // Smoothly snap at the end
          await Scrollable.ensureVisible(
            key.currentContext!,
            alignment: 0.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
          );
          return;
        }

        final double currentOffset = _scrollController.offset;
        final double maxScroll = _scrollController.position.maxScrollExtent;

        if (currentOffset >= maxScroll && attempts > 1) break;

        final double viewportHeight =
            _scrollController.position.viewportDimension;

        // Calculate how far we are in terms of indices to adjust speed
        int currentMaxIndex =
            _mountedIndices.isNotEmpty
                ? _mountedIndices.reduce((a, b) => a > b ? a : b)
                : 0;
        int remainingIndices = (targetIndex - currentMaxIndex).abs();

        // Fast-to-slow curve logic:
        // We normalize the distance. Let's say 20 items is "far".
        double factor = (remainingIndices / 20.0).clamp(0.0, 1.0);

        // Aggressive speed parameters:
        // When far (factor=1.0): jump = 6.0x viewport, duration = 40ms
        // When near (factor=0.0): jump = 1.0x viewport, duration = 200ms
        double jumpMultiplier = 1.0 + (5.0 * factor);
        int durationMs = (200 - (160 * factor)).toInt();

        final double nextOffset =
            (currentOffset + (viewportHeight * jumpMultiplier)).clamp(
              0.0,
              maxScroll,
            );

        await _scrollController.animateTo(
          nextOffset,
          duration: Duration(milliseconds: durationMs),
          curve: Curves.linear,
        );
      }
    } finally {
      _isInitialScrolling = false;
    }
  }

  void _checkVisibility() {
    if (_isInitialScrolling) return;

    int? mostVisibleIndex;
    double maxVisibleFraction = 0.0;

    final scrollBox = context.findRenderObject() as RenderBox?;
    if (scrollBox == null) return;

    final scrollBounds = Offset.zero & scrollBox.size;

    for (final index in _mountedIndices) {
      final key = _itemKeys[index];
      final renderBox = key?.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null && renderBox.attached) {
        final offset = renderBox.localToGlobal(
          Offset.zero,
          ancestor: scrollBox,
        );
        final itemBounds = offset & renderBox.size;
        final intersection = scrollBounds.intersect(itemBounds);

        if (intersection.width > 0 && intersection.height > 0) {
          final visibleFraction =
              (intersection.width * intersection.height) /
              (renderBox.size.width * renderBox.size.height);

          // We prioritize the item that takes the most space on screen,
          // but also favor the one closest to the top if they are large.
          if (visibleFraction > maxVisibleFraction) {
            maxVisibleFraction = visibleFraction;
            mostVisibleIndex = index;
          }
        }
      }
    }

    if (mostVisibleIndex != null && mostVisibleIndex != _lastReportedIndex) {
      _lastReportedIndex = mostVisibleIndex;
      widget.onVisibleIndexChanged?.call(mostVisibleIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_isInitialScrolling) return false;
        if (notification is ScrollUpdateNotification) {
          if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent &&
              widget.itemCount > 0) {
            final lastIndex = widget.itemCount - 1;
            if (lastIndex != _lastReportedIndex) {
              _lastReportedIndex = lastIndex;
              widget.onVisibleIndexChanged?.call(lastIndex);
            }
          } else {
            _checkVisibility();
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          return _ItemVisibilityTracker(
            index: index,
            onMounted: (i) => _mountedIndices.add(i),
            onUnmounted: (i) {
              _mountedIndices.remove(i);
              _itemKeys.remove(i);
            },
            child: Container(
              key: _getKey(index),
              child: widget.itemBuilder(context, index),
            ),
          );
        },
      ),
    );
  }
}

class _ItemVisibilityTracker extends StatefulWidget {
  final int index;
  final Widget child;
  final void Function(int index) onMounted;
  final void Function(int index) onUnmounted;

  const _ItemVisibilityTracker({
    required this.index,
    required this.child,
    required this.onMounted,
    required this.onUnmounted,
  });

  @override
  State<_ItemVisibilityTracker> createState() => _ItemVisibilityTrackerState();
}

class _ItemVisibilityTrackerState extends State<_ItemVisibilityTracker> {
  @override
  void initState() {
    super.initState();
    widget.onMounted(widget.index);
  }

  @override
  void dispose() {
    widget.onUnmounted(widget.index);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
