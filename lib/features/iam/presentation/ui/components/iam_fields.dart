import 'package:flutter/material.dart';

/// Text field kept in sync with a [value] that lives in the UI state.
class IamTextField extends StatefulWidget {
  /// Creates the field.
  const IamTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.enabled = true,
  });

  final String label;
  final String value;
  final ValueChanged<String> onValueChange;
  final IconData? icon;
  final TextInputType keyboardType;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  State<IamTextField> createState() => _IamTextFieldState();
}

class _IamTextFieldState extends State<IamTextField> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(IamTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_controller, widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IconData? icon = widget.icon;
    return TextField(
      controller: _controller,
      onChanged: widget.onValueChange,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
    );
  }
}

/// Password field with a button that shows or hides the text.
class IamPasswordField extends StatefulWidget {
  /// Creates the field.
  const IamPasswordField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    required this.isVisible,
    required this.onToggleVisibility,
    this.errorText,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.enabled = true,
  });

  final String label;
  final String value;
  final ValueChanged<String> onValueChange;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final String? errorText;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  State<IamPasswordField> createState() => _IamPasswordFieldState();
}

class _IamPasswordFieldState extends State<IamPasswordField> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(IamPasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_controller, widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onValueChange,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      obscureText: !widget.isVisible,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        errorMaxLines: 2,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: widget.isVisible ? 'Ocultar contraseña' : 'Mostrar contraseña',
          icon: Icon(widget.isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: widget.onToggleVisibility,
        ),
      ),
    );
  }
}

/// Puts [value] in [controller] when the state changed it from outside, keeping the cursor at the end.
void _syncController(TextEditingController controller, String value) {
  if (value == controller.text) return;
  controller.value = TextEditingValue(text: value, selection: TextSelection.collapsed(offset: value.length));
}
