import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SongStructureBuilderWidget extends StatefulWidget {
  final List<Map<String, dynamic>> sections;
  final Function(List<Map<String, dynamic>>) onSectionsChanged;

  const SongStructureBuilderWidget({
    Key? key,
    required this.sections,
    required this.onSectionsChanged,
  }) : super(key: key);

  @override
  State<SongStructureBuilderWidget> createState() =>
      _SongStructureBuilderWidgetState();
}

class _SongStructureBuilderWidgetState
    extends State<SongStructureBuilderWidget> {
  final List<String> availableSections = [
    'A',
    'B',
    'C',
    'Verse',
    'Chorus',
    'Bridge',
    'Intro',
    'Outro'
  ];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Song Structure',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: _showAddSectionDialog,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'add',
                        color: AppTheme.lightTheme.colorScheme.surface,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Add',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          widget.sections.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.5),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'library_music',
                        color: AppTheme.inactive,
                        size: 32,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'No sections added yet',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.inactive,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Tap "Add" to create your first section',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.inactive,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.sections.length,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    final section = widget.sections[index];
                    return _buildSectionCard(section, index);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(Map<String, dynamic> section, int index) {
    return Card(
      key: ValueKey(section['id']),
      margin: EdgeInsets.only(bottom: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: EdgeInsets.all(3.w),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.accent,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  section['name'] as String,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['name'] as String,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    section['chords'] != null &&
                            (section['chords'] as String).isNotEmpty
                        ? section['chords'] as String
                        : 'No chords added',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: section['chords'] != null &&
                              (section['chords'] as String).isNotEmpty
                          ? AppTheme.lightTheme.colorScheme.onSurface
                          : AppTheme.inactive,
                      fontSize: 12.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _editSection(index),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    child: CustomIconWidget(
                      iconName: 'edit',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 1.w),
                InkWell(
                  onTap: () => _removeSection(index),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    child: CustomIconWidget(
                      iconName: 'delete',
                      color: AppTheme.error,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 1.w),
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
    );
  }

  void _showAddSectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Section',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableSections.length,
            itemBuilder: (context, index) {
              final sectionName = availableSections[index];
              return ListTile(
                title: Text(
                  sectionName,
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                onTap: () {
                  _addSection(sectionName);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
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
        ],
      ),
    );
  }

  void _addSection(String name) {
    final newSection = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'chords': '',
      'timeSignature': '4/4',
    };

    final updatedSections = List<Map<String, dynamic>>.from(widget.sections)
      ..add(newSection);
    widget.onSectionsChanged(updatedSections);
  }

  void _editSection(int index) {
    // Navigate to chord input for this section
    Navigator.pushNamed(
      context,
      '/song-editor',
      arguments: {
        'section': widget.sections[index],
        'sectionIndex': index,
      },
    );
  }

  void _removeSection(int index) {
    final updatedSections = List<Map<String, dynamic>>.from(widget.sections)
      ..removeAt(index);
    widget.onSectionsChanged(updatedSections);
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final updatedSections = List<Map<String, dynamic>>.from(widget.sections);
    final item = updatedSections.removeAt(oldIndex);
    updatedSections.insert(newIndex, item);

    widget.onSectionsChanged(updatedSections);
  }
}
