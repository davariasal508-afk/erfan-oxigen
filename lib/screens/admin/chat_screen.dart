import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/chat_model.dart';
import '../../models/user_model.dart';
import '../../services/chat_service.dart';
import '../../services/customer_session_service.dart';
import '../../services/current_user.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final UserModel? contact;
  const ChatScreen({super.key, this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();

  String get _myPhone => CustomerSessionService.customer != null ? (CustomerSessionService.customer?.phone ?? '') : CurrentUser.phone;
  String get _myName => CustomerSessionService.customer != null ? (CustomerSessionService.customer?.name ?? '') : CurrentUser.name;
  bool get _isCustomer => CustomerSessionService.customer != null;
  final picker = ImagePicker();
  String? activeThreadId;
  int tab = 0; // 0 private, 1 group
  ChatThread? activeThread;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    if (widget.contact != null) {
      activeThread = await ChatService.ensurePrivateThread(widget.contact!);
    } else if (CurrentUser.role == 'student' || CurrentUser.role == 'teacher' || _isCustomer) {
      activeThread = await ChatService.ensureAdminThread();
    } else {
      final list = ChatService.threadsForUser('admin');
      if (list.isNotEmpty) activeThread = list.first;
    }
    if (!mounted) return;
    setState(() => activeThreadId = activeThread?.id);
    if (activeThread != null) await ChatService.markSeen(activeThread!.id);
  }

  List<ChatThread> get threads => ChatService.threadsForUser(CurrentUser.role == 'admin' ? 'admin' : _myPhone, kind: _isCustomer ? 'private' : (tab == 0 ? 'private' : 'group'));

  Future<void> openThread(ChatThread thread) async {
    activeThread = thread;
    activeThreadId = thread.id;
    await ChatService.markSeen(thread.id);
    if (mounted) setState(() {});
  }

  Future<void> sendText() async {
    final text = controller.text.trim();
    if (text.isEmpty || activeThread == null) return;
    await ChatService.send(ChatMessage(id: '${DateTime.now().microsecondsSinceEpoch}', threadId: activeThread!.id, senderPhone: _myPhone, senderName: _myName, type: 'text', content: text));
    controller.clear();
    if (mounted) setState(() {});
  }

  Future<void> attachImage() async {
    if (activeThread == null) return;
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (file == null) return;
    await _sendAttachment('image', File(file.path), file.name);
  }

  Future<void> attachFile() async {
    if (activeThread == null) return;
    final result = await FilePicker.platform.pickFiles(withData: false);
    final file = result?.files.single;
    if (file?.path == null) return;
    await _sendAttachment('file', File(file!.path!), file.name);
  }

  Future<void> attachVideo() async {
    if (activeThread == null) return;
    final file = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));
    if (file == null) return;
    await _sendAttachment('video', File(file.path), file.name);
  }

  Future<void> attachAudio() async {
    if (activeThread == null) return;
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'ogg'], withData: false);
    final file = result?.files.single;
    if (file?.path == null) return;
    await _sendAttachment('audio', File(file!.path!), file.name);
  }

  Future<void> sendSticker() async {
    if (activeThread == null) return;
    await ChatService.send(ChatMessage(id: '${DateTime.now().microsecondsSinceEpoch}', threadId: activeThread!.id, senderPhone: _myPhone, senderName: _myName, type: 'sticker', content: '✨'));
    if (mounted) setState(() {});
  }

  Future<void> _sendAttachment(String type, File file, String name) async {
    if (activeThread == null) return;
    await ChatService.send(ChatMessage(id: '${DateTime.now().microsecondsSinceEpoch}', threadId: activeThread!.id, senderPhone: _myPhone, senderName: _myName, type: type, content: type == 'image' ? 'تصویر' : 'فایل', attachmentName: name, attachmentPath: file.path));
    if (mounted) setState(() {});
  }

  Future<void> pickContact() async {
    final candidates = CurrentUser.role == 'admin'
        ? UserManager.users.where((u) => u.role != 'admin' && u.active).toList()
        : CurrentUser.role == 'student'
            ? UserManager.getUsersByRole('teacher').where((u) => u.active).toList()
            : UserManager.getUsersByRole('admin').where((u) => u.active).toList();
    if (candidates.isEmpty) return;
    final selected = await showModalBottomSheet<UserModel>(
      context: context,
      builder: (context) => SafeArea(child: ListView.builder(itemCount: candidates.length, itemBuilder: (context, index) { final user = candidates[index]; return ListTile(leading: const CircleAvatar(backgroundColor: AppTheme.gold, foregroundColor: Colors.black, child: Icon(Icons.person)), title: Text(user.name), subtitle: Text(user.role == 'teacher' ? 'مدرس' : user.role == 'student' ? 'هنرجو' : 'مدیر'), onTap: () => Navigator.pop(context, user)); })),
    );
    if (selected == null) return;
    activeThread = await ChatService.ensurePrivateThread(selected);
    activeThreadId = activeThread!.id;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = ChatService.threadsForUser(CurrentUser.role == 'admin' ? 'admin' : _myPhone, kind: _isCustomer ? 'private' : (tab == 0 ? 'private' : 'group'));
    final activeMessages = activeThreadId == null ? <ChatMessage>[] : ChatService.forThread(activeThreadId!);
    return OxygenPage(
      title: activeThread?.title.isNotEmpty == true ? activeThread!.title : 'گفتگوها',
      actions: [
        if (CurrentUser.role == 'admin' && activeThread != null) IconButton(tooltip: 'چه کسانی مشاهده کرده‌اند', onPressed: _showViewers, icon: const Icon(Icons.visibility_rounded)),
        IconButton(tooltip: 'گفتگوی جدید', onPressed: pickContact, icon: const Icon(Icons.add_comment_rounded)),
      ],
      child: Column(
        children: [
          if (!_isCustomer)
            Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 8), child: SegmentedButton<int>(segments: const [ButtonSegment(value: 0, label: Text('خصوصی'), icon: Icon(Icons.person_rounded)), ButtonSegment(value: 1, label: Text('گروه‌ها'), icon: Icon(Icons.groups_rounded))], selected: {tab}, onSelectionChanged: (value) => setState(() => tab = value.first))),
          if (_isCustomer) const SizedBox(height: 10),
          SizedBox(height: 88, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: list.length, separatorBuilder: (context, index) => const SizedBox(width: 8), itemBuilder: (context, index) { final t = list[index]; final selected = t.id == activeThreadId; return InkWell(onTap: () => openThread(t), borderRadius: BorderRadius.circular(18), child: Container(width: 190, padding: const EdgeInsets.all(12), decoration: AppTheme.glass(radius: 18, strong: selected), child: Row(children: [CircleAvatar(backgroundColor: selected ? AppTheme.gold : Colors.white12, foregroundColor: selected ? Colors.black : Colors.white, child: Icon(t.kind == 'group' ? Icons.groups_rounded : Icons.person_rounded, size: 19)), const SizedBox(width: 9), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.title.isEmpty ? t.participantName : t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)), const SizedBox(height: 3), Text(t.lastMessage.isEmpty ? 'شروع گفتگو' : t.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 10))]))]))); }),),
          const Divider(height: 1, color: Colors.white10),
          Expanded(child: activeThread == null ? const Center(child: Text('یک گفتگوی خصوصی را انتخاب کنید', style: TextStyle(color: AppTheme.muted))) : Column(children: [Expanded(child: activeMessages.isEmpty ? const Center(child: Text('هنوز پیامی وجود ندارد', style: TextStyle(color: AppTheme.muted))) : ListView.builder(reverse: false, padding: const EdgeInsets.fromLTRB(14, 16, 14, 8), itemCount: activeMessages.length, itemBuilder: (context, index) => _bubble(activeMessages[index])),), _composer()])),
        ],
      ),
    );
  }

  Widget _bubble(ChatMessage message) {
    final mine = message.senderPhone == _myPhone;
    final children = <Widget>[];
    if (!mine) {
      children.add(Text(message.senderName, style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w800, fontSize: 11)));
      children.add(const SizedBox(height: 4));
    }
    children.add(Text(message.content, style: TextStyle(color: mine ? Colors.black : Colors.white, fontWeight: FontWeight.w600)));
    if (message.attachmentName != null) {
      children.add(const SizedBox(height: 6));
      children.add(Row(children: [const Icon(Icons.attach_file_rounded, size: 15), const SizedBox(width: 5), Flexible(child: Text(message.attachmentName!, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis))]));
    }
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: mine ? AppTheme.gold.withValues(alpha: .92) : Colors.white.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: mine ? Colors.transparent : Colors.white10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  Widget _composer() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          child: Row(
            children: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'image') attachImage();
                  if (value == 'video') attachVideo();
                  if (value == 'audio') attachAudio();
                  if (value == 'file') attachFile();
                  if (value == 'sticker') sendSticker();
                },
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.gold),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'image', child: Text('عکس')),
                  PopupMenuItem(value: 'video', child: Text('ویدئو تا ۶۰ ثانیه')),
                  PopupMenuItem(value: 'audio', child: Text('ویس / صوت')),
                  PopupMenuItem(value: 'file', child: Text('فایل / PDF')),
                  PopupMenuItem(value: 'sticker', child: Text('استیکر')),
                ],
              ),
              Expanded(child: TextField(controller: controller, minLines: 1, maxLines: 4, textInputAction: TextInputAction.newline, decoration: const InputDecoration(hintText: 'پیام، لینک یا توضیح نمونه‌کار...'))),
              const SizedBox(width: 8),
              FloatingActionButton.small(onPressed: sendText, backgroundColor: AppTheme.gold, foregroundColor: Colors.black, child: const Icon(Icons.send_rounded)),
            ],
          ),
        ),
      );

  Future<void> _showViewers() async {
    final viewers = ChatService.viewers(activeThread!.id);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مشاهده‌کنندگان گفتگو'),
        content: viewers.isEmpty ? const Text('هنوز کسی این گفتگو را مشاهده نکرده است.') : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: viewers.map((name) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('• $name'))).toList(),),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('بستن'))],
      ),
    );
  }

}
