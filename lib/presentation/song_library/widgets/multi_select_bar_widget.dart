import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MultiSelectBarWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onSelectAll;
  final VoidCallback onDeleteSelected;
  final VoidCallback onExportSelected;
  final bool isAllSelected;

  const MultiSelectBarWidget({
    Key? key,
    required this.selectedCount,
    required this.onCancel,
    required this.onSelectAll,
    required this.onDeleteSelected,
    required this.onExportSelected,
    required this.isAllSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.secondaryContainer,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onCancel,
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSecondaryContainer,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              '$selectedCount selected',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onSelectAll,
            child: Text(
              isAllSelected ? 'Deselect All' : 'Select All',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          IconButton(
            onPressed: selectedCount > 0 ? onExportSelected : null,
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: selectedCount > 0
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.5),
              size: 24,
            ),
          ),
          IconButton(
            onPressed: selectedCount > 0 ? onDeleteSelected : null,
            icon: CustomIconWidget(
              iconName: 'delete',
              color: selectedCount > 0
                  ? AppTheme.error
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.5),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
