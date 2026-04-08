import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

/// A small wrapper that invokes [onEnter] when the user presses
/// the Enter key (including numpad Enter) while the child is focused.
///
/// Usage:
/// ```dart
/// EnterKeyListener(
///   onEnter: () => submit(),
///   child: YourButton(...),
/// )
/// ```
class EnterIntent extends Intent {
  const EnterIntent();
}

class EnterKeyListener extends StatelessWidget {
  final Widget child;
  final VoidCallback onEnter;
  final bool autofocus;

  const EnterKeyListener({
    Key? key,
    required this.child,
    required this.onEnter,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.enter): const EnterIntent(),
        LogicalKeySet(LogicalKeyboardKey.numpadEnter): const EnterIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          EnterIntent: CallbackAction<EnterIntent>(
            onInvoke: (intent) {
              onEnter();
              return null;
            },
          ),
        },
        child: Focus(autofocus: autofocus, child: child),
      ),
    );
  }
}
