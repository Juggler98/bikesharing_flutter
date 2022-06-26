import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeDialog extends StatefulWidget {
  final BuildContext context;
  final BuildContext ctx;
  final bool isDecimal;
  final String title;

  const CodeDialog(this.context, this.ctx, this.isDecimal, this.title,
      {Key? key})
      : super(key: key);

  @override
  State<CodeDialog> createState() => _CodeDialogState();
}

class _CodeDialogState extends State<CodeDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: SingleChildScrollView(
          child: AlertDialog(
            title: Text(widget.title),
            content: Form(
              key: _formKey,
              child: Column(
                //mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    keyboardType: !widget.isDecimal
                        ? TextInputType.number
                        : const TextInputType.numberWithOptions(
                            decimal: true, signed: false),
                    enableSuggestions: false,
                    autofocus: true,
                    inputFormatters: <TextInputFormatter>[
                      if (widget.isDecimal)
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                      if (widget.isDecimal)
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            final text = newValue.text;
                            if (text.isNotEmpty) double.parse(text);
                            return newValue;
                          } catch (e) {
                            return oldValue;
                          }
                        }),
                      if (!widget.isDecimal)
                        FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: null,
                    onSaved: (value) {
                      Navigator.of(context).pop(value);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(widget.ctx).pop();
                },
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              TextButton(
                onPressed: () {
                  final isValid = _formKey.currentState?.validate();
                  if (!isValid!) {
                    return;
                  }
                  _formKey.currentState?.save();
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
