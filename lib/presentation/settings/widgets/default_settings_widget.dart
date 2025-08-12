import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './settings_section_widget.dart';

class DefaultSettingsWidget extends StatelessWidget {
  final Map<String, dynamic> defaults;
  final Function(String, dynamic) onDefaultChanged;

  const DefaultSettingsWidget({
    Key? key,
    required this.defaults,
    required this.onDefaultChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsItemWidget(
          title: 'Default Key Signature',
          subtitle: '${defaults['keySignature']} Major',
          iconName: 'music_note',
          trailing: CustomIconWidget(
            iconName: 'chevron_right',
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTap: () => _showKeySignatureSelector(context),
        ),
        SettingsItemWidget(
          title: 'Default Tempo',
          subtitle: '${defaults['tempo']} BPM',
          iconName: 'speed',
          trailing: CustomIconWidget(
            iconName: 'chevron_right',
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTap: () => _showTempoSelector(context),
        ),
        SettingsItemWidget(
          title: 'Default Time Signature',
          subtitle: defaults['timeSignature'],
          iconName: 'timer',
          trailing: CustomIconWidget(
            iconName: 'chevron_right',
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTap: () => _showTimeSignatureSelector(context),
        ),
        SettingsItemWidget(
          title: 'Default Instrument Tuning',
          subtitle: defaults['tuning'],
          iconName: 'piano',
          trailing: CustomIconWidget(
            iconName: 'chevron_right',
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTap: () => _showTuningSelector(context),
        ),
      ],
    );
  }

  void _showKeySignatureSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _KeySignatureSelector(
        selectedKey: defaults['keySignature'],
        onKeySelected: (key) {
          onDefaultChanged('keySignature', key);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTempoSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _TempoSelector(
        selectedTempo: defaults['tempo'],
        onTempoSelected: (tempo) {
          onDefaultChanged('tempo', tempo);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTimeSignatureSelector(BuildContext context) {
    final timeSignatures = ['4/4', '3/4', '2/4', '6/8', '12/8'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Time Signature',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            ...timeSignatures.map((timeSignature) => ListTile(
                  title: Text(timeSignature),
                  leading: Radio<String>(
                    value: timeSignature,
                    groupValue: defaults['timeSignature'],
                    onChanged: (value) {
                      onDefaultChanged('timeSignature', value);
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showTuningSelector(BuildContext context) {
    final tunings = ['Standard', 'Drop D', 'DADGAD', 'Open G', 'Open D'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Instrument Tuning',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            ...tunings.map((tuning) => ListTile(
                  title: Text(tuning),
                  leading: Radio<String>(
                    value: tuning,
                    groupValue: defaults['tuning'],
                    onChanged: (value) {
                      onDefaultChanged('tuning', value);
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _KeySignatureSelector extends StatelessWidget {
  final String selectedKey;
  final Function(String) onKeySelected;

  const _KeySignatureSelector({
    required this.selectedKey,
    required this.onKeySelected,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B'
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Key Signature',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final isSelected = selectedKey == key;

              return InkWell(
                onTap: () => onKeySelected(key),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      key,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : AppTheme.getTextColor(context),
                          ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TempoSelector extends StatefulWidget {
  final int selectedTempo;
  final Function(int) onTempoSelected;

  const _TempoSelector({
    required this.selectedTempo,
    required this.onTempoSelected,
  });

  @override
  State<_TempoSelector> createState() => _TempoSelectorState();
}

class _TempoSelectorState extends State<_TempoSelector> {
  late int _currentTempo;

  @override
  void initState() {
    super.initState();
    _currentTempo = widget.selectedTempo;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Tempo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Text(
                '60 BPM',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Expanded(
                child: Slider(
                  value: _currentTempo.toDouble(),
                  min: 60,
                  max: 200,
                  divisions: 140,
                  label: '$_currentTempo BPM',
                  onChanged: (value) {
                    setState(() {
                      _currentTempo = value.round();
                    });
                  },
                ),
              ),
              Text(
                '200 BPM',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Center(
            child: Text(
              '$_currentTempo BPM',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onTempoSelected(_currentTempo),
              child: const Text('Select'),
            ),
          ),
        ],
      ),
    );
  }
}
