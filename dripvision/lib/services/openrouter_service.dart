import 'package:dio/dio.dart';
import '../core/env.dart';

class OpenRouterService {
  late final Dio _dio;

  OpenRouterService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://openrouter.ai/api/v1/',
      headers: {
        'Authorization': 'Bearer ${Env.openRouterKey}',
        'HTTP-Referer': 'https://dripvision.app',
        'X-Title': 'DripVision',
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<String> enhancePrompt({
    required String prompt,
    required String modelSlug,
  }) async {
    final response = await _dio.post(
      'chat/completions',
      data: {
        'model': modelSlug,
        'messages': [
          {
            'role': 'system',
            'content': 'Rewrite into cinematic camera motion, lighting, and composition. Keep under 200 words.'
          },
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
      },
    );
    return response.data['choices'][0]['message']['content'] as String;
  }
}
