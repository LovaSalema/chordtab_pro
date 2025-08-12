import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ChordChartWidget extends StatelessWidget {
  final Map<String, dynamic> songData;
  final double zoomLevel;
  final bool isLandscape;
  final Function(String) onChordTap;

  const ChordChartWidget({
    Key? key,
    required this.songData,
    required this.zoomLevel,
    required this.isLandscape,
    required this.onChordTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sections = (songData['sections'] as List?) ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections
            .map<Widget>((section) => _buildSection(context, section))
            .toList(),
      ),
    );
  }

  Widget _buildSection(BuildContext context, Map<String, dynamic> section) {
    final sectionName = section['name'] as String? ?? 'Untitled';
    final measures = (section['measures'] as List?) ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, sectionName),
          SizedBox(height: 1.h),
          _buildMeasures(context, measures),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String sectionName) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        sectionName,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontSize: (14 * zoomLevel).sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.lightTheme.colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildMeasures(BuildContext context, List measures) {
    if (isLandscape) {
      return _buildLandscapeMeasures(context, measures);
    } else {
      return _buildPortraitMeasures(context, measures);
    }
  }

  Widget _buildPortraitMeasures(BuildContext context, List measures) {
    return Column(
      children: measures.map<Widget>((measure) {
        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          child: _buildMeasureRow(context, measure),
        );
      }).toList(),
    );
  }

  Widget _buildLandscapeMeasures(BuildContext context, List measures) {
    List<Widget> rows = [];
    for (int i = 0; i < measures.length; i += 2) {
      List<Widget> rowMeasures = [];
      rowMeasures.add(Expanded(child: _buildMeasureRow(context, measures[i])));

      if (i + 1 < measures.length) {
        rowMeasures.add(SizedBox(width: 2.w));
        rowMeasures
            .add(Expanded(child: _buildMeasureRow(context, measures[i + 1])));
      } else {
        rowMeasures.add(Expanded(child: Container()));
      }

      rows.add(
        Container(
          margin: EdgeInsets.only(bottom: 2.h),
          child: Row(children: rowMeasures),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildMeasureRow(BuildContext context, Map<String, dynamic> measure) {
    final chords = (measure['chords'] as List?) ?? [];
    final measureNumber = measure['number'] as int? ?? 1;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Text(
              'M$measureNumber',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                fontSize: (10 * zoomLevel).sp,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(2.w),
            child: Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: chords
                  .map<Widget>((chord) => _buildChord(context, chord))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChord(BuildContext context, Map<String, dynamic> chord) {
    final chordSymbol = chord['symbol'] as String? ?? '';
    final extension = chord['extension'] as String? ?? '';
    final duration = chord['duration'] as String? ?? '';

    return GestureDetector(
      onTap: () => onChordTap(chordSymbol),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                text: chordSymbol,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontSize: (16 * zoomLevel).sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                children: extension.isNotEmpty
                    ? [
                        TextSpan(
                          text: extension,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontSize: (10 * zoomLevel).sp,
                            fontWeight: FontWeight.w400,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ]
                    : null,
              ),
            ),
            if (duration.isNotEmpty) ...[
              SizedBox(height: 0.5.h),
              Text(
                duration,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  fontSize: (8 * zoomLevel).sp,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
