import 'package:flutter/material.dart';

/// Circular spinner in the named sizes of `App/Atom/Indicador de carregamento`
/// (small 20 dp, medium 24 dp, large 40 dp). Callers pick a size by
/// constructor; there is no free size.
class AppLoadingIndicator extends StatelessWidget {
  /// 20 dp, for inside buttons.
  const AppLoadingIndicator.small({super.key, this.color}) : _size = 20;

  /// 24 dp, for list-level and inline loading.
  const AppLoadingIndicator.medium({super.key, this.color}) : _size = 24;

  /// 40 dp, for a whole page.
  const AppLoadingIndicator.large({super.key, this.color}) : _size = 40;

  final double _size;

  /// Defaults to `color/primary`; buttons pass their label colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _size,
      width: _size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
