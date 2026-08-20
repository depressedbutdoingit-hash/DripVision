import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';

class VideoStitchingService {
  Future<String> concatenateScenes(List<String> videoPaths) async {
    if (videoPaths.isEmpty) throw ArgumentError('No videos to stitch');
    if (videoPaths.length == 1) return videoPaths.first;

    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/master_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final concatFile = File('${tempDir.path}/concat_${DateTime.now().millisecondsSinceEpoch}.txt');

    final lines = videoPaths.map((p) => "file '${p.replaceAll("'", "'\''")}'").join('
');
    await concatFile.writeAsString(lines);

    final command = "-f concat -safe 0 -i "${concatFile.path}" -c copy -movflags +faststart "$outputPath"";
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (await concatFile.exists()) await concatFile.delete();

    if (returnCode?.isValueSuccess() ?? false) return outputPath;
    final logs = await session.getLogs();
    throw Exception('Stitch failed: ${logs.map((l) => l.getMessage()).join()}');
  }

  Future<String> mixAudio({
    required String videoPath,
    required String audioPath,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/mixed_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final command = "-i "$videoPath" -i "$audioPath" -c:v copy -c:a aac -shortest "$outputPath"";
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (returnCode?.isValueSuccess() ?? false) return outputPath;
    throw Exception('Audio mix failed');
  }
}
