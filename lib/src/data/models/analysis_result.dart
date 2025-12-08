import 'package:flutter/material.dart';

import 'media_item.dart';

/// Simulated analysis result model for the DeepShield MVP.
enum Verdict { authentic, suspected, inconclusive }

class AnalysisResult {
  AnalysisResult({
    required this.id,
    required this.mediaTitle,
    required this.mediaUrl,
    required this.confidence,
    required this.verdict,
    required this.createdAt,
    required this.blockchainHash,
    required this.explanation,
    required this.mediaItem,
  });

  final String id;
  final String mediaTitle;
  final String mediaUrl;
  final double confidence;
  final Verdict verdict;
  final DateTime createdAt;
  final String blockchainHash;
  final String explanation;
  final MediaItem mediaItem;

  String get verdictLabel {
    switch (verdict) {
      case Verdict.authentic:
        return 'Authentic';
      case Verdict.suspected:
        return 'Suspected Manipulation';
      case Verdict.inconclusive:
        return 'Inconclusive';
    }
  }

  Color get verdictColor {
    switch (verdict) {
      case Verdict.authentic:
        return Colors.greenAccent;
      case Verdict.suspected:
        return Colors.redAccent;
      case Verdict.inconclusive:
        return Colors.amberAccent;
    }
  }
}
