class StudentScoreAdmin {
  final String name;
  final double score;
  final double attendanceScore;
  final double assignmentScore;
  final double testScore;

  StudentScoreAdmin(
    this.name, 
    this.score, {
    this.attendanceScore = 0.0,
    this.assignmentScore = 0.0,
    this.testScore = 0.0,
  });
}
