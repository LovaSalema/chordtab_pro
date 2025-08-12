import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/multi_select_bar_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/song_card_widget.dart';
import './widgets/sort_bottom_sheet_widget.dart';

class SongLibrary extends StatefulWidget {
  const SongLibrary({Key? key}) : super(key: key);

  @override
  State<SongLibrary> createState() => _SongLibraryState();
}

class _SongLibraryState extends State<SongLibrary>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _currentSortOption = 'date_created';
  bool _isMultiSelectMode = false;
  Set<int> _selectedSongIds = {};

  // Mock data for songs
  final List<Map<String, dynamic>> _allSongs = [
    {
      "id": 1,
      "title": "Autumn Leaves",
      "keySignature": "G",
      "tempo": 120,
      "chordPreview": "Cmaj7 - Am7 - Dm7 - G7",
      "createdDate": DateTime.now().subtract(const Duration(days: 5)),
      "modifiedDate": DateTime.now().subtract(const Duration(days: 2)),
      "structure": ["A", "A", "B", "A"],
      "chordProgression": "I - vi - ii - V7"
    },
    {
      "id": 2,
      "title": "Blue Bossa",
      "keySignature": "C",
      "tempo": 140,
      "chordPreview": "Cm7 - F7 - BbMaj7 - EbMaj7",
      "createdDate": DateTime.now().subtract(const Duration(days: 10)),
      "modifiedDate": DateTime.now().subtract(const Duration(days: 1)),
      "structure": ["A", "B", "A", "C"],
      "chordProgression": "i7 - IV7 - bVIIMaj7 - bIIIMaj7"
    },
    {
      "id": 3,
      "title": "All The Things You Are",
      "keySignature": "Ab",
      "tempo": 110,
      "chordPreview": "Fm7 - Bb7 - EbMaj7 - AbMaj7",
      "createdDate": DateTime.now().subtract(const Duration(days: 15)),
      "modifiedDate": DateTime.now().subtract(const Duration(days: 8)),
      "structure": ["A", "A", "B", "A"],
      "chordProgression": "vi7 - II7 - VMaj7 - IMaj7"
    },
    {
      "id": 4,
      "title": "Giant Steps",
      "keySignature": "B",
      "tempo": 180,
      "chordPreview": "BMaj7 - D7 - GMaj7 - Bb7",
      "createdDate": DateTime.now().subtract(const Duration(days: 3)),
      "modifiedDate": DateTime.now().subtract(const Duration(hours: 5)),
      "structure": ["A", "B", "A", "B"],
      "chordProgression": "IMaj7 - bIII7 - bVIMaj7 - bI7"
    },
    {
      "id": 5,
      "title": "So What",
      "keySignature": "D",
      "tempo": 132,
      "chordPreview": "Dm7 - Dm7 - Ebm7 - Ebm7",
      "createdDate": DateTime.now().subtract(const Duration(days: 20)),
      "modifiedDate": DateTime.now().subtract(const Duration(days: 12)),
      "structure": ["A", "A", "B", "B"],
      "chordProgression": "i7 - i7 - bii7 - bii7"
    },
    {
      "id": 6,
      "title": "Take Five",
      "keySignature": "Eb",
      "tempo": 176,
      "chordPreview": "Ebm7 - Bbm7 - Ebm7 - Bbm7",
      "createdDate": DateTime.now().subtract(const Duration(days: 7)),
      "modifiedDate": DateTime.now().subtract(const Duration(days: 4)),
      "structure": ["A", "B", "A", "B"],
      "chordProgression": "i7 - v7 - i7 - v7"
    },
  ];

  List<Map<String, dynamic>> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredSongs = List.from(_allSongs);
    _applySorting();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLibraryTab(),
                  _buildCreateTab(),
                  _buildSettingsTab(),
                ],
              ),
            ),
            if (_isMultiSelectMode) _buildMultiSelectBar(),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0 && !_isMultiSelectMode
          ? FloatingActionButton(
              onPressed: _navigateToSongCreation,
              child: CustomIconWidget(
                iconName: 'add',
                color: AppTheme
                    .lightTheme.floatingActionButtonTheme.foregroundColor,
                size: 24,
              ),
            )
          : null,
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            icon: CustomIconWidget(
              iconName: 'library_music',
              color: _tabController.index == 0
                  ? AppTheme.lightTheme.tabBarTheme.labelColor
                  : AppTheme.lightTheme.tabBarTheme.unselectedLabelColor,
              size: 24,
            ),
            text: 'Library',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'add_circle_outline',
              color: _tabController.index == 1
                  ? AppTheme.lightTheme.tabBarTheme.labelColor
                  : AppTheme.lightTheme.tabBarTheme.unselectedLabelColor,
              size: 24,
            ),
            text: 'Create',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: _tabController.index == 2
                  ? AppTheme.lightTheme.tabBarTheme.labelColor
                  : AppTheme.lightTheme.tabBarTheme.unselectedLabelColor,
              size: 24,
            ),
            text: 'Settings',
          ),
        ],
        onTap: (index) {
          setState(() {
            if (index != 0) {
              _exitMultiSelectMode();
            }
          });
        },
      ),
    );
  }

  Widget _buildLibraryTab() {
    return Column(
      children: [
        SearchBarWidget(
          onSearchChanged: _onSearchChanged,
          onSortPressed: _showSortBottomSheet,
          currentSortOption: _currentSortOption,
        ),
        Expanded(
          child: _filteredSongs.isEmpty
              ? _searchQuery.isNotEmpty
                  ? _buildNoSearchResults()
                  : EmptyStateWidget(onCreateFirstSong: _navigateToSongCreation)
              : RefreshIndicator(
                  onRefresh: _refreshLibrary,
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 10.h),
                    itemCount: _filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = _filteredSongs[index];
                      final songId = song["id"] as int;

                      return SongCardWidget(
                        song: song,
                        onTap: () => _navigateToSongDetail(song),
                        onDuplicate: () => _duplicateSong(song),
                        onExport: () => _exportSong(song),
                        onShare: () => _shareSong(song),
                        onDelete: () => _deleteSong(songId),
                        isSelected: _selectedSongIds.contains(songId),
                        isMultiSelectMode: _isMultiSelectMode,
                        onSelectionChanged: (isSelected) =>
                            _toggleSongSelection(songId, isSelected ?? false),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCreateTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'add_circle',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 48,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Create New Song',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Start composing your chord progressions\nand song structures.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: _navigateToSongCreation,
              child: Text('Start Creating'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'settings',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 48,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Settings',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Configure your preferences and\napplication settings.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: _navigateToSettings,
              child: Text('Open Settings'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'No songs found',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search terms',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectBar() {
    return MultiSelectBarWidget(
      selectedCount: _selectedSongIds.length,
      onCancel: _exitMultiSelectMode,
      onSelectAll: _toggleSelectAll,
      onDeleteSelected: _deleteSelectedSongs,
      onExportSelected: _exportSelectedSongs,
      isAllSelected: _selectedSongIds.length == _filteredSongs.length,
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterSongs();
    });
  }

  void _filterSongs() {
    _filteredSongs = _allSongs.where((song) {
      final title = (song["title"] as String? ?? "").toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      return title.contains(searchLower);
    }).toList();

    _applySorting();
  }

  void _applySorting() {
    switch (_currentSortOption) {
      case 'alphabetical':
        _filteredSongs.sort((a, b) => (a["title"] as String? ?? "")
            .compareTo(b["title"] as String? ?? ""));
        break;
      case 'date_created':
        _filteredSongs.sort((a, b) {
          final dateA = a["createdDate"] as DateTime? ?? DateTime.now();
          final dateB = b["createdDate"] as DateTime? ?? DateTime.now();
          return dateB.compareTo(dateA);
        });
        break;
      case 'date_modified':
        _filteredSongs.sort((a, b) {
          final dateA = a["modifiedDate"] as DateTime? ?? DateTime.now();
          final dateB = b["modifiedDate"] as DateTime? ?? DateTime.now();
          return dateB.compareTo(dateA);
        });
        break;
      case 'tempo':
        _filteredSongs.sort((a, b) =>
            (a["tempo"] as int? ?? 0).compareTo(b["tempo"] as int? ?? 0));
        break;
    }
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.bottomSheetTheme.backgroundColor,
      shape: AppTheme.lightTheme.bottomSheetTheme.shape,
      builder: (context) => SortBottomSheetWidget(
        currentSortOption: _currentSortOption,
        onSortOptionSelected: (option) {
          setState(() {
            _currentSortOption = option;
            _applySorting();
          });
        },
      ),
    );
  }

  Future<void> _refreshLibrary() async {
    await Future.delayed(const Duration(milliseconds: 500));
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Library refreshed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _toggleSongSelection(int songId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedSongIds.add(songId);
        if (!_isMultiSelectMode) {
          _isMultiSelectMode = true;
        }
      } else {
        _selectedSongIds.remove(songId);
        if (_selectedSongIds.isEmpty) {
          _isMultiSelectMode = false;
        }
      }
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedSongIds.clear();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedSongIds.length == _filteredSongs.length) {
        _selectedSongIds.clear();
        _isMultiSelectMode = false;
      } else {
        _selectedSongIds =
            _filteredSongs.map((song) => song["id"] as int).toSet();
        _isMultiSelectMode = true;
      }
    });
  }

  void _deleteSelectedSongs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Songs'),
        content: Text(
            'Are you sure you want to delete ${_selectedSongIds.length} selected songs? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allSongs.removeWhere(
                    (song) => _selectedSongIds.contains(song["id"]));
                _filterSongs();
                _exitMultiSelectMode();
              });
              Fluttertoast.showToast(
                msg: "${_selectedSongIds.length} songs deleted",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportSelectedSongs() {
    final selectedSongs = _allSongs
        .where((song) => _selectedSongIds.contains(song["id"]))
        .toList();
    String exportContent = "ChordTab Pro - Song Export\n";
    exportContent += "Generated: ${DateTime.now().toString()}\n\n";

    for (final song in selectedSongs) {
      exportContent += "Title: ${song["title"]}\n";
      exportContent += "Key: ${song["keySignature"]} Major\n";
      exportContent += "Tempo: ${song["tempo"]} BPM\n";
      exportContent += "Chord Preview: ${song["chordPreview"]}\n";
      exportContent +=
          "Structure: ${(song["structure"] as List).join(" - ")}\n";
      exportContent += "Progression: ${song["chordProgression"]}\n";
      exportContent += "Created: ${song["createdDate"]}\n\n";
    }

    Fluttertoast.showToast(
      msg: "${selectedSongs.length} songs exported",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    _exitMultiSelectMode();
  }

  void _duplicateSong(Map<String, dynamic> song) {
    final newSong = Map<String, dynamic>.from(song);
    newSong["id"] = _allSongs.length + 1;
    newSong["title"] = "${song["title"]} (Copy)";
    newSong["createdDate"] = DateTime.now();
    newSong["modifiedDate"] = DateTime.now();

    setState(() {
      _allSongs.insert(0, newSong);
      _filterSongs();
    });

    Fluttertoast.showToast(
      msg: "Song duplicated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _exportSong(Map<String, dynamic> song) {
    String exportContent = "ChordTab Pro - Song Export\n\n";
    exportContent += "Title: ${song["title"]}\n";
    exportContent += "Key: ${song["keySignature"]} Major\n";
    exportContent += "Tempo: ${song["tempo"]} BPM\n";
    exportContent += "Chord Preview: ${song["chordPreview"]}\n";
    exportContent += "Structure: ${(song["structure"] as List).join(" - ")}\n";
    exportContent += "Progression: ${song["chordProgression"]}\n";
    exportContent += "Created: ${song["createdDate"]}\n";

    Fluttertoast.showToast(
      msg: "Song exported",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _shareSong(Map<String, dynamic> song) {
    Fluttertoast.showToast(
      msg: "Sharing \"${song["title"]}\"",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _deleteSong(int songId) {
    setState(() {
      _allSongs.removeWhere((song) => song["id"] == songId);
      _filterSongs();
    });

    Fluttertoast.showToast(
      msg: "Song deleted",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _navigateToSongDetail(Map<String, dynamic> song) {
    Navigator.pushNamed(context, '/song-detail-view', arguments: song);
  }

  void _navigateToSongCreation() {
    Navigator.pushNamed(context, '/song-creation');
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }
}
