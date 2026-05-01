import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../data/models/analysis_result.dart';
import '../../../data/models/report_summary.dart';
import '../../../routes/app_router.dart';
import '../../widgets/primary_button.dart';

/// Displays deepfake analysis result with actions.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});

  final AnalysisResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // state for expanded history items will be kept in a set of IDs
  final Set<String> _expandedHistoryItems = {};

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 12),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVerdictHeader(context, result),
              const SizedBox(height: AppSpacing.lg),
              _buildMainCard(context, result),
              const SizedBox(height: AppSpacing.lg),
              
              if (result.type == 'video') ...[
                _buildVideoAnalysis(context, result),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              _buildForensicHistory(context, result),
              const SizedBox(height: AppSpacing.lg),

              PrimaryButton(
                label: 'View full PDF report',
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                onPressed: () {
                  final summary = ReportSummary(
                    result: result,
                    mediaType: result.mediaItem.type,
                    duration: '00:20',
                    size: '2.4 MB',
                    qrPlaceholderAsset: 'assets/vectors/qr_placeholder.svg',
                    heatmapAsset: '',
                  );
                  Navigator.pushNamed(context, AppRoutes.report, arguments: summary);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: 'Verify on blockchain',
                icon: const Icon(Icons.verified_outlined, color: Colors.white),
                onPressed: () => _showBlockchainSheet(context, result),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: 'Analyze another media',
                icon: const Icon(Icons.replay_outlined, color: Colors.white),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildMetadataSection(context, result),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerdictHeader(BuildContext context, AnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                result.prediction,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: result.verdictColor,
                    ),
                maxLines: 2,
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: result.confidence),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Text(
                  '${(value * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Band classification: ${result.band}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: result.confidence),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.border,
                color: result.verdictColor,
                minHeight: 8,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context, AnalysisResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardOverlay,
        borderRadius: AppRadii.card,
        boxShadow: const [AppShadows.soft],
        border: Border.all(color: AppColors.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.filename,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadii.card,
            child: Container(
              height: 200,
              width: double.infinity,
              color: AppColors.border.withOpacity(0.2),
              child: _buildHeatmapImage(result.heatmapUrl),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (result.details != null && result.details!['model'] == 'ucf_and_xception') ...[
            Text(
              'Ensemble Fusion Weights',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Builder(
              builder: (context) {
                final fusion = result.details!['fusion_weights'] as Map<String, dynamic>?;
                if (fusion == null) return const SizedBox.shrink();
                final ucfW = (fusion['ucf'] as num?)?.toDouble() ?? 0.8;
                final xcepW = (fusion['xception'] as num?)?.toDouble() ?? 0.2;
                return Text(
                  'UCF weight: ${(ucfW * 100).toInt()}%  |  Xception weight: ${(xcepW * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(
            result.explanation,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoAnalysis(BuildContext context, AnalysisResult result) {
    if (result.details == null) return const SizedBox.shrink();

    final frameCount = result.details!['frame_count'];
    final xception = result.details!['xception_metrics'] as Map<String, dynamic>?;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.videocam_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Video Analysis Tracker', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (frameCount != null)
            _metaRow('Analyzed frames', '$frameCount evaluated'),
          if (xception != null) ...[
            _metaRow('Mean frame confidence', '${((xception['mean'] as num?)?.toDouble() ?? 0.0) * 100.0}%'),
            _metaRow('Max frame confidence', '${((xception['max'] as num?)?.toDouble() ?? 0.0) * 100.0}%'),
          ]
        ],
      ),
    );
  }

  Widget _buildForensicHistory(BuildContext context, AnalysisResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: result.isDuplicate ? AppColors.surface : AppColors.cardOverlay,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Forensic History', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          
          if (!result.isDuplicate && result.priorAnalyses.length <= 1)
            Text(
              'First submission — no prior history for this file.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠️ This file has been submitted before.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            ..._buildHistoryList(result),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildHistoryList(AnalysisResult result) {
    final list = result.priorAnalyses.where((e) => e.id != result.id).toList();
    if (list.isEmpty) return [];

    final formatter = DateFormat('MMM d, y, h:mm a');

    return list.map((item) {
      final isExpanded = _expandedHistoryItems.contains(item.id);
      
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.cardOverlay,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.subtle),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedHistoryItems.remove(item.id);
              } else {
                _expandedHistoryItems.add(item.id);
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.prediction,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(item.confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatter.format(item.createdAt),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 16),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      color: AppColors.border.withOpacity(0.2),
                      child: _buildHeatmapImage(item.heatmapUrl),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildHeatmapImage(String? url) {
    if (url == null || url.isEmpty) {
      return const Center(
        child: Text(
          'Heatmap unavailable',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Text(
          'Heatmap unavailable',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context, AnalysisResult result) {
    final formatter = DateFormat('MMM d, y • h:mm a');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Metadata', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _metaRow('Analyzed on', formatter.format(result.createdAt)),
          _metaRow('Media type', result.type),
          _metaRow('Blockchain hash', '${result.blockchainHash.substring(0, 16)}...'),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockchainSheet(BuildContext context, AnalysisResult result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Blockchain Verification',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _metaRow('Status', 'Anchored'),
              _metaRow('Hash', result.blockchainHash),
              _metaRow('Timestamp', DateFormat('MMM d, h:mm a').format(result.createdAt)),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: 'Close',
                onPressed: () => Navigator.pop(context),
                fullWidth: true,
              )
            ],
          ),
        );
      },
    );
  }
}

