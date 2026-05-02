import 'package:flutter/material.dart';

import 'media_item.dart';

enum Verdict { authentic, suspected, inconclusive }

class PriorAnalysis {
  PriorAnalysis({
    required this.id,
    required this.prediction,
    required this.confidence,
    required this.band,
    required this.createdAt,
    this.heatmapUrl,
  });

  final String id;
  final String prediction;
  final double confidence;
  final String band;
  final DateTime createdAt;
  final String? heatmapUrl;

  factory PriorAnalysis.fromJson(Map<String, dynamic> json) {
    return PriorAnalysis(
      id: json['id']?.toString() ?? '',
      prediction: json['prediction'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      band: json['band'] as String? ?? 'Unknown',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      heatmapUrl: json['heatmap_url'] as String?,
    );
  }
}

class AnalysisResult {
  AnalysisResult({
    required this.id,
    required this.prediction,
    required this.confidence,
    required this.band,
    required this.type,
    required this.createdAt,
    required this.mediaItem,
    required this.processingTimeSeconds,
    required this.filename,
    required this.isDuplicate,
    required this.priorAnalyses,
    this.heatmapUrl,
    this.thresholds,
    this.details,
    this.reportUrl,
    this.blockchainStatus,
    this.polygonUrl,
    this.blockchainTxHash,
    // Keep old fields to prevent compilation errors temporarily
    this.mediaTitle = '',
    this.mediaUrl = '',
    this.blockchainHash = '',
    this.explanation = '',
  });

  final String id;
  final String prediction;
  final double
  confidence; // e.g. 0.812 means 81.2% or could be just used directly. We will assume 0.812 from backend -> 81.2% in UI
  final String band;
  final String type;
  final String? heatmapUrl;
  final Map<String, dynamic>? thresholds;
  final Map<String, dynamic>? details;
  final String? reportUrl;
  final String? blockchainStatus;
  final String? polygonUrl;
  final String? blockchainTxHash;
  final double processingTimeSeconds;
  final String filename;
  final bool isDuplicate;
  final List<PriorAnalysis> priorAnalyses;
  final DateTime createdAt;
  final MediaItem mediaItem;

  // Legacy fields (optional / defaults)
  final String mediaTitle;
  final String mediaUrl;
  final String blockchainHash;
  final String explanation;

  Verdict get verdict {
    final lower = prediction.toLowerCase();
    if (lower.contains('manipulated') || lower.contains('ai-generated')) {
      return Verdict.suspected;
    }
    if (lower.contains('authentic')) {
      return Verdict.authentic;
    }
    return Verdict.inconclusive;
  }

  String get verdictLabel => prediction;

  Color get verdictColor {
    final b = band.toLowerCase();
    if (b.contains('real')) return Colors.greenAccent;
    if (b.contains('unsure')) return Colors.yellowAccent;
    if (b.contains('likely fake')) return Colors.orangeAccent;
    if (b.contains('strong fake')) return Colors.redAccent;
    return Colors.amberAccent; // default fallback
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json, MediaItem media) {
    var analysesList = <PriorAnalysis>[];
    if (json['prior_analyses'] != null) {
      final list = json['prior_analyses'] as List;
      analysesList = list.map((e) => PriorAnalysis.fromJson(e)).toList();
    }

    return AnalysisResult(
      id: json['id']?.toString() ?? '',
      prediction: json['prediction'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      band: json['band'] as String? ?? 'Unknown',
      type:
          json['type'] as String? ??
          json['media_type'] as String? ??
          media.type,
      heatmapUrl: json['heatmap_url'] as String?,
      thresholds: json['thresholds'] as Map<String, dynamic>?,
      details: json['details'] as Map<String, dynamic>?,
      reportUrl: json['report_url'] as String? ?? json['pdf_url'] as String?,
      blockchainStatus: json['blockchain_status'] as String?,
      polygonUrl: json['polygon_url'] as String?,
      blockchainTxHash: json['blockchain_tx_hash'] as String?,
      processingTimeSeconds:
          (json['processing_time_seconds'] as num?)?.toDouble() ?? 0.0,
      filename: json['filename'] as String? ?? media.title,
      isDuplicate: json['is_duplicate'] as bool? ?? false,
      priorAnalyses: analysesList,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      mediaItem: media,
      mediaTitle: media.title,
      mediaUrl: media.url,
      blockchainHash: json['blockchain_tx_hash'] as String? ?? _fakeHash(),
      explanation:
          'Analysis processed in ${(json['processing_time_seconds'] as num?)?.toDouble() ?? 0.0} seconds.',
    );
  }

  static String _fakeHash() {
    const chars = 'abcdef0123456789';
    final rand = DateTime.now().microsecondsSinceEpoch;
    return List.generate(
      64,
      (index) => chars[(rand + index) % chars.length],
    ).join();
  }
}
