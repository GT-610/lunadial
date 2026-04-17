import 'dart:async';

import 'package:flutter/material.dart';

class BurnInProtectionLayer extends StatefulWidget {
  const BurnInProtectionLayer({
    super.key,
    required this.enabled,
    required this.child,
    this.stepDuration = const Duration(seconds: 45),
  });

  final bool enabled;
  final Widget child;
  final Duration stepDuration;

  @override
  State<BurnInProtectionLayer> createState() => _BurnInProtectionLayerState();
}

class _BurnInProtectionLayerState extends State<BurnInProtectionLayer> {
  static const List<Offset> _offsets = [
    Offset(0, 0),
    Offset(3, -2),
    Offset(-2, 2),
    Offset(2, 3),
    Offset(-3, -1),
  ];

  Timer? _timer;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant BurnInProtectionLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.stepDuration != widget.stepDuration) {
      _syncTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncTimer() {
    _timer?.cancel();
    if (!widget.enabled) {
      if (_index != 0) {
        setState(() {
          _index = 0;
        });
      }
      return;
    }

    _timer = Timer.periodic(widget.stepDuration, (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _index = (_index + 1) % _offsets.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final offset = widget.enabled ? _offsets[_index] : Offset.zero;
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: Offset.zero, end: offset),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, animatedOffset, child) {
        return Transform.translate(
          key: const Key('burn-in-transform'),
          offset: animatedOffset,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
