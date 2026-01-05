import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CupertinoSegmentedControl<T> extends StatefulWidget {
  /// The labels for each segment.
  /// The key is the value returned in [onValueChanged].
  /// The value is the String label to display.
  final Map<T, String> children;

  /// The currently selected key.
  final T groupValue;

  /// Callback when the selection changes.
  final ValueChanged<T>? onValueChanged;

  /// The color of the selected segment (tint).
  final Color? activeColor;

  /// The background color of the control.
  final Color? backgroundColor;

  /// The color of the text in the control.
  final Color? textColor;

  const CupertinoSegmentedControl({
    super.key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
    this.activeColor,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<CupertinoSegmentedControl<T>> createState() =>
      _CupertinoSegmentedControlState<T>();
}

class _CupertinoSegmentedControlState<T>
    extends State<CupertinoSegmentedControl<T>> {
  MethodChannel? _channel;

  @override
  void didUpdateWidget(covariant CupertinoSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.groupValue != oldWidget.groupValue ||
        !mapEquals(widget.children, oldWidget.children) ||
        widget.activeColor != oldWidget.activeColor ||
        widget.backgroundColor != oldWidget.backgroundColor ||
        widget.textColor != oldWidget.textColor) {
      _updateNativeView();
    }
  }

  void _updateNativeView() {
    final Map<String, dynamic> params = _getCreationParams();
    _channel?.invokeMethod('update', params);
  }

  Map<String, dynamic> _getCreationParams() {
    // We need to pass the keys as indices or strings to the native side.
    // Since T can be anything, we'll map them to a list of labels and pass the index of the selected value.
    // The native side will just deal with indices [0, 1, 2...].
    // We'll map the native index back to T in the callback.

    final List<T> keys = widget.children.keys.toList();
    final List<String> values = widget.children.values.toList();
    final int selectedIndex = keys.indexOf(widget.groupValue);

    return <String, dynamic>{
      'values': values,
      'selectedIndex': selectedIndex,
      if (widget.activeColor != null) 'activeColor': widget.activeColor!.value,
      if (widget.backgroundColor != null)
        'backgroundColor': widget.backgroundColor!.value,
      if (widget.textColor != null) 'textColor': widget.textColor!.value,
    };
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('flutter_cupertino/segmented_$id');
    _channel?.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onValueChanged') {
      final int? index = call.arguments as int?;
      if (index != null && index >= 0 && index < widget.children.length) {
        final T value = widget.children.keys.elementAt(index);
        widget.onValueChanged?.call(value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = 'flutter_cupertino/segmented';

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        height: 32, // Standard height for segmented control
        width: double.infinity,
        child: UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: _getCreationParams(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        ),
      );
    } else {
      return SizedBox(
        height: 32,
        child: Center(
          child: Text(
            'Segmented Control (iOS)',
            style: TextStyle(
              color: widget.activeColor ?? const Color(0xFF007AFF),
            ),
          ),
        ),
      );
    }
  }
}
