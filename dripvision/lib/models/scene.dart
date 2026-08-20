import 'character.dart';

class SceneNode {
  final String id;
  final int sequenceIndex;
  final String prompt;
  final String enhancedPrompt;
  final Character character;
  final String? inputLastFrameUrl;
  final String? outputVideoUrl;
  final String? generatedLastFrameUrl;
  final String? cameraMotion;
  final DateTime createdAt;

  SceneNode({
    required this.id,
    required this.sequenceIndex,
    required this.prompt,
    required this.enhancedPrompt,
    required this.character,
    this.inputLastFrameUrl,
    this.outputVideoUrl,
    this.generatedLastFrameUrl,
    this.cameraMotion,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
