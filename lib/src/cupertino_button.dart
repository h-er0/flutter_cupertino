import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum CupertinoButtonStyle {
  automatic,
  filled,
  tinted,
  gray,
  plain,
  glass,
  glassProminent,
}

enum CupertinoControlSize { mini, small, regular, large, extraLarge }

class CupertinoButton extends StatefulWidget {
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
  /// If null, uses the system default for the selected style.
  final double? borderRadius;

  /// The style of the button (SwiftUI style).
  final CupertinoButtonStyle style;

  /// The size of the control.
  final CupertinoControlSize controlSize;

  /// Whether to force a circular shape (useful for icon-only buttons).
  final bool? isCircle;

  final double width;
  final double height;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Custom text style for the button label.
  final TextStyle? textStyle;

  /// Custom icon bytes (e.g. from an asset or memory).
  /// If provided, this takes precedence over [systemIconName].
  final Uint8List? iconBytes;

  const CupertinoButton({
    super.key,
    this.text,
    this.systemIconName,
    this.color,
    this.textColor,
    this.borderRadius,
    this.style = CupertinoButtonStyle.automatic,
    this.controlSize = CupertinoControlSize.regular,
    this.isCircle,
    this.width = 200,
    this.height = 50,
    this.onPressed,
    this.textStyle,
    this.iconBytes,
  }) : assert(
         text != null || systemIconName != null || iconBytes != null,
         'Either text, systemIconName, or iconBytes must be provided',
       );

  @override
  State<CupertinoButton> createState() => _CupertinoButtonState();
}

class _CupertinoButtonState extends State<CupertinoButton> {
  MethodChannel? _channel;

  @override
  void didUpdateWidget(covariant CupertinoButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text ||
        widget.systemIconName != oldWidget.systemIconName ||
        widget.color != oldWidget.color ||
        widget.textColor != oldWidget.textColor ||
        widget.borderRadius != oldWidget.borderRadius ||
        widget.style != oldWidget.style ||
        widget.controlSize != oldWidget.controlSize ||
        widget.isCircle != oldWidget.isCircle ||
        widget.textStyle != oldWidget.textStyle ||
        widget.iconBytes != oldWidget.iconBytes) {
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
      if (widget.borderRadius != null) 'borderRadius': widget.borderRadius,
      'style': widget.style.name,
      'controlSize': widget.controlSize.name,
      if (widget.isCircle != null) 'isCircle': widget.isCircle,
      if (widget.textStyle != null) ...{
        if (widget.textStyle!.fontSize != null)
          'fontSize': widget.textStyle!.fontSize,
        if (widget.textStyle!.fontWeight != null)
          'fontWeight': widget.textStyle!.fontWeight!.value,
        if (widget.textStyle!.color != null)
          'textColor': widget.textStyle!.color!.value,
      },
      if (widget.iconBytes != null) 'iconBytes': widget.iconBytes,
    };
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('flutter_cupertino/button_$id');
    _channel?.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onPressed') {
      widget.onPressed?.call();
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = 'flutter_cupertino/view';

    Widget buttonView;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      buttonView = UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: _getCreationParams(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      // Fallback for non-iOS platforms with GestureDetector for onPressed
      buttonView = GestureDetector(
        onTap: widget.onPressed,
        child: Center(
          child: Text(
            '${widget.text ?? widget.systemIconName} (Not supported on $defaultTargetPlatform)',
            style: TextStyle(
              color: widget.textColor ?? const Color(0xFF000000),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: buttonView,
    );
  }
}
