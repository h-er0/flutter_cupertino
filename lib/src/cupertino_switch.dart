import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CupertinoSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? thumbColor;

  const CupertinoSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.thumbColor,
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
      return SizedBox(
        width: 51,
        height: 31,
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
