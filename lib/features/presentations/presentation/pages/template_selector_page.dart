/// Template Selector Page
/// Allows agents to select and apply presentation templates
import 'package:flutter/material.dart';
import '../../data/repositories/presentation_repository.dart';
import '../../data/models/presentation_models.dart';
import '../../data/models/presentation_model.dart';
import '../../data/models/slide_model.dart';
import '../pages/presentation_editor_page.dart';

class TemplateSelectorPage extends StatefulWidget {
  final String agentId;

  const TemplateSelectorPage({
    super.key,
    required this.agentId,
  });

  @override
  State<TemplateSelectorPage> createState() => _TemplateSelectorPageState();
}

class _TemplateSelectorPageState extends State<TemplateSelectorPage> {
  final PresentationRepository _repository = PresentationRepository();
  List<PresentationTemplate> _templates = [];
  List<PresentationTemplate> _filteredTemplates = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedCategory;

  final List<String> _categories = [
    'All',
    'term_insurance',
    'health_insurance',
    'child_plans',
    'retirement',
  ];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final templates = await _repository.getTemplates();
      setState(() {
        _templates = templates;
        _filteredTemplates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load templates: $e';
        _isLoading = false;
      });
    }
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null || category == 'All') {
        _filteredTemplates = _templates;
      } else {
        _filteredTemplates = _templates
            .where((template) => template.category == category)
            .toList();
      }
    });
  }

  Future<void> _applyTemplate(PresentationTemplate template) async {
    // Convert template slides to SlideModel format
    final slides = template.slides.asMap().entries.map((entry) {
      final index = entry.key;
      final slide = entry.value;
      final metadata = slide.metadata ?? {};

      return SlideModel(
        slideOrder: index,
        slideType: slide.type ?? 'text',
        mediaUrl: slide.imageUrl ?? slide.videoUrl,
        mediaType: slide.imageUrl != null ? 'image' : (slide.videoUrl != null ? 'video' : null),
        title: slide.title,
        subtitle: slide.content,
        layout: slide.layout ?? 'centered',
        textColor: metadata['text_color'] ?? '#FFFFFF',
        backgroundColor: metadata['background_color'] ?? '#000000',
        overlayOpacity: (metadata['overlay_opacity'] ?? 0.5) is double
            ? (metadata['overlay_opacity'] ?? 0.5) as double
            : ((metadata['overlay_opacity'] ?? 0.5) as num).toDouble(),
        duration: metadata['duration'] ?? 4,
        ctaButton: metadata['cta_button'],
        agentBranding: metadata['agent_branding'],
      );
    }).toList();

    // Create presentation from template
    final presentation = PresentationModel(
      agentId: widget.agentId,
      name: template.name,
      description: template.description,
      status: 'draft',
      isActive: false,
      slides: slides,
      templateId: template.templateId,
    );

    // Navigate to editor with template applied
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PresentationEditorPage(
            presentation: presentation,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Template'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category ||
                    (category == 'All' && _selectedCategory == null);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category.replaceAll('_', ' ').toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _filterByCategory(category == 'All' ? null : category);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Templates List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadTemplates,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredTemplates.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.dashboard_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No templates found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try selecting a different category',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _filteredTemplates.length,
                            itemBuilder: (context, index) {
                              final template = _filteredTemplates[index];
                              return _buildTemplateCard(template);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(PresentationTemplate template) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _applyTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: template.thumbnailUrl != null && template.thumbnailUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          template.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderThumbnail();
                          },
                        ),
                      )
                    : _buildPlaceholderThumbnail(),
              ),
            ),

            // Template Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (template.description.isNotEmpty)
                      Expanded(
                        child: Text(
                          template.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            template.category.replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${template.slides.length} slides',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderThumbnail() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.slideshow,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Template',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

