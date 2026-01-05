import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CupertinoLiquidButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    const String viewType = 'flutter_cupertino/view';
    final Map<String, dynamic> creationParams = <String, dynamic>{
      if (text != null) 'text': text,
      if (systemIconName != null) 'systemIconName': systemIconName,
      if (color != null) 'color': color!.value,
      if (textColor != null) 'textColor': textColor!.value,
      'borderRadius': borderRadius,
      if (enableLiquid != null) 'enableLiquid': enableLiquid,
    };

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        width: width,
        height: height,
        child: UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Text(
          '${text ?? systemIconName} (Not supported on $defaultTargetPlatform)',
          style: TextStyle(color: textColor ?? const Color(0xFF000000)),
        ),
      ),
    );
  }
}
