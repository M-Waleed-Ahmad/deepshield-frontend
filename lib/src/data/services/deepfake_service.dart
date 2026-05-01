import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/environment.dart';
import '../../../providers/auth_provider.dart';
import '../models/analysis_result.dart';
import '../models/deepfake_request.dart';
import '../models/media_item.dart';
import '../models/health_status.dart';
import 'history_service.dart';

/// Calls backend deepfake APIs and maps responses into AnalysisResult.
class DeepfakeService {
  DeepfakeService({required this.historyService, required this.authProvider});

  final HistoryService historyService;
  final AuthProvider authProvider;

  Future<HealthStatus> checkHealth() async {
    final baseUrl = _resolveBaseUrl(Environment.aiServiceUrl);
    final trimmedBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$trimmedBase/health');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return HealthStatus.fromJson(data);
      }
      throw Exception('Unhealthy status code: ${response.statusCode}');
    } catch (e) {
      throw Exception('Backend unreachable');
    }
  }

  Future<AnalysisResult> analyze(DeepfakeRequest request) async {
    final baseUrl = _resolveBaseUrl(Environment.aiServiceUrl);
    final trimmedBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$trimmedBase/analyze');

    final file = File(request.filePath);
    if (!file.existsSync()) {
      throw Exception('Selected file not found at ${request.filePath}');
    }

    final multipartRequest = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final token = authProvider.token;
    if (token != null && token.isNotEmpty) {
      multipartRequest.headers['Authorization'] = 'Bearer $token';
    }

    try {
      final streamed = await multipartRequest.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 400) {
        throw Exception(
          'This file could not be analyzed. Accepted formats: JPG, PNG, WEBP, MP4, MOV, AVI.',
        );
      }
      if (response.statusCode == 413) {
        throw Exception(
          'File exceeds the 50MB limit. Please upload a smaller file.',
        );
      }
      if (response.statusCode == 401) {
        throw const UnauthorizedException();
      }
      if (response.statusCode != 200) {
        throw Exception(
          'Analysis failed. Please try again. Raw: ${response.reasonPhrase}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final mediaItem = MediaItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: request.mediaTitle,
        url: request.filePath,
        type: request.mediaType,
        thumbnailAsset: 'assets/images/logo.png',
      );

      final result = AnalysisResult.fromJson(data, mediaItem);
      historyService.addResult(result);
      return result;
    } on TimeoutException {
      throw Exception(
        'Connection to the analysis server timed out. Please check your network and try again.',
      );
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('This file could not be analyzed') ||
          e.toString().contains('exceeds the 50MB limit') ||
          e.toString().contains(
            'Connection to the analysis server timed out',
          ) ||
          e.toString().contains('Analysis failed. Please try again.')) {
        rethrow;
      }
      throw Exception('Analysis failed. Please try again.');
    }
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
}

class UnauthorizedException implements Exception {
  const UnauthorizedException();

  @override
  String toString() => 'Unauthorized';
}
