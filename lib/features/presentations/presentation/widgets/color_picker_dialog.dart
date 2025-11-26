import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Color Picker Dialog Widget
class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final String title;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    this.title = 'Pick a color',
  });

  static Future<Color?> show(
    BuildContext context, {
    required Color initialColor,
    String title = 'Pick a color',
  }) async {
    return showDialog<Color>(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: initialColor,
        title: title,
      ),
    );
  }

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color Picker
            BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            // Color Preview
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _colorToHex(_selectedColor),
                  style: TextStyle(
                    color: _getContrastColor(_selectedColor),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // RGB Values
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildColorValue('R', _selectedColor.red),
                _buildColorValue('G', _selectedColor.green),
                _buildColorValue('B', _selectedColor.blue),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedColor),
          child: const Text('Select'),
        ),
      ],
    );
  }

  Widget _buildColorValue(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

