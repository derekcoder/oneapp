class Chat {
  Chat({required this.content, required this.role});

  final String content;
  final Role role;

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      content: json['content'] as String,
      role: json['role'] == 'user' ? Role.user : Role.assistant,
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
