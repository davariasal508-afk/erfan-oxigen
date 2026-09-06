import '../models/chat_model.dart';
import '../models/user_model.dart';
import 'admin_profile_service.dart';
import 'customer_session_service.dart';
import 'current_user.dart';
import 'storage_service.dart';
import 'user_manager.dart';
import 'view_tracking_service.dart';

class ChatService {
  static final List<ChatMessage> messages = [];
  static final List<ChatThread> threads = [];

  static Future<void> initialize() async {
    final data = await StorageService.loadChat();
    messages
      ..clear()
      ..addAll(data.$1.map(ChatMessage.fromJson));
    threads
      ..clear()
      ..addAll(data.$2.map(ChatThread.fromJson));
    final members = ['admin', ...UserManager.users.where((u) => u.active && u.role != 'customer').map((u) => u.phone)];
    if (!threads.any((t) => t.id == 'group_general')) {
      threads.add(ChatThread(id: 'group_general', kind: 'group', title: 'گروه آموزشگاه', participantPhones: members, participantPhone: '', participantName: 'گروه آموزشگاه', role: 'group'));
      await _save();
    }
  }

  static List<ChatThread> threadsForUser(String phone, {String? kind}) {
    return threads.where((thread) {
      final allowed = thread.participantPhones.contains(phone) || phone == 'admin' && thread.participantPhones.contains('admin');
      final matchesKind = kind == null || thread.kind == kind;
      return allowed && matchesKind;
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static List<ChatMessage> forThread(String threadId) => messages.where((m) => m.threadId == threadId).toList()..sort((a, b) => a.sentAt.compareTo(b.sentAt));

  static Future<ChatThread> ensurePrivateThread(UserModel other) async {
    final mine = CurrentUser.phone;
    final sortedPhones = [mine, other.phone]..sort();
    final threadId = 'private_${sortedPhones.join('_')}';
    final existing = threads.where((t) => t.id == threadId).firstOrNull;
    if (existing != null) return existing;
    final thread = ChatThread(
      id: threadId,
      kind: 'private',
      title: other.name,
      participantPhones: [mine, other.phone],
      participantPhone: other.phone,
      participantName: other.name,
      role: other.role,
    );
    threads.add(thread);
    await _save();
    return thread;
  }

  static Future<ChatThread> ensureAdminThread() async {
    final mine = CustomerSessionService.customer != null ? (CustomerSessionService.customer?.phone ?? '') : CurrentUser.phone;
    final threadId = 'private_admin_$mine';
    final existing = threads.where((t) => t.id == threadId).firstOrNull;
    if (existing != null) return existing;
    final thread = ChatThread(
      id: threadId,
      kind: 'private',
      title: AdminProfileService.displayName,
      participantPhones: [mine, 'admin'],
      participantPhone: 'admin',
      participantName: AdminProfileService.displayName,
      role: 'admin',
    );
    threads.add(thread);
    await _save();
    return thread;
  }

  static Future<ChatThread> ensureGroupThread(String id, String title, List<String> members) async {
    final existing = threads.where((t) => t.id == id).firstOrNull;
    if (existing != null) return existing;
    final thread = ChatThread(id: id, kind: 'group', title: title, participantPhones: members, participantPhone: '', participantName: title, role: 'group');
    threads.add(thread);
    await _save();
    return thread;
  }

  static Future<void> send(ChatMessage message) async {
    messages.add(message);
    final thread = threads.where((t) => t.id == message.threadId).firstOrNull;
    if (thread != null) {
      thread.lastMessage = message.type == 'text' ? message.content : 'پیوست ${message.type}';
      thread.updatedAt = DateTime.now();
      for (final phone in thread.participantPhones) {
        if (phone != message.senderPhone) {
          thread.unreadCount += 1;
        }
      }
    }
    await _save();
  }

  static Future<void> markSeen(String threadId) async {
    for (final message in messages.where((m) => m.threadId == threadId && m.senderPhone != CurrentUser.phone)) {
      message.seen = true;
    }
    final thread = threads.where((t) => t.id == threadId).firstOrNull;
    if (thread != null) thread.unreadCount = 0;
    await ViewTrackingService.markViewed(type: 'chat', itemId: threadId, viewerPhone: CurrentUser.phone, viewerName: CurrentUser.name);
    await _save();
  }

  static Future<void> react(String messageId, String reaction) async {
    final message = messages.where((m) => m.id == messageId).firstOrNull;
    if (message == null) return;
    message.reaction = reaction;
    await _save();
  }

  static List<String> viewers(String threadId) => ViewTrackingService.viewers('chat', threadId).map((e) => e.viewerName).toSet().toList();

  static Future<void> _save() => StorageService.saveChat(messages.map((e) => e.toJson()).toList(), threads.map((e) => e.toJson()).toList());
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
