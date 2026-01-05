import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CupertinoLiquidButton extends StatefulWidget {
  /// The text label of the button.
  final String? text;

  /// The SF Symbol name for the icon.
  /// See: https://developer.apple.com/sf-symbols/
  final String? systemIconName;

  /// The background color of the button.
  /// If null, a default style is used (visual effect for liquid, solid color for legacy).
  final Color? color;

  /// The color of the text and icon.
  final Color? textColor;

  /// The border radius of the button.
  final double borderRadius;

  /// Whether to force liquid style (iOS 13+ visual effect) or legacy.
  /// If null, auto-detects based on system version (simulated logic in native for now).
  final bool? enableLiquid;

  final double width;
  final double height;

  const CupertinoLiquidButton({
    super.key,
    this.text,
    this.systemIconName,
    this.color,
    this.textColor,
    this.borderRadius = 16.0,
    this.enableLiquid,
    this.width = 200,
    this.height = 50,
  }) : assert(
         text != null || systemIconName != null,
         'Either text or systemIconName must be provided',
       );

  @override
  State<CupertinoLiquidButton> createState() => _CupertinoLiquidButtonState();
}

class _CupertinoLiquidButtonState extends State<CupertinoLiquidButton> {
  MethodChannel? _channel;

  @override
  void didUpdateWidget(covariant CupertinoLiquidButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text ||
        widget.systemIconName != oldWidget.systemIconName ||
        widget.color != oldWidget.color ||
        widget.textColor != oldWidget.textColor ||
        widget.borderRadius != oldWidget.borderRadius ||
        widget.enableLiquid != oldWidget.enableLiquid) {
      _updateNativeView();
    }
  }

  void _updateNativeView() {
    final Map<String, dynamic> params = _getCreationParams();
    _channel?.invokeMethod('update', params);
  }

  Map<String, dynamic> _getCreationParams() {
    return <String, dynamic>{
      if (widget.text != null) 'text': widget.text,
      if (widget.systemIconName != null)
        'systemIconName': widget.systemIconName,
      if (widget.color != null) 'color': widget.color!.value,
      if (widget.textColor != null) 'textColor': widget.textColor!.value,
      'borderRadius': widget.borderRadius,
      if (widget.enableLiquid != null) 'enableLiquid': widget.enableLiquid,
    };
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('flutter_cupertino/liquid_button_$id');
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = 'flutter_cupertino/view';

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: _getCreationParams(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: Text(
          '${widget.text ?? widget.systemIconName} (Not supported on $defaultTargetPlatform)',
          style: TextStyle(color: widget.textColor ?? const Color(0xFF000000)),
        ),
      ),
    );
  }
}
