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
  int _lastReportedIndex = -1;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _lastReportedIndex = widget.initialIndex;
    
    if (widget.initialIndex > 0) {
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

  GlobalKey _getKey(int index) {
    return _itemKeys.putIfAbsent(index, () => GlobalKey());
  }

  void _scrollToIndex(int index) {
    final key = _itemKeys[index];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        alignment: 0.0,
        duration: Duration.zero,
      );
    }
  }

  void _checkVisibility() {
    int? mostVisibleIndex;
    double maxVisibleFraction = 0.0;

    final scrollBox = context.findRenderObject() as RenderBox?;
    if (scrollBox == null) return;

    final scrollBounds = Offset.zero & scrollBox.size;

    for (final entry in _itemKeys.entries) {
      final index = entry.key;
      final key = entry.value;
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null && renderBox.attached) {
        final offset = renderBox.localToGlobal(Offset.zero, ancestor: scrollBox);
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
        if (notification is ScrollUpdateNotification) {
          _checkVisibility();
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          return Container(
            key: _getKey(index),
            child: widget.itemBuilder(context, index),
          );
        },
      ),
    );
  }
}
