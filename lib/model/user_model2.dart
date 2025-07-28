class ClientModel {
  final String name;
  final String email;
  final String username;
  final DateTime createdAT;
  final String imageUrl;
  final int userPoint;
  final String userRole;
  final int availablePoints;
  final DateTime lastResetMonth;
  final String department;

  ClientModel(
      {required this.createdAT,
      required this.name,
      required this.userPoint,
      required this.lastResetMonth,
      required this.availablePoints,
      required this.email,
      //  required this.taskManager,
      //  required this.taskManager1,
      //  required this.taskManager2,
      required this.username,
      required this.userRole,
      required this.imageUrl,
      required this.department,
      });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'created': createdAT,
      'imageUrl': 'noImage',
      'points': userPoint,
      'availablePoints': availablePoints,
      'lastResetMonth': lastResetMonth,
      'role': userRole,
      'department': department,
    };
  }
}
