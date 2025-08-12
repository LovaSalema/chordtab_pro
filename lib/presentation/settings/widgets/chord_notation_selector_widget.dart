import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChordNotationSelectorWidget extends StatelessWidget {
  final String selectedNotation;
  final Function(String) onNotationChanged;

  const ChordNotationSelectorWidget({
    Key? key,
    required this.selectedNotation,
    required this.onNotationChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildNotationOption(
          context,
          'Roman Numerals',
          'roman',
          'I - vi - ii - V',
          'Classical music theory notation',
        ),
        SizedBox(height: 1.h),
        _buildNotationOption(
          context,
          'Nashville Numbers',
          'nashville',
          '1 - 6m - 2m - 5',
          'Popular music notation system',
        ),
      ],
    );
  }

  Widget _buildNotationOption(
    BuildContext context,
    String title,
    String value,
    String example,
    String description,
  ) {
    final isSelected = selectedNotation == value;

    return InkWell(
      onTap: () => onNotationChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.1)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getTextColor(context),
                            ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        example,
                        style: AppTheme.getMonospaceStyle(
                          isLight:
                              Theme.of(context).brightness == Brightness.light,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.getTextColor(context,
                              isHighEmphasis: false),
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
