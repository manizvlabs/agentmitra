/// OTP input widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatefulWidget {
  final TextEditingController controller;

  const OtpInput({
    super.key,
    required this.controller,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    // Sync individual controllers with main controller
    for (var controller in _controllers) {
      controller.addListener(_updateMainController);
    }
    widget.controller.addListener(_updateFromMainController);
  }

  void _updateMainController() {
    final otp = _controllers.map((c) => c.text).join();
    if (widget.controller.text != otp) {
      widget.controller.text = otp;
    }
  }

  void _updateFromMainController() {
    final otp = widget.controller.text;
    if (otp.length <= 6) {
      for (int i = 0; i < 6; i++) {
        if (i < otp.length) {
          if (_controllers[i].text != otp[i]) {
            _controllers[i].text = otp[i];
          }
        } else {
          if (_controllers[i].text.isNotEmpty) {
            _controllers[i].clear();
          }
        }
      }
    }
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onBackspace(int index) {
    if (index > 0 && _controllers[index].text.isEmpty) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.removeListener(_updateMainController);
      controller.dispose();
    }
    widget.controller.removeListener(_updateFromMainController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 50,
          height: 60,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) => _onChanged(index, value),
            onTap: () {
              _controllers[index].selection = TextSelection.fromPosition(
                TextPosition(offset: _controllers[index].text.length),
              );
            },
            onSubmitted: (_) {
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}

