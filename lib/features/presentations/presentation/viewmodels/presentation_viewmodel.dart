/// Presentation ViewModel
import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../data/repositories/presentation_repository.dart';
import '../../data/models/presentation_model.dart';

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

  @override
  Future<void> initialize() async {
    // Initialize can be called when needed
  }

  /// Load active presentation for an agent
  Future<void> loadActivePresentation(String agentId) async {
    setLoading(true);
    clearError();

    try {
      _activePresentation =
          await _presentationRepository.getActivePresentation(agentId);
    } catch (e) {
      setError('Failed to load active presentation: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Load all presentations for an agent
  Future<void> loadAgentPresentations(
    String agentId, {
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    setLoading(true);
    clearError();

    try {
      final result = await _presentationRepository.getAgentPresentations(
        agentId,
        status: status,
        limit: limit,
        offset: offset,
      );

      _presentations = (result['presentations'] as List<dynamic>)
          .map((p) => PresentationModel.fromJson(p as Map<String, dynamic>))
          .toList();
      _totalPresentations = result['total'] ?? 0;
    } catch (e) {
      setError('Failed to load presentations: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Create a new presentation
  Future<PresentationModel?> createPresentation(
    String agentId,
    PresentationModel presentation,
  ) async {
    setLoading(true);
    clearError();

    try {
      final created = await _presentationRepository.createPresentation(
        agentId,
        presentation,
      );
      _presentations.add(created);
      return created;
    } catch (e) {
      setError('Failed to create presentation: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Update an existing presentation
  Future<bool> updatePresentation(
    String agentId,
    String presentationId,
    PresentationModel presentation,
  ) async {
    setLoading(true);
    clearError();

    try {
      final updated = await _presentationRepository.updatePresentation(
        agentId,
        presentationId,
        presentation,
      );

      final index = _presentations.indexWhere(
        (p) => p.presentationId == presentationId,
      );
      if (index != -1) {
        _presentations[index] = updated;
      }

      if (_activePresentation?.presentationId == presentationId) {
        _activePresentation = updated;
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

