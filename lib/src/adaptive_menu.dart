import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'adaptive_menu_item.dart';

class CupertinoAdaptiveMenu extends StatefulWidget {
  const CupertinoAdaptiveMenu({
    super.key,
    required this.child,
    required this.items,
    this.primaryAction,
  });

  /// The widget that triggers the menu.
  /// The menu interaction will be native (e.g. context menu on long press or button tap).
  final Widget child;

  /// The configuration of the menu.
  final List<CupertinoAdaptiveMenuItem> items;

  /// An optional primary action if the menu is used in a context where
  /// tap performs an action and long-press shows menu (context menu behavior).
  /// Note: The Native implementation default will be 'menu provided' behavior.
  final VoidCallback? primaryAction;

  @override
  State<CupertinoAdaptiveMenu> createState() => _CupertinoAdaptiveMenuState();
}

class _CupertinoAdaptiveMenuState extends State<CupertinoAdaptiveMenu> {
  final Map<int, VoidCallback> _actions = {};
  int _nextId = 0;
  MethodChannel? _channel;

  @override
  Widget build(BuildContext context) {
    // We use a Stack to place the transparent Platform View over the child.
    // This maintains the Flutter child's appearance but intercepts touches for the menu.
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: UiKitView(
            viewType: 'flutter_cupertino/adaptive_menu',
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: _serializeParams(),
            onPlatformViewCreated: _onPlatformViewCreated,
            // Allow gestures to pass through if the platform view is considered transparent?
            // Actually, we WANT it to intercept to show the menu.
            // But if we want simple "Context Menu" behavior, maybe we only want to intercept long press?
            // The default native UIButton with context menu works on Tap or Long Press depending on config.
            // We'll configure the native side to be transparent and fill bounds.
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _serializeParams() {
    _actions.clear();
    _nextId = 0;

    return {
      'items': widget.items.map(_serializeItem).toList(),
      'hasPrimaryAction': widget.primaryAction != null,
    };
  }

  Map<String, dynamic> _serializeItem(CupertinoAdaptiveMenuItem item) {
    final int id = _nextId++;
    if (item.onPressed != null) {
      _actions[id] = item.onPressed!;
    }

    List<Map<String, dynamic>>? children;
    if (item.children != null) {
      children = item.children!.map(_serializeItem).toList();
    }

    return {
      'id': id,
      'label': item.label,
      'icon': item.iconName,
      'isDestructive': item.isDestructive,
      'isEnabled': item.isEnabled,
      'type': item.type.index,
      'children': children,
    };
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('flutter_cupertino/adaptive_menu_$id');
    _channel?.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onAction') {
      final int actionId = call.arguments as int;
      final action = _actions[actionId];
      if (action != null) {
        action();
      }
    } else if (call.method == 'performPrimaryAction') {
      widget.primaryAction?.call();
    }
  }

  @override
  void didUpdateWidget(CupertinoAdaptiveMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items ||
        widget.primaryAction != oldWidget.primaryAction) {
      _updateMenu();
    }
  }

  void _updateMenu() {
    if (_channel != null) {
      _channel!.invokeMethod('updateMenu', _serializeParams());
    }
  }
}
