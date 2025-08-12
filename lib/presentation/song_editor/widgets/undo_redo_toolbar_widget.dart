import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UndoRedoToolbarWidget extends StatelessWidget {
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const UndoRedoToolbarWidget({
    Key? key,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: canUndo ? onUndo : null,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: canUndo
                    ? AppTheme.accent.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: canUndo
                      ? AppTheme.accent.withValues(alpha: 0.5)
                      : AppTheme.inactive.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'undo',
                    color: canUndo ? AppTheme.accent : AppTheme.inactive,
                    size: 18,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Undo',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: canUndo ? AppTheme.accent : AppTheme.inactive,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 2.w),
          InkWell(
            onTap: canRedo ? onRedo : null,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: canRedo
                    ? AppTheme.accent.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: canRedo
                      ? AppTheme.accent.withValues(alpha: 0.5)
                      : AppTheme.inactive.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'redo',
                    color: canRedo ? AppTheme.accent : AppTheme.inactive,
                    size: 18,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Redo',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: canRedo ? AppTheme.accent : AppTheme.inactive,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.inactive,
                  size: 12,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Shake to undo',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.inactive,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
