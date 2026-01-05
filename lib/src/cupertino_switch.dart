import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CupertinoSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool labelsHidden;
  final Color? activeColor;
  final Color? thumbColor;
  final double? width;

  const CupertinoSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.labelsHidden = true,
    this.activeColor,
    this.thumbColor,
    this.width,
  });

  @override
  State<CupertinoSwitch> createState() => _CupertinoSwitchState();
}

class _CupertinoSwitchState extends State<CupertinoSwitch> {
  MethodChannel? _channel;

  @override
  void didUpdateWidget(covariant CupertinoSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value ||
        widget.label != oldWidget.label ||
        widget.labelsHidden != oldWidget.labelsHidden ||
        widget.activeColor != oldWidget.activeColor ||
        widget.thumbColor != oldWidget.thumbColor ||
        widget.width != oldWidget.width) {
      _updateNativeView();
    }
  }

  void _updateNativeView() {
    final Map<String, dynamic> params = _getCreationParams();
    _channel?.invokeMethod('update', params);
  }

  Map<String, dynamic> _getCreationParams() {
    return <String, dynamic>{
      'value': widget.value,
      if (widget.label != null) 'label': widget.label,
      'labelsHidden': widget.labelsHidden,
      if (widget.activeColor != null) 'activeColor': widget.activeColor!.value,
      if (widget.thumbColor != null) 'thumbColor': widget.thumbColor!.value,
    };
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('flutter_cupertino/switch_$id');
    _channel?.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onChanged') {
      final bool? newValue = call.arguments as bool?;
      if (newValue != null && widget.onChanged != null) {
        widget.onChanged!(newValue);
      }
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = 'flutter_cupertino/switch';

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Standard iOS switch size is approx 51x31
      // If label is shown, we need to allow more width.
      Widget nativeView = UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: _getCreationParams(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );

      // If we have a label and it's visible, we should calculate the width if not provided.
      if (widget.label != null && !widget.labelsHidden) {
        double width = widget.width ?? 0;

        if (widget.width == null) {
          // Estimate width based on text
          final TextPainter textPainter = TextPainter(
            text: TextSpan(
              text: widget.label,
              style: const TextStyle(
                fontSize: 17, // Standard iOS body size
                color: Color(0xFF000000), // Default text color
                fontWeight: FontWeight.w400,
              ),
            ),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout();

          // Switch width (51) + Spacing/Padding (approx 20) + Text width
          width = textPainter.width + 51 + 20;
        }

        return SizedBox(width: width, height: 44, child: nativeView);
      }

      return SizedBox(width: 51, height: 31, child: nativeView);
    } else {
      return SizedBox(
        width: 51,
        height: 31,
        child: Center(
          child: Text(
            'iOS',
            style: TextStyle(
              color: widget.activeColor ?? const Color(0xFF007AFF),
              fontSize: 10,
            ),
          ),
        ),
      );
    }
  }
}
