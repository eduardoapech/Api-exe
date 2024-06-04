// class NotificationMessage {
//   final int id;
//   final String message;
//   final bool read;

//   NotificationMessage({
//     required this.id,
//     required this.message,
//     required this.read,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'message': message,
//       'read': read ? 1 : 0,
//     };
//   }

//   factory NotificationMessage.fromMap(Map<String, dynamic> map) {
//     return NotificationMessage(
//       id: map['id'],
//       message: map['message'],
//       read: map['read'] == 1,
//     );
//   }
// }
