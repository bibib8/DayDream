import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_typography.dart';
import '../../data/models/entry_model.dart';
import '../../data/sample_data.dart';
import '../../providers/diary_provider.dart';

const List<String> kCuratedStickers = [
  '🩵', '🌸', '🎀', '🧸', '🍓',
  '💿', '💌', '✨', '🌙', '🕊️',
  '🌷', '🍰', '🍒', '📖', '🕯️',
  '🎧', '☁️', '🫧', '🗝️', '🦋',
];

class WashiTapeItem {
  final String id;
  final String name;
  final String assetPath;

  const WashiTapeItem({
    required this.id,
    required this.name,
    required this.assetPath,
  });
}

const List<WashiTapeItem> kWashiTapes = [
  WashiTapeItem(id: 'washi_1', name: 'Royal Blue Crepe', assetPath: 'assets/images/washi_1.png'),
  WashiTapeItem(id: 'washi_2', name: 'Sky Blue Gingham', assetPath: 'assets/images/washi_2.png'),
  WashiTapeItem(id: 'washi_3', name: 'Lavender Dots', assetPath: 'assets/images/washi_3.png'),
  WashiTapeItem(id: 'washi_4', name: 'Dusty Rose Crepe', assetPath: 'assets/images/washi_4.png'),
  WashiTapeItem(id: 'washi_5', name: 'Baby Pink Gingham', assetPath: 'assets/images/washi_5.png'),
  WashiTapeItem(id: 'washi_6', name: 'Pink Polka Dots', assetPath: 'assets/images/washi_6.png'),
  WashiTapeItem(id: 'washi_7', name: 'Sage Green Crepe', assetPath: 'assets/images/washi_7.png'),
  WashiTapeItem(id: 'washi_8', name: 'Olive Gingham', assetPath: 'assets/images/washi_8.png'),
  WashiTapeItem(id: 'washi_9', name: 'Mint Green Dots', assetPath: 'assets/images/washi_9.png'),
  WashiTapeItem(id: 'washi_10', name: 'Mustard Yellow Crepe', assetPath: 'assets/images/washi_10.png'),
  WashiTapeItem(id: 'washi_11', name: 'Buttercup Daisy', assetPath: 'assets/images/washi_11.png'),
  WashiTapeItem(id: 'washi_12', name: 'Kraft Vintage Stars', assetPath: 'assets/images/washi_12.png'),
];

class DiaryEditorScreen extends StatefulWidget {
  const DiaryEditorScreen({super.key});

  @override
  State<DiaryEditorScreen> createState() => DiaryEditorScreenState();
}

class PromptTextEditingController extends TextEditingController {
  String? promptText;

  PromptTextEditingController({super.text, this.promptText});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (text.isEmpty) {
      return TextSpan(text: '', style: style);
    }

    int boldLength = 0;

    // 1. If explicit promptText is provided, match against it
    if (promptText != null && promptText!.isNotEmpty) {
      if (text.startsWith(promptText!)) {
        boldLength = promptText!.length;
      } else {
        final newlineIndex = text.indexOf('\n');
        final firstLine = newlineIndex > 0 ? text.substring(0, newlineIndex) : text;
        if (firstLine.endsWith('?') ||
            promptText!.contains(firstLine.trim()) ||
            firstLine.trim().contains(promptText!.trim())) {
          boldLength = firstLine.length;
        }
      }
    }

    // 2. If no promptText or not matched, check known dailyPrompts
    if (boldLength == 0) {
      for (final p in dailyPrompts) {
        if (text.startsWith(p)) {
          promptText = p;
          boldLength = p.length;
          break;
        }
      }
    }

    // 3. Fallback: if promptText was previously set and has a newline, keep first line bold
    if (boldLength == 0 && promptText != null && promptText!.isNotEmpty) {
      final newlineIndex = text.indexOf('\n');
      if (newlineIndex > 0) {
        boldLength = newlineIndex;
      }
    }

