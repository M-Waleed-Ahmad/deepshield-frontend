import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../logic/utils/service_locator.dart';
import '../../../routes/app_router.dart';
import '../../widgets/analysis_card.dart';

/// Displays simulated analysis history.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = ServiceLocator.historyService.getHistory();
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: history.isEmpty
            ? Center(
                child: Text(
                  'No analyses yet.\nRun an analysis to see it here.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.separated(
                itemBuilder: (context, index) {
                  final item = history[index];
                  return AnalysisCard(
                    result: item,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.result,
                      arguments: item,
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemCount: history.length,
              ),
      ),
    );
  }
}
