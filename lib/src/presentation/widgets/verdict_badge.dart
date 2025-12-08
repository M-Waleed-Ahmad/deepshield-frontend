import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../data/models/analysis_result.dart';

class VerdictBadge extends StatelessWidget {
  const VerdictBadge({super.key, required this.verdict, this.compact = false});

  final Verdict verdict;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = switch (verdict) {
      Verdict.authentic => 'Authentic',
      Verdict.suspected => 'Suspected Manipulation',
      Verdict.inconclusive => 'Inconclusive',
    };

    final color = switch (verdict) {
      Verdict.authentic => Colors.greenAccent,
      Verdict.suspected => Colors.redAccent,
      Verdict.inconclusive => Colors.amberAccent,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_moon_outlined, color: color, size: compact ? 16 : 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 12 : 14,
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