    if (boldLength > 0 && boldLength <= text.length) {
      return TextSpan(
        style: style,
        children: [
          TextSpan(
            text: text.substring(0, boldLength),
            style: style?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          TextSpan(
            text: text.substring(boldLength),
            style: style?.copyWith(
              fontWeight: FontWeight.normal,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      );
    }

    return TextSpan(text: text, style: style);
  }
}

class DiaryEditorScreenState extends State<DiaryEditorScreen> {
  late TextEditingController _titleController;
  late PromptTextEditingController _contentController;
  late TextEditingController _weatherController;
  late TextEditingController _soundtrackController;

  String _paperStyle = 'paper-plain'; // 'paper-plain', 'paper-grid', 'paper-lined', 'paper-dotted'
  String _fontFamily = 'serif'; // 'editorial', 'serif', 'handwriting', 'sans'
  String _paperColor = '#FFFFFF';
  List<StickerItem> _stickers = [];
  List<String> _imageUrls = [];
  bool _isUploadingPhoto = false;
  String? _loadedEntryId;
  String? _selectedStickerId;

  // Auto-save state
  Timer? _debounceTimer;
  bool _isSaving = false;
  bool _hasPendingChanges = false;
  bool _isProgrammaticUpdate = false;

  @override
  void initState() {
    super.initState();
    final prov = Provider.of<DiaryProvider>(context, listen: false);
    final entry = prov.activeEntry;
    _loadedEntryId = entry.id;

    String? initialPrompt = prov.currentPromptForEditor;
    if (initialPrompt == null || initialPrompt.isEmpty) {
      for (final p in dailyPrompts) {
        if (entry.content.startsWith(p)) {
          initialPrompt = p;
          break;
        }
      }
    }

    _titleController = TextEditingController(text: entry.title);
    _contentController = PromptTextEditingController(
      text: entry.content,
      promptText: initialPrompt,
    );
    _weatherController = TextEditingController(text: entry.weather);
    _soundtrackController = TextEditingController(text: entry.soundtrack);
    _paperStyle = (entry.paperStyle == 'paper-cloud' || entry.paperStyle.isEmpty)
        ? 'paper-plain'
        : entry.paperStyle;
    _fontFamily = entry.fontFamily;
    _paperColor = entry.paperColor.isNotEmpty ? entry.paperColor : '#FFFFFF';
    _stickers = List.from(entry.stickers);
    _imageUrls = List.from(entry.imageUrls);
    prov.clearPromptForEditor();

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onTextChanged);
    _titleController.dispose();
    _contentController.dispose();
    _weatherController.dispose();
    _soundtrackController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_isProgrammaticUpdate || !mounted) return;
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _hasPendingChanges = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _saveEntry();
      }
    });
  }

  bool _isEntryEmpty() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final isDefaultTitle = title.isEmpty ||
        title == 'A New Whispered Reverie' ||
        title == 'Reflections on Today' ||
        title == 'Untitled Reverie';
    return isDefaultTitle && content.isEmpty && _stickers.isEmpty && _imageUrls.isEmpty;
  }

  Future<void> _flushSaveAndNavigate(VoidCallback navigateAction) async {
    _debounceTimer?.cancel();
    if (_hasPendingChanges) {
      await _saveEntry();
    }
    navigateAction();
  }

  Future<void> flushSaveAndGoBack() async {
    final prov = Provider.of<DiaryProvider>(context, listen: false);
    await _flushSaveAndNavigate(() {
      if (mounted) {
        prov.goBackFromEditor();
      }
    });
  }

  Future<void> _saveEntry() async {
    final prov = Provider.of<DiaryProvider>(context, listen: false);
    final current = prov.activeEntry;

    // Guard: Do not save empty new drafts
    final isExistingEntry = prov.entries.any((e) => e.id == current.id);
    if (!isExistingEntry && _isEntryEmpty()) {
      _hasPendingChanges = false;
      return;
    }

    if (mounted) {
      setState(() => _isSaving = true);
    }

    final now = DateTime.now();
    final actualDate = current.date.isNotEmpty ? current.date : DateFormat('MMMM d, yyyy').format(now);
    final actualTime = current.time.isNotEmpty ? current.time : DateFormat('h:mm a').format(now);

    final updated = EntryModel(
      id: current.id,
      diaryId: current.diaryId,
      title: _titleController.text.trim().isEmpty ? 'Untitled Reverie' : _titleController.text.trim(),
      date: actualDate,
      time: actualTime,
      moodKey: current.moodKey,
      moodLabel: current.moodLabel,
      moodIcon: current.moodIcon,
      weather: _weatherController.text,
      soundtrack: _soundtrackController.text,
      paperStyle: _paperStyle,
      fontFamily: _fontFamily,
      paperColor: _paperColor,
      content: _contentController.text,
      stickers: _stickers,
      imageUrls: _imageUrls,
      createdAt: current.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await prov.saveEntry(updated);
      _loadedEntryId = prov.activeEntry.id;
      _hasPendingChanges = false;
    } catch (e) {
      debugPrint("Auto-save sync error: $e");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickAndUploadPhoto(DiaryProvider prov) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final Uint8List bytes = await picked.readAsBytes();

      // Check 2 MB limit (2 * 1024 * 1024 = 2097152 bytes)
      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image exceeds 2 MB limit! Please choose an image under 2 MB."),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
        setState(() => _isUploadingPhoto = false);
        return;
      }

      final url = await prov.uploadImage(bytes, picked.name);
      setState(() {
        _imageUrls.add(url);
        _isUploadingPhoto = false;
      });
      _scheduleAutoSave();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Photo uploaded successfully! 📷✨"),
          backgroundColor: Color(0xFF26374A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload error: $e"),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  void _showDecorateSheet(DiaryProvider prov) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          top: false,
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 460,
            ),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFEF6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: const Color(0xFF26374A), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(38, 55, 74, 0.15),
                  blurRadius: 18,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag indicator pill
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Decorate Your Page",
                      style: AppTypography.sans(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Color(0xFF26374A)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "Add personal photos, washi tapes, and stickers to enrich your journal entry.",
                  style: AppTypography.sans(fontSize: 12, color: const Color(0xFF6C8299)),
                ),
                const SizedBox(height: 16),

                // Scrollable Decorate Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── 1. PROMINENT ADD PHOTO CARD ───
                        InkWell(
                          onTap: _isUploadingPhoto
                              ? null
                              : () async {
                                  setSheetState(() => _isUploadingPhoto = true);
                                  await _pickAndUploadPhoto(prov);
                                  if (ctx.mounted) {
                                    setSheetState(() => _isUploadingPhoto = false);
                                    Navigator.pop(ctx);
                                  }
                                },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF0F7FD), Color(0xFFE5F1FC)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF26374A), width: 1.3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(38, 55, 74, 0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFF26374A), width: 1.2),
                                  ),
                                  child: _isUploadingPhoto
                                      ? const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF26374A)),
                                        )
                                      : const Icon(
                                          Icons.add_photo_alternate_rounded,
                                          size: 24,
                                          color: Color(0xFF26374A),
                                        ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "📷 Add Photo / Polaroid",
                                        style: AppTypography.sans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _isUploadingPhoto
                                            ? "Uploading to cloud archive..."
                                            : "Choose image from gallery (JPG/PNG <= 2 MB)",
                                        style: AppTypography.sans(
                                          fontSize: 11.5,
                                          color: const Color(0xFF6C8299),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 13,
                                  color: Color(0xFF26374A),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ─── 2. WASHI TAPES SECTION ───
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text("🎀", style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  "Washi Tape Strips (12 Styles)",
                                  style: AppTypography.sans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "Tap to stick on page",
                              style: AppTypography.sans(
                                fontSize: 11,
                                color: const Color(0xFF6C8299),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        LayoutBuilder(
                          builder: (c, constraints) {
                            final crossCount = constraints.maxWidth > 520 ? 3 : 2;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossCount,
                                childAspectRatio: 2.8,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: kWashiTapes.length,
                              itemBuilder: (ctx, i) {
                                final tape = kWashiTapes[i];
                                return InkWell(
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    final newId = 'washi_${DateTime.now().millisecondsSinceEpoch}_$i';
                                    setState(() {
                                      _selectedStickerId = newId;
                                      _stickers.add(
                                        StickerItem(
                                          id: newId,
                                          type: 'washi',
                                          imageUrl: tape.assetPath,
                                          x: 40.0 + (_stickers.length % 3) * 35.0,
                                          y: 60.0 + (_stickers.length % 4) * 45.0,
                                          rotate: (i % 2 == 0 ? -0.06 : 0.06),
                                        ),
                                      );
                                    });
                                    _scheduleAutoSave();
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(38, 55, 74, 0.04),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      tape.assetPath,
                                      height: 28,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // ─── 3. STICKERS SECTION HEADER ───
                        Row(
                          children: [
                            const Text("✨", style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              "Whimsical Sticker Pack (20 items)",
                              style: AppTypography.sans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: kCuratedStickers.length,
                          itemBuilder: (ctx, i) {
                            final emoji = kCuratedStickers[i];
                            return InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                final newId = 'st_${DateTime.now().millisecondsSinceEpoch}_$i';
                                setState(() {
                                  _selectedStickerId = newId;
                                  _stickers.add(
                                    StickerItem(
                                      id: newId,
                                      type: 'sticker',
                                      emoji: emoji,
                                      x: 40.0 + (i % 3) * 50.0,
                                      y: 60.0 + (i % 4) * 40.0,
                                    ),
                                  );
                                });
                                _scheduleAutoSave();
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(38, 55, 74, 0.05),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPickerSheet() {
    final colors = [
      {'name': 'White', 'hex': '#FFFFFF', 'color': Colors.white},
      {'name': 'Cream', 'hex': '#FFFDF2', 'color': const Color(0xFFFFFDF2)},
      {'name': 'Icy Sky', 'hex': '#EFF6FC', 'color': const Color(0xFFEFF6FC)},
      {'name': 'Rose', 'hex': '#FDF2F8', 'color': const Color(0xFFFDF2F8)},
      {'name': 'Matcha', 'hex': '#F0FDF4', 'color': const Color(0xFFF0FDF4)},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEF6),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: const Color(0xFF26374A), width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Paper Background Color",
              style: AppTypography.sans(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: colors.map((c) {
                final isChosen = _paperColor == c['hex'];
                return InkWell(
                  onTap: () {
                    setState(() => _paperColor = c['hex'] as String);
                    _scheduleAutoSave();
                    Navigator.pop(ctx);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c['color'] as Color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF26374A),
                            width: isChosen ? 2.5 : 1.2,
                          ),
                          boxShadow: isChosen
                              ? [const BoxShadow(color: Color(0x3326374A), blurRadius: 6, offset: Offset(0, 2))]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(c['name'] as String, style: AppTypography.sans(fontSize: 11)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Color _parseHex(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.white;
    }
  }

  TextStyle _getTextStyle() {
    switch (_fontFamily) {
      case 'editorial':
        return AppTypography.editorial(fontSize: 16, fontStyle: FontStyle.italic);
      case 'handwriting':
        return AppTypography.handwriting(fontSize: 21);
      case 'sans':
        return AppTypography.sans(fontSize: 14.5);
      case 'serif':
      default:
        return AppTypography.serif(fontSize: 16.5);
    }
  }

  TextStyle _getTitleStyle() {
    switch (_fontFamily) {
      case 'editorial':
        return AppTypography.editorial(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        );
      case 'handwriting':
        return AppTypography.handwriting(
          fontSize: 28,
        ).copyWith(fontWeight: FontWeight.bold);
      case 'sans':
        return AppTypography.sans(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        );
      case 'serif':
      default:
        return AppTypography.serif(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DiaryProvider>(context);
    final activeDiary = prov.activeDiary;
    final activeEntry = prov.activeEntry;

    // Detect if this is an auto-save ID change for the currently active entry
    final isSameEntryAutoSave = _isSaving ||
        (_contentController.text == activeEntry.content &&
            _titleController.text.trim() == activeEntry.title.trim());

    if (_loadedEntryId != activeEntry.id && isSameEntryAutoSave && _contentController.text.isNotEmpty) {
      _loadedEntryId = activeEntry.id;
    } else if (_loadedEntryId != activeEntry.id) {
      _debounceTimer?.cancel();
      _loadedEntryId = activeEntry.id;
      _isProgrammaticUpdate = true;
      _titleController.text = activeEntry.title;

      // Resolve prompt text for this entry
      String? resolvedPrompt = prov.currentPromptForEditor;
      if (resolvedPrompt == null || resolvedPrompt.isEmpty) {
        for (final p in dailyPrompts) {
          if (activeEntry.content.startsWith(p)) {
            resolvedPrompt = p;
            break;
          }
        }
      }

      _contentController.promptText = resolvedPrompt;
      _contentController.text = activeEntry.content;
      _weatherController.text = activeEntry.weather;
      _soundtrackController.text = activeEntry.soundtrack;
      _paperStyle = (activeEntry.paperStyle == 'paper-cloud' || activeEntry.paperStyle.isEmpty)
          ? 'paper-plain'
          : activeEntry.paperStyle;
      _fontFamily = activeEntry.fontFamily;
      _paperColor = activeEntry.paperColor.isNotEmpty ? activeEntry.paperColor : '#FFFFFF';
      _stickers = List.from(activeEntry.stickers);
      _imageUrls = List.from(activeEntry.imageUrls);
      _selectedStickerId = null;
      _hasPendingChanges = false;
      _isProgrammaticUpdate = false;
      prov.clearPromptForEditor();
    }

    if (prov.currentNavIndex != 3 && _hasPendingChanges) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_hasPendingChanges && mounted) {
          _saveEntry();
        }
      });
    }

    final paperBg = _parseHex(_paperColor);

    return Scaffold(
      backgroundColor: const Color(0xFFEDF5FC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── 1. TOP LACE RIBBON ATTACHED TO TOP ───
            Image.asset(
              'assets/images/lace_top.png',
              width: double.infinity,
              height: 36,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),

            // ─── 2. TOP TOOLBAR HEADER ───
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    children: [
                  // Row: Back Button + Diary Title Info + Auto-save Indicator
                  Row(
                    children: [
                      // Back Button
                      InkWell(
                        onTap: () => flushSaveAndGoBack(),
                        borderRadius: BorderRadius.circular(50),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.arrow_back,
                            size: 22,
                            color: Color(0xFF26374A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Diary Title Header
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Daydream Journal",
                              style: AppTypography.sans(
                                fontSize: 11,
                                color: const Color(0xFF6C8299),
                              ),
                            ),
                            Text(
                              activeDiary.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.sans(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Auto-save Status Indicator (Replaces Save Button)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: _isSaving
                              ? const Color(0xFFFFFDF0)
                              : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: const Color(0xFF26374A).withValues(alpha: _isSaving ? 0.35 : 0.2),
                            width: 1.1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isSaving) ...[
                              const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Color(0xFF26374A),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "Saving...",
                                style: AppTypography.sans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6C8299),
                                ),
                              ),
                            ] else ...[
                              const Icon(
                                Icons.cloud_done_outlined,
                                size: 14,
                                color: Color(0xFF26374A),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Saved",
                                style: AppTypography.sans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF26374A),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Toolbar Row: Paper Pattern, Color, Font, Stickers, Photo
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Paper Pattern Dropdown
                        Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDF0),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: const Color(0xFF26374A), width: 1.1),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _paperStyle,
                              isDense: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: Color(0xFF26374A)),
                              dropdownColor: const Color(0xFFFFFEF6),
                              borderRadius: BorderRadius.circular(16),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _paperStyle = val);
                                  _scheduleAutoSave();
                                }
                              },
                              items: const [
                                DropdownMenuItem(value: 'paper-plain', child: Text("Paper: Plain", style: TextStyle(fontSize: 11.5, color: Color(0xFF26374A)))),
                                DropdownMenuItem(value: 'paper-grid', child: Text("Paper: Graph", style: TextStyle(fontSize: 11.5, color: Color(0xFF26374A)))),
                                DropdownMenuItem(value: 'paper-lined', child: Text("Paper: Lined", style: TextStyle(fontSize: 11.5, color: Color(0xFF26374A)))),
                                DropdownMenuItem(value: 'paper-dotted', child: Text("Paper: Dots", style: TextStyle(fontSize: 11.5, color: Color(0xFF26374A)))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Paper Color Picker Pill (frame filled with selected color, no inner dot)
                        InkWell(
                          onTap: _showColorPickerSheet,
                          hoverColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            decoration: BoxDecoration(
                              color: paperBg,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: const Color(0xFF26374A), width: 1.1),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Color",
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF26374A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Font Dropdown
                        Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDF0),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: const Color(0xFF26374A), width: 1.1),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _fontFamily,
                              isDense: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: Color(0xFF26374A)),
                              dropdownColor: const Color(0xFFFFFEF6),
                              borderRadius: BorderRadius.circular(16),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _fontFamily = val);
                                  _scheduleAutoSave();
                                }
                              },
                              items: const [
                                DropdownMenuItem(value: 'serif', child: Text("Font: Serif", style: TextStyle(fontSize: 11.5, color: Color(0xFF26374A)))),
                                DropdownMenuItem(value: 'editorial', child: Text("Font: Bodoni", style: TextStyle(fontSize: 11.5, color: Color(0xFF26374A)))),
                                DropdownMenuItem(value: 'handwriting', child: Text("Font: Script", style: TextStyle(fontSize: 11.5, color: Color(0xFF26374A)))),
                                DropdownMenuItem(value: 'sans', child: Text("Font: Sans", style: TextStyle(fontSize: 11.5, color: Color(0xFF26374A)))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Decorate Button (opens Decorate Sheet with Add Photo & Stickers)
                        InkWell(
                          onTap: () => _showDecorateSheet(prov),
                          hoverColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 11),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFDF0),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: const Color(0xFF26374A), width: 1.1),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Decorate",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF26374A),
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 15,
                                  color: Color(0xFF26374A),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

            // Divider Line
            Container(height: 1.2, color: const Color(0xFF26374A)),

            // ─── PAGE NAVIGATION STRIP ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: const BoxDecoration(
                color: Color(0xFFE5F1FC),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF26374A), width: 1.0),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  // Older / Previous Page Button
                  InkWell(
                    onTap: prov.hasOlderEntryInDiary ? () => _flushSaveAndNavigate(() => prov.goToOlderEntryInDiary()) : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Opacity(
                      opacity: prov.hasOlderEntryInDiary ? 1.0 : 0.35,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF26374A), width: 1.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_ios_rounded, size: 10.5, color: Color(0xFF26374A)),
                            const SizedBox(width: 4),
                            Text(
                              "Older",
                              style: AppTypography.sans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF26374A)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Center: Page Counter Pill & "All Pages" Shortcut
                  InkWell(
                    onTap: () => _flushSaveAndNavigate(() => prov.openDiary(activeDiary.id)),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDF0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF26374A), width: 1.1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.menu_book_rounded, size: 13, color: Color(0xFF26374A)),
                          const SizedBox(width: 5),
                          Text(
                            prov.activeDiaryEntries.isNotEmpty && prov.activeEntryIndexInDiary != -1
                                ? "Page ${prov.activeDiaryEntries.length - prov.activeEntryIndexInDiary} of ${prov.activeDiaryEntries.length} • All Pages"
                                : "View All Pages",
                            style: AppTypography.sans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF26374A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Newer / Next Page Button
                  InkWell(
                    onTap: prov.hasNewerEntryInDiary ? () => _flushSaveAndNavigate(() => prov.goToNewerEntryInDiary()) : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Opacity(
                      opacity: prov.hasNewerEntryInDiary ? 1.0 : 0.35,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF26374A), width: 1.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Newer",
                              style: AppTypography.sans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF26374A)),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 10.5, color: Color(0xFF26374A)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

            // ─── 3. MAIN SCROLLABLE JOURNAL CARD WITH DRAGGABLE STICKERS ───
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 520),
                  decoration: BoxDecoration(
                    color: paperBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFF26374A), width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(38, 55, 74, 0.08),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (_selectedStickerId != null) {
                          setState(() => _selectedStickerId = null);
                        }
                      },
                      child: Stack(
                        children: [
                        // Background Pattern Painter
                        Positioned.fill(
                          child: CustomPaint(
                            painter: PaperPatternPainter(pattern: _paperStyle),
                          ),
                        ),

                        // Content Form
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: Date Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    activeEntry.date,
                                    style: AppTypography.sans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF6C8299),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Uploaded Photos Shelf
                              if (_imageUrls.isNotEmpty) ...[
                                SizedBox(
                                  height: 140,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _imageUrls.length,
                                    itemBuilder: (ctx, idx) {
                                      final url = _imageUrls[idx];
                                      return Container(
                                        margin: const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: const Color(0xFF26374A), width: 1.2),
                                          boxShadow: const [
                                            BoxShadow(color: Color(0x1F26374A), blurRadius: 6, offset: Offset(0, 2)),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                url,
                                                width: 120,
                                                height: 128,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  width: 120,
                                                  height: 128,
                                                  color: const Color(0xFFF1F5F9),
                                                  child: const Icon(Icons.broken_image, size: 28),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 2,
                                              right: 2,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() => _imageUrls.removeAt(idx));
                                                  _scheduleAutoSave();
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(3),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.black54,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Entry Title
                              TextField(
                                controller: _titleController,
                                style: _getTitleStyle().copyWith(
                                  color: const Color(0xFF1E293B),
                                ),
                                decoration: InputDecoration(
                                  hintText: "Title of today's reverie...",
                                  hintStyle: _getTitleStyle().copyWith(
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Solid Divider Line under Title
                              Container(height: 1.2, color: const Color(0xFF26374A)),
                              const SizedBox(height: 14),

                              // Entry Content Field
                              TextField(
                                controller: _contentController,
                                maxLines: null,
                                minLines: 14,
                                style: _getTextStyle().copyWith(
                                  height: 1.75,
                                  color: const Color(0xFF1E293B),
                                ),
                                decoration: InputDecoration(
                                  hintText: "Spill your thoughts on paper here...",
                                  hintStyle: _getTextStyle().copyWith(
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        // Draggable Stickers & Washi Tapes on the Canvas
                        ..._stickers.map((st) {
                          final isWashi = st.type == 'washi' || (st.imageUrl != null && st.imageUrl!.contains('washi'));
                          final isSelected = _selectedStickerId == st.id;
                          final outerBoxSize = isWashi ? 180.0 : 100.0;
                          final cardWidth = isWashi ? 160.0 : 68.0;
                          final cardHeight = isWashi ? 64.0 : 68.0;

                          return Positioned(
                            left: st.x,
                            top: st.y,
                            child: SizedBox(
                              width: outerBoxSize,
                              height: outerBoxSize,
                              child: Center(
                                child: Transform.rotate(
                                  angle: st.rotate,
                                  child: SizedBox(
                                    width: cardWidth,
                                    height: cardHeight,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // 0. SUBTLE DASHED SELECTION OUTLINE (Only when selected)
                                        if (isSelected)
                                          Positioned.fill(
                                            child: CustomPaint(
                                              painter: DashedBorderPainter(
                                                color: const Color(0xFF26374A).withValues(alpha: 0.5),
                                                strokeWidth: 1.2,
                                                radius: 8.0,
                                              ),
                                            ),
                                          ),

                                        // 1. TAPE OR STICKER BODY (Handles Dragging & Selection)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              setState(() {
                                                _selectedStickerId = st.id;
                                                _stickers.remove(st);
                                                _stickers.add(st);
                                              });
                                            },
                                            onPanUpdate: (details) {
                                              setState(() {
                                                _selectedStickerId = st.id;
                                                st.x += details.delta.dx;
                                                st.y += details.delta.dy;
                                              });
                                            },
                                            onPanEnd: (_) {
                                              _scheduleAutoSave();
                                            },
                                            child: isWashi && st.imageUrl != null
                                                ? Image.asset(
                                                    st.imageUrl!,
                                                    width: 136,
                                                    fit: BoxFit.contain,
                                                    filterQuality: FilterQuality.medium,
                                                  )
                                                : Center(
                                                    child: Text(
                                                      st.emoji,
                                                      style: const TextStyle(fontSize: 32),
                                                    ),
                                                  ),
                                          ),
                                        ),

                                        // 2. CONTROLS (Only visible when isSelected == true)
                                        if (isSelected) ...[
                                          // CLOSE / DELETE BUTTON (Top-Right)
                                          Positioned(
                                            top: 2,
                                            right: 2,
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                setState(() {
                                                  _stickers.remove(st);
                                                  if (_selectedStickerId == st.id) {
                                                    _selectedStickerId = null;
                                                  }
                                                });
                                                _scheduleAutoSave();
                                              },
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF26374A),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white, width: 1.5),
                                                  boxShadow: const [
                                                    BoxShadow(color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 1)),
                                                  ],
                                                ),
                                                child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
                                              ),
                                            ),
                                          ),

                                          // ROTATE HANDLE BUTTON (Bottom-Right)
                                          Positioned(
                                            bottom: 2,
                                            right: 2,
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                setState(() {
                                                  st.rotate = (st.rotate + 0.261799) % (3.141592653589793 * 2);
                                                });
                                                _scheduleAutoSave();
                                              },
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF26374A),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white, width: 1.5),
                                                  boxShadow: const [
                                                    BoxShadow(color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 1)),
                                                  ],
                                                ),
                                                child: const Icon(Icons.rotate_right_rounded, size: 13, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
);
  }
}

// Custom Painter for Graph, Lined, and Dots on Paper
class PaperPatternPainter extends CustomPainter {
  final String pattern; // 'paper-plain', 'paper-grid', 'paper-lined', 'paper-dotted'

  PaperPatternPainter({required this.pattern});

  @override
  void paint(Canvas canvas, Size size) {
    if (pattern == 'paper-plain') {
      return;
    }

    final linePaint = Paint()
      ..color = const Color(0x1F000000)
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = const Color(0x38000000)
      ..style = PaintingStyle.fill;

    if (pattern == 'paper-grid') {
      const double step = 20.0;
      for (double x = step; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      }
      for (double y = step; y < size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      }
    } else if (pattern == 'paper-lined') {
      const double step = 32.0;
      final marginPaint = Paint()
        ..color = const Color(0x38C85050)
        ..strokeWidth = 1.0;
      canvas.drawLine(const Offset(44, 0), Offset(44, size.height), marginPaint);

      for (double y = step; y < size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      }
    } else if (pattern == 'paper-dotted') {
      const double step = 20.0;
      for (double x = step; x < size.width; x += step) {
        for (double y = step; y < size.height; y += step) {
          canvas.drawCircle(Offset(x, y), 0.75, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PaperPatternPainter oldDelegate) => oldDelegate.pattern != pattern;
}

// Custom Painter for Delicate Dashed Selection Border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  DashedBorderPainter({
    this.color = const Color(0xFF26374A),
    this.strokeWidth = 1.2,
    this.radius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      const double dashLength = 4.0;
      const double spaceLength = 4.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next > metric.length ? metric.length : next),
          paint,
        );
        distance = next + spaceLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}
