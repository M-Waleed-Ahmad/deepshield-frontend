import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/analysis_result.dart';
import '../../../data/models/report_summary.dart';
import '../../../routes/app_router.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/verdict_badge.dart';

/// Displays simulated analysis result with actions.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final AnalysisResult result;

  @override
  Widget build(BuildContext context) {
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
              Row(
                children: [
                  VerdictBadge(verdict: result.verdict),
                  const Spacer(),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: result.confidence),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return Text(
                        '${value.toStringAsFixed(0)}% confidence',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
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
                      result.mediaTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.mediaUrl,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ClipRRect(
                      borderRadius: AppRadii.card,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        color: AppColors.surface,
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ClipRRect(
                      borderRadius: AppRadii.card,
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        color: AppColors.border.withOpacity(0.2),
                        child: SvgPicture.asset(
                          'assets/vectors/heatmap_placeholder.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      result.explanation,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
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
                    heatmapAsset: 'assets/vectors/heatmap_placeholder.svg',
                  );
                  Navigator.pushNamed(context, AppRoutes.report, arguments: summary);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: 'Verify on blockchain',
                icon: const Icon(Icons.verified_outlined, color: Colors.white),
                onPressed: () => _showBlockchainSheet(context),
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
              _metadataSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metadataSection(BuildContext context) {
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
          _metaRow('Media type', result.mediaItem.type),
          _metaRow('Blockchain hash', result.blockchainHash.substring(0, 16) + '...'),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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

  void _showBlockchainSheet(BuildContext context) {
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
              _metaRow('Timestamp',
                  DateFormat('MMM d, h:mm a').format(result.createdAt)),
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
