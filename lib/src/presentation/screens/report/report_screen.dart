import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../data/models/report_summary.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/verdict_badge.dart';

/// Report detail UI built from simulated data.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key, required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final result = summary.result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                VerdictBadge(verdict: result.verdict),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '${result.confidence.toStringAsFixed(1)}% confidence',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _section(
              context,
              title: 'Media metadata',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Title', result.mediaTitle),
                  _row('URL', result.mediaUrl),
                  _row('Type', summary.mediaType),
                  _row('Duration', summary.duration),
                  _row('Size', summary.size),
                  _row(
                    'Analyzed on',
                    DateFormat('MMM d, y • h:mm a').format(result.createdAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _section(
              context,
              title: 'Visual explanation',
                child: ClipRRect(
                    borderRadius: AppRadii.card,
                    child: SvgPicture.asset(
                      summary.heatmapAsset,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )),
            ),
            const SizedBox(height: AppSpacing.md),
            _section(
              context,
              title: 'Blockchain',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Status', 'Anchored'),
                  _row('Hash', result.blockchainHash),
                  _row(
                    'Timestamp',
                    DateFormat('MMM d, h:mm a').format(result.createdAt),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.card,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SvgPicture.asset(
                        summary.qrPlaceholderAsset,
                        height: 140,
                        width: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Download report',
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Download will be implemented later'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context,
      {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardOverlay,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
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
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
