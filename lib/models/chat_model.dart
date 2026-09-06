class ChatThread {
  final String id;
  final String kind; // private | group
  String title;
  final List<String> participantPhones;
  String participantPhone;
  String participantName;
  final String role;
  String lastMessage;
  DateTime updatedAt;
  int unreadCount;

  ChatThread({
    required this.id,
    this.kind = 'private',
    this.title = '',
    this.participantPhones = const [],
    required this.participantPhone,
    required this.participantName,
    required this.role,
    this.lastMessage = '',
    DateTime? updatedAt,
    this.unreadCount = 0,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'title': title,
        'participantPhones': participantPhones,
        'participantPhone': participantPhone,
        'participantName': participantName,
        'role': role,
        'lastMessage': lastMessage,
        'updatedAt': updatedAt.toIso8601String(),
        'unreadCount': unreadCount,
      };

  factory ChatThread.fromJson(Map<String, dynamic> json) => ChatThread(
        id: json['id'] ?? '',
        kind: json['kind'] ?? 'private',
        title: json['title'] ?? '',
        participantPhones: List<String>.from(json['participantPhones'] ?? const []),
        participantPhone: json['participantPhone'] ?? '',
        participantName: json['participantName'] ?? 'کاربر',
        role: json['role'] ?? '',
        lastMessage: json['lastMessage'] ?? '',
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      );
}

class ChatMessage {
  final String id;
  final String threadId;
  final String senderPhone;
  final String senderName;
  final String type; // text, image, file, audio, video, sticker, link, portfolio
  final String content;
  final String? attachmentName;
  final String? attachmentPath;
  final DateTime sentAt;
  bool delivered;
  bool seen;
  final String? replyToId;
  String? reaction;

  ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderPhone,
    required this.senderName,
    required this.type,
    required this.content,
    this.attachmentName,
    this.attachmentPath,
    DateTime? sentAt,
    this.delivered = true,
    this.seen = false,
    this.replyToId,
    this.reaction,
  }) : sentAt = sentAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'threadId': threadId,
        'senderPhone': senderPhone,
        'senderName': senderName,
        'type': type,
        'content': content,
        'attachmentName': attachmentName,
        'attachmentPath': attachmentPath,
        'sentAt': sentAt.toIso8601String(),
        'delivered': delivered,
        'seen': seen,
        'replyToId': replyToId,
        'reaction': reaction,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] ?? '',
        threadId: json['threadId'] ?? '',
        senderPhone: json['senderPhone'] ?? '',
        senderName: json['senderName'] ?? '',
        type: json['type'] ?? 'text',
        content: json['content'] ?? '',
        attachmentName: json['attachmentName'],
        attachmentPath: json['attachmentPath'],
        sentAt: DateTime.tryParse(json['sentAt'] ?? '') ?? DateTime.now(),
        delivered: json['delivered'] ?? true,
        seen: json['seen'] ?? false,
        replyToId: json['replyToId'],
        reaction: json['reaction'],
      );
}
