import 'package:attendance_app/core/utils/app_colors.dart';
import 'package:attendance_app/features/analysis/models/student_score_admin.dart';
import 'package:flutter/material.dart';

class tBarChartAdmin extends StatefulWidget {
  final List<StudentScoreAdmin> studentScores;
  final double animationValue;
  final bool isSmallScreen;
  final bool isMediumScreen;

  const tBarChartAdmin({
    super.key,
    required this.studentScores,
    required this.animationValue,
    this.isSmallScreen = false,
    this.isMediumScreen = false,
  });

  @override
  State<tBarChartAdmin> createState() => _tBarChartAdminState();
}

class _tBarChartAdminState extends State<tBarChartAdmin> {
  int? selectedIndex; // To track which bar was tapped
  Offset? tapPosition;
  String? selectedStudentName; // To track selected student name

  @override
  Widget build(BuildContext context) {
    final containerPadding = widget.isSmallScreen ? 8.0 : 16.0;
    final titleFontSize = widget.isSmallScreen ? 14.0 : 18.0;
    final axisFontSize = widget.isSmallScreen ? 12.0 : 15.0;
    final labelFontSize = widget.isSmallScreen ? 8.0 : 10.0;
    final barWidth = widget.isSmallScreen
        ? 20.0
        : (widget.isMediumScreen ? 25.0 : 32.0); // Increased bar width

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Best 5 Students\' Analysis',
              style: TextStyle(
                color: Colors.blue,
                fontFamily: 'Poppins',
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: widget.isSmallScreen ? 10 : 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight =
                    constraints.maxHeight - 40; // Reserve space for labels
                return Stack(
                  // Use Stack to position the label container
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Y-Axis
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('100',
                                style: TextStyle(
                                    fontSize: axisFontSize,
                                    color: Colors.grey[600])),
                            Text('90',
                                style: TextStyle(
                                    fontSize: axisFontSize,
                                    color: Colors.grey[600])),
                            Text('80',
                                style: TextStyle(
                                    fontSize: axisFontSize,
                                    color: Colors.grey[600])),
                            Text('70',
                                style: TextStyle(
                                    fontSize: axisFontSize,
                                    color: Colors.grey[600])),
                            Text('60',
                                style: TextStyle(
                                    fontSize: axisFontSize,
                                    color: Colors.grey[600])),
                            Text('50',
                                style: TextStyle(
                                    fontSize: axisFontSize,
                                    color: Colors.grey[600])),
                            Text('40',
                                style: TextStyle(
                                    fontSize: axisFontSize,
                                    color: Colors.grey[600])),
                            Text('30',
                                style: TextStyle(
                                    fontSize: axisFontSize,
                                    color: Colors.grey[600])),
                            Text('20',
                                style: TextStyle(
                                    fontSize: axisFontSize,
                                    color: Colors.grey[600])),
                            Text('10',
                                style: TextStyle(
                                    fontSize: axisFontSize,
                                    color: Colors.grey[600])),
                            Text('0',
                                style: TextStyle(
                                    fontSize: axisFontSize,
                                    color: Colors.grey[600])),
                          ],
                        ),
                        const SizedBox(width: 5),
                        // Chart Area
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTapDown: (details) {
                                    final barWidthTotal = barWidth * 5 +
                                        20; // Total width of bars + spacing
                                    final tapX = details.localPosition.dx;
                                    final index = (tapX / barWidthTotal * 5)
                                        .floor()
                                        .clamp(0, 4);
                                    setState(() {
                                      tapPosition = details.localPosition;
                                      selectedIndex = index;
                                      selectedStudentName =
                                          widget.studentScores.length > index
                                              ? widget.studentScores[index].name
                                              : 'Unknown';
                                    });
                                  },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(5, (index) {
                                      final score =
                                          widget.studentScores.length > index
                                              ? widget.studentScores[index]
                                              : StudentScoreAdmin(
                                                  'Student ${index + 1}', 0);

                                      // A real student must have a non-zero score (at least 5% to be considered)
                                      bool isRealStudent =
                                          widget.studentScores.length > index &&
                                              score.score > 5.0;

                                      // For debugging
                                      if (widget.studentScores.length > index) {
                                        print(
                                            "Bar $index: ${score.name} - Total: ${score.score.toStringAsFixed(1)}%, Attendance: ${score.attendanceScore.toStringAsFixed(1)}%, Assignments: ${score.assignmentScore.toStringAsFixed(1)}%, Tests: ${score.testScore.toStringAsFixed(1)}%");
                                      }

                                      // Use student's first name only if available
                                      String displayName = isRealStudent
                                          ? score.name.split(' ').first
                                          : 'Student ${index + 1}';

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedIndex = index;
                                            selectedStudentName = isRealStudent
                                                ? score.name
                                                : 'Student ${index + 1}';
                                          });
                                        },
                                        child: _buildBarWithLabel(
                                          // Only show a bar with actual height if student has data
                                          isRealStudent
                                              ? score.score *
                                                  widget.animationValue
                                              : 0,
                                          displayName,
                                          // Blue for real students, grey for placeholders
                                          isRealStudent
                                              ? Colors.blue.shade600
                                              : Colors.grey.shade300,
                                          availableHeight,
                                          barWidth,
                                          labelFontSize,
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              // X-Axis Line
                              Container(
                                height: 2,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Display selected student name next to the bar
                    if (selectedIndex != null && tapPosition != null)
                      Positioned(
                        left: (barWidth * selectedIndex! +
                            (selectedIndex! * 5) +
                            barWidth / 2), // Position centered above bar
                        top: (tapPosition!.dy - 90).clamp(
                            20.0,
                            availableHeight +
                                20), // Adjust vertically to ensure visibility
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[200]!, Colors.blue[400]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.studentScores.length > selectedIndex!
                                ? '${selectedStudentName ?? 'غير معروف'}\nإجمالي: ${widget.studentScores[selectedIndex!].score.toStringAsFixed(1)}%\nالحضور: ${widget.studentScores[selectedIndex!].attendanceScore.toStringAsFixed(1)}%\nالواجبات: ${widget.studentScores[selectedIndex!].assignmentScore.toStringAsFixed(1)}%\nالاختبارات: ${widget.studentScores[selectedIndex!].testScore.toStringAsFixed(1)}%'
                                : '${selectedStudentName ?? 'غير معروف'}\n0%',
                            style: TextStyle(
                              fontSize: labelFontSize + 2,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
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
    final double barHeight = (value / 100) * maxHeight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: barWidth,
          height: barHeight > maxHeight ? maxHeight : barHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        FittedBox(
          child: Text(
            label,
            style:
                TextStyle(fontSize: labelFontSize, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
