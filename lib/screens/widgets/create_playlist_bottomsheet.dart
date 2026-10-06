import 'package:streambeats/blocs/library/cubit/library_items_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:streambeats/core/theme/app_theme.dart';
import 'package:streambeats/l10n/app_localizations.dart';
import 'package:streambeats/services/supabase_playlist_service.dart';
import 'package:streambeats/routes/app_router.dart';
import 'package:streambeats/screens/widgets/snackbar.dart';

void createPlaylistDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: l10n.createPlaylistDialogBarrierLabel,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    transitionDuration: const Duration(milliseconds: 250), // Slightly faster
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _CreatePlaylistDialog();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05), // Starts slightly lower and slides up
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

class _CreatePlaylistDialog extends StatefulWidget {
  const _CreatePlaylistDialog({Key? key}) : super(key: key);

  @override
  State<_CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<_CreatePlaylistDialog> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isShared = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.addListener(() {
      setState(() {});
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isInputValid => _controller.text.trim().length > 2;

  void _submit() async {
    if (_isInputValid) {
      final title = _controller.text.trim();
      if (_isShared) {
        try {
          final code = await SupabasePlaylistService.createSharedPlaylist(title, []);
          if (code != null) {
            context.pop(); // Dismiss the dialog
            SnackbarService.showMessage('Berhasil! Kode Playlist: $code');
            context.pushNamed('SharedPlaylist', queryParameters: {'code': code});
          } else {
            SnackbarService.showMessage('Gagal membuat playlist bersama.');
          }
        } catch (e) {
          SnackbarService.showMessage('Gagal: ${e.toString().replaceAll('Exception: ', '')}');
        }
      } else {
        context.read<LibraryItemsCubit>().createPlaylist(title);
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset / 2.5 : 0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A), // Floating grey box
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.playlistCreateNew,
                          style: Default_Theme.secondoryTextStyleMedium.merge(
                            const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isInputValid 
                                ? Colors.white.withValues(alpha: 0.5) 
                                : Colors.white.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            textInputAction: TextInputAction.done,
                            maxLines: 1,
                            maxLength: 35,
                            cursorColor: Colors.white,
                            cursorWidth: 3,
                            cursorRadius: const Radius.circular(3),
                            style: Default_Theme.secondoryTextStyleMedium.merge(
                              const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            decoration: InputDecoration(
                              counterText: "",
                              hintText: l10n.createPlaylistDialogNameHint,
                              hintStyle: Default_Theme.secondoryTextStyleMedium.merge(
                                TextStyle(
                                  fontSize: 20,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onSubmitted: (_) => _submit(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Theme(
                          data: Theme.of(context).copyWith(
                            listTileTheme: const ListTileThemeData(
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          child: SwitchListTile(
                            title: const Text('Jadikan Playlist Bersama', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                            subtitle: const Text('Dengarkan dan kelola lagu bersama teman', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            value: _isShared,
                            onChanged: (val) {
                              setState(() {
                                _isShared = val;
                              });
                            },
                            activeColor: Colors.white,
                            activeTrackColor: Default_Theme.primaryColor1,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context.pop(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  l10n.buttonCancel,
                                  style: Default_Theme.secondoryTextStyleMedium.merge(
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  l10n.createPlaylistDialogCreate,
                                  style: Default_Theme.secondoryTextStyleMedium.merge(
                                    TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isInputValid ? Colors.black : Colors.white54,
                                    ),
                                  ),
                                ),
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
          ),
        ),
      ),
    );
  }
}