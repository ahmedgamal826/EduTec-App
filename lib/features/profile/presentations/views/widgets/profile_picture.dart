import 'package:flutter/material.dart';

class ProfilePicture extends StatefulWidget {
  final String imageUrl;

  const ProfilePicture({super.key, required this.imageUrl});

  @override
  State<ProfilePicture> createState() => ProfilePictureState();
}

class ProfilePictureState extends State<ProfilePicture>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Move image loading logic here
    if (widget.imageUrl.isNotEmpty) {
      precacheImage(NetworkImage(widget.imageUrl), context).then((_) {
        if (mounted) {
          // Ensure the widget is still mounted before calling setState
          setState(() {
            _isImageLoaded = true;
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _isImageLoaded = true; // Treat as loaded to show fallback icon
          });
        }
      });
    } else {
      _isImageLoaded = true; // No image to load, show fallback immediately
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Profile Picture with Animation
        ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: widget.imageUrl.isNotEmpty && _isImageLoaded
                  ? NetworkImage(widget.imageUrl)
                  : null,
              child: widget.imageUrl.isEmpty || !_isImageLoaded
                  ? const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ),
        // Circular Loading Indicator Around the Avatar
        if (!_isImageLoaded && widget.imageUrl.isNotEmpty)
          SizedBox(
            width:
                164, // Slightly larger than the CircleAvatar (radius * 2 + padding)
            height: 164,
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
      ],
    );
  }
}
