/// Presentation ViewModel
import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../data/repositories/presentation_repository.dart';
import '../../data/models/presentation_model.dart';
import '../../data/models/presentation_models.dart';
import '../../data/models/slide_model.dart';

class PresentationViewModel extends BaseViewModel {
  final PresentationRepository _presentationRepository;

  PresentationViewModel({
    PresentationRepository? presentationRepository,
  }) : _presentationRepository =
            presentationRepository ?? PresentationRepository();

  PresentationModel? _activePresentation;
  List<PresentationModel> _presentations = [];
  int _totalPresentations = 0;

  PresentationModel? get activePresentation => _activePresentation;
  List<PresentationModel> get presentations => _presentations;
  int get totalPresentations => _totalPresentations;

  /// Convert Presentation to PresentationModel
  PresentationModel _presentationToModel(Presentation presentation) {
    return PresentationModel(
      presentationId: presentation.presentationId,
      agentId: presentation.agentId,
      name: presentation.title,
      description: presentation.description,
      status: presentation.status,
      isActive: presentation.status == 'active',
      slides: presentation.slides.map((slide) => SlideModel(
        slideOrder: 0, // Default order
        slideType: slide.type ?? 'text',
        title: slide.title,
        subtitle: slide.content,
        mediaUrl: slide.imageUrl ?? slide.videoUrl,
        layout: slide.layout ?? 'centered',
      )).toList(),
      createdAt: presentation.createdAt,
      updatedAt: presentation.updatedAt,
    );
  }

  @override
  Future<void> initialize() async {
    await super.initialize();
    // Initialize can be called when needed
  }

  /// Load active presentation for an agent with offline caching
  Future<void> loadActivePresentation(String agentId) async {
    setLoading(true);
    clearError();

    try {
      final presentation = await _presentationRepository.getActivePresentation(agentId);
      _activePresentation = presentation != null ? _presentationToModel(presentation) : null;
    } catch (e) {
      setError(e.toString());
    }

    setLoading(false);
  }

  /// Refresh active presentation
  Future<void> refreshActivePresentation(String agentId) async {
    await loadActivePresentation(agentId);
  }

  /// Load all presentations for an agent
  Future<void> loadAgentPresentations(String agentId) async {
    setLoading(true);
    clearError();

    try {
      final presentations = await _presentationRepository.getAgentPresentations(agentId);
      _presentations = presentations.map((p) => _presentationToModel(p)).toList();
      _totalPresentations = presentations.length;
    } catch (e) {
      setError('Failed to load presentations: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Create a new presentation
  Future<PresentationModel?> createPresentation({
    required String agentId,
    required String title,
    String? description,
    List<PresentationSlide>? slides,
  }) async {
    setLoading(true);
    clearError();

    try {
      final created = await _presentationRepository.createPresentation(
        agentId: agentId,
        title: title,
        description: description,
        slides: slides,
      );
      final model = _presentationToModel(created);
      _presentations.add(model);
      return model;
    } catch (e) {
      setError('Failed to create presentation: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Update an existing presentation
  Future<bool> updatePresentation({
    required String presentationId,
    String? title,
    String? description,
    List<PresentationSlide>? slides,
    String? status,
  }) async {
    setLoading(true);
    clearError();

    try {
      final updated = await _presentationRepository.updatePresentation(
        presentationId: presentationId,
        title: title,
        description: description,
        slides: slides,
        status: status,
      );

      final model = _presentationToModel(updated);
      final index = _presentations.indexWhere(
        (p) => p.presentationId == presentationId,
      );
      if (index != -1) {
        _presentations[index] = model;
      }

      if (_activePresentation?.presentationId == presentationId) {
        _activePresentation = model;
      }

      return true;
    } catch (e) {
      setError('Failed to update presentation: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
}

