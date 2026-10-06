import 'package:flutter/material.dart';

import 'package:streambeats/core/theme/app_theme.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class PlayPauseButton extends StatefulWidget {
  final double size;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final bool isPlaying;
  const PlayPauseButton({
    super.key,
    this.size = 60,
    this.onPlay,
    this.onPause,
    this.isPlaying = false,
  });
  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _setupAnimations();

    if (widget.isPlaying) {
      _colorController.value = 1.0;
    }
  }

  void _setupAnimations() {
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = ColorTween(
      begin: Colors.white.withValues(alpha: 0.4),
      end: Colors.white.withValues(alpha: 0.4),
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant PlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _colorController.forward();
      } else {
        _colorController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (widget.isPlaying) {
      widget.onPause?.call();
    } else {
      widget.onPlay?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: AnimatedBuilder(
        animation: _colorController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: _glowAnimation.value ?? Default_Theme.accentColor2,
                  spreadRadius: 1,
                  blurRadius: 20,
                )
              ],
              shape: BoxShape.circle,
              color: _colorAnimation.value,
            ),
            width: size,
            height: size,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: Tween<double>(begin: 0.5, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: widget.isPlaying
                    ? Icon(
                        FontAwesome.pause_solid,
                        key: const ValueKey('pause'),
                        size: size * 0.5,
                        color: Colors.black,
                      )
                    : Icon(
                        MingCute.play_fill,
                        key: const ValueKey('play'),
                        size: size * 0.5,
                        color: Colors.black,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}