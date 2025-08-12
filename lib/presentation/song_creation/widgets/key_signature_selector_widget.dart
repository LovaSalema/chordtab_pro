import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class KeySignatureSelectorWidget extends StatelessWidget {
  final String selectedKey;
  final Function(String) onKeySelected;

  const KeySignatureSelectorWidget({
    Key? key,
    required this.selectedKey,
    required this.onKeySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Signature',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          InkWell(
            onTap: () => _showKeySignatureBottomSheet(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedKey.isEmpty ? 'Select key signature' : selectedKey,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: selectedKey.isEmpty
                          ? AppTheme.inactive
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontSize: 16.sp,
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showKeySignatureBottomSheet(BuildContext context) {
    final List<Map<String, dynamic>> keySignatures = [
      {'key': 'C Major', 'notation': '♮'},
      {'key': 'G Major', 'notation': '♯'},
      {'key': 'D Major', 'notation': '♯♯'},
      {'key': 'A Major', 'notation': '♯♯♯'},
      {'key': 'E Major', 'notation': '♯♯♯♯'},
      {'key': 'B Major', 'notation': '♯♯♯♯♯'},
      {'key': 'F♯ Major', 'notation': '♯♯♯♯♯♯'},
      {'key': 'F Major', 'notation': '♭'},
      {'key': 'B♭ Major', 'notation': '♭♭'},
      {'key': 'E♭ Major', 'notation': '♭♭♭'},
      {'key': 'A♭ Major', 'notation': '♭♭♭♭'},
      {'key': 'D♭ Major', 'notation': '♭♭♭♭♭'},
      {'key': 'G♭ Major', 'notation': '♭♭♭♭♭♭'},
      {'key': 'A Minor', 'notation': '♮'},
      {'key': 'E Minor', 'notation': '♯'},
      {'key': 'B Minor', 'notation': '♯♯'},
      {'key': 'F♯ Minor', 'notation': '♯♯♯'},
      {'key': 'C♯ Minor', 'notation': '♯♯♯♯'},
      {'key': 'G♯ Minor', 'notation': '♯♯♯♯♯'},
      {'key': 'D♯ Minor', 'notation': '♯♯♯♯♯♯'},
      {'key': 'D Minor', 'notation': '♭'},
      {'key': 'G Minor', 'notation': '♭♭'},
      {'key': 'C Minor', 'notation': '♭♭♭'},
      {'key': 'F Minor', 'notation': '♭♭♭♭'},
      {'key': 'B♭ Minor', 'notation': '♭♭♭♭♭'},
      {'key': 'E♭ Minor', 'notation': '♭♭♭♭♭♭'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.inactive,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Text(
                'Select Key Signature',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: keySignatures.length,
                itemBuilder: (context, index) {
                  final keyData = keySignatures[index];
                  final isSelected = selectedKey == keyData['key'];

                  return ListTile(
                    title: Text(
                      keyData['key'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppTheme.accent
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    trailing: Text(
                      keyData['notation'] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontSize: 18.sp,
                        color: isSelected ? AppTheme.accent : AppTheme.inactive,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: AppTheme.accent.withValues(alpha: 0.1),
                    onTap: () {
                      onKeySelected(keyData['key'] as String);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
