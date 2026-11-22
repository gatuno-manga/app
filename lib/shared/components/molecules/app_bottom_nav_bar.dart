import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../atoms/app_nav_bar_item.dart';

/// The phone bottom bar: Início, Biblioteca and Livros, in the order of the
/// shell's branches. 80 dp tall (Figma `Shell/Barra inferior`), plus the
/// system gesture inset below it.
class AppBottomNavBar extends StatelessWidget {
  static const double height = 80;

  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerTheme.color ?? theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        // The bar's opaque background would paint over the items' ink, so the
        // ink needs a Material of its own above it.
        child: Material(
          type: MaterialType.transparency,
          child: SizedBox(
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppNavBarItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: l10n.homeTitle,
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                AppNavBarItem(
                  icon: Icons.bookmark_border,
                  selectedIcon: Icons.bookmark,
                  label: l10n.libraryTitle,
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                AppNavBarItem(
                  icon: Icons.book_outlined,
                  selectedIcon: Icons.book,
                  label: l10n.booksTitle,
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
