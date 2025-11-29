import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../viewmodels/presentation_viewmodel.dart';
import '../../data/models/presentation_model.dart';
import '../../data/models/slide_model.dart';
import '../../data/models/presentation_models.dart';
import '../widgets/color_picker_dialog.dart';
import '../../../../core/services/agent_service.dart';
import '../../../../core/services/logger_service.dart';

// Web-specific imports are handled dynamically below

/// Presentation Editor Page
/// Full slide management with add, edit, delete, reorder functionality
class PresentationEditorPage extends StatefulWidget {
  final PresentationModel? presentation;

  const PresentationEditorPage({super.key, this.presentation});

  @override
  State<PresentationEditorPage> createState() => _PresentationEditorPageState();
}

class _PresentationEditorPageState extends State<PresentationEditorPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  PresentationModel? _currentPresentation;
  SlideModel? _selectedSlide;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentPresentation = widget.presentation;
    if (_currentPresentation != null) {
      _titleController.text = _currentPresentation!.name;
      _descriptionController.text = _currentPresentation!.description ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          final shouldLeave = await _showUnsavedChangesDialog();
          return shouldLeave ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          title: Text(_currentPresentation == null ? 'New Presentation' : 'Edit Presentation'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveDraft,
              tooltip: 'Save Draft',
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _publishPresentation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Publish'),
              ),
            ),
          ],
        ),
        body: Row(
          children: [
            // Slide List Panel
            Expanded(
              flex: 2,
              child: _buildSlideListPanel(),
            ),
            const VerticalDivider(width: 1),
            // Editor Panel
            Expanded(
              flex: 3,
              child: _selectedSlide != null ? _buildEditorPanel() : _buildEmptyEditorPanel(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addNewSlide,
          backgroundColor: Theme.of(context).primaryColor,
          icon: const Icon(Icons.add),
          label: const Text('Add Slide'),
        ),
      ),
    );
  }

  Widget _buildSlideListPanel() {
    final slides = _currentPresentation?.slides ?? [];

    return Column(
      children: [
        // Presentation Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Presentation Title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _hasUnsavedChanges = true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (_) => _hasUnsavedChanges = true,
              ),
            ],
          ),
        ),
        // Slides List
        Expanded(
          child: slides.isEmpty
              ? _buildEmptySlidesState()
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: slides.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      _reorderSlides(oldIndex, newIndex);
                      _hasUnsavedChanges = true;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    final isSelected = _selectedSlide?.slideId == slide.slideId;
                    return _buildSlideListItem(slide, index, isSelected);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSlideListItem(SlideModel slide, int index, bool isSelected) {
    return Card(
      key: ValueKey(slide.slideId ?? index),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_handle, color: Colors.grey),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getSlideTypeColor(slide.slideType).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getSlideTypeIcon(slide.slideType),
                color: _getSlideTypeColor(slide.slideType),
              ),
            ),
          ],
        ),
        title: Text(
          slide.title ?? 'Slide ${index + 1}',
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          '${slide.slideType} • ${slide.layout} • ${slide.duration}s',
          style: TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _selectSlide(slide),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _deleteSlide(slide),
              tooltip: 'Delete',
            ),
          ],
        ),
        onTap: () => _selectSlide(slide),
      ),
    );
  }

  Widget _buildEmptySlidesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.slideshow, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No slides yet',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first slide to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewSlide,
            icon: const Icon(Icons.add),
            label: const Text('Add Slide'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEditorPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Select a slide to edit',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a slide from the list or create a new one',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorPanel() {
    if (_selectedSlide == null) return _buildEmptyEditorPanel();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slide Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Edit Slide',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedSlide = null),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 24),

          // Slide Type
          _buildSectionTitle('Slide Type'),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'text', label: Text('Text'), icon: Icon(Icons.text_fields)),
              ButtonSegment(value: 'image', label: Text('Image'), icon: Icon(Icons.image)),
              ButtonSegment(value: 'video', label: Text('Video'), icon: Icon(Icons.videocam)),
            ],
            selected: {_selectedSlide!.slideType},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedSlide = _selectedSlide!.copyWith(
                  slideType: newSelection.first,
                );
                _hasUnsavedChanges = true;
              });
            },
          ),
          const SizedBox(height: 24),

          // Title
          _buildSectionTitle('Title'),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: _selectedSlide!.title),
            decoration: const InputDecoration(
              hintText: 'Enter slide title',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _selectedSlide = _selectedSlide!.copyWith(title: value);
                _hasUnsavedChanges = true;
              });
            },
          ),
          const SizedBox(height: 16),

          // Subtitle
          _buildSectionTitle('Subtitle'),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: _selectedSlide!.subtitle),
            decoration: const InputDecoration(
              hintText: 'Enter slide subtitle',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _selectedSlide = _selectedSlide!.copyWith(subtitle: value);
                _hasUnsavedChanges = true;
              });
            },
          ),
          const SizedBox(height: 24),

          // Layout
          _buildSectionTitle('Layout'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['centered', 'top', 'bottom', 'left', 'right'].map((layout) {
              return ChoiceChip(
                label: Text(layout.toUpperCase()),
                selected: _selectedSlide!.layout == layout,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedSlide = _selectedSlide!.copyWith(layout: layout);
                      _hasUnsavedChanges = true;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Duration
          _buildSectionTitle('Duration (seconds)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _selectedSlide!.duration.toDouble(),
                  min: 2,
                  max: 10,
                  divisions: 8,
                  label: '${_selectedSlide!.duration}s',
                  onChanged: (value) {
                    setState(() {
                      _selectedSlide = _selectedSlide!.copyWith(duration: value.toInt());
                      _hasUnsavedChanges = true;
                    });
                  },
                ),
              ),
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_selectedSlide!.duration}s',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Overlay Opacity
          _buildSectionTitle('Overlay Opacity'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _selectedSlide!.overlayOpacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  label: '${(_selectedSlide!.overlayOpacity * 100).toStringAsFixed(0)}%',
                  onChanged: (value) {
                    setState(() {
                      _selectedSlide = _selectedSlide!.copyWith(overlayOpacity: value);
                      _hasUnsavedChanges = true;
                    });
                  },
                ),
              ),
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(_selectedSlide!.overlayOpacity * 100).toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Colors
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Text Color'),
                    const SizedBox(height: 8),
                    _buildColorPicker(
                      _selectedSlide!.textColor,
                      (color) {
                        setState(() {
                          _selectedSlide = _selectedSlide!.copyWith(textColor: color);
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Background Color'),
                    const SizedBox(height: 8),
                    _buildColorPicker(
                      _selectedSlide!.backgroundColor,
                      (color) {
                        setState(() {
                          _selectedSlide = _selectedSlide!.copyWith(backgroundColor: color);
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Media URL (for image/video)
          if (_selectedSlide!.slideType != 'text') ...[
            _buildSectionTitle('Media URL'),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: _selectedSlide!.mediaUrl),
              decoration: const InputDecoration(
                hintText: 'Enter media URL or upload file',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.upload_file),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedSlide = _selectedSlide!.copyWith(mediaUrl: value);
                  _hasUnsavedChanges = true;
                });
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _uploadMedia,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Upload Media'),
            ),
            const SizedBox(height: 24),
          ],

          // Preview
          _buildSectionTitle('Preview'),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: _parseColor(_selectedSlide!.backgroundColor),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_selectedSlide!.title != null && _selectedSlide!.title!.isNotEmpty)
                    Text(
                      _selectedSlide!.title!,
                      style: TextStyle(
                        color: _parseColor(_selectedSlide!.textColor),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (_selectedSlide!.subtitle != null && _selectedSlide!.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _selectedSlide!.subtitle!,
                      style: TextStyle(
                        color: _parseColor(_selectedSlide!.textColor),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_selectedSlide!.mediaUrl != null && _selectedSlide!.mediaUrl!.isNotEmpty)
                    Icon(
                      _selectedSlide!.slideType == 'image' ? Icons.image : Icons.videocam,
                      size: 48,
                      color: _parseColor(_selectedSlide!.textColor),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildColorPicker(String colorHex, Function(String) onColorChanged) {
    final color = _parseColor(colorHex);
    return InkWell(
      onTap: () async {
        final pickedColor = await ColorPickerDialog.show(
          context,
          initialColor: color,
          title: 'Select Color',
        );
        if (pickedColor != null) {
          onColorChanged(_colorToHex(pickedColor));
        }
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Center(
          child: Text(
            colorHex.toUpperCase(),
            style: TextStyle(
              color: _getContrastColor(color),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addNewSlide() async {
    final newSlide = SlideModel(
      slideOrder: (_currentPresentation?.slides.length ?? 0),
      slideType: 'text',
      title: 'New Slide',
      subtitle: 'Slide content',
    );

    if (_currentPresentation == null) {
      final agentId = await AgentService().getCurrentAgentId();
      if (agentId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to create presentation. Please ensure you are logged in as an agent.'),
            ),
          );
        }
        return;
      }
      setState(() {
        _currentPresentation = PresentationModel(
          agentId: agentId,
          name: _titleController.text.isNotEmpty ? _titleController.text : 'Untitled Presentation',
          description: _descriptionController.text,
          slides: [newSlide],
        );
        _selectedSlide = newSlide;
        _hasUnsavedChanges = true;
      });
    } else {
      setState(() {
        final slides = List<SlideModel>.from(_currentPresentation!.slides);
        slides.add(newSlide);
        _currentPresentation = _currentPresentation!.copyWith(slides: slides);
        _selectedSlide = newSlide;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _selectSlide(SlideModel slide) {
    setState(() {
      _selectedSlide = slide;
    });
  }

  void _deleteSlide(SlideModel slide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Slide'),
        content: const Text('Are you sure you want to delete this slide?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final slides = List<SlideModel>.from(_currentPresentation!.slides);
                slides.removeWhere((s) => s.slideId == slide.slideId);
                // Reorder slides
                for (int i = 0; i < slides.length; i++) {
                  slides[i] = slides[i].copyWith(slideOrder: i);
                }
                _currentPresentation = _currentPresentation!.copyWith(slides: slides);
                if (_selectedSlide?.slideId == slide.slideId) {
                  _selectedSlide = slides.isNotEmpty ? slides.first : null;
                }
                _hasUnsavedChanges = true;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _reorderSlides(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final slides = List<SlideModel>.from(_currentPresentation!.slides);
    final slide = slides.removeAt(oldIndex);
    slides.insert(newIndex, slide);
    // Update slide orders
    for (int i = 0; i < slides.length; i++) {
      slides[i] = slides[i].copyWith(slideOrder: i);
    }
    _currentPresentation = _currentPresentation!.copyWith(slides: slides);
  }

  Future<void> _saveDraft() async {
    if (_currentPresentation == null) {
      _createNewPresentation();
      return;
    }

    setState(() => _isSaving = true);
    final viewModel = Provider.of<PresentationViewModel>(context, listen: false);

    final success = await viewModel.updatePresentation(
      presentationId: _currentPresentation!.presentationId!,
      title: _titleController.text,
      description: _descriptionController.text,
      slides: _convertSlidesToPresentationSlides(_currentPresentation!.slides),
      status: 'draft',
    );

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Draft saved' : 'Failed to save draft'),
        ),
      );
      if (success) {
        _hasUnsavedChanges = false;
      }
    }
  }

  Future<void> _publishPresentation() async {
    if (_currentPresentation == null) {
      await _createNewPresentation();
    }

    if (_currentPresentation == null) return;

    setState(() => _isSaving = true);
    final viewModel = Provider.of<PresentationViewModel>(context, listen: false);

    final success = await viewModel.updatePresentation(
      presentationId: _currentPresentation!.presentationId!,
      title: _titleController.text,
      description: _descriptionController.text,
      slides: _convertSlidesToPresentationSlides(_currentPresentation!.slides),
      status: 'published',
    );

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Presentation published' : 'Failed to publish'),
        ),
      );
      if (success) {
        _hasUnsavedChanges = false;
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _createNewPresentation() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a presentation title')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final viewModel = Provider.of<PresentationViewModel>(context, listen: false);

    final agentId = await AgentService().getCurrentAgentId();
    if (agentId == null) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to create presentation. Please ensure you are logged in as an agent.'),
          ),
        );
      }
      return;
    }

    final created = await viewModel.createPresentation(
      agentId: agentId,
      title: _titleController.text,
      description: _descriptionController.text,
      slides: _currentPresentation != null
          ? _convertSlidesToPresentationSlides(_currentPresentation!.slides)
          : [],
    );

    setState(() => _isSaving = false);

    if (mounted) {
      if (created != null) {
        setState(() {
          _currentPresentation = created;
          _hasUnsavedChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Presentation created')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? 'Failed to create presentation')),
        );
      }
    }
  }

  Future<void> _uploadMedia() async {
    if (kIsWeb) {
      // Temporarily disable web file upload to avoid compilation issues
      // TODO: Re-enable web file upload with proper conditional imports
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Web file upload temporarily disabled'),
        ),
      );
      return;
    } else {
      // Mobile file picker using file_picker package
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'avi'],
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          if (file.bytes != null) {
            await _handleMediaUpload(file.name, file.bytes!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to read file. Please try again.'),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Mobile file upload failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File upload failed: $e'),
          ),
        );
      }
    }
  }


  Future<void> _handleMediaUpload(String fileName, Uint8List fileBytes) async {
    try {
      setState(() => _isSaving = true);
      final viewModel = Provider.of<PresentationViewModel>(context, listen: false);

      // Upload to backend
      final response = await viewModel.uploadMedia(fileName, fileBytes);
      
      if (response != null && response['media_url'] != null) {
        final mediaUrl = response['media_url'] as String;
        setState(() {
          if (_selectedSlide != null) {
            _selectedSlide = _selectedSlide!.copyWith(mediaUrl: mediaUrl);
            _hasUnsavedChanges = true;
          }
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Media uploaded successfully')),
          );
        }
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      LoggerService().error('Failed to upload media: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload media: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to save before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveDraft();
              if (mounted) Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  IconData _getSlideTypeIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      default:
        return Icons.text_fields;
    }
  }

  Color _getSlideTypeColor(String type) {
    switch (type) {
      case 'image':
        return Colors.blue;
      case 'video':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.black;
    }
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildSlidePreview(SlideModel slide) {
    return Container(
      decoration: BoxDecoration(
        color: _parseColor(slide.backgroundColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (slide.mediaUrl != null && slide.mediaUrl!.isNotEmpty) ...[
            if (slide.slideType == 'image')
              Image.network(
                slide.mediaUrl!,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image,
                  size: 48,
                  color: _parseColor(slide.textColor),
                ),
              )
            else
              Icon(
                Icons.videocam,
                size: 48,
                color: _parseColor(slide.textColor),
              ),
            const SizedBox(height: 12),
          ],
          if (slide.title != null && slide.title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                slide.title!,
                style: TextStyle(
                  color: _parseColor(slide.textColor),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (slide.subtitle != null && slide.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                slide.subtitle!,
                style: TextStyle(
                  color: _parseColor(slide.textColor),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullPreview() {
    if (_currentPresentation == null || _currentPresentation!.slides.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No slides to preview')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Presentation Preview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Carousel Preview
              Expanded(
                child: PageView.builder(
                  itemCount: _currentPresentation!.slides.length,
                  itemBuilder: (context, index) {
                    final slide = _currentPresentation!.slides[index];
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildSlidePreview(slide),
                    );
                  },
                ),
              ),
              // Indicators
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _currentPresentation!.slides.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PresentationSlide> _convertSlidesToPresentationSlides(List<SlideModel> slides) {
    return slides.map((slide) {
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
          if (slide.ctaButton != null) 'cta_button': slide.ctaButton,
          if (slide.agentBranding != null) 'agent_branding': slide.agentBranding,
        },
      );
    }).toList();
  }
}

