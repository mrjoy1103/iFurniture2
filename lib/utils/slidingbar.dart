import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SlidingBar extends StatefulWidget {
  final String message;
  final bool isError;

  const SlidingBar({super.key, required this.message, this.isError = false});

  @override
  _SlidingBarState createState() => _SlidingBarState();
}

class _SlidingBarState extends State<SlidingBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _animationController.reverse().then((_) {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        elevation: 10,
        color: widget.isError ? Colors.red : Colors.green,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
