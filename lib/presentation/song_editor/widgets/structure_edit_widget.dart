import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StructureEditWidget extends StatefulWidget {
  final List<Map<String, dynamic>> sections;
  final Function(List<Map<String, dynamic>>) onSectionsChanged;

  const StructureEditWidget({
    Key? key,
    required this.sections,
    required this.onSectionsChanged,
  }) : super(key: key);

  @override
  State<StructureEditWidget> createState() => _StructureEditWidgetState();
}

class _StructureEditWidgetState extends State<StructureEditWidget> {
  final List<String> availableSections = [
    'A',
    'B',
    'C',
    'D',
    'Verse',
    'Chorus',
    'Bridge',
    'Intro',
    'Outro',
    'Solo'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(4.w),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accent.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'reorder',
                color: AppTheme.accent,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Structure',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Drag to reorder, tap to edit, long press for options',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.sections.isEmpty
              ? _buildEmptyState()
              : _buildSectionsList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'library_music',
            color: AppTheme.inactive,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No sections in this song',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.inactive,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add sections to start building the structure',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.inactive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsList() {
    return ReorderableListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: widget.sections.length,
      onReorder: _onReorder,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(animation.value);
            final elevation = lerpDouble(0, 6, t) ?? 0;
            return Material(
              elevation: elevation,
              borderRadius: BorderRadius.circular(12),
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final section = widget.sections[index];
        return _buildSectionCard(section, index);
      },
    );
  }

  Widget _buildSectionCard(Map<String, dynamic> section, int index) {
    return Card(
      key: ValueKey(section['id']),
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _editSection(index),
        onLongPress: () => _showSectionOptions(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              Container(
                width: 15.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    section['name'],
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            section['name'],
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            section['timeSignature'] ?? '4/4',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      section['chords'] != null && section['chords'].isNotEmpty
                          ? section['chords']
                          : 'No chords added',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: section['chords'] != null &&
                                section['chords'].isNotEmpty
                            ? AppTheme.lightTheme.colorScheme.onSurface
                            : AppTheme.inactive,
                        fontSize: 12.sp,
                        fontFamily: 'JetBrainsMono',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _duplicateSection(index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      child: CustomIconWidget(
                        iconName: 'content_copy',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  InkWell(
                    onTap: () => _removeSection(index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      child: CustomIconWidget(
                        iconName: 'delete',
                        color: AppTheme.error,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  CustomIconWidget(
                    iconName: 'drag_handle',
                    color: AppTheme.inactive,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editSection(int index) {
    // Navigate to chord editing or show inline editing
    // For now, we'll show a simple dialog
    _showEditSectionDialog(index);
  }

  void _showEditSectionDialog(int index) {
    final section = widget.sections[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${section['name']}'),
        content: Text('Chord editing will be available in the Chords tab'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSectionOptions(int index) {
    HapticFeedback.mediumImpact();
    final section = widget.sections[index];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.inactive,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '${section['name']} Options',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Edit Section',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _editSection(index);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Duplicate Section',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _duplicateSection(index);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.error,
                size: 24,
              ),
              title: Text(
                'Delete Section',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteSection(index);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _duplicateSection(int index) {
    final section = widget.sections[index];
    final duplicatedSection = {
      ...section,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': '${section['name']} (Copy)',
    };

    final updatedSections = List<Map<String, dynamic>>.from(widget.sections);
    updatedSections.insert(index + 1, duplicatedSection);
    widget.onSectionsChanged(updatedSections);

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Section duplicated'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDeleteSection(int index) {
    final section = widget.sections[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Section'),
        content: Text('Are you sure you want to delete "${section['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.inactive,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeSection(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: Text(
              'Delete',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeSection(int index) {
    final updatedSections = List<Map<String, dynamic>>.from(widget.sections);
    updatedSections.removeAt(index);
    widget.onSectionsChanged(updatedSections);

    HapticFeedback.lightImpact();
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final updatedSections = List<Map<String, dynamic>>.from(widget.sections);
    final item = updatedSections.removeAt(oldIndex);
    updatedSections.insert(newIndex, item);

    widget.onSectionsChanged(updatedSections);
    HapticFeedback.selectionClick();
  }
}

double? lerpDouble(num a, num b, double t) {
  return a + (b - a) * t;
}
