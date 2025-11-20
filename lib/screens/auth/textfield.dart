import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int? maxLength;
  final bool enabled;
  final IconData? prefixIcon;
  final String? hint;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final FocusNode? focusNode;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final bool obscureText;
  final VoidCallback? onChanged;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.enabled = true,
    this.prefixIcon,
    this.hint,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.textStyle,
    this.focusNode,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      textCapitalization: widget.textCapitalization,
      textAlign: widget.textAlign,
      style: widget.textStyle ??
          const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines ?? (widget.obscureText ? 1 : null),
      obscureText: _obscureText,
      onChanged: (value) {
        widget.onChanged?.call();
        // Rebuild to update character counter color if needed
        setState(() {});
      },
      decoration: InputDecoration(
        label: Text(widget.label),
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: Colors.grey.shade500,
                size: 20,
              )
            : null,
        suffixIcon: widget.suffixIcon,
        counter: widget.maxLength != null
            ? Text(
                '${widget.controller.text.length}/${widget.maxLength}',
                style: TextStyle(
                  fontSize: 12,
                  color: _getCounterColor(),
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF13005A),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade600,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        errorStyle: TextStyle(
          color: Colors.red.shade600,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        filled: !widget.enabled,
        fillColor: !widget.enabled ? Colors.grey.shade100 : Colors.transparent,
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.prefixIcon != null ? 12 : 16,
          vertical: 16,
        ),
      ),
    );
  }

  Color _getCounterColor() {
    if (widget.maxLength == null) return Colors.grey.shade500;

    final percentage =
        widget.controller.text.length / widget.maxLength!;

    if (percentage >= 1.0) {
      return Colors.red.shade600;
    } else if (percentage >= 0.8) {
      return Colors.orange.shade600;
    } else {
      return Colors.grey.shade500;
    }
  }
}