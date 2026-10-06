import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:streambeats/l10n/app_localizations.dart';
import 'package:streambeats/screens/screen/home_views/setting_views/about.dart';
import 'package:streambeats/screens/screen/home_views/setting_views/appui_setting.dart';
import 'package:streambeats/screens/screen/home_views/setting_views/statistics_view.dart';
import 'package:streambeats/screens/screen/home_views/timer_view.dart';
import 'package:streambeats/screens/screen/player_views/equalizer_view.dart';

import 'package:streambeats/screens/widgets/snackbar.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:streambeats/screens/screen/home_views/setting_view.dart';
import 'package:streambeats/services/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeSidebarDrawer extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeSidebarDrawer({
    super.key,
    required this.navigationShell,
  });


  void _showFeedbackDialog(BuildContext context) {
    final nameController = TextEditingController();
    final messageController = TextEditingController();
    int rating = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF161618),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Kirim Umpan Balik',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukan Anda sangat berharga bagi kami untuk mengembangkan StreamBeats.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              // Rating Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? MingCute.star_fill : MingCute.star_line,
                      color: Colors.amber,
                      size: 28,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 12),
              // Name input
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Nama Anda (opsional)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF222225),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Message input
              TextField(
                controller: messageController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tulis saran, kritik atau laporkan bug...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF222225),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                SnackbarService.showMessage('Terima kasih atas umpan balik Anda!');
              },
              child: const Text('Kirim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161618),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Pusat Bantuan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Bagaimana cara memutar lagu?',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Masuk ke menu Cari, lalu cari lagu, artis, atau album. Pastikan plugin pemutar musik sudah aktif di Pengaturan → Plugin.',
                  style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
                ),
                SizedBox(height: 16),
                Text(
                  '2. Cara mengunduh lagu untuk offline?',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Buka daftar lagu, klik tombol tiga titik di sebelah kanan lagu, lalu pilih "Unduh Lagu". Lagu Anda akan tersimpan di menu Offline.',
                  style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
                ),
                SizedBox(height: 16),
                Text(
                  '3. Mengapa tidak bisa memutar musik?',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Periksa koneksi internet Anda atau pastikan plugin repository diatur dengan benar di Pengaturan.',
                  style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F11),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return const ShareBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIdx = navigationShell.currentIndex;

    return Drawer(
      backgroundColor: const Color(0xFF0B0B0C),
      child: SafeArea(
        child: Column(
          children: [
            // User profile section wrapped in StreamBuilder auth listener
            StreamBuilder<AuthState>(
              stream: SupabaseAuthService.authStateChanges,
              builder: (context, snapshot) {
                final user = SupabaseAuthService.currentUser;
                String displayName = 'Guest';
                String subtitle = 'StreamBeats Official Music';
                String? avatarUrl;

                if (user != null) {
                  final meta = user.userMetadata ?? {};
                  displayName = meta['full_name'] ?? user.email?.split('@')[0] ?? 'User';
                  avatarUrl = meta['avatar_url'];
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Row(
                    children: [
                      // Circle Avatar
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: avatarUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(avatarUrl),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: AssetImage('assets/icons/streambeats_logo.png'),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        child: avatarUrl == null
                            ? const Center(
                                child: Icon(Icons.person, color: Colors.white24, size: 28),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      // User Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Muted divider
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),

            // Scrollable Menu List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // --- MENU SECTION ---
                  _buildSectionTitle('MENU'),
                  _buildDrawerItem(
                    label: l10n.navHome,
                    icon: currentIdx == 0 ? MingCute.home_4_fill : MingCute.home_4_line,
                    isSelected: currentIdx == 0,
                    onTap: () {
                      Navigator.pop(context);
                      navigationShell.goBranch(0);
                    },
                  ),
                  _buildDrawerItem(
                    label: l10n.navLibrary,
                    icon: currentIdx == 1 ? MingCute.book_5_fill : MingCute.book_5_line,
                    isSelected: currentIdx == 1,
                    onTap: () {
                      Navigator.pop(context);
                      navigationShell.goBranch(1);
                    },
                  ),
                  _buildDrawerItem(
                    label: l10n.navSearch,
                    icon: currentIdx == 2 ? MingCute.search_2_fill : MingCute.search_2_line,
                    isSelected: currentIdx == 2,
                    onTap: () {
                      Navigator.pop(context);
                      navigationShell.goBranch(2);
                    },
                  ),
                  _buildDrawerItem(
                    label: l10n.navLocal,
                    icon: currentIdx == 3 ? MingCute.music_2_fill : MingCute.music_2_line,
                    isSelected: currentIdx == 3,
                    onTap: () {
                      Navigator.pop(context);
                      navigationShell.goBranch(3);
                    },
                  ),
                  _buildDrawerItem(
                    label: l10n.navOffline,
                    icon: currentIdx == 4 ? MingCute.folder_download_fill : MingCute.folder_download_line,
                    isSelected: currentIdx == 4,
                    showDot: true,
                    onTap: () {
                      Navigator.pop(context);
                      navigationShell.goBranch(4);
                    },
                  ),

                  const SizedBox(height: 16),
                  // --- FITUR SECTION ---
                  _buildSectionTitle('FITUR'),
                  _buildDrawerItem(
                    label: 'Sleep Timer',
                    icon: MingCute.stopwatch_line,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TimerView()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Equalizer',
                    icon: Icons.equalizer_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EqualizerView()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Tema',
                    icon: MingCute.palette_line,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AppUISettings()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Statistik',
                    icon: Icons.bar_chart_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StatisticsView()),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  // --- LAINNYA SECTION ---
                  _buildSectionTitle('LAINNYA'),
                  _buildDrawerItem(
                    label: 'Tentang Aplikasi',
                    icon: Icons.info_outline_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const About()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Kirim Umpan Balik',
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      _showFeedbackDialog(context);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Bantuan',
                    icon: Icons.help_outline_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      _showHelpDialog(context);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Bagikan Aplikasi',
                    icon: Icons.share_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      _shareApp(context);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Pengaturan',
                    icon: Icons.settings_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsView()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Muted divider
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),

            // Footer Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Exit (Keluar) Button
                  GestureDetector(
                    onTap: () {
                      SystemNavigator.pop();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.15),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(MingCute.exit_line, color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Keluar',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                   // Dynamic Version text
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final version = snapshot.data?.version ?? '3.2.2';
                      final build = snapshot.data?.buildNumber ?? '3';
                      return Text(
                        'StreamBeats v$version+$build',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.35),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isSelected = false,
    bool showDot = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: showDot
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF9C27B0),
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}

class ShareBottomSheet extends StatelessWidget {
  const ShareBottomSheet({super.key});

  static const String shareUrl = 'https://streambeats.valoraofficial.workers.dev/';
  static const String shareText = 'Download StreamBeats sekarang! Pemutar musik gratis tanpa iklan: $shareUrl';

  Future<void> _launchShareUrl(String platform) async {
    Uri? uri;
    switch (platform) {
      case 'whatsapp':
        uri = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(shareText)}');
        break;
      case 'telegram':
        uri = Uri.parse('https://t.me/share/url?url=${Uri.encodeComponent(shareUrl)}&text=${Uri.encodeComponent("Download StreamBeats sekarang! Pemutar musik gratis tanpa iklan!")}');
        break;
      case 'facebook':
        uri = Uri.parse('https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(shareUrl)}');
        break;
      case 'twitter':
        uri = Uri.parse('https://twitter.com/intent/tweet?text=${Uri.encodeComponent("Download StreamBeats sekarang! Pemutar musik gratis tanpa iklan!")}&url=${Uri.encodeComponent(shareUrl)}');
        break;
    }

    if (uri != null) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        SnackbarService.showMessage('Tidak dapat membuka aplikasi $platform');
      }
    }
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: shareUrl));
    SnackbarService.showMessage('Tautan berhasil disalin ke papan klip!');
  }

  void _shareNative() {
    // ignore: deprecated_member_use
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F11),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Indicator
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bagikan StreamBeats',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Bagikan pemutar musik gratis tanpa iklan ini',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Options Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareOption(
                icon: MingCute.whatsapp_fill,
                label: 'WhatsApp',
                iconColor: const Color(0xFF25D366),
                onTap: () => _launchShareUrl('whatsapp'),
              ),
              _buildShareOption(
                icon: MingCute.telegram_fill,
                label: 'Telegram',
                iconColor: const Color(0xFF26A5E4),
                onTap: () => _launchShareUrl('telegram'),
              ),
              _buildShareOption(
                icon: MingCute.facebook_fill,
                label: 'Facebook',
                iconColor: const Color(0xFF1877F2),
                onTap: () => _launchShareUrl('facebook'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareOption(
                icon: MingCute.twitter_fill,
                label: 'Twitter / X',
                iconColor: Colors.white,
                onTap: () => _launchShareUrl('twitter'),
              ),
              _buildShareOption(
                icon: MingCute.copy_2_fill,
                label: 'Salin Tautan',
                iconColor: const Color(0xFF9E9E9E),
                onTap: () => _copyToClipboard(context),
              ),
              _buildShareOption(
                icon: MingCute.share_forward_fill,
                label: 'Lainnya',
                iconColor: const Color(0xFF9E9E9E),
                onTap: _shareNative,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Link Preview Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    shareUrl,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _copyToClipboard(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Salin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

