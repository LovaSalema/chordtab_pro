import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BottomToolbarWidget extends StatelessWidget {
  final VoidCallback onTransposeUp;
  final VoidCallback onTransposeDown;
  final VoidCallback onShare;
  final VoidCallback onPlayback;
  final bool isPlaying;

  const BottomToolbarWidget({
    Key? key,
    required this.onTransposeUp,
    required this.onTransposeDown,
    required this.onShare,
    required this.onPlayback,
    this.isPlaying = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToolbarButton(
              context,
              icon: 'remove',
              label: 'Transpose -',
              onPressed: onTransposeDown,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            _buildToolbarButton(
              context,
              icon: 'add',
              label: 'Transpose +',
              onPressed: onTransposeUp,
              color: AppTheme.lightTheme.colorScheme.tertiary,
            ),
            _buildToolbarButton(
              context,
              icon: isPlaying ? 'pause' : 'play_arrow',
              label: isPlaying ? 'Pause' : 'Play',
              onPressed: onPlayback,
              color: AppTheme.lightTheme.colorScheme.secondary,
            ),
            _buildToolbarButton(
              context,
              icon: 'share',
              label: 'Share',
              onPressed: onShare,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: CustomIconWidget(
            iconName: icon,
            color: color,
            size: 24,
          ),
          style: IconButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(3.w),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
