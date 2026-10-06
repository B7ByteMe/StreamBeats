import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:streambeats/core/theme/app_theme.dart';
import 'package:streambeats/services/supabase_playlist_service.dart';
import 'package:streambeats/screens/widgets/snackbar.dart';
import 'package:streambeats/routes/app_router.dart';

void joinSharedPlaylistDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Join Shared Playlist',
    barrierColor: Colors.black.withValues(alpha: 0.85),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _JoinSharedPlaylistDialog();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(curve),
        child: FadeTransition(
          opacity: curve,
          child: RepaintBoundary(child: child),
        ),
      );
    },
  );
}

class _JoinSharedPlaylistDialog extends StatefulWidget {
  const _JoinSharedPlaylistDialog({Key? key}) : super(key: key);

  @override
  State<_JoinSharedPlaylistDialog> createState() => _JoinSharedPlaylistDialogState();
}

class _JoinSharedPlaylistDialogState extends State<_JoinSharedPlaylistDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isInputValid => _controller.text.trim().length >= 5;

  void _submit() async {
    if (_isInputValid) {
      final code = _controller.text.trim().toUpperCase();
      context.pop();
      SnackbarService.showMessage('Mencari playlist...');
      
      final success = await SupabasePlaylistService.joinPlaylist(code);
      if (success) {
        SnackbarService.showMessage('Berhasil bergabung!');
        context.pushNamed('SharedPlaylist', queryParameters: {'code': code});
      } else {
        SnackbarService.showMessage('Playlist tidak ditemukan atau kode salah.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset / 2.5 : 0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gabung Playlist',
                    style: Default_Theme.secondoryTextStyleMedium.merge(
                      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Masukkan kode unik yang dibagikan oleh teman Anda.', style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isInputValid ? Colors.white.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Kode (Misal: X9K2LM)',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Batal', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isInputValid ? _submit : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white.withValues(alpha: 0.2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text('Gabung', style: TextStyle(color: _isInputValid ? Colors.black : Colors.white54, fontWeight: FontWeight.bold)),
                        ),
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
