import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FontSizeSelectorWidget extends StatelessWidget {
  final String selectedFontSize;
  final Function(String) onFontSizeChanged;

  const FontSizeSelectorWidget({
    Key? key,
    required this.selectedFontSize,
    required this.onFontSizeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFontSizeOption(
          context,
          'Small',
          'small',
          12.0,
          'Compact chord notation',
        ),
        SizedBox(height: 1.h),
        _buildFontSizeOption(
          context,
          'Medium',
          'medium',
          14.0,
          'Standard chord notation',
        ),
        SizedBox(height: 1.h),
        _buildFontSizeOption(
          context,
          'Large',
          'large',
          16.0,
          'Easy-to-read chord notation',
        ),
      ],
    );
  }

  Widget _buildFontSizeOption(
    BuildContext context,
    String title,
    String value,
    double fontSize,
    String description,
  ) {
    final isSelected = selectedFontSize == value;

    return InkWell(
      onTap: () => onFontSizeChanged(value),
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
                        'Cmaj7',
                        style: AppTheme.getMonospaceStyle(
                          isLight:
                              Theme.of(context).brightness == Brightness.light,
                          fontSize: fontSize,
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
