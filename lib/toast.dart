import 'package:flutter/material.dart';

class CustomToast extends StatefulWidget {
  final String message;
  final Duration duration;

  CustomToast({required this.message, this.duration = const Duration(seconds: 2)});

  @override
  _CustomToastState createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    );

    _controller!.forward();
    Future.delayed(widget.duration, () {
      _controller!.reverse().then((_) => Navigator.of(context).pop());
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation!,
      child: Center(
        child: Material(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Text(
              widget.message,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ),
        ),
      ),
    );
  }
}

void showToast(BuildContext context, String message) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (BuildContext context, _, __) {
        return CustomToast(message: message);
      },
    ),
  );
}


  void confirmDialog(BuildContext context, String msg, void Function() on) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(msg),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                on();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }