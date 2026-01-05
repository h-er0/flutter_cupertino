import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CupertinoSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int?
  divisions; // Note: SwiftUI Slider 'step' is similar to divisions but calculated differently.
  // SwiftUI Slider(value: in: step:)

  final Color? activeColor;
  final Color? thumbColor;

  const CupertinoSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.activeColor,
    this.thumbColor,
  });

  @override
  State<CupertinoSlider> createState() => _CupertinoSliderState();
}

class _CupertinoSliderState extends State<CupertinoSlider> {
  MethodChannel? _channel;

  @override
  void didUpdateWidget(covariant CupertinoSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value ||
        widget.min != oldWidget.min ||
        widget.max != oldWidget.max ||
        widget.divisions != oldWidget.divisions ||
        widget.activeColor != oldWidget.activeColor ||
        widget.thumbColor != oldWidget.thumbColor) {
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
      'min': widget.min,
      'max': widget.max,
      if (widget.divisions != null) 'divisions': widget.divisions,
      if (widget.activeColor != null) 'activeColor': widget.activeColor!.value,
      if (widget.thumbColor != null) 'thumbColor': widget.thumbColor!.value,
    };
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('flutter_cupertino/slider_$id');
    _channel?.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onChanged') {
      final double? newValue = call.arguments as double?;
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
    const String viewType = 'flutter_cupertino/slider';

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        height: 44, // Standard height for slider touch target
        width: double.infinity,
        child: UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: _getCreationParams(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
          },
        ),
      );
    } else {
      return SizedBox(
        height: 44,
        child: Center(
          child: Text(
            'CupertinoSlider (iOS only)',
            style: TextStyle(
              color: widget.activeColor ?? const Color(0xFF007AFF),
            ),
          ),
        ),
      );
    }
  }
}
