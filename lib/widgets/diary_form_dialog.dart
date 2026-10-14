import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/cover_gradients.dart';
import '../data/models/diary_model.dart';
import '../providers/diary_provider.dart';
import 'diary_cover_view.dart';

const List<String?> kCoverCuratedEmojis = [
  null, // None
  '📖', '🌸', '🩵', '✨', '🌙', '💌', '🧸', '🕊️', '🍒', '🍰', '🌿', '☕', '🕯️', '🎨', '📷', '🎀'
];

class DiaryFormDialog extends StatefulWidget {
  final DiaryModel? diary;
  final DiaryProvider provider;

  const DiaryFormDialog({
    super.key,
    this.diary,
    required this.provider,
  });

  static Future<void> show(BuildContext context, DiaryProvider prov, {DiaryModel? diary}) {
    return showDialog(
      context: context,
      barrierColor: const Color.fromRGBO(38, 55, 74, 0.45),
      builder: (ctx) => DiaryFormDialog(diary: diary, provider: prov),
    );
  }

  @override
  State<DiaryFormDialog> createState() => _DiaryFormDialogState();
}

class _DiaryFormDialogState extends State<DiaryFormDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _coverTextCtrl;

  late String _selectedHex;
  String? _selectedEmoji;
  String? _coverImageUrl;
  bool _isUploading = false;
  bool _isSaving = false;

  CoverGradientPreset? _findPreset(String hex) {
    for (final p in kCoverGradients) {
      if (hex.toUpperCase() == p.hexPair.toUpperCase()) return p;
    }
    final clean = hex.replaceAll('#', '').toUpperCase();
    for (final p in kCoverGradients) {
      final start = p.startHex.replaceAll('#', '').toUpperCase();
      final end = p.endHex.replaceAll('#', '').toUpperCase();
      if (clean.contains(start) && clean.contains(end)) return p;
    }
    for (final p in kCoverGradients) {
      final start = p.startHex.replaceAll('#', '').toUpperCase();
      final end = p.endHex.replaceAll('#', '').toUpperCase();
      if (clean.contains(end) || clean.contains(start)) return p;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final d = widget.diary;
    _titleCtrl = TextEditingController(text: d?.title ?? (d == null ? "Sweet Reverie" : ""));
    _descCtrl = TextEditingController(text: d?.description ?? (d == null ? "Soft mornings and gentle thoughts" : ""));
    _coverTextCtrl = TextEditingController(text: d?.coverText ?? "");

    if (d != null) {
      _selectedHex = d.coverColorHex;
      _selectedEmoji = d.coverEmoji;
      _coverImageUrl = d.coverImageUrl;
    } else {
      _selectedHex = kCoverGradients[0].hexPair;
      _selectedEmoji = "🩵";
      _coverImageUrl = null;
    }

    _coverTextCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _coverTextCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadCoverPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final Uint8List bytes = await picked.readAsBytes();

      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image exceeds 2 MB limit! Please choose an image under 2 MB."),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
        setState(() => _isUploading = false);
        return;
      }

      final url = await widget.provider.uploadImage(bytes, "cover_${picked.name}");
      if (!mounted) return;
      setState(() {
        _coverImageUrl = url;
        _isUploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to upload image: $e"),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _onSave() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSaving = true);

    final desc = _descCtrl.text.trim();
    final coverText = _coverTextCtrl.text.trim();

    try {
      if (widget.diary != null) {
        await widget.provider.updateDiary(
          diaryId: widget.diary!.id,
          title: title,
          description: desc,
          coverColor: _selectedHex,
          coverImageUrl: _coverImageUrl,
          coverEmoji: _selectedEmoji,
          coverText: coverText.isNotEmpty ? coverText : null,
        );
      } else {
        await widget.provider.createNewDiary(
          title: title,
          description: desc.isNotEmpty ? desc : "A cozy space for thoughts, dreams, and quiet moments.",
          coverColor: _selectedHex,
          coverImageUrl: _coverImageUrl,
          coverEmoji: _selectedEmoji,
          coverText: coverText.isNotEmpty ? coverText : null,
        );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Save error: $e");
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.diary != null;
    final currentBgColor = DiaryModel.parseHexColor(_selectedHex);
    final activePreset = _findPreset(_selectedHex);
    final currentGradient = activePreset?.gradient ??
        (DiaryModel.parseGradientColors(_selectedHex) != null
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: DiaryModel.parseGradientColors(_selectedHex)!,
              )
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(Colors.white, currentBgColor, 0.45) ?? currentBgColor,
                  currentBgColor,
                ],
              ));
    final activeCoverText = _coverTextCtrl.text.trim().isNotEmpty ? _coverTextCtrl.text.trim() : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEF6),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF26374A), width: 1.4),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(38, 55, 74, 0.16),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? "Edit Diary Cover" : "Create New Diary",
                    style: AppTypography.sans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, size: 20, color: Color(0xFF6C8299)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── LIVE COVER PREVIEW ───
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 110,
                      height: 148,
                      child: Stack(
                        children: [
                          DiaryCoverView(
                            backgroundColor: currentBgColor,
                            gradient: currentGradient,
                            imageUrl: _coverImageUrl,
                            emoji: _selectedEmoji,
                            coverText: activeCoverText,
                            borderRadius: 14,
                            borderWidth: 1.3,
                            emojiSize: 32,
                            fontSize: 11,
                          ),
                          if (_isUploading)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Live Cover Preview",
                      style: AppTypography.sans(
                        fontSize: 11,
                        color: const Color(0xFF6C8299),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── PHOTO ACTIONS ───
              Text(
                "Cover Photo",
                style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUploading ? null : _pickAndUploadCoverPhoto,
                      icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                      label: Text(
                        _coverImageUrl != null ? "Change Photo" : "Upload Photo",
                        style: AppTypography.sans(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF26374A),
                        side: const BorderSide(color: Color(0xFF26374A), width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  if (_coverImageUrl != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _coverImageUrl = null),
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                      label: Text(
                        "Remove",
                        style: AppTypography.sans(fontSize: 12, color: const Color(0xFFDC2626), fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: BorderSide(color: const Color(0xFFDC2626).withValues(alpha: 0.5), width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              // ─── COVER EMOJI PICKER ───
              Text(
                "Cover Emoji",
                style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: kCoverCuratedEmojis.map((e) {
                    final isSelected = _selectedEmoji == e;
                    final isNone = e == null;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => setState(() => _selectedEmoji = e),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: EdgeInsets.symmetric(
                            horizontal: isNone ? 8 : 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF26374A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF26374A) : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            isNone ? "❌ None" : e,
                            style: TextStyle(
                              fontSize: isNone ? 11 : 16,
                              color: isSelected && isNone ? Colors.white : (isSelected ? Colors.white : const Color(0xFF1E293B)),
                              fontWeight: isNone ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // ─── COVER TEXT / TITLE PLATE ───
              Text(
                "Cover Text (Optional)",
                style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _coverTextCtrl,
                style: AppTypography.sans(fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Leave blank or type custom title on cover...",
                  hintStyle: AppTypography.sans(fontSize: 12, color: const Color(0xFF94A3B8)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF26374A), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ─── COVER GRADIENT PALETTE PICKER ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Cover Gradient",
                    style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    activePreset?.name ?? "Pastel Gradient",
                    style: AppTypography.sans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6C8299),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: kCoverGradients.map((preset) {
                  final isChosen = activePreset?.id == preset.id ||
                      _selectedHex.toUpperCase() == preset.hexPair.toUpperCase();
                  return Tooltip(
                    message: preset.name,
                    child: InkWell(
                      onTap: () => setState(() => _selectedHex = preset.hexPair),
                      borderRadius: BorderRadius.circular(22),
                      hoverColor: Colors.transparent,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: preset.gradient,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF26374A),
                            width: isChosen ? 2.5 : 1.2,
                          ),
                          boxShadow: isChosen
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF26374A).withValues(alpha: 0.28),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : const [
                                  BoxShadow(
                                    color: Color.fromRGBO(38, 55, 74, 0.08),
                                    blurRadius: 4,
                                    offset: Offset(0, 1.5),
                                  ),
                                ],
                        ),
                        child: isChosen
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF26374A),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // ─── DIARY TITLE & DESCRIPTION ───
              Text(
                "Diary Details",
                style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleCtrl,
                style: AppTypography.sans(fontSize: 13),
                decoration: InputDecoration(
                  labelText: "Diary Title",
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF26374A), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descCtrl,
                style: AppTypography.sans(fontSize: 13),
                decoration: InputDecoration(
                  labelText: "Description",
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF26374A), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ─── ACTION BUTTONS ───
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: AppTypography.sans(color: const Color(0xFF6C8299)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26374A),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFF26374A).withValues(alpha: 0.25),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            isEditing ? "Save Changes" : "Create Diary",
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
