// Path: lib/features/analysis/presentation/widgets/bar_chart_student.dart

import 'package:flutter/material.dart';

import '../../../models/student_score_student.dart';

class BarChartStudent extends StatelessWidget {
  final List<StudentScoreStudent> studentScores;
  final double animationValue;
  final bool isSmallScreen;
  final bool isMediumScreen;
  final Color themeColor;

  const BarChartStudent({
    super.key,
    required this.studentScores,
    required this.animationValue,
    this.isSmallScreen = false,
    this.isMediumScreen = false,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    // Adjust padding and font size based on screen size
    final containerPadding = isSmallScreen ? 8.0 : 16.0;
    final axisFontSize = isSmallScreen ? 9.0 : 12.0;
    final labelFontSize = isSmallScreen ? 10.0 : 12.0;
    
    // Increase bar width for better visibility
    final barWidth = isSmallScreen ? 40.0 : (isMediumScreen ? 50.0 : 60.0);

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: themeColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                top: containerPadding,
                right: containerPadding / 2,
                bottom: 0, // Remove bottom padding to prevent overflow
                left: containerPadding,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Y-Axis with values every 10 units
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('100',
                              style: TextStyle(
                                  fontSize: axisFontSize,
                                  color: Colors.grey[700])),
                          Text('90',
                              style: TextStyle(
                                  fontSize: axisFontSize,
                                  color: Colors.grey[700])),
                          Text('80',
                              style: TextStyle(
                                  fontSize: axisFontSize,
                                  color: Colors.grey[700])),
                          Text('70',
                              style: TextStyle(
                                  fontSize: axisFontSize,
                                  color: Colors.grey[700])),
                          Text('60',
                              style: TextStyle(
                                  fontSize: axisFontSize,
                                  color: Colors.grey[700])),
                          Text('50',
                              style: TextStyle(
                                  fontSize: axisFontSize,
                                  color: Colors.grey[700])),
                          Text('40',
                              style: TextStyle(
                                  fontSize: axisFontSize,
                                  color: Colors.grey[700])),
                          Text('30',
                              style: TextStyle(
                                  fontSize: axisFontSize,
                                  color: Colors.grey[700])),
                          Text('20',
                              style: TextStyle(
                                  fontSize: axisFontSize,
                                  color: Colors.grey[700])),
                          Text('10',
                              style: TextStyle(
                                  fontSize: axisFontSize,
                                  color: Colors.grey[700])),
                          Text('0',
                              style: TextStyle(
                                  fontSize: axisFontSize,
                                  color: Colors.grey[700])),
                        ],
                      ),
                      const SizedBox(width: 10),
                      // Chart Area
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: studentScores.map((score) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 4.0 : 8.0), // Reduced padding to fit wider bars
                                    child: _buildBarWithLabel(
                                      score.score * animationValue,
                                      score.name,
                                      score.color,
                                      constraints.maxHeight - 30, // Further reduced height to avoid overflow
                                      barWidth,
                                      labelFontSize,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 8), // Reduced space before the red line
                            // X-Axis Line (خط المحور الأفقي)
                            Container(
                              height: 2,
                              color: Colors.red.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarWithLabel(
    double value,
    String label,
    Color color,
    double maxHeight,
    double barWidth,
    double labelFontSize,
  ) {
    // Calculate the actual height of the bar based on percentage
    final double adjustedMaxHeight = maxHeight - 8; // Further reduced subtraction to avoid overflow
    final double barHeight = (value / 100) * adjustedMaxHeight;

    // Store the actual value for display
    final int displayValue = value.toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Transparent container for full height
            Container(
              width: barWidth,
              height: adjustedMaxHeight,
              color: Colors.transparent,
            ),

            // Main bar with solid color
            Container(
              width: barWidth,
              height: barHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              // Add diagonal stripes pattern for visual interest
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(child: Container()),
                  if (barHeight > 15)
                    ClipRect(
                      child: Container(
                        width: barWidth,
                        height: 15, // Fixed height for pattern
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          backgroundBlendMode: BlendMode.multiply,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Value label centered in the bar
            if (barHeight >
                labelFontSize * 1.5) // Only show if there's enough room
              Positioned(
                bottom: barHeight / 2 - labelFontSize / 2,
                child: Text(
                  '$displayValue',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: labelFontSize,
                  ),
                ),
              ),
          ],
        ),
        // Remove the SizedBox to save vertical space
        SizedBox(
          width: barWidth,
          child: Text(
            label,
            style:
                TextStyle(fontSize: labelFontSize, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
