import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'cupertino_button.dart';

class CupertinoAlert {
  static const MethodChannel _channel = MethodChannel(
    'flutter_cupertino_plugin',
  );

  static Future<int?> show(
    BuildContext context, {
    String? title,
    String? content,
    List<CupertinoButton> actions = const [],
  }) async {
    final List<Map<String, dynamic>> actionParams = actions.map((btn) {
      return {
        if (btn.text != null) 'text': btn.text,
        if (btn.systemIconName != null) 'systemIconName': btn.systemIconName,
        if (btn.color != null) 'color': btn.color!.value,
        if (btn.textColor != null) 'textColor': btn.textColor!.value,
        'borderRadius': btn.borderRadius,
        if (btn.enableLiquid != null) 'enableLiquid': btn.enableLiquid,
        'width': btn.width,
        'height': btn.height,
      };
    }).toList();

    try {
      final int? index = await _channel.invokeMethod<int>('showAlert', {
        if (title != null) 'title': title,
        if (content != null) 'message': content,
        'actions': actionParams,
      });

      if (index != null && index >= 0 && index < actions.length) {
        final btn = actions[index];
        if (btn.onPressed != null) {
          btn.onPressed!();
        }
      }
      return index;
    } on PlatformException catch (e) {
      debugPrint("Failed to show alert: '${e.message}'.");
      return null;
    }
  }
}
