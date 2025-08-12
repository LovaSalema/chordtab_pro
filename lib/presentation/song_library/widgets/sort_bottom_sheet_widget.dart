import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SortBottomSheetWidget extends StatelessWidget {
  final String currentSortOption;
  final ValueChanged<String> onSortOptionSelected;

  const SortBottomSheetWidget({
    Key? key,
    required this.currentSortOption,
    required this.onSortOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.bottomSheetTheme.backgroundColor,
        borderRadius: (AppTheme.lightTheme.bottomSheetTheme.shape as RoundedRectangleBorder?)?.borderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Sort Songs',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildSortOption(
            context,
            'Alphabetical (A-Z)',
            'alphabetical',
            'sort_by_alpha',
          ),
          _buildSortOption(
            context,
            'Date Created',
            'date_created',
            'calendar_today',
          ),
          _buildSortOption(
            context,
            'Date Modified',
            'date_modified',
            'update',
          ),
          _buildSortOption(
            context,
            'Tempo (BPM)',
            'tempo',
            'speed',
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    String value,
    String iconName,
  ) {
    final bool isSelected = currentSortOption == value;

    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: isSelected
            ? AppTheme.lightTheme.colorScheme.secondary
            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.secondary
              : AppTheme.lightTheme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? CustomIconWidget(
              iconName: 'check',
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 20,
            )
          : null,
      onTap: () {
        onSortOptionSelected(value);
        Navigator.pop(context);
      },
    );
  }
}