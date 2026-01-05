import 'package:flutter/foundation.dart';

/// The style of the action button in a Cupertino alert.
enum CupertinoActionStyle {
  /// The default style for an action.
  ///
  /// The action button will be displayed with the standard font weight and color.
  /// This maps to a standard button with no specific role in SwiftUI.
  defaultValue,

  /// The style for an action that cancels the operation.
  ///
  /// The action button will be displayed with a bolder font weight.
  /// This maps to `ButtonRole.cancel` in SwiftUI.
  cancel,

  /// The style for an action that performs a destructive operation.
  ///
  /// The action button will be displayed with a red text color.
  /// This maps to `ButtonRole.destructive` in SwiftUI.
  destructive,
}

/// A button to be used within a [CupertinoAlert].
///
/// This class is specifically designed for alerts and maps directly to
/// native alert actions (Default, Cancel, Destructive).
class CupertinoActionButton {
  /// The text label of the button.
  final String text;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// The style of the action button.
  final CupertinoActionStyle style;

  const CupertinoActionButton({
    required this.text,
    this.onPressed,
    this.style = CupertinoActionStyle.defaultValue,
  });
}
