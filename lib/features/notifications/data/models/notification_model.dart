
class NotificationModel {
  final String id;
  final String subject;
  final String description;
  final String date;
  final String? time;  // وقت إنشاء الإشعار
  final String? courseId;
  final String? type;
  final String? createdBy;
  final String? createdByName;  // اسم منشئ الإشعار (مثل اسم الدكتور)
  final String? deadline;  // الموعد النهائي للواجب
  final List<String>? recipients; // قائمة بمعرفات المستخدمين الذين سيتلقون الإشعار
  final bool isRead; // حالة قراءة الإشعار

  NotificationModel({
    required this.id,
    required this.subject,
    required this.description,
    required this.date,
    this.time,
    this.courseId,
    this.type,
    this.createdBy,
    this.createdByName,
    this.deadline,
    this.recipients,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      time: map['time'],
      courseId: map['courseId'],
      type: map['type'],
      createdBy: map['createdBy'],
      createdByName: map['createdByName'],
      deadline: map['deadline'],
      recipients: map['recipients'] != null
          ? List<String>.from(map['recipients'])
          : null,
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'description': description,
      'date': date,
      'time': time,
      'courseId': courseId,
      'type': type,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'deadline': deadline,
      'recipients': recipients,
      'isRead': isRead,
    };
  }

  // إنشاء نسخة جديدة مع تغيير حالة القراءة
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      subject: subject,
      description: description,
      date: date,
      time: time,
      courseId: courseId,
      type: type,
      createdBy: createdBy,
      createdByName: createdByName,
      deadline: deadline,
      recipients: recipients,
      isRead: isRead ?? this.isRead,
    );
  }
} 