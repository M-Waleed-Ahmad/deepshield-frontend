import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/media_item.dart';
import '../../../logic/utils/service_locator.dart';
import '../../../routes/app_router.dart';

/// Animated analysis status screen using simulated analysis service.
class AnalysisProgressScreen extends StatefulWidget {
  const AnalysisProgressScreen({super.key, required this.media});

  final MediaItem media;

  @override
  State<AnalysisProgressScreen> createState() => _AnalysisProgressScreenState();
}

class _AnalysisProgressScreenState extends State<AnalysisProgressScreen> {
  bool uploadingDone = false;
  bool aiDone = false;
  bool reportDone = false;
  bool chainDone = false;

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => uploadingDone = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => aiDone = true);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => reportDone = true);

    final result =
        await ServiceLocator.fakeAnalysisService.analyzeMedia(widget.media);
    setState(() => chainDone = true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.result,
      arguments: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Analysis'),
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, _) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [AppColors.primary, AppColors.secondary, AppColors.primary],
                      ),
                    ),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.surface,
                        child: Icon(Icons.shield_rounded, size: 40, color: AppColors.primary),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Analyzing Content',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Please wait while we verify authenticity...',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: chainDone
                    ? 1
                    : reportDone
                        ? 0.8
                        : aiDone
                            ? 0.6
                            : uploadingDone
                                ? 0.3
                                : 0.1,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView(
                children: [
                  _stepTile(
                    icon: Icons.upload_rounded,
                    label: 'Uploading',
                    done: uploadingDone,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _stepTile(
                    icon: Icons.psychology_alt_outlined,
                    label: 'AI Analysis',
                    done: aiDone,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _stepTile(
                    icon: Icons.description_outlined,
                    label: 'Generating Report',
                    done: reportDone,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _stepTile(
                    icon: Icons.shield_outlined,
                    label: 'Blockchain Anchoring',
                    done: chainDone,
                    inProgress: !chainDone,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Do not close this window. Analysis may take up a few minutes.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepTile({
    required IconData icon,
    required String label,
    required bool done,
    bool inProgress = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: done ? Colors.green : AppColors.primary,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (done)
            const Icon(Icons.check_circle, color: Colors.greenAccent)
          else if (inProgress)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}
