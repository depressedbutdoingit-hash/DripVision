import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import '../models/scene.dart';
import '../models/user_profile.dart';
import '../services/openrouter_service.dart';
import '../services/drip_engine_service.dart';
import '../services/media_action_service.dart';
import '../services/whisper_service.dart';
import '../services/audio_generation_service.dart';
import '../services/lip_sync_service.dart';
import '../services/purchase_service.dart';
import '../services/generation_guard.dart';
import '../services/prompt_enhancer_service.dart';
import '../services/video_stitching_service.dart';
import '../services/watermark_export_service.dart';
import '../services/ai_queue_service.dart';

// Services
final openRouterProvider = Provider((ref) => OpenRouterService());
final dripEngineProvider = Provider((ref) => DripEngineService());
final mediaActionProvider = Provider((ref) => MediaActionService());
final whisperProvider = Provider((ref) => WhisperService());
final audioGenProvider = Provider((ref) => AudioGenerationService());
final lipSyncProvider = Provider((ref) => LipSyncService());
final purchaseServiceProvider = Provider((ref) => PurchaseService());
final generationGuardProvider = Provider((ref) => GenerationGuard());
final promptEnhancerProvider = Provider((ref) => PromptEnhancerService());
final videoStitchProvider = Provider((ref) => VideoStitchingService());
final aiQueueProvider = Provider((ref) => AIQueueService());

// State
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
  return UserProfileNotifier();
});

final sceneListProvider = StateNotifierProvider<SceneListNotifier, List<SceneNode>>((ref) {
  return SceneListNotifier();
});

final activeCharacterProvider = StateProvider<Character?>((ref) => null);
final generationProgressProvider = StateProvider<double>((ref) => 0.0);
final isGeneratingProvider = StateProvider<bool>((ref) => false);

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  UserProfileNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await PurchaseService.fetchUserProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();

  Future<void> deductTokens(int cost) async {
    state.whenData((profile) async {
      final newBalance = profile.tokenBalance - cost;
      await PurchaseService.updateTokenBalance(newBalance);
      state = AsyncValue.data(profile.copyWith(tokenBalance: newBalance));
    });
  }
}

class SceneListNotifier extends StateNotifier<List<SceneNode>> {
  SceneListNotifier() : super([]);

  void addScene(SceneNode scene) => state = [...state, scene];
  void removeScene(String id) => state = state.where((s) => s.id != id).toList();
  void updateScene(SceneNode updated) {
    state = state.map((s) => s.id == updated.id ? updated : s).toList();
  }

  void clear() => state = [];
}
