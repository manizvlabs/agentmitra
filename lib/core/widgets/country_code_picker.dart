import 'package:flutter/material.dart';

/// Country code data model
class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

/// List of common country codes
class CountryCodes {
  static const List<CountryCode> codes = [
    CountryCode(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
    CountryCode(name: 'United States', code: 'US', dialCode: '+1', flag: '🇺🇸'),
    CountryCode(name: 'United Kingdom', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
    CountryCode(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
    CountryCode(name: 'Australia', code: 'AU', dialCode: '+61', flag: '🇦🇺'),
    CountryCode(name: 'Germany', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
    CountryCode(name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
    CountryCode(name: 'Japan', code: 'JP', dialCode: '+81', flag: '🇯🇵'),
    CountryCode(name: 'China', code: 'CN', dialCode: '+86', flag: '🇨🇳'),
    CountryCode(name: 'Singapore', code: 'SG', dialCode: '+65', flag: '🇸🇬'),
    CountryCode(name: 'UAE', code: 'AE', dialCode: '+971', flag: '🇦🇪'),
    CountryCode(name: 'Saudi Arabia', code: 'SA', dialCode: '+966', flag: '🇸🇦'),
  ];

  static CountryCode getDefault() => codes.first; // India
}

/// Country Code Picker Widget
class CountryCodePicker extends StatefulWidget {
  final CountryCode? initialCountry;
  final ValueChanged<CountryCode>? onChanged;
  final bool showFlag;
  final bool showCountryName;

  const CountryCodePicker({
    super.key,
    this.initialCountry,
    this.onChanged,
    this.showFlag = true,
    this.showCountryName = false,
  });

  @override
  State<CountryCodePicker> createState() => _CountryCodePickerState();
}

class _CountryCodePickerState extends State<CountryCodePicker> {
  late CountryCode _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry ?? CountryCodes.getDefault();
  }

  Future<void> _showCountryPicker() async {
    final result = await showModalBottomSheet<CountryCode>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CountryPickerSheet(
        selectedCountry: _selectedCountry,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCountry = result;
      });
      widget.onChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showCountryPicker,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showFlag)
              Text(
                _selectedCountry.flag,
                style: const TextStyle(fontSize: 20),
              ),
            if (widget.showFlag) const SizedBox(width: 8),
            Text(
              _selectedCountry.dialCode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// Country Picker Bottom Sheet
class _CountryPickerSheet extends StatefulWidget {
  final CountryCode selectedCountry;

  const _CountryPickerSheet({required this.selectedCountry});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryCode> _filteredCountries = CountryCodes.codes;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = CountryCodes.codes;
      } else {
        _filteredCountries = CountryCodes.codes.where((country) {
          return country.name.toLowerCase().contains(query) ||
              country.dialCode.contains(query) ||
              country.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search country...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Country list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected = country.code == widget.selectedCountry.code;

                return ListTile(
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(country.name),
                  subtitle: Text(country.dialCode),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF1a237e))
                      : null,
                  selected: isSelected,
                  selectedTileColor: const Color(0xFF1a237e).withOpacity(0.1),
                  onTap: () {
                    Navigator.of(context).pop(country);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

