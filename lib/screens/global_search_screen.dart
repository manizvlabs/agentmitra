import 'package:flutter/material.dart';

/// Global Search Screen
/// Allows searching across policies, clients, documents, etc.
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];


  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _performSearch();
    });
  }

  void _performSearch() {
    if (_searchQuery.isEmpty) {
      _searchResults = [];
      return;
    }

    // TODO: Implement real search API
    // For now, show empty results with a message that search needs backend integration
    _searchResults = [];
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search functionality requires backend API integration')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Search policies, clients, documents...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: _buildSearchBody(),
    );
  }

  Widget _buildSearchBody() {
    if (_searchQuery.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return _buildSearchResults();
  }

  Widget _buildSearchSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Suggestions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSuggestionChip('Policy numbers'),
          _buildSuggestionChip('Client names'),
          _buildSuggestionChip('Premium amounts'),
          _buildSuggestionChip('Document status'),
          const SizedBox(height: 24),
          Text(
            'Recent Searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildRecentSearch('LA123456789'),
          _buildRecentSearch('Amit Kumar'),
          _buildRecentSearch('Jeevan Anand'),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, right: 8),
      child: Chip(
        label: Text(text),
        backgroundColor: Colors.blue.shade50,
        labelStyle: TextStyle(color: Colors.blue.shade700),
        onDeleted: () {
          _searchController.text = text;
        },
        deleteIcon: const Icon(Icons.search, size: 16),
      ),
    );
  }

  Widget _buildRecentSearch(String text) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        _searchController.text = text;
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildSearchResultItem(result);
      },
    );
  }

  Widget _buildSearchResultItem(Map<String, dynamic> result) {
    final IconData icon = _getIconForType(result['type']);
    final Color color = _getColorForType(result['type']);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          result['title'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result['subtitle']),
            Text(
              result['client'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(result['status']),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            result['status'],
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(result['route']);
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'policy':
        return Icons.policy;
      case 'client':
        return Icons.person;
      case 'document':
        return Icons.description;
      default:
        return Icons.search;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'policy':
        return Colors.blue;
      case 'client':
        return Colors.green;
      case 'document':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    if (status.contains('Active')) return Colors.green;
    if (status.contains('Verified')) return Colors.blue;
    return Colors.grey;
  }
}
