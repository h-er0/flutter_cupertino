import 'package:flutter_cupertino/src/cupertino_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Abstract base class for all menu elements
abstract class CupertinoMenuElement {
  const CupertinoMenuElement();

  Map<String, dynamic> toMap(int index);
}

/// Abstract base class for sections within the menu
abstract class CupertinoMenuSectionBase {
  const CupertinoMenuSectionBase();

  Map<String, dynamic> toMap(int sectionIndex);
}

/// A standard section with a vertical list of items.
class CupertinoMenuSection extends CupertinoMenuSectionBase {
  final String? title;
  final List<CupertinoMenuItem> items;

  const CupertinoMenuSection({this.title, required this.items});

  // Alternative compatibility constructor if user wanted to pass just items
  // const CupertinoMenuSection.items(this.items) : title = null;

  @override
  Map<String, dynamic> toMap(int sectionIndex) {
    return {
      'type': 'section',
      'title': title,
      'items': items.asMap().entries.map((e) => e.value.toMap(e.key)).toList(),
    };
  }
}

/// A horizontal row of actions, typically used as a header.
/// This will be rendered as a ControlGroup or header actions in the native menu.
class CupertinoMenuActionRow extends CupertinoMenuSectionBase {
  final List<CupertinoMenuItem> items;

  const CupertinoMenuActionRow({required this.items});

  @override
  Map<String, dynamic> toMap(int sectionIndex) {
    // This is a special marker for the Swift side to know it's a header
    return {
      'type': 'header',
      'items': items.asMap().entries.map((e) => e.value.toMap(e.key)).toList(),
    };
  }
}

/// A standard menu item or a submenu if [children] is provided.
class CupertinoMenuItem extends CupertinoMenuElement {
  final String label;
  final String? systemIconName;
  final bool isDestructive;
  final bool isEnabled;
  final String? trailingIconName; // For custom suffix icon
  final VoidCallback? onPressed;
  final List<CupertinoMenuItem>? children; // Submenus contain items

  const CupertinoMenuItem({
    required this.label,
    this.systemIconName,
    this.isDestructive = false,
    this.isEnabled = true,
    this.trailingIconName,
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
      'isEnabled': isEnabled,
      'trailingIconName': trailingIconName,
      'index': index,
      'children': children
          ?.asMap()
          .entries
          .map((e) => e.value.toMap(e.key))
          .toList(),
    };
  }
}

/// Deprecated: Use [CupertinoMenuSection] to separate items implicitly.
// @Deprecated('Use CupertinoMenuSection to separate items implicitly')
// class CupertinoMenuDivider extends CupertinoMenuElement {
//   const CupertinoMenuDivider();
//
//   @override
//   Map<String, dynamic> toMap(int index) {
//     return {'type': 'divider'};
//   }
// }

class CupertinoMenu extends StatefulWidget {
  final String? label;
  final String systemIconName;
  final List<CupertinoMenuSectionBase> sections;

  final double? width;
  final double? height;
  final CupertinoButtonStyle style;
  final CupertinoControlSize controlSize;
  final Color? color;
  final Color? textColor;
  final double? borderRadius;
  final bool? isCircle;

  const CupertinoMenu({
    super.key,
    this.label,
    required this.systemIconName,
    required this.sections,
    this.width,
    this.height,
    this.style = CupertinoButtonStyle.glass,
    this.controlSize = CupertinoControlSize.regular,
    this.color,
    this.textColor,
    this.borderRadius,
    this.isCircle,
  });

  @override
  State<CupertinoMenu> createState() => _CupertinoMenuState();
}

class _CupertinoMenuState extends State<CupertinoMenu> {
  MethodChannel? _channel;

  List<CupertinoMenuItem>? get _headerActions {
    if (widget.sections.isNotEmpty &&
        widget.sections.first is CupertinoMenuActionRow) {
      return (widget.sections.first as CupertinoMenuActionRow).items;
    }
    return null;
  }

  List<CupertinoMenuSection> get _regularSections {
    List<CupertinoMenuSection> result = [];
    for (var section in widget.sections) {
      if (section is CupertinoMenuSection) {
        result.add(section);
      }
    }
    return result;
  }

  @override
  void didUpdateWidget(covariant CupertinoMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool shouldUpdate =
        widget.label != oldWidget.label ||
        widget.systemIconName != oldWidget.systemIconName ||
        widget.style != oldWidget.style ||
        widget.color != oldWidget.color ||
        widget.textColor != oldWidget.textColor ||
        widget.borderRadius != oldWidget.borderRadius ||
        widget.controlSize != oldWidget.controlSize ||
        widget.sections != oldWidget.sections ||
        widget.isCircle != oldWidget.isCircle;

    if (shouldUpdate) {
      _updateNativeView();
    }
  }

  void _updateNativeView() {
    final params = _getCreationParams();
    _channel?.invokeMethod('update', params);
  }

  Map<String, dynamic> _getCreationParams() {
    final Map<String, dynamic> args = {
      'label': widget.label,
      'systemIconName': widget.systemIconName,
      'style': widget.style.index,
      'controlSize': widget.controlSize.index,
      'borderRadius': widget.borderRadius ?? 8.0,
    };
    if (widget.color != null) args['color'] = widget.color!.value;
    if (widget.textColor != null) args['textColor'] = widget.textColor!.value;
    if (widget.isCircle != null) args['isCircle'] = widget.isCircle;

    final header = _headerActions;
    final bodySections = _regularSections;

    if (header != null) {
      args['header'] = header
          .asMap()
          .entries
          .map((e) => e.value.toMap(e.key))
          .toList();
    }

    if (bodySections.isNotEmpty) {
      args['sections'] = bodySections.map((s) => s.toMap(0)).toList();
    }

    return args;
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
      final List<dynamic> path = call.arguments;
      _handleSelection(path.cast<int>());
    }
  }

  void _handleSelection(List<int> path) {
    if (path.isEmpty) return;

    // Check for header special code (e.g. -1 in first slot, index in second)
    if (path[0] == -1) {
      if (path.length > 1) {
        int headerIndex = path[1];
        final header = _headerActions;
        if (header != null && headerIndex < header.length) {
          header[headerIndex].onPressed?.call();
        }
      }
      return;
    }

    // Regular sections
    final bodySections = _regularSections;
    int sectionIndex = path[0];

    if (sectionIndex < bodySections.length) {
      final section = bodySections[sectionIndex];
      if (path.length > 1) {
        int itemIndex = path[1];
        if (itemIndex < section.items.length) {
          _triggerItem(section.items[itemIndex], path.sublist(2));
        }
      }
    }
  }

  void _triggerItem(CupertinoMenuItem item, List<int> remainingPath) {
    if (remainingPath.isEmpty) {
      item.onPressed?.call();
    } else {
      if (item.children != null && remainingPath.isNotEmpty) {
        int nextIndex = remainingPath[0];
        if (nextIndex < item.children!.length) {
          _triggerItem(item.children![nextIndex], remainingPath.sublist(1));
        }
      }
    }
  }
}
