import 'package:flutter/material.dart';

/// Calls [onLoadMore] once each time the scrollable [child] comes within
/// [threshold] pixels of its end; it re-arms after scrolling back out.
class LoadMoreListener extends StatefulWidget {
  final Widget child;
  final VoidCallback onLoadMore;
  final bool enabled;
  final double threshold;

  const LoadMoreListener({
    super.key,
    required this.child,
    required this.onLoadMore,
    this.enabled = true,
    this.threshold = 300,
  });

  @override
  State<LoadMoreListener> createState() => _LoadMoreListenerState();
}

class _LoadMoreListenerState extends State<LoadMoreListener> {
  bool _armed = true;

  @override
  void didUpdateWidget(LoadMoreListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A load that ended (or was discarded) while the user stayed near the
    // end must be able to trigger the next one on the next scroll event.
    if (widget.enabled && !oldWidget.enabled) _armed = true;
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    final nearEnd = notification.metrics.extentAfter <= widget.threshold;
    if (!nearEnd) {
      _armed = true;
    } else if (_armed && widget.enabled) {
      _armed = false;
      widget.onLoadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: widget.child,
    );
  }
}
