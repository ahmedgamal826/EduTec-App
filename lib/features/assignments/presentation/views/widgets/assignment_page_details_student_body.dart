import 'package:flutter/material.dart';
import '../../../data/models/question_model_student.dart';

class TestPageDetailsStudentBody extends StatelessWidget {
  final List<AssignmentQuestion> questions;
  final int currentQuestionIndex;
  final Function(int) onQuestionChanged;

  const TestPageDetailsStudentBody({
    super.key,
    required this.questions,
    required this.currentQuestionIndex,
    required this.onQuestionChanged,
  });

  // معاينة الصورة بشكل كامل
  void _showFullScreenImage(
    BuildContext context,
    String imagePath,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.85),
            body: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image with interactive viewer for zoom
                  Center(
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Close button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AssignmentQuestion currentQuestion = questions[currentQuestionIndex];

    // الألوان المستخدمة في التطبيق
    const Color primaryBlue = Color(0xFF1A75FF);
    const Color lightBlue = Color(0xFFF0F7FF);
    const Color mediumBlue = Color(0xFFE6F0FF);
    const Color correctGreen = Colors.green;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Question Container - Only show if current question doesn't have an image
          if (!currentQuestion.hasImage)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: primaryBlue,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question ${currentQuestionIndex + 1}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQuestion.questionText,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Image Container
          Container(
            width: double.infinity,
            height: 200, // ارتفاع الصورة
            decoration: BoxDecoration(
              color: mediumBlue,
              border: Border.all(
                color: primaryBlue,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: currentQuestion.hasImage
                ? GestureDetector(
                    onTap: () {
                      // افتح الصورة في وضع ملء الشاشة عند النقر عليها
                      _showFullScreenImage(
                        context,
                        currentQuestion.imagePath ?? "assets/images/img.png",
                      );
                    },
                    child: Stack(
                      children: [
                        // صورة السؤال
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              currentQuestion.imagePath ??
                                  "assets/images/img.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // وضع رقم السؤال في الأعلى
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Question ${currentQuestionIndex + 1}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        // أيقونة للإشارة إلى أن الصورة قابلة للتكبير
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 48,
                          color: primaryBlue.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Question Image",
                          style: TextStyle(
                            fontSize: 18,
                            color: primaryBlue.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          // Answer Options
          if (currentQuestion.questionType ==
              AssignmentQuestionType.trueOrFalse)
            _buildTrueFalseOptions(
                currentQuestion, primaryBlue, mediumBlue, correctGreen)
          else
            _buildMultipleChoiceOptions(
                currentQuestion, primaryBlue, mediumBlue, correctGreen),

          const Spacer(),

          // Bottom Questions List (Horizontal Scrollable)
          _buildQuestionsList(
              questions, currentQuestionIndex, primaryBlue, correctGreen),
        ],
      ),
    );
  }

  Widget _buildTrueFalseOptions(AssignmentQuestion currentQuestion,
      Color primaryBlue, Color mediumBlue, Color correctGreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // True option
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: currentQuestion.correctAnswer == 0
                  ? correctGreen.withOpacity(0.2)
                  : mediumBlue,
              border: Border.all(
                color: currentQuestion.correctAnswer == 0
                    ? correctGreen
                    : primaryBlue,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: currentQuestion.correctAnswer == 0
                      ? correctGreen
                      : primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  "True",
                  style: TextStyle(
                    color: currentQuestion.correctAnswer == 0
                        ? correctGreen
                        : primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                if (currentQuestion.correctAnswer == 0)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: correctGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // False option
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: currentQuestion.correctAnswer == 1
                  ? correctGreen.withOpacity(0.2)
                  : mediumBlue,
              border: Border.all(
                color: currentQuestion.correctAnswer == 1
                    ? correctGreen
                    : primaryBlue,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cancel,
                  color: currentQuestion.correctAnswer == 1
                      ? correctGreen
                      : primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  "False",
                  style: TextStyle(
                    color: currentQuestion.correctAnswer == 1
                        ? correctGreen
                        : primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                if (currentQuestion.correctAnswer == 1)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: correctGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceOptions(AssignmentQuestion currentQuestion,
      Color primaryBlue, Color mediumBlue, Color correctGreen) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Option 1
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: currentQuestion.correctAnswer == 0
                      ? correctGreen.withOpacity(0.2)
                      : mediumBlue,
                  border: Border.all(
                    color: currentQuestion.correctAnswer == 0
                        ? correctGreen
                        : primaryBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Text(
                  currentQuestion.options[0],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: currentQuestion.correctAnswer == 0
                        ? correctGreen
                        : primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Option 2
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: currentQuestion.correctAnswer == 1
                      ? correctGreen.withOpacity(0.2)
                      : mediumBlue,
                  border: Border.all(
                    color: currentQuestion.correctAnswer == 1
                        ? correctGreen
                        : primaryBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Text(
                  currentQuestion.options[1],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: currentQuestion.correctAnswer == 1
                        ? correctGreen
                        : primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Option 3
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: currentQuestion.correctAnswer == 2
                      ? correctGreen.withOpacity(0.2)
                      : mediumBlue,
                  border: Border.all(
                    color: currentQuestion.correctAnswer == 2
                        ? correctGreen
                        : primaryBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Text(
                  currentQuestion.options[2],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: currentQuestion.correctAnswer == 2
                        ? correctGreen
                        : primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Option 4
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: currentQuestion.correctAnswer == 3
                      ? correctGreen.withOpacity(0.2)
                      : mediumBlue,
                  border: Border.all(
                    color: currentQuestion.correctAnswer == 3
                        ? correctGreen
                        : primaryBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Text(
                  currentQuestion.options[3],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: currentQuestion.correctAnswer == 3
                        ? correctGreen
                        : primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionsList(List<AssignmentQuestion> questions,
      int currentQuestionIndex, Color primaryBlue, Color correctGreen) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: primaryBlue,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: questions.length,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              onQuestionChanged(index);
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: currentQuestionIndex == index
                    ? primaryBlue.withOpacity(0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: currentQuestionIndex == index
                      ? correctGreen
                      : primaryBlue,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: currentQuestionIndex == index
                            ? correctGreen
                            : primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      questions[index].questionType ==
                              AssignmentQuestionType.trueOrFalse
                          ? "صح/خطأ"
                          : questions[index].hasImage
                              ? "صورة"
                              : "اختيار",
                      style: TextStyle(
                        color: currentQuestionIndex == index
                            ? correctGreen
                            : primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
