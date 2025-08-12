import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bottom_toolbar_widget.dart';
import './widgets/chord_chart_widget.dart';
import './widgets/chord_edit_modal_widget.dart';
import './widgets/song_header_widget.dart';

class SongDetailView extends StatefulWidget {
  const SongDetailView({Key? key}) : super(key: key);

  @override
  State<SongDetailView> createState() => _SongDetailViewState();
}

class _SongDetailViewState extends State<SongDetailView> {
  double _zoomLevel = 1.0;
  bool _isPlaying = false;
  int _currentTransposition = 0;

  // Mock song data
  final Map<String, dynamic> _songData = {
    "id": 1,
    "title": "Autumn Leaves",
    "keySignature": "Bb",
    "tempo": 120,
    "lastModified": "Aug 12, 2025 at 7:38 AM",
    "sections": [
      {
        "name": "A Section",
        "measures": [
          {
            "number": 1,
            "chords": [
              {"symbol": "Cm", "extension": "7", "duration": "4"},
              {"symbol": "F", "extension": "7", "duration": "4"},
            ]
          },
          {
            "number": 2,
            "chords": [
              {"symbol": "BbMaj", "extension": "7", "duration": "4"},
              {"symbol": "EbMaj", "extension": "7", "duration": "4"},
            ]
          },
          {
            "number": 3,
            "chords": [
              {"symbol": "Am", "extension": "7b5", "duration": "4"},
              {"symbol": "D", "extension": "7", "duration": "4"},
            ]
          },
          {
            "number": 4,
            "chords": [
              {"symbol": "Gm", "extension": "", "duration": "8"},
            ]
          },
        ]
      },
      {
        "name": "B Section",
        "measures": [
          {
            "number": 5,
            "chords": [
              {"symbol": "Am", "extension": "7b5", "duration": "4"},
              {"symbol": "D", "extension": "7", "duration": "4"},
            ]
          },
          {
            "number": 6,
            "chords": [
              {"symbol": "Gm", "extension": "", "duration": "4"},
              {"symbol": "Gm", "extension": "", "duration": "4"},
            ]
          },
          {
            "number": 7,
            "chords": [
              {"symbol": "Cm", "extension": "7", "duration": "4"},
              {"symbol": "F", "extension": "7", "duration": "4"},
            ]
          },
          {
            "number": 8,
            "chords": [
              {"symbol": "BbMaj", "extension": "7", "duration": "8"},
            ]
          },
        ]
      },
      {
        "name": "Chorus",
        "measures": [
          {
            "number": 9,
            "chords": [
              {"symbol": "Dm", "extension": "7", "duration": "4"},
              {"symbol": "G", "extension": "7", "duration": "4"},
            ]
          },
          {
            "number": 10,
            "chords": [
              {"symbol": "Cm", "extension": "7", "duration": "4"},
              {"symbol": "F", "extension": "7", "duration": "4"},
            ]
          },
          {
            "number": 11,
            "chords": [
              {"symbol": "BbMaj", "extension": "7", "duration": "4"},
              {"symbol": "EbMaj", "extension": "7", "duration": "4"},
            ]
          },
          {
            "number": 12,
            "chords": [
              {"symbol": "Am", "extension": "7b5", "duration": "4"},
              {"symbol": "D", "extension": "7", "duration": "4"},
            ]
          },
        ]
      },
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;

          return GestureDetector(
            onScaleUpdate: (details) {
              setState(() {
                _zoomLevel = (_zoomLevel * details.scale).clamp(0.5, 2.0);
              });
            },
            child: Column(
              children: [
                if (!isLandscape) ...[
                  SafeArea(
                    child: SongHeaderWidget(
                      songData: _songData,
                      onEditPressed: _navigateToEditor,
                    ),
                  ),
                ],
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: () => _showChordEditModal(''),
                    child: ChordChartWidget(
                      songData: _songData,
                      zoomLevel: _zoomLevel,
                      isLandscape: isLandscape,
                      onChordTap: _showChordEditModal,
                    ),
                  ),
                ),
                BottomToolbarWidget(
                  onTransposeUp: _transposeUp,
                  onTransposeDown: _transposeDown,
                  onShare: _shareSheet,
                  onPlayback: _togglePlayback,
                  isPlaying: _isPlaying,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToEditor() {
    Navigator.pushNamed(context, '/song-editor');
  }

  void _showChordEditModal(String chord) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ChordEditModalWidget(
          initialChord: chord,
          onChordUpdated: (newChord) {
            HapticFeedback.selectionClick();
            // Update chord in song data
            setState(() {
              // Implementation would update the specific chord in _songData
            });
          },
        ),
      ),
    );
  }

  void _transposeUp() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentTransposition++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transposed up (+$_currentTransposition semitones)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _transposeDown() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentTransposition--;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transposed down ($_currentTransposition semitones)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _togglePlayback() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPlaying = !_isPlaying;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isPlaying ? 'Playback started' : 'Playback stopped'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareSheet() {
    HapticFeedback.lightImpact();

    final songTitle = _songData['title'] as String? ?? 'Untitled Song';
    final keySignature = _songData['keySignature'] as String? ?? 'C';
    final tempo = _songData['tempo'] as int? ?? 120;

    String shareText = '$songTitle\n';
    shareText += 'Key: $keySignature | Tempo: $tempo BPM\n\n';

    final sections = (_songData['sections'] as List?) ?? [];
    for (var section in sections) {
      final sectionName = section['name'] as String? ?? 'Section';
      shareText += '[$sectionName]\n';

      final measures = (section['measures'] as List?) ?? [];
      for (var measure in measures) {
        final measureNumber = measure['number'] as int? ?? 1;
        final chords = (measure['chords'] as List?) ?? [];

        shareText += 'M$measureNumber: ';
        for (var chord in chords) {
          final symbol = chord['symbol'] as String? ?? '';
          final extension = chord['extension'] as String? ?? '';
          shareText += '$symbol$extension ';
        }
        shareText += '\n';
      }
      shareText += '\n';
    }

    shareText += 'Generated by ChordTab Pro';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Song',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Copy to Clipboard'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: shareText));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'text_snippet',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 24,
              ),
              title: Text('Export as Text'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Text export feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'picture_as_pdf',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              title: Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('PDF export feature coming soon')),
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
