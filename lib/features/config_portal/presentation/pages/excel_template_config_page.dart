import 'package:flutter/material.dart';

/// Excel Template Configuration Page
/// Section 5.3: Template selection, field mapping, and validation rules
class ExcelTemplateConfigPage extends StatefulWidget {
  const ExcelTemplateConfigPage({super.key});

  @override
  State<ExcelTemplateConfigPage> createState() => _ExcelTemplateConfigPageState();
}

class _ExcelTemplateConfigPageState extends State<ExcelTemplateConfigPage> {
  String? _selectedTemplate;
  final Map<String, String> _fieldMappings = {};
  final List<Map<String, dynamic>> _validationRules = [];

  final List<String> _templates = [
    'Customer Import Template',
    'Agent Data Template',
    'Policy Update Template',
    'Premium Payment Template',
  ];

  final List<Map<String, String>> _availableFields = [
    {'name': 'Customer Name', 'type': 'text', 'required': 'true'},
    {'name': 'Phone Number', 'type': 'phone', 'required': 'true'},
    {'name': 'Email', 'type': 'email', 'required': 'false'},
    {'name': 'Date of Birth', 'type': 'date', 'required': 'true'},
    {'name': 'Address', 'type': 'text', 'required': 'false'},
    {'name': 'Policy Number', 'type': 'text', 'required': 'true'},
    {'name': 'Premium Amount', 'type': 'number', 'required': 'true'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a237e)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Excel Template Configuration',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template Selection
            _buildTemplateSelection(),
            const SizedBox(height: 24),

            if (_selectedTemplate != null) ...[
              // Field Mapping
              _buildFieldMapping(),
              const SizedBox(height: 24),

              // Validation Rules
              _buildValidationRules(),
              const SizedBox(height: 24),

              // Preview Section
              _buildPreviewSection(),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Template',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a237e),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTemplate,
              decoration: InputDecoration(
                labelText: 'Template Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _templates.map((template) {
                return DropdownMenuItem(
                  value: template,
                  child: Text(template),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTemplate = value;
                });
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Download template
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Sample Template'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldMapping() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Field Mapping',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a237e),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Auto-map fields
                  },
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('Auto-Map'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._availableFields.map((field) => _buildFieldMappingRow(field)),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldMappingRow(Map<String, String> field) {
    final fieldName = field['name']!;
    final mappedColumn = _fieldMappings[fieldName] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      fieldName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (field['required'] == 'true')
                      const Text(
                        ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
                Text(
                  'Type: ${field['type']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: mappedColumn.isEmpty ? null : mappedColumn,
              decoration: InputDecoration(
                hintText: 'Select Excel column',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: ['Column A', 'Column B', 'Column C', 'Column D', 'Column E']
                  .map((col) => DropdownMenuItem(value: col, child: Text(col)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    _fieldMappings[fieldName] = value;
                  } else {
                    _fieldMappings.remove(fieldName);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationRules() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Validation Rules',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a237e),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _showAddValidationRuleDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_validationRules.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No validation rules added',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._validationRules.map((rule) => _buildValidationRuleCard(rule)),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationRuleCard(Map<String, dynamic> rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.blue.shade50,
      child: ListTile(
        title: Text(rule['field'] as String),
        subtitle: Text(rule['rule'] as String),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            setState(() {
              _validationRules.remove(rule);
            });
          },
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a237e),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Text('Sample data preview will appear here'),
                  SizedBox(height: 8),
                  Text(
                    'Upload Excel file to see preview',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Upload and preview
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Excel File'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Save template configuration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template configuration saved')),
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1a237e),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Template'),
          ),
        ),
      ],
    );
  }

  void _showAddValidationRuleDialog() {
    String? selectedField;
    String? selectedRule;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Validation Rule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Field',
                border: OutlineInputBorder(),
              ),
              items: _availableFields.map((field) {
                return DropdownMenuItem(
                  value: field['name'],
                  child: Text(field['name']!),
                );
              }).toList(),
              onChanged: (value) => selectedField = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Rule',
                border: OutlineInputBorder(),
              ),
              items: [
                'Required',
                'Unique',
                'Min Length: 5',
                'Max Length: 100',
                'Email Format',
                'Phone Format',
              ].map((rule) => DropdownMenuItem(value: rule, child: Text(rule))).toList(),
              onChanged: (value) => selectedRule = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedField != null && selectedRule != null) {
                setState(() {
                  _validationRules.add({
                    'field': selectedField,
                    'rule': selectedRule,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

