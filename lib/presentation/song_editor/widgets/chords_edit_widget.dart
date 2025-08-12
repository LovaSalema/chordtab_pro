import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './chord_cell_widget.dart';
import './chord_edit_modal_widget.dart';

class ChordsEditWidget extends StatefulWidget {
  final List<Map<String, dynamic>> sections;
  final Function(List<Map<String, dynamic>>) onSectionsChanged;

  const ChordsEditWidget({
    Key? key,
    required this.sections,
    required this.onSectionsChanged,
  }) : super(key: key);

  @override
  State<ChordsEditWidget> createState() => _ChordsEditWidgetState();
}

class _ChordsEditWidgetState extends State<ChordsEditWidget> {
  Set<String> selectedChordIds = {};
  String? copiedChordData;
  bool isSelectionMode = false;

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
                iconName: 'music_note',
                color: AppTheme.accent,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Chords',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Tap to edit, long press to select multiple chords',
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
        if (isSelectionMode) _buildSelectionToolbar(),
        Expanded(
          child:
              widget.sections.isEmpty ? _buildEmptyState() : _buildChordsList(),
        ),
      ],
    );
  }

  Widget _buildSelectionToolbar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.accent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            '${selectedChordIds.length} selected',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          InkWell(
            onTap: _copySelectedChords,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: EdgeInsets.all(1.w),
              child: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.accent,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          if (copiedChordData != null) ...[
            InkWell(
              onTap: _pasteChords,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: EdgeInsets.all(1.w),
                child: CustomIconWidget(
                  iconName: 'content_paste',
                  color: AppTheme.accent,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 2.w),
          ],
          InkWell(
            onTap: _deleteSelectedChords,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: EdgeInsets.all(1.w),
              child: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.error,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          InkWell(
            onTap: _transposeSelectedChords,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: EdgeInsets.all(1.w),
              child: CustomIconWidget(
                iconName: 'swap_vert',
                color: AppTheme.accent,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          InkWell(
            onTap: _exitSelectionMode,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: EdgeInsets.all(1.w),
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.inactive,
                size: 20,
              ),
            ),
          ),
        ],
      ),
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
            iconName: 'music_note',
            color: AppTheme.inactive,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No chord sections available',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.inactive,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add sections in the Structure tab to start editing chords',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.inactive,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChordsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: widget.sections.length,
      itemBuilder: (context, index) {
        final section = widget.sections[index];
        return _buildSectionChords(section, index);
      },
    );
  }

  Widget _buildSectionChords(Map<String, dynamic> section, int sectionIndex) {
    final chords = section['chords'] as String? ?? '';
    final chordList = chords.isEmpty
        ? []
        : chords
            .split(' - ')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.accent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      section['name'],
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    section['name'],
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _addChordToSection(sectionIndex),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppTheme.accent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'add',
                          color: AppTheme.accent,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Add',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          chordList.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.7),
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
                        iconName: 'music_note',
                        color: AppTheme.inactive,
                        size: 24,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'No chords in this section',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.inactive,
                        ),
                      ),
                      Text(
                        'Tap "Add" to create chords',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.inactive,
                        ),
                      ),
                    ],
                  ),
                )
              : Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: chordList.asMap().entries.map((entry) {
                    final chordIndex = entry.key;
                    final chord = entry.value;
                    final chordId = '${section['id']}_$chordIndex';

                    return ChordCellWidget(
                      chord: chord,
                      isSelected: selectedChordIds.contains(chordId),
                      isSelectionMode: isSelectionMode,
                      onTap: () =>
                          _handleChordTap(sectionIndex, chordIndex, chordId),
                      onLongPress: () => _handleChordLongPress(chordId),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  void _handleChordTap(int sectionIndex, int chordIndex, String chordId) {
    if (isSelectionMode) {
      setState(() {
        if (selectedChordIds.contains(chordId)) {
          selectedChordIds.remove(chordId);
          if (selectedChordIds.isEmpty) {
            isSelectionMode = false;
          }
        } else {
          selectedChordIds.add(chordId);
        }
      });
    } else {
      _editChord(sectionIndex, chordIndex);
    }
  }

  void _handleChordLongPress(String chordId) {
    HapticFeedback.mediumImpact();
    setState(() {
      isSelectionMode = true;
      selectedChordIds.add(chordId);
    });
  }

  void _editChord(int sectionIndex, int chordIndex) {
    final section = widget.sections[sectionIndex];
    final chords = section['chords'] as String? ?? '';
    final chordList = chords
        .split(' - ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (chordIndex < chordList.length) {
      final currentChord = chordList[chordIndex];

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ChordEditModalWidget(
          initialChord: currentChord,
          onSave: (newChord) {
            _updateChord(sectionIndex, chordIndex, newChord);
          },
        ),
      );
    }
  }

  void _updateChord(int sectionIndex, int chordIndex, String newChord) {
    final updatedSections = List<Map<String, dynamic>>.from(widget.sections);
    final section = updatedSections[sectionIndex];
    final chords = section['chords'] as String? ?? '';
    final chordList = chords
        .split(' - ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (chordIndex < chordList.length) {
      chordList[chordIndex] = newChord;
      section['chords'] = chordList.join(' - ');
      widget.onSectionsChanged(updatedSections);
    }
  }

  void _addChordToSection(int sectionIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChordEditModalWidget(
        initialChord: '',
        onSave: (newChord) {
          _insertChord(sectionIndex, newChord);
        },
      ),
    );
  }

  void _insertChord(int sectionIndex, String newChord) {
    final updatedSections = List<Map<String, dynamic>>.from(widget.sections);
    final section = updatedSections[sectionIndex];
    final chords = section['chords'] as String? ?? '';
    final chordList = chords.isEmpty
        ? <String>[]
        : chords
            .split(' - ')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    chordList.add(newChord);
    section['chords'] = chordList.join(' - ');
    widget.onSectionsChanged(updatedSections);
  }

  void _copySelectedChords() {
    // Implementation for copying selected chords
    HapticFeedback.lightImpact();
    copiedChordData = selectedChordIds.join(',');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedChordIds.length} chords copied'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _pasteChords() {
    // Implementation for pasting chords
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chords pasted'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteSelectedChords() {
    HapticFeedback.mediumImpact();
    // Implementation for deleting selected chords
    setState(() {
      selectedChordIds.clear();
      isSelectionMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected chords deleted'),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _transposeSelectedChords() {
    _showTransposeDialog();
  }

  void _showTransposeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transpose Chords'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select transposition amount:'),
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: [-5, -4, -3, -2, -1, 1, 2, 3, 4, 5].map((semitones) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _performTranspose(semitones);
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.accent),
                    ),
                    child: Text(
                      '${semitones > 0 ? '+' : ''}$semitones',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _performTranspose(int semitones) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chords transposed by $semitones semitones'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    _exitSelectionMode();
  }

  void _exitSelectionMode() {
    setState(() {
      selectedChordIds.clear();
      isSelectionMode = false;
    });
  }
}
