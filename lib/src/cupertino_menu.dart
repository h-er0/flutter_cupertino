import 'package:flutter_cupertino/src/cupertino_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Abstract base class for all menu elements
abstract class CupertinoMenuElement {
  const CupertinoMenuElement();

  Map<String, dynamic> toMap(int index);
}

/// A standard menu item or a submenu if [children] is provided.
class CupertinoMenuItem extends CupertinoMenuElement {
  final String label;
  final String? systemIconName;
  final bool isDestructive;
  final VoidCallback? onPressed;
  final List<CupertinoMenuElement>? children;

  const CupertinoMenuItem({
    required this.label,
    this.systemIconName,
    this.isDestructive = false,
    this.onPressed,
    this.children,
  });

  @override
  Map<String, dynamic> toMap(int index) {
    return {
      'type': 'action',
      'label': label,
      'systemIconName': systemIconName,
      'isDestructive': isDestructive,
      'index': index,
      'children': children
          ?.asMap()
          .entries
          .map((e) => e.value.toMap(e.key))
          .toList(),
    };
  }
}

/// A visual divider between menu items.
class CupertinoMenuDivider extends CupertinoMenuElement {
  const CupertinoMenuDivider();

  @override
  Map<String, dynamic> toMap(int index) {
    return {'type': 'divider'};
  }
}

class CupertinoMenu extends StatefulWidget {
  final String? label;
  final String systemIconName;
  final List<CupertinoMenuElement> children;
  final double? width;
  final double? height;
  final CupertinoButtonStyle style;
  final Color? color;
  final Color? textColor;
  final double? borderRadius;
  final CupertinoControlSize controlSize;

  const CupertinoMenu({
    super.key,
    this.label,
    required this.systemIconName,
    required this.children,
    this.width,
    this.height,
    this.style = CupertinoButtonStyle.glass,
    this.controlSize = CupertinoControlSize.regular,
    this.color,
    this.textColor,
    this.borderRadius,
  });

  @override
  State<CupertinoMenu> createState() => _CupertinoMenuState();
}

class _CupertinoMenuState extends State<CupertinoMenu> {
  MethodChannel? _channel;

  @override
  void didUpdateWidget(covariant CupertinoMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Logic to detect changes
    bool shouldUpdate =
        widget.label != oldWidget.label ||
        widget.systemIconName != oldWidget.systemIconName ||
        widget.style != oldWidget.style ||
        widget.color != oldWidget.color ||
        widget.textColor != oldWidget.textColor ||
        widget.borderRadius != oldWidget.borderRadius ||
        widget.controlSize != oldWidget.controlSize ||
        widget.children != oldWidget.children;

    if (shouldUpdate) {
      print("CupertinoMenu: sending update to native view");
      _updateNativeView();
    }
  }

  void _updateNativeView() {
    final params = _getCreationParams();
    _channel?.invokeMethod('update', params);
  }

  Map<String, dynamic> _getCreationParams() {
    return <String, dynamic>{
      'label': widget.label,
      'systemIconName': widget.systemIconName,
      'style': widget.style.index,
      'controlSize': widget.controlSize.index,
      'color': widget.color?.value,
      'textColor': widget.textColor?.value,
      'borderRadius': widget.borderRadius,
      'items': widget.children
          .asMap()
          .entries
          .map((entry) => entry.value.toMap(entry.key))
          .toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = 'flutter_cupertino/menu';
    final Map<String, dynamic> creationParams = _getCreationParams();

    return SizedBox(
      width: widget.width ?? 150, // Default width
      height: widget.height ?? 44, // Default height
      child: UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('flutter_cupertino/menu_$id');
    _channel!.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onItemSelected') {
      final List<dynamic> indices = call.arguments as List<dynamic>;
      _triggerAction(widget.children, indices.cast<int>());
    }
  }

  void _triggerAction(List<CupertinoMenuElement> elements, List<int> path) {
    if (path.isEmpty) return;

    final int index = path.first;
    if (index >= 0 && index < elements.length) {
      final element = elements[index];
      if (path.length == 1) {
        // We reached the target item
        if (element is CupertinoMenuItem) {
          element.onPressed?.call();
        }
      } else if (element is CupertinoMenuItem && element.children != null) {
        // Recursive step
        _triggerAction(element.children!, path.sublist(1));
      }
    }
  }
}
