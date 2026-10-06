import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:streambeats/core/theme/app_theme.dart';
import 'package:streambeats/services/supabase_party_service.dart';
import 'package:streambeats/screens/widgets/snackbar.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class PartyRoomScreen extends StatefulWidget {
  const PartyRoomScreen({Key? key}) : super(key: key);

  @override
  State<PartyRoomScreen> createState() => _PartyRoomScreenState();
}

class _PartyRoomScreenState extends State<PartyRoomScreen> {
  final _joinController = TextEditingController();

  @override
  void dispose() {
    _joinController.dispose();
    super.dispose();
  }

  void _createParty() async {
    SnackbarService.showMessage('Membuat ruang party...');
    final code = await SupabasePartyService.createParty();
    if (code != null) {
      SnackbarService.showMessage('Ruang dibuat! Kode: $code');
      setState(() {});
    } else {
      SnackbarService.showMessage('Gagal membuat ruang.');
    }
  }

  void _joinParty() async {
    final code = _joinController.text.trim().toUpperCase();
    if (code.length < 5) return;
    
    try {
      SnackbarService.showMessage('Bergabung ke $code...');
      final success = await SupabasePartyService.joinParty(code);
      if (success) {
        SnackbarService.showMessage('Berhasil bergabung!');
        if (mounted) setState(() {});
      } else {
        SnackbarService.showMessage('Gagal bergabung.');
      }
    } catch (e) {
      SnackbarService.showMessage('Gagal bergabung: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  void _leaveParty() async {
    try {
      await SupabasePartyService.leaveParty();
      SnackbarService.showMessage('Meninggalkan party.');
      if (mounted) setState(() {});
    } catch (e) {
      SnackbarService.showMessage('Gagal meninggalkan party: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final inParty = SupabasePartyService.currentRole != PartyRole.none;
    
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Default_Theme.primaryColor1),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Listen Together',
          style: TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: inParty ? _buildInPartyView() : _buildJoinCreateView(),
      ),
    );
  }

  Widget _buildJoinCreateView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(MingCute.music_2_fill, size: 80, color: Default_Theme.primaryColor1),
        const SizedBox(height: 24),
        const Text(
          'Dengarkan musik bersam-sama secara sinkron.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 48),
        FilledButton.icon(
          onPressed: _createParty,
          icon: const Icon(MingCute.add_circle_fill, color: Colors.black),
          label: const Text('Buat Ruang (Host)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          style: FilledButton.styleFrom(
            backgroundColor: Default_Theme.primaryColor1,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 32),
        const Text('ATAU', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
          ),
          child: TextField(
            controller: _joinController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Masukkan Kode Party',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _joinParty,
          icon: const Icon(MingCute.group_fill, color: Colors.white),
          label: const Text('Gabung (Guest)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildInPartyView() {
    final role = SupabasePartyService.currentRole == PartyRole.host ? 'Host' : 'Guest';
    final code = SupabasePartyService.currentRoomCode ?? '???';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cell_tower_rounded, size: 80, color: Default_Theme.accentColor2),
        const SizedBox(height: 24),
        const Text(
          'Anda sedang dalam Party!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text('Kode Ruang', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
              const SizedBox(height: 8),
              Text(code, style: const TextStyle(color: Default_Theme.primaryColor1, fontSize: 32, letterSpacing: 4, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(MingCute.user_3_fill, color: Colors.white54, size: 20),
                  const SizedBox(width: 8),
                  Text('Peran: $role', style: const TextStyle(color: Colors.white54, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              if (SupabasePartyService.currentRole == PartyRole.guest)
                const Text(
                  'Pemutaran musik Anda akan disinkronkan dengan Host.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Default_Theme.accentColor2, fontSize: 12),
                ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        FilledButton.icon(
          onPressed: _leaveParty,
          icon: const Icon(MingCute.exit_fill, color: Colors.white),
          label: const Text('Keluar dari Party', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
            foregroundColor: Colors.redAccent,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}
