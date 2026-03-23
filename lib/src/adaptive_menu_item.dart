import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum CupertinoAdaptiveMenuItemType { action, submenu, section }

/// Represents a single item in the [CupertinoAdaptiveMenu].
@immutable
class CupertinoAdaptiveMenuItem {
  /// Defines a standard action item.
  const CupertinoAdaptiveMenuItem({
    required this.label,
    this.onPressed,
    this.iconName,
    this.isDestructive = false,
    this.isEnabled = true,
  }) : type = CupertinoAdaptiveMenuItemType.action,
       children = null;

  /// Defines a submenu or section that contains children.
  ///
  /// In iOS UIMenu terms, this creates a nested UIMenu or inline section.
  const CupertinoAdaptiveMenuItem.menu({
    required this.label,
    required this.children,
    this.iconName,
    this.isEnabled = true,
  }) : type = CupertinoAdaptiveMenuItemType.submenu,
       onPressed = null,
       isDestructive = false;

  /// Defines an inline section (UIMenuOptions.displayInline).
  ///
  /// This groups the children visually using a separator-like behavior.
  const CupertinoAdaptiveMenuItem.section({
    String? title,
    required this.children,
  }) : type = CupertinoAdaptiveMenuItemType.section,
       label = title ?? '',
       onPressed = null,
       iconName = null,
       isEnabled = true,
       isDestructive = false;

  final String label;
  final String? iconName; // System symbol name (SF Symbol)
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isEnabled;
  final List<CupertinoAdaptiveMenuItem>? children;

  final CupertinoAdaptiveMenuItemType type;
}
