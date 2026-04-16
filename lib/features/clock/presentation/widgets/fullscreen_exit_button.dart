import 'dart:async';

import 'package:flutter/material.dart';

class FullscreenExitButton extends StatefulWidget {
  final VoidCallback onExit;
  final bool visibleSignal;

  const FullscreenExitButton({
    super.key,
    required this.onExit,
    required this.visibleSignal,
  });

  @override
  State<FullscreenExitButton> createState() => _FullscreenExitButtonState();
}

class _FullscreenExitButtonState extends State<FullscreenExitButton> {
  Timer? _timer;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _restartHideTimer();
  }

  @override
  void didUpdateWidget(covariant FullscreenExitButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visibleSignal != widget.visibleSignal) {
      _showTemporarily();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showTemporarily() {
    setState(() {
      _isVisible = true;
    });
    _restartHideTimer();
  }

  void _restartHideTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: IconButton(
        icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
        onPressed: widget.onExit,
      ),
    );
  }
}
