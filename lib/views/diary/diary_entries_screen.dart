import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_typography.dart';
import '../../data/models/entry_model.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/diary_form_dialog.dart';

class DiaryEntriesScreen extends StatefulWidget {
  const DiaryEntriesScreen({super.key});

  @override
  State<DiaryEntriesScreen> createState() => _DiaryEntriesScreenState();
}

class _DiaryEntriesScreenState extends State<DiaryEntriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diaryProv = Provider.of<DiaryProvider>(context);
    final diary = diaryProv.activeDiary;
    final allEntries = diaryProv.entries.where((e) => e.diaryId == diary.id).toList();

    // Filter by search query if any
    final filteredEntries = _searchQuery.trim().isEmpty
        ? allEntries
        : allEntries.where((e) {
            final q = _searchQuery.toLowerCase();
            return e.title.toLowerCase().contains(q) ||
                e.content.toLowerCase().contains(q) ||
                e.date.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEDF5FC),
      body: Stack(
        children: [
          // 1. Top Lace Ribbon
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 52,
            child: SafeArea(
              bottom: false,
              child: Image.asset(
                'assets/images/lace_top.png',
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const SizedBox(height: 12),

                  // ─── TOP BAR: BACK BUTTON + DIARY TITLE + NEW PAGE BUTTON ───
                  Row(
                    children: [
                      // Back Button to Bookshelf
                      InkWell(
                        onTap: () => diaryProv.setNavIndex(2),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF26374A), width: 1.3),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(38, 55, 74, 0.08),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            size: 20,
                            color: Color(0xFF26374A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title & Subtitle Header
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DIARY ARCHIVE",
                              style: AppTypography.sans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6C8299),
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              diary.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.sans(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // "+ New Page" Action Pill Button
                      _HoverPillButton(
                        onTap: () => diaryProv.createNewEntry(
                          diaryId: diary.id,
                          returnIndex: 5,
                        ),
                        backgroundColor: const Color(0xFFFFFDF0),
                        border: Border.all(color: const Color(0xFF26374A), width: 1.3),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit_note_rounded, size: 17, color: Color(0xFF26374A)),
                            const SizedBox(width: 4),
                            Text(
                              "+ New Page",
                              style: AppTypography.sans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF26374A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ─── DIARY OVERVIEW HERO BANNER ───
                  Builder(
                    builder: (context) {
                      final hasImage = diary.coverImageUrl != null && diary.coverImageUrl!.trim().isNotEmpty;
                      final hasEmoji = diary.coverEmoji != null && diary.coverEmoji!.trim().isNotEmpty;
                      final hasCoverText = diary.coverText != null && diary.coverText!.trim().isNotEmpty;

                      return Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 130),
                        decoration: BoxDecoration(
                          color: diary.color,
                          gradient: diary.gradient,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: const Color(0xFF26374A), width: 1.4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(38, 55, 74, 0.08),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.6),
                          child: Stack(
                            children: [
                              // 1. Full-bleed Cover Photo (if present)
                              if (hasImage)
                                Positioned.fill(
                                  child: Image.network(
                                    diary.coverImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(
                                      decoration: BoxDecoration(
                                        color: diary.color,
                                        gradient: diary.gradient,
                                      ),
                                    ),
                                  ),
                                ),

                              // 2. Readability overlays when image is active
                              if (hasImage) ...[
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.12),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.68),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              // 3. Banner Content Area
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (hasEmoji) ...[
                                      Text(
                                        diary.coverEmoji!,
                                        style: TextStyle(
                                          fontSize: 28,
                                          shadows: hasImage
                                              ? const [
                                                  Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1.5)),
                                                ]
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                    ],

                                    // Diary Title
                                    Text(
                                      diary.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.sans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: hasImage ? Colors.white : const Color(0xFF1E293B),
                                      ).copyWith(
                                        shadows: hasImage
                                            ? const [
                                                Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1.5)),
                                              ]
                                            : null,
                                      ),
                                    ),

                                    // Description or Cover text
                                    if (diary.description.isNotEmpty || hasCoverText) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        diary.description.isNotEmpty ? diary.description : (diary.coverText ?? ''),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.sans(
                                          fontSize: 12.5,
                                          color: hasImage ? Colors.white.withValues(alpha: 0.92) : const Color(0xFF475569),
                                          height: 1.35,
                                        ).copyWith(
                                          shadows: hasImage
                                              ? const [
                                                  Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                                                ]
                                              : null,
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 12),

                                    // Badges Row
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        _InfoBadge(
                                          icon: Icons.auto_stories_rounded,
                                          label: "${allEntries.length} ${allEntries.length == 1 ? 'Page' : 'Pages'}",
                                          bgColor: hasImage
                                              ? Colors.white.withValues(alpha: 0.92)
                                              : const Color(0xFFE5F1FC),
                                        ),
                                        InkWell(
                                          onTap: () => DiaryFormDialog.show(context, diaryProv, diary: diary),
                                          borderRadius: BorderRadius.circular(12),
                                          child: _InfoBadge(
                                            icon: Icons.edit_note_rounded,
                                            label: "Edit Cover",
                                            bgColor: hasImage
                                                ? Colors.white.withValues(alpha: 0.92)
                                                : const Color(0xFFFFFDF0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // ─── SEARCH & FILTER BAR ───
                  if (allEntries.isNotEmpty) ...[
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFF26374A), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(38, 55, 74, 0.03),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, size: 19, color: Color(0xFF6C8299)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: AppTypography.sans(fontSize: 13, color: const Color(0xFF1E293B)),
                              decoration: InputDecoration(
                                hintText: "Search in this diary's pages...",
                                hintStyle: AppTypography.sans(fontSize: 13, color: const Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (val) => setState(() => _searchQuery = val),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            InkWell(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF6C8299)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ─── SECTION TITLE ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "PAGES IN THIS DIARY",
                        style: AppTypography.sans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6C8299),
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        "${filteredEntries.length} entries",
                        style: AppTypography.sans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6C8299),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ─── ENTRIES LIST OR EMPTY STATE ───
                  if (allEntries.isEmpty) ...[
                    // Empty state for diary without pages
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF26374A), width: 1.4),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(38, 55, 74, 0.04),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F1FC),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF26374A), width: 1.3),
                            ),
                            child: const Center(
                              child: Text("📖", style: TextStyle(fontSize: 28)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "This diary is empty",
                            style: AppTypography.sans(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "A blank canvas waiting for your thoughts, reflections, and quiet daydreams.",
                            textAlign: TextAlign.center,
                            style: AppTypography.sans(
                              fontSize: 12.5,
                              color: const Color(0xFF6C8299),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _HoverPillButton(
                            onTap: () => diaryProv.createNewEntry(
                              diaryId: diary.id,
                              returnIndex: 5,
                            ),
                            backgroundColor: const Color(0xFFFFFDF0),
                            border: Border.all(color: const Color(0xFF26374A), width: 1.3),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFF26374A)),
                                const SizedBox(width: 6),
                                Text(
                                  "Write the First Page ✨",
                                  style: AppTypography.sans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF26374A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (filteredEntries.isEmpty) ...[
                    // Empty search result
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFF26374A), width: 1.2),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded, size: 36, color: Color(0xFF6C8299)),
                          const SizedBox(height: 8),
                          Text(
                            "No pages found for '$_searchQuery'",
                            style: AppTypography.sans(fontSize: 13.5, color: const Color(0xFF6C8299)),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // List of Diary Pages
                    ...filteredEntries.asMap().entries.map((item) {
                      final index = item.key;
                      final entry = item.value;
                      final pageNumber = allEntries.length - index;

                      return _HoverDiaryPageCard(
                        entry: entry,
                        pageNumber: pageNumber,
                        onTap: () => diaryProv.openEntry(entry.id, returnIndex: 5),
                        onDelete: () => _showDeleteEntryDialog(context, diaryProv, entry),
                      );
                    }),
                  ],

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
  }

  void _showDeleteEntryDialog(BuildContext context, DiaryProvider prov, EntryModel entry) {
    showDialog(
      context: context,
      barrierColor: const Color.fromRGBO(38, 55, 74, 0.45),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFEF6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF26374A), width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(38, 55, 74, 0.12),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Delete Page",
                style: AppTypography.sans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to delete '${entry.title}'? This action cannot be undone.",
                style: AppTypography.sans(fontSize: 13.5, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text("Cancel", style: AppTypography.sans(color: const Color(0xFF6C8299))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await prov.deleteEntry(entry.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      "Delete",
                      style: AppTypography.sans(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Information badge chip
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF26374A), width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: const Color(0xFF26374A)),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.sans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF26374A),
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive Page Card with smooth hover lift and details
class _HoverDiaryPageCard extends StatefulWidget {
  final EntryModel entry;
  final int pageNumber;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HoverDiaryPageCard({
    required this.entry,
    required this.pageNumber,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_HoverDiaryPageCard> createState() => _HoverDiaryPageCardState();
}

class _HoverDiaryPageCardState extends State<_HoverDiaryPageCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 14),
        transform: Matrix4.translationValues(0, _isHovered ? -3.5 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF26374A),
            width: _isHovered ? 1.5 : 1.4,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF26374A).withValues(alpha: 0.08),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: const Color(0xFF26374A).withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color.fromRGBO(38, 55, 74, 0.04),
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(38, 55, 74, 0.015),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: widget.onTap,
            hoverColor: Colors.transparent,
            splashColor: const Color(0xFF26374A).withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Page Badge, Date & Time, Delete Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Page number tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFDF0),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF26374A), width: 1.1),
                            ),
                            child: Text(
                              "Page ${widget.pageNumber}",
                              style: AppTypography.sans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF26374A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Date
                          Text(
                            entry.date,
                            style: AppTypography.sans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6C8299),
                            ),
                          ),
                        ],
                      ),

                      // Quick Delete
                      InkWell(
                        onTap: widget.onDelete,
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Entry Title
                  Text(
                    entry.title,
                    style: AppTypography.sans(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),

                  // Content preview
                  if (entry.content.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      entry.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sans(
                        fontSize: 12,
                        color: const Color(0xFF6C8299),
                        height: 1.4,
                      ),
                    ),
                  ],

                  // Photo Thumbnails Strip (if any)
                  if (entry.imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 56,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: entry.imageUrls.length,
                        itemBuilder: (ctx, idx) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF26374A), width: 1.1),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            entry.imageUrls[idx],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(Icons.broken_image, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Bottom metadata & Read prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Stickers indicator
                      if (entry.stickers.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 13, color: Color(0xFF6C8299)),
                            const SizedBox(width: 4),
                            Text(
                              "${entry.stickers.length} stickers",
                              style: AppTypography.sans(fontSize: 11, color: const Color(0xFF6C8299)),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),

                      // Read / Edit Action Indicator
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Open Page",
                            style: AppTypography.sans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF26374A),
                            ),
                          ),
                          const SizedBox(width: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            transform: Matrix4.translationValues(_isHovered ? 3 : 0, 0, 0),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: Color(0xFF26374A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft Hover Pill Button with subtle lift & ambient shadow
class _HoverPillButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color backgroundColor;
  final BoxBorder? border;
  final EdgeInsetsGeometry padding;

  const _HoverPillButton({
    required this.onTap,
    required this.child,
    required this.backgroundColor,
    this.border,
    required this.padding,
  });

  @override
  State<_HoverPillButton> createState() => _HoverPillButtonState();
}

class _HoverPillButtonState extends State<_HoverPillButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -1.5 : 0, 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(50),
          border: widget.border,
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF26374A).withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color.fromRGBO(38, 55, 74, 0.05),
                    blurRadius: 6,
                    offset: Offset(0, 1.5),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            onTap: widget.onTap,
            hoverColor: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
