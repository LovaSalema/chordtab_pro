import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChordCellWidget extends StatelessWidget {
  final String chord;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ChordCellWidget({
    Key? key,
    required this.chord,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accent.withValues(alpha: 0.2)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.accent
                : _isValidChord(chord)
                    ? AppTheme.lightTheme.colorScheme.outline
                    : AppTheme.error,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelectionMode && isSelected)
              Container(
                margin: EdgeInsets.only(right: 2.w),
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.accent,
                  size: 16,
                ),
              ),
            Text(
              chord,
              style: AppTheme.getMonospaceStyle(
                isLight: true,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ).copyWith(
                color: _isValidChord(chord)
                    ? (isSelected
                        ? AppTheme.accent
                        : AppTheme.lightTheme.colorScheme.primary)
                    : AppTheme.error,
              ),
            ),
            if (!_isValidChord(chord))
              Container(
                margin: EdgeInsets.only(left: 1.w),
                child: CustomIconWidget(
                  iconName: 'error',
                  color: AppTheme.error,
                  size: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isValidChord(String chord) {
    if (chord.isEmpty) return false;

    // Basic chord validation - can be expanded
    final chordPattern = RegExp(
        r'^[A-G][#b]?(maj7?|min7?|m7?|7|dim|aug|sus[24]?|add[29]|[+°])?(/[A-G][#b]?)?$');
    final romanPattern = RegExp(r'^[ivxIVX]+[°+]?[67]?$');

    return chordPattern.hasMatch(chord) ||
        romanPattern.hasMatch(chord) ||
        chord == 'N.C.' || // No chord
        chord == '%' || // Repeat previous chord
        chord == 'X'; // Stop/rest
  }
}
