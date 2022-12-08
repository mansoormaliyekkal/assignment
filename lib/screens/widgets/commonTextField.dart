import 'package:flutter/material.dart';

class CommonTextField extends StatefulWidget {
  const CommonTextField(
      {Key key,
      @required this.controller,
      @required this.label,
      @required this.validator,
      this.disable = true,
      this.maxLines,
      this.hint,
      this.labelColor,
      this.prefixIcon,
      this.outlineBorder,
      TextInputType keyboardType})
      : super(
          key: key,
        );

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final String label;
  final String hint;
  final bool disable;
  final Widget prefixIcon;
  final int maxLines;
  final Color labelColor;
  final bool outlineBorder;

  @override
  _CommonTextFieldState createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      //keyboardType: TextInputType.number,
      controller: widget.controller,
      enabled: widget.disable,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon,
        border: widget.outlineBorder != null
            ? (widget.outlineBorder ? OutlineInputBorder() : InputBorder.none)
            : UnderlineInputBorder(),
        hoverColor: Theme.of(context).primaryColor,
        labelText: widget.label,
        labelStyle: TextStyle(color: widget.labelColor),
        hintText: widget.hint,
      ),
      style: TextStyle(color: Colors.black),
      validator: widget.validator,
    );
  }
}
