import 'dart:math';
import 'package:flutter/material.dart';

class AntiGravityWidget extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration speed;
  final Duration delay;

  const AntiGravityWidget({
    super.key,
    required this.child,
    this.amplitude = 8.0,
    this.speed = const Duration(seconds: 4),
    this.delay = Duration.zero,
  });

  @override
  State<AntiGravityWidget> createState() => _AntiGravityWidgetState();
}

class _AntiGravityWidgetState extends State<AntiGravityWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.speed,
    );

    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    // Start with subtle delay if provided
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Organic vertical floating motion using sine wave
        final double offset = sin(_animation.value) * widget.amplitude;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
