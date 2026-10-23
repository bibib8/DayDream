import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/polka_dot_painter.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 720;

    return Scaffold(
      backgroundColor: const Color(0xFFEDF5FC),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Delicate Polka Dot Painter Background
          const CustomPaint(
            painter: WelcomePolkaDotPainter(),
          ),

          // 2. Top Lace Ribbon
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: isDesktop ? 48 : 36,
            child: SafeArea(
              bottom: false,
              child: Image.asset(
                'assets/images/lace_top.png',
                width: double.infinity,
                fit: isDesktop ? BoxFit.fitHeight : BoxFit.fitWidth,
                repeat: isDesktop ? ImageRepeat.repeatX : ImageRepeat.noRepeat,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // 3. Scrollable Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar with aesthetic back button
                _buildAppBar(context),

                // Scrollable Document
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : 16,
                      vertical: 16,
                    ),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 760),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFEF6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF26374A), width: 1.4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(38, 55, 74, 0.08),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Color.fromRGBO(38, 55, 74, 0.04),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 36 : 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Document Header
                              _buildDocumentHeader(context),

                              const SizedBox(height: 20),
                              _buildDivider(),
                              const SizedBox(height: 20),

                              // Intro
                              _buildParagraph(
                                "This Privacy Policy explains how the Daydream Digital Diary mobile app "
                                "(\"the App\", \"we\", \"us\") collects, uses, stores and shares information when you use it. "
                                "The App is a personal digital diary and scrapbook that lets you write journal entries, decorate pages, "
                                "add photos and track your daily mood.",
                              ),
                              const SizedBox(height: 12),
                              _buildParagraph(
                                "By using the App, you agree to the practices described here. If you do not agree, please do not use the App.",
                              ),

                              const SizedBox(height: 28),

                              // Section 1: Information we collect
                              _buildSectionTitle("1", "Information we collect"),
                              const SizedBox(height: 12),

                              _buildSubSectionTitle("Information you give us"),
                              const SizedBox(height: 10),
                              _buildDataTable(context, isDesktop),
                              const SizedBox(height: 14),
                              _buildParagraph(
                                "Diary entries and mood logs can contain sensitive personal information about your feelings and daily life. "
                                "You decide what to write, and this content is used only to provide the App's features to you.",
                              ),

                              const SizedBox(height: 20),
                              _buildSubSectionTitle("Information collected automatically"),
                              const SizedBox(height: 8),
                              _buildBulletItem(
                                "Technical data",
                                "When the App communicates with our servers, our hosting provider may record technical information such as your IP address, device/browser type, and the date and time of requests. This is used for security, preventing abuse and keeping the service running.",
                              ),
                              const SizedBox(height: 8),
                              _buildBulletItem(
                                "Font loading",
                                "The App may download fonts from Google Fonts servers. When this happens, Google receives your IP address as part of a normal web request.",
                              ),
                              const SizedBox(height: 10),
                              _buildParagraph(
                                "We do not use advertising, advertising IDs, analytics or tracking tools, and we do not collect your precise location, contacts or call logs.",
                              ),

                              const SizedBox(height: 20),
                              _buildSubSectionTitle("Device permissions"),
                              const SizedBox(height: 8),
                              _buildBulletItem(
                                "Photos / gallery",
                                "Used only when you choose to add a photo to an entry or set a profile picture.",
                              ),
                              const SizedBox(height: 8),
                              _buildBulletItem(
                                "Camera",
                                "Used only when you choose to take a photo for your profile picture.",
                              ),
                              const SizedBox(height: 10),
                              _buildParagraph(
                                "The App only accesses the specific photo you select. You can refuse or revoke these permissions in your device settings at any time; the rest of the App will keep working.",
                              ),

                              const SizedBox(height: 28),

                              // Section 2: How we use your information
                              _buildSectionTitle("2", "How we use your information"),
                              const SizedBox(height: 12),
                              _buildBulletItem(null, "To provide the App's core features: accounts, writing and saving diary entries, photos and the mood calendar."),
                              const SizedBox(height: 8),
                              _buildBulletItem(null, "To keep your data synced to your account across sign-ins and devices."),
                              const SizedBox(height: 8),
                              _buildBulletItem(null, "To keep the service secure and fix problems."),
                              const SizedBox(height: 8),
                              _buildBulletItem(null, "To respond to your questions or requests."),
                              const SizedBox(height: 12),
                              _buildParagraph(
                                "We do not sell your personal information, use your diary content for advertising, or share it with advertisers.",
                              ),

                              const SizedBox(height: 28),

                              // Section 3: How your information is stored and shared
                              _buildSectionTitle("3", "How your information is stored and shared"),
                              const SizedBox(height: 12),
                              _buildParagraph(
                                "We use Supabase (supabase.com) as our cloud backend for authentication, database and file storage. "
                                "Supabase processes your data on our behalf only to run the App. Its servers may be located outside your country. "
                                "Data is sent between the App and Supabase over encrypted connections (HTTPS/TLS).",
                              ),
                              const SizedBox(height: 10),
                              _buildParagraph(
                                "Each user's account, diaries, entries and mood logs are protected by access rules so that only the signed-in owner can read or change them.",
                              ),
                              const SizedBox(height: 14),

                              _buildCalloutBox(
                                title: "About photos",
                                content:
                                    "Photos you upload (diary photos and profile pictures) are stored in cloud storage and given a long, randomly generated web address. "
                                    "These addresses are not listed or searchable, but anyone who obtains the exact link can open the image. "
                                    "Please avoid uploading photos you would not want anyone else to see.",
                                icon: Icons.photo_camera_back_outlined,
                              ),
                              const SizedBox(height: 14),
                              _buildParagraph(
                                "We may also disclose information if required by law, to protect the rights and safety of our users or others, "
                                "or in connection with a transfer of the App to a new owner (in which case this policy will continue to apply).",
                              ),

                              const SizedBox(height: 28),

                              // Section 4: Data retention
                              _buildSectionTitle("4", "Data retention"),
                              const SizedBox(height: 12),
                              _buildParagraph(
                                "We keep your information for as long as your account exists. When you delete a diary or an entry, it is removed from our database. "
                                "When you delete your account, we delete your account and associated data as described below. Copies in routine backups held by our hosting provider may persist for a limited period before they are overwritten.",
                              ),

                              const SizedBox(height: 28),

                              // Section 5: Deleting your account and data
                              _buildSectionTitle("5", "Deleting your account and data"),
                              const SizedBox(height: 12),
                              _buildParagraph("You can delete your data in two ways:"),
                              const SizedBox(height: 10),
                              _buildBulletItem(
                                "In the App",
                                "Go to Settings → Delete Account. This removes your diaries, entries, mood logs and profile.",
                              ),
                              const SizedBox(height: 8),
                              _buildBulletItem(
                                "By email",
                                "Send a request from your account's email address to support@daydreamdiary.app with the subject \"Delete my Daydream account\". We will delete your account, sign-in credentials, uploaded photos and all associated data within 30 days and confirm by email.",
                              ),
                              const SizedBox(height: 12),
                              _buildParagraph(
                                "You can also delete individual entries or diaries at any time inside the App.",
                              ),

                              const SizedBox(height: 28),

                              // Section 6: Your rights
                              _buildSectionTitle("6", "Your rights"),
                              const SizedBox(height: 12),
                              _buildParagraph(
                                "Depending on where you live (for example under Thailand's Personal Data Protection Act B.E. 2562 (PDPA) or the EU/UK GDPR), "
                                "you may have the right to access, correct, delete or receive a copy of your personal data, to object to or restrict its processing, "
                                "and to withdraw consent. To exercise any of these rights, contact us at support@daydreamdiary.app. "
                                "You may also have the right to complain to your local data protection authority.",
                              ),

                              const SizedBox(height: 28),

                              // Section 7: Children's privacy
                              _buildSectionTitle("7", "Children's privacy"),
                              const SizedBox(height: 12),
                              _buildParagraph(
                                "The App is not directed at children under 13, and we do not knowingly collect personal information from children under 13. "
                                "If you believe a child has given us personal information, please contact us and we will delete it.",
                              ),

                              const SizedBox(height: 28),

                              // Section 8: Security
                              _buildSectionTitle("8", "Security"),
                              const SizedBox(height: 12),
                              _buildParagraph(
                                "We use reasonable measures to protect your information, including encrypted connections and per-user access controls. "
                                "No method of transmission or storage is completely secure, so we cannot guarantee absolute security. "
                                "Please use a strong password that you do not use elsewhere.",
                              ),

                              const SizedBox(height: 28),

                              // Section 9: Changes to this policy
                              _buildSectionTitle("9", "Changes to this policy"),
                              const SizedBox(height: 12),
                              _buildParagraph(
                                "We may update this Privacy Policy from time to time. When we do, we will change the effective date at the top of this page "
                                "and, for significant changes, notify you in the App.",
                              ),

                              const SizedBox(height: 28),

                              // Section 10: Contact us
                              _buildSectionTitle("10", "Contact us"),
                              const SizedBox(height: 12),
                              _buildParagraph(
                                "If you have any questions about this Privacy Policy or your data, please contact:",
                              ),
                              const SizedBox(height: 12),
                              _buildContactCard(context),

                              const SizedBox(height: 32),

                              // Understood Action Button
                              Center(
                                child: Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFF0F7FD),
                                        Color(0xFFDEF1FE),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(21),
                                    border: Border.all(color: const Color(0xFF26374A), width: 1.4),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromRGBO(38, 55, 74, 0.06),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => Navigator.of(context).pop(),
                                      borderRadius: BorderRadius.circular(21),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 28),
                                        child: Center(
                                          child: Text(
                                            "Understood",
                                            style: AppTypography.sans(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF26374A),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),
                              _buildDivider(),
                              const SizedBox(height: 18),

                              // Footer
                              Center(
                                child: Text(
                                  "© 2026 Daydream Digital Diary • All rights reserved",
                                  style: AppTypography.sans(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button in vintage pill style
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: const Color(0xFF26374A), width: 1.3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(38, 55, 74, 0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF26374A)),
                    const SizedBox(width: 6),
                    Text(
                      "Back",
                      style: AppTypography.sans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF26374A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Central title tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F1FC),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: const Color(0xFF26374A), width: 1.1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 18,
                    height: 18,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Daydream Legal",
                  style: AppTypography.sans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF26374A),
                  ),
                ),
              ],
            ),
          ),

          // Placeholder to balance the row
          const SizedBox(width: 68),
        ],
      ),
    );
  }

  Widget _buildDocumentHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE5F1FC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF477FAF), width: 1),
          ),
          child: Text(
            "DAYDREAM DIGITAL DIARY",
            style: AppTypography.sans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: const Color(0xFF477FAF),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Main Title
        Text(
          "Privacy Policy",
          style: AppTypography.editorial(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF26374A),
          ),
        ),
        const SizedBox(height: 6),

        // Metadata badge
        Row(
          children: [
            const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF5B6F84)),
            const SizedBox(width: 6),
            Text(
              "Effective date: October 23, 2026",
              style: AppTypography.sans(
                fontSize: 13,
                color: const Color(0xFF5B6F84),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1.2,
      color: const Color(0xFF26374A).withValues(alpha: 0.15),
    );
  }

  Widget _buildSectionTitle(String number, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFE5F1FC),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF26374A), width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: AppTypography.sans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF26374A),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTypography.editorial(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF26374A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubSectionTitle(String subtitle) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF477FAF),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            subtitle,
            style: AppTypography.sans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF26374A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: AppTypography.sans(
        fontSize: 13.5,
        height: 1.6,
        color: const Color(0xFF26374A),
      ),
    );
  }

  Widget _buildBulletItem(String? title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 10),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF477FAF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF26374A), width: 1),
            ),
          ),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                if (title != null) ...[
                  TextSpan(
                    text: "$title: ",
                    style: AppTypography.sans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF26374A),
                    ),
                  ),
                ],
                TextSpan(
                  text: description,
                  style: AppTypography.sans(
                    fontSize: 13.5,
                    height: 1.55,
                    color: const Color(0xFF26374A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalloutBox({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5F1FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              color: const Color(0xFF477FAF),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 18, color: const Color(0xFF477FAF)),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: AppTypography.sans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF26374A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      style: AppTypography.sans(
                        fontSize: 13,
                        height: 1.55,
                        color: const Color(0xFF26374A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, bool isDesktop) {
    final rows = [
      {
        "data": "Account information",
        "examples": "Email address, password, pen name",
        "why": "To create your account, sign you in and show your name in the App. Your password is handled by our authentication provider and is stored only in hashed (encrypted) form; we never see it.",
      },
      {
        "data": "Profile picture",
        "examples": "An emoji, or a photo you choose from your gallery or take with your camera",
        "why": "To display your avatar in the App.",
      },
      {
        "data": "Diary content",
        "examples": "Diary names, cover designs, entry titles and text, weather and soundtrack notes, stickers and page decorations",
        "why": "To save your diary and sync it to your account so you can see it again after signing in.",
      },
      {
        "data": "Photos",
        "examples": "Images you add to diary entries",
        "why": "To show them on your diary pages.",
      },
      {
        "data": "Mood logs",
        "examples": "The mood you choose for a day (e.g. happy, calm, tired) and an optional note",
        "why": "To build your monthly mood calendar.",
      },
    ];

    if (!isDesktop) {
      // Mobile-friendly card list (prevents horizontal scrolling/squished columns)
      return Column(
        children: rows.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF26374A), width: 1.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F1FC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF26374A), width: 1),
                  ),
                  child: Text(
                    item["data"]!,
                    style: AppTypography.sans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF26374A),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Examples: ",
                        style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF477FAF)),
                      ),
                      TextSpan(
                        text: item["examples"]!,
                        style: AppTypography.sans(fontSize: 12.5, color: const Color(0xFF26374A)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Why we need it: ",
                        style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF477FAF)),
                      ),
                      TextSpan(
                        text: item["why"]!,
                        style: AppTypography.sans(fontSize: 12.5, height: 1.45, color: const Color(0xFF26374A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    // Desktop/Tablet styled table
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF26374A), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1.4),
          2: FlexColumnWidth(2.4),
        },
        border: TableBorder.all(color: const Color(0xFFD6E4F2), width: 1),
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFE5F1FC)),
            children: [
              _buildTableCell("Data", isHeader: true),
              _buildTableCell("Examples", isHeader: true),
              _buildTableCell("Why we need it", isHeader: true),
            ],
          ),
          ...rows.map(
            (row) => TableRow(
              children: [
                _buildTableCell(row["data"]!, isBold: true),
                _buildTableCell(row["examples"]!),
                _buildTableCell(row["why"]!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: AppTypography.sans(
          fontSize: isHeader ? 13 : 12.5,
          fontWeight: (isHeader || isBold) ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF26374A),
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    const contactEmail = "support@daydreamdiary.app";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26374A), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(38, 55, 74, 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F1FC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF26374A), width: 1.1),
            ),
            child: const Icon(Icons.mail_outline_rounded, size: 20, color: Color(0xFF26374A)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daydream Digital Diary Support",
                  style: AppTypography.sans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF26374A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contactEmail,
                  style: AppTypography.sans(
                    fontSize: 13,
                    color: const Color(0xFF477FAF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: contactEmail));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Email address copied to clipboard! 📋"),
                    backgroundColor: Color(0xFF26374A),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF26374A), width: 1.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF26374A)),
                    const SizedBox(width: 4),
                    Text(
                      "Copy",
                      style: AppTypography.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF26374A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
