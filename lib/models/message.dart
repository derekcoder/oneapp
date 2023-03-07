class Message {
  Message({required this.content, required this.role, required this.date});

  final String content;
  final Role role;
  final DateTime date;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'] as String,
      role: json['role'] == 'user' ? Role.user : Role.assistant,
      date: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'role': role.name,
    };
  }
}

enum Role {
  user,
  assistant,
}
