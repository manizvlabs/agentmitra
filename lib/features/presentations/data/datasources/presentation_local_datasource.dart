import 'package:hive/hive.dart';
import '../models/presentation_model.dart';

abstract class PresentationLocalDataSource {
  Future<void> cacheActivePresentation(String agentId, PresentationModel presentation);
  Future<PresentationModel?> getCachedActivePresentation(String agentId);
  Future<void> cachePresentations(String agentId, List<PresentationModel> presentations);
  Future<List<PresentationModel>?> getCachedPresentations(String agentId);
  Future<void> clearCache(String agentId);
  Future<void> clearAllCache();
}

class PresentationLocalDataSourceImpl implements PresentationLocalDataSource {
  static const String _presentationsBoxName = 'presentations';

  late Box<Map> _presentationsBox;

  Future<void> init() async {
    _presentationsBox = await Hive.openBox<Map>(_presentationsBoxName);
  }

  @override
  Future<void> cacheActivePresentation(String agentId, PresentationModel presentation) async {
    final key = 'active_$agentId';
    await _presentationsBox.put(key, presentation.toJson());
  }

  @override
  Future<PresentationModel?> getCachedActivePresentation(String agentId) async {
    final key = 'active_$agentId';
    final cached = _presentationsBox.get(key);
    if (cached != null) {
      try {
        return PresentationModel.fromJson(Map<String, dynamic>.from(cached));
      } catch (e) {
        // If parsing fails, remove corrupted data
        await _presentationsBox.delete(key);
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> cachePresentations(String agentId, List<PresentationModel> presentations) async {
    final key = 'list_$agentId';
    final presentationsJson = presentations.map((p) => p.toJson()).toList();
    await _presentationsBox.put(key, {'presentations': presentationsJson});
  }

  @override
  Future<List<PresentationModel>?> getCachedPresentations(String agentId) async {
    final key = 'list_$agentId';
    final cached = _presentationsBox.get(key);
    if (cached != null && cached['presentations'] != null) {
      try {
        final presentationsJson = List<Map<String, dynamic>>.from(cached['presentations']);
        return presentationsJson.map((json) => PresentationModel.fromJson(json)).toList();
      } catch (e) {
        // If parsing fails, remove corrupted data
        await _presentationsBox.delete(key);
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearCache(String agentId) async {
    final activeKey = 'active_$agentId';
    final listKey = 'list_$agentId';
    await _presentationsBox.delete(activeKey);
    await _presentationsBox.delete(listKey);
  }

  @override
  Future<void> clearAllCache() async {
    await _presentationsBox.clear();
  }
}
