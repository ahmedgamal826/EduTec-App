import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final double cardHeight;
  final double fontSizeTitle;
  final double fontSizeSubtitle;
  final BoxConstraints constraints;
  final String courseName;
  final String semester;
  final String date;
  final void Function(BuildContext context) onMorePressed;

  const CourseCard({
    super.key,
    required this.cardHeight,
    required this.fontSizeTitle,
    required this.fontSizeSubtitle,
    required this.constraints,
    required this.courseName,
    required this.semester,
    required this.date,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.asset(
              "assets/images/1.jpg",
              fit: BoxFit.cover,
              width: double.infinity,
              height: cardHeight,
            ),
            Container(
              height: cardHeight,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: constraints.maxWidth * 0.75,
                    child: Text(
                      courseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      semester,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSizeSubtitle,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => onMorePressed(context),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 12,
              right: 20,
              child: Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSizeSubtitle,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
