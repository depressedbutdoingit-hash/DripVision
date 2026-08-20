import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../models/character.dart';
import '../../services/push_notification_service.dart';
import '../widgets/camera_joystick.dart';
import '../widgets/drip_swapper.dart';
import '../widgets/media_picker_button.dart';
import '../widgets/video_action_bar.dart';

class DripVisionStudioScreen extends ConsumerStatefulWidget {
  const DripVisionStudioScreen({super.key});

  @override
  ConsumerState<DripVisionStudioScreen> createState() => _DripVisionStudioScreenState();
}

class _DripVisionStudioScreenState extends ConsumerState<DripVisionStudioScreen> {
  final _promptController = TextEditingController();
  String _selectedCameraMotion = 'static';
  bool _isRecording = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    final character = ref.read(activeCharacterProvider);
    if (character == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a character first')),
      );
      return;
    }

    final guard = ref.read(generationGuardProvider);
    final hasTokens = await guard.deductAndValidateTokens(costInTokens: 10);
    if (!hasTokens) {
      _showPaywall();
      return;
    }

    ref.read(isGeneratingProvider.notifier).state = true;
    ref.read(generationProgressProvider.notifier).state = 0;

    try {
      final enhanced = await ref.read(promptEnhancerProvider).enhancePrompt(
            prompt,
            character.defaultStylePrompt,
          );

      final previousScene = ref.read(sceneListProvider).lastOrNull;

      final scene = await ref.read(dripEngineProvider).generateNextScene(
            previousScene: previousScene,
            rawPrompt: prompt,
            enhancedPrompt: enhanced,
            character: character,
            cameraMotion: _selectedCameraMotion,
            onProgress: (p) => ref.read(generationProgressProvider.notifier).state = p,
          );

      ref.read(sceneListProvider.notifier).addScene(scene);
      await PushNotificationService.showAlert(
        title: 'Drip Complete',
        body: 'Scene ${scene.sequenceIndex + 1} is ready',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      ref.read(isGeneratingProvider.notifier).state = false;
    }
  }

  void _showPaywall() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DripTheme.surface,
        title: const Text(
          'Out of Tokens',
          style: TextStyle(
            color: DripTheme.nebulaCyan,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Upgrade to Starter or Pro for more tokens, or grab a top-up pack.',
          style: TextStyle(color: DripTheme.chrome),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DripTheme.cosmicTeal,
              foregroundColor: DripTheme.voidBlack,
            ),
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('View Plans', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _recordVoicePrompt() async {
    final whisper = ref.read(whisperProvider);
    if (!await whisper.hasPermission()) return;

    if (_isRecording) {
      final path = await whisper.stopRecording();
      setState(() => _isRecording = false);
      if (path != null) {
        final text = await whisper.transcribe(path);
        _promptController.text = text;
      }
    } else {
      await whisper.startRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGenerating = ref.watch(isGeneratingProvider);
    final progress = ref.watch(generationProgressProvider);
    final scenes = ref.watch(sceneListProvider);
    final character = ref.watch(activeCharacterProvider);
    final lastScene = scenes.lastOrNull;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'DRIPVISION',
          style: TextStyle(
            color: DripTheme.nebulaCyan,
            fontWeight: FontWeight.black,
            letterSpacing: 3,
            fontSize: 18,
            shadows: [
              Shadow(
                color: DripTheme.cosmicTeal,
                blurRadius: 15,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.checkroom, color: DripTheme.cosmicTeal),
            onPressed: () => _showCharacterCloset(context, character),
          ),
          IconButton(
            icon: const Icon(Icons.movie_filter_outlined, color: DripTheme.chrome),
            onPressed: scenes.length > 1 ? _stitchMasterCut : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DripTheme.surface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: DripTheme.cosmicTeal.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: DripTheme.cosmicTeal.withOpacity(0.1),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: lastScene?.outputVideoUrl != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            color: Colors.black,
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: DripTheme.cosmicTeal,
                                size: 64,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: VideoActionBar(
                                videoUrl: lastScene!.outputVideoUrl!,
                                prompt: lastScene.prompt,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.movie_creation_outlined,
                              color: Colors.white24,
                              size: 64,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Tap bolt to generate',
                              style: TextStyle(color: Colors.white30, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          if (isGenerating)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation(DripTheme.cosmicTeal),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: CameraMotionJoystick(
              initialSelection: _selectedCameraMotion,
              onMotionSelected: (m) => _selectedCameraMotion = m,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                MediaPickerButton(
                  label: 'Ref',
                  onMediaSelected: (file) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Image added: ${file.path.split('/').last}'),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: "3-word scene action...",
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: DripTheme.surfaceLight.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isRecording ? Icons.mic : Icons.mic_none,
                          color: _isRecording ? DripTheme.cosmicTeal : Colors.white30,
                        ),
                        onPressed: _recordVoicePrompt,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  backgroundColor: DripTheme.cosmicTeal,
                  elevation: 0,
                  onPressed: isGenerating ? null : _generate,
                  child: isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: DripTheme.voidBlack,
                          ),
                        )
                      : const Icon(Icons.bolt, color: DripTheme.voidBlack, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showCharacterCloset(BuildContext context, Character? character) {
    if (character == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DripSwapperView(
        character: character,
        onOutfitSelected: (outfit) {
          ref.read(activeCharacterProvider.notifier).state =
              character.copyWith(activeOutfitId: outfit.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _stitchMasterCut() async {
    final scenes = ref.read(sceneListProvider);
    final paths = scenes.map((s) => s.outputVideoUrl!).whereType<String>().toList();
    if (paths.length < 2) return;

    ref.read(isGeneratingProvider.notifier).state = true;
    try {
      final masterPath = await ref.read(videoStitchProvider).concatenateScenes(paths);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Master cut saved: $masterPath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stitch failed: $e')),
      );
    } finally {
      ref.read(isGeneratingProvider.notifier).state = false;
    }
  }
}
