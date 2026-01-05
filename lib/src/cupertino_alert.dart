import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'cupertino_action_button.dart';

class CupertinoAlert {
  static const MethodChannel _channel = MethodChannel('flutter_cupertino');

  static Future<int?> show(
    BuildContext context, {
    String? title,
    String? content,
    List<CupertinoActionButton> actions = const [],
  }) async {
    final List<Map<String, dynamic>> actionParams = actions.map((btn) {
      String styleName;
      switch (btn.style) {
        case CupertinoActionStyle.destructive:
          styleName = 'destructive';
          break;
        case CupertinoActionStyle.cancel:
          styleName = 'cancel';
          break;
        case CupertinoActionStyle.defaultValue:
        default:
          styleName = 'default';
          break;
      }

      return {'text': btn.text, 'style': styleName};
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
