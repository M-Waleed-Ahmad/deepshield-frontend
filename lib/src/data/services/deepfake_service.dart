import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/environment.dart';
import '../models/analysis_result.dart';
import '../models/deepfake_request.dart';
import '../models/media_item.dart';
import 'history_service.dart';

/// Calls backend deepfake APIs and maps responses into AnalysisResult.
class DeepfakeService {
  DeepfakeService({required this.historyService});

  final HistoryService historyService;

  static const _detector = 'ucf';

  Future<AnalysisResult> analyze(DeepfakeRequest request) async {
    final baseUrl = _resolveBaseUrl(Environment.aiServiceUrl);
    final trimmedBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final isVideo = request.mediaType.toLowerCase() == 'video';
    final path = isVideo ? '/deepfake/video' : '/deepfake/image';
    final uri = Uri.parse('$trimmedBase$path');

    final file = File(request.filePath);
    if (!file.existsSync()) {
      throw Exception('Selected file not found at ${request.filePath}');
    }

    final multipartRequest = http.MultipartRequest('POST', uri)
      ..fields['detector'] = _detector
      ..files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

    final streamed = await multipartRequest.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 400) {
      throw Exception(
          'Analysis failed (${response.statusCode}): ${response.reasonPhrase}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final mediaItem = MediaItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: request.mediaTitle,
      url: request.filePath,
      type: request.mediaType,
      thumbnailAsset: 'assets/images/logo.png',
    );
    final result = _mapToAnalysisResult(
      data: data,
      media: mediaItem,
      detector: _detector,
    );

    historyService.addResult(result);
    return result;
  }

  AnalysisResult _mapToAnalysisResult({
    required Map<String, dynamic> data,
    required MediaItem media,
    required String detector,
  }) {
    // Image/video response: prob_fake, prob_real, label.
    final label = (data['label'] as String? ?? '').toLowerCase();
    double confidence;
    double? probFake;
    double? probReal;

    probFake = (data['prob_fake'] as num?)?.toDouble();
    probReal = (data['prob_real'] as num?)?.toDouble();
    confidence =
        (([probFake ?? 0, probReal ?? 0].reduce((a, b) => a > b ? a : b)) *
                100)
            .clamp(0, 100)
            .toDouble();

    final verdict = _labelToVerdict(label);
    final explanation = _buildExplanation(
      label: label,
      detector: detector,
      confidence: confidence,
      media: media,
    );

    return AnalysisResult(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      mediaTitle: media.title,
      mediaUrl: media.url,
      confidence: confidence,
      verdict: verdict,
      createdAt: DateTime.now(),
      blockchainHash: _fakeHash(),
      explanation: explanation,
      mediaItem: media,
      detector: data['detector'] as String? ?? detector,
      probFake: probFake,
      probReal: probReal,
      rawLabel: data['label'] as String?,
    );
  }

  String _resolveBaseUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final isLocalHost = uri.host == 'localhost' || uri.host == '127.0.0.1';
      if (isLocalHost && Platform.isAndroid) {
        // Android emulator cannot reach host "localhost"; use 10.0.2.2 instead.
        return uri.replace(host: '10.0.2.2').toString();
      }
      return url;
    } catch (_) {
      return url;
    }
  }

  Verdict _labelToVerdict(String label) {
    if (label.contains('fake')) return Verdict.suspected;
    if (label.contains('real')) return Verdict.authentic;
    return Verdict.inconclusive;
  }

  String _buildExplanation({
    required String label,
    required String detector,
    required double confidence,
    required MediaItem media,
  }) {
    return 'Detector $detector flagged this ${media.type} as "$label" '
        'with ${confidence.toStringAsFixed(1)}% confidence.';
  }

  String _fakeHash() {
    const chars = 'abcdef0123456789';
    final rand = DateTime.now().microsecondsSinceEpoch;
    return List.generate(
      64,
      (index) => chars[(rand + index) % chars.length],
    ).join();
  }
}
