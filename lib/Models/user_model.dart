class User {
  final String id;
  final String name;
  final String email;
  final String enrollmentNo;
  final String course;
  final String year;
  final String phonenumber;
  final String hostelblock;
  final String room;
  final String gender;
  
  // ✅ REMOVE 'final' from these two so they can be updated
  bool isApproved; 
  DateTime? accessExpiresAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.enrollmentNo,
    required this.course,
    required this.year,
    required this.phonenumber,
    required this.hostelblock,
    required this.room,
    required this.isApproved,
    required this.gender,
    this.accessExpiresAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Guest',
      email: json['email'] ?? '',
      enrollmentNo: json['enrollmentNo']?.toString() ?? '',
      course: json['course'] ?? '',
      year: json['year']?.toString() ?? '',
      phonenumber: json['phonenumber']?.toString() ?? '',
      hostelblock: json['hostelblock'] ?? '',
      room: json['room']?.toString() ?? '',
      isApproved: json['isApproved'] ?? false,
      gender: json['gender'] ?? '',
      accessExpiresAt: json['accessExpiresAt'] != null 
          ? DateTime.parse(json['accessExpiresAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'enrollmentNo': enrollmentNo,
      'course': course,
      'year': year,
      'phonenumber': phonenumber,
      'hostelblock': hostelblock,
      'room': room,
      'isApproved': isApproved,
      'gender': gender,
      'accessExpiresAt': accessExpiresAt?.toIso8601String(),
    };
  }
}