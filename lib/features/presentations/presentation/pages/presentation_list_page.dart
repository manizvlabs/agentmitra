import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/presentation_viewmodel.dart';
import '../../data/models/presentation_model.dart';
import '../../data/models/presentation_models.dart';

/// Presentation List Page
/// Shows all presentations with filters, search, and management actions
class PresentationListPage extends StatefulWidget {
  const PresentationListPage({super.key});

  @override
  State<PresentationListPage> createState() => _PresentationListPageState();
}

class _PresentationListPageState extends State<PresentationListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // 'all', 'active', 'draft', 'archived'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<PresentationViewModel>(context, listen: false);
      // TODO: Get agent ID from user session
      viewModel.loadAgentPresentations('agent_123');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presentations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _PresentationSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<PresentationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.loadAgentPresentations('agent_123');
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredPresentations = _filterPresentations(viewModel.presentations);

          if (filteredPresentations.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Filter Chips
              _buildFilterChips(),
              // Presentations List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => viewModel.loadAgentPresentations('agent_123'),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPresentations.length,
                    itemBuilder: (context, index) {
                      return _buildPresentationCard(filteredPresentations[index], viewModel);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewPresentation(context),
        icon: const Icon(Icons.add),
        label: const Text('New Presentation'),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'All'),
            const SizedBox(width: 8),
            _buildFilterChip('active', 'Active'),
            const SizedBox(width: 8),
            _buildFilterChip('draft', 'Draft'),
            const SizedBox(width: 8),
            _buildFilterChip('archived', 'Archived'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildPresentationCard(PresentationModel presentation, PresentationViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _openPresentationEditor(presentation),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(presentation.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      presentation.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(presentation.status),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Actions Menu
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, presentation, viewModel),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 18),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      if (presentation.status != 'archived')
                        const PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive, size: 18),
                              SizedBox(width: 8),
                              Text('Archive'),
                            ],
                          ),
                        ),
                      if (presentation.status == 'archived')
                        const PopupMenuItem(
                          value: 'unarchive',
                          child: Row(
                            children: [
                              Icon(Icons.unarchive, size: 18),
                              SizedBox(width: 8),
                              Text('Unarchive'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                presentation.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (presentation.description != null && presentation.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  presentation.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              // Metadata
              Row(
                children: [
                  Icon(Icons.slideshow, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${presentation.slides.length} slides',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  if (presentation.createdAt != null) ...[
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(presentation.createdAt!),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              // Action Buttons
              Row(
                children: [
                  if (presentation.status == 'draft')
                    OutlinedButton.icon(
                      onPressed: () => _publishPresentation(presentation, viewModel),
                      icon: const Icon(Icons.publish, size: 16),
                      label: const Text('Publish'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _openPresentationEditor(presentation),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.preview),
                    onPressed: () => _previewPresentation(presentation),
                    tooltip: 'Preview',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.slideshow, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No presentations found',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first presentation to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createNewPresentation(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Presentation'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'archived':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  List<PresentationModel> _filterPresentations(List<PresentationModel> presentations) {
    var filtered = presentations;

    // Apply status filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((p) {
        if (_selectedFilter == 'active') {
          return p.status == 'active' || p.status == 'published';
        }
        return p.status == _selectedFilter;
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (p.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Presentations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('All'),
              value: 'all',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Active'),
              value: 'active',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Draft'),
              value: 'draft',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Archived'),
              value: 'archived',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, PresentationModel presentation, PresentationViewModel viewModel) {
    switch (action) {
      case 'edit':
        _openPresentationEditor(presentation);
        break;
      case 'duplicate':
        _duplicatePresentation(presentation, viewModel);
        break;
      case 'archive':
        _archivePresentation(presentation, viewModel);
        break;
      case 'unarchive':
        _unarchivePresentation(presentation, viewModel);
        break;
      case 'delete':
        _deletePresentation(presentation, viewModel);
        break;
    }
  }

  void _openPresentationEditor(PresentationModel presentation) {
    Navigator.of(context).pushNamed(
      '/presentation-editor',
      arguments: presentation,
    );
  }

  void _previewPresentation(PresentationModel presentation) {
    // TODO: Navigate to preview page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preview: ${presentation.name}')),
    );
  }

  void _createNewPresentation(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/presentation-editor',
      arguments: null, // null means create new
    );
  }

  Future<void> _publishPresentation(PresentationModel presentation, PresentationViewModel viewModel) async {
    final success = await viewModel.updatePresentation(
      presentationId: presentation.presentationId!,
      status: 'published',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Presentation published' : 'Failed to publish'),
        ),
      );
    }
  }

  Future<void> _duplicatePresentation(PresentationModel presentation, PresentationViewModel viewModel) async {
    // Convert SlideModel to PresentationSlide
    final slides = presentation.slides.map((slide) {
      return PresentationSlide(
        type: slide.slideType,
        layout: slide.layout,
        title: slide.title,
        content: slide.subtitle,
        imageUrl: slide.slideType == 'image' ? slide.mediaUrl : null,
        videoUrl: slide.slideType == 'video' ? slide.mediaUrl : null,
        metadata: {
          'slide_order': slide.slideOrder,
          'duration': slide.duration,
          'text_color': slide.textColor,
          'background_color': slide.backgroundColor,
        },
      );
    }).toList();

    final duplicated = await viewModel.createPresentation(
      agentId: presentation.agentId,
      title: '${presentation.name} (Copy)',
      description: presentation.description,
      slides: slides,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(duplicated != null ? 'Presentation duplicated' : 'Failed to duplicate'),
        ),
      );
    }
  }

  Future<void> _archivePresentation(PresentationModel presentation, PresentationViewModel viewModel) async {
    final success = await viewModel.updatePresentation(
      presentationId: presentation.presentationId!,
      status: 'archived',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Presentation archived' : 'Failed to archive'),
        ),
      );
    }
  }

  Future<void> _unarchivePresentation(PresentationModel presentation, PresentationViewModel viewModel) async {
    final success = await viewModel.updatePresentation(
      presentationId: presentation.presentationId!,
      status: 'draft',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Presentation unarchived' : 'Failed to unarchive'),
        ),
      );
    }
  }

  Future<void> _deletePresentation(PresentationModel presentation, PresentationViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Presentation'),
        content: Text('Are you sure you want to delete "${presentation.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: Implement delete in ViewModel
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete functionality coming soon')),
      );
    }
  }
}

class _PresentationSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: Implement search results
    return const Center(child: Text('Search results'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: Implement search suggestions
    return const Center(child: Text('Search suggestions'));
  }
}

