import 'package:flutter/material.dart';

/// ROI Score Card Widget
/// Displays the overall ROI score with grade, trend, and visual indicators
class ROIScoreCard extends StatelessWidget {
  final Map<String, dynamic> roiData;

  const ROIScoreCard({
    super.key,
    required this.roiData,
  });

  @override
  Widget build(BuildContext context) {
    final overallRoi = roiData['overall_roi'] ?? 0.0;
    final roiGrade = roiData['roi_grade'] ?? 'C';
    final roiTrend = roiData['roi_trend'] ?? 'stable';
    final roiChange = roiData['roi_change'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall ROI Score',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${overallRoi.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTrendColor(roiTrend).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getTrendColor(roiTrend),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTrendIcon(roiTrend),
                                color: _getTrendColor(roiTrend),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${roiChange > 0 ? '+' : ''}${roiChange.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: _getTrendColor(roiTrend),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getGradeIcon(roiGrade),
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (overallRoi / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grade: $roiGrade',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _getGradeDescription(roiGrade),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
        return Colors.green.shade300;
      case 'down':
        return Colors.red.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
        return Icons.trending_up;
      case 'down':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  IconData _getGradeIcon(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return Icons.grade;
      case 'B':
        return Icons.star;
      case 'C':
        return Icons.star_half;
      case 'D':
        return Icons.star_border;
      case 'F':
        return Icons.clear;
      default:
        return Icons.help_outline;
    }
  }

  String _getGradeDescription(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return 'Excellent Performance';
      case 'B':
        return 'Good Performance';
      case 'C':
        return 'Average Performance';
      case 'D':
        return 'Below Average';
      case 'F':
        return 'Needs Improvement';
      default:
        return 'Performance Grade';
    }
  }
}
