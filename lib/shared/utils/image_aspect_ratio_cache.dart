import 'package:flutter/material.dart';

/// A simple in-memory cache for image aspect ratios indexed by URL.
/// This helps to prevent layout jumps when re-visiting or re-rendering images.
class ImageAspectRatioCache {
  static final Map<String, double> _cache = {};

  /// Gets the cached aspect ratio for a given URL.
  static double? get(String url) => _cache[url];

  /// Sets the cached aspect ratio for a given URL.
  static void set(String url, double aspectRatio) {
    _cache[url] = aspectRatio;
  }

  /// Calculates and saves the aspect ratio from a [Size].
  static double updateFromSize(String url, Size size) {
    final aspectRatio = size.width / size.height;
    set(url, aspectRatio);
    return aspectRatio;
  }

  /// Clears the cache.
  static void clear() => _cache.clear();
}
