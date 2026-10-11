import 'package:flutter/material.dart';

class DoctorChatScreen extends StatefulWidget {
  const DoctorChatScreen({
    super.key,
    this.doctorName = 'Doctor',
    this.conversations = const [],
    this.initialMessages = const [],
    this.onSendMessage,
    this.onOpenConversation,
  });

  final String doctorName;

  // Conversation fields: id, patientName, lastMessage,
  // time, unreadCount, patientId.
  final List<Map<String, dynamic>> conversations;

  // Message fields: id, senderId, text, time, isRead.
  final List<Map<String, dynamic>> initialMessages;

  // Connect these callbacks to your backend later.
  final Future<void> Function(String conversationId, String message)?
  onSendMessage;

  final ValueChanged<Map<String, dynamic>>? onOpenConversation;

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredConversations {
    return widget.conversations.where((conversation) {
      final name = (conversation['patientName'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _openChat(Map<String, dynamic> conversation) {
    widget.onOpenConversation?.call(conversation);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoctorChatConversationScreen(
          conversation: conversation,
          initialMessages: widget.initialMessages,
          onSendMessage: widget.onSendMessage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _filteredConversations;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF16324F),
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Connect notifications to your messaging service.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${widget.doctorName}',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Patient conversations',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16324F),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search patients...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF087F8C),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: conversations.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      return _buildConversationTile(conversation);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    final patientName = (conversation['patientName'] ?? 'Patient').toString();
    final lastMessage = (conversation['lastMessage'] ?? 'Start a conversation')
        .toString();
    final time = (conversation['time'] ?? '').toString();
    final unreadCount =
        int.tryParse('${conversation['unreadCount'] ?? 0}') ?? 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openChat(conversation),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: const Color(0xFFDDF4F0),
                child: Text(
                  patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                  style: const TextStyle(
                    color: Color(0xFF087F8C),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF16324F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                  const SizedBox(height: 8),
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF087F8C),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFDDF4F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF087F8C),
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF16324F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Patient conversations will appear here when available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorChatConversationScreen extends StatefulWidget {
  const DoctorChatConversationScreen({
    super.key,
    required this.conversation,
    this.initialMessages = const [],
    this.onSendMessage,
  });

  final Map<String, dynamic> conversation;
  final List<Map<String, dynamic>> initialMessages;

  final Future<void> Function(String conversationId, String message)?
  onSendMessage;

  @override
  State<DoctorChatConversationScreen> createState() =>
      _DoctorChatConversationScreenState();
}

class _DoctorChatConversationScreenState
    extends State<DoctorChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<Map<String, dynamic>> _messages;
  bool _sending = false;

  String get _conversationId =>
      (widget.conversation['id'] ?? widget.conversation['_id'] ?? '')
          .toString();

  String get _patientName =>
      (widget.conversation['patientName'] ?? 'Patient').toString();

  @override
  void initState() {
    super.initState();

    _messages = widget.initialMessages.where((message) {
      final messageConversationId = (message['conversationId'] ?? '')
          .toString();

      // If message records have a conversationId, show only
      // messages for this conversation.
      return messageConversationId.isEmpty ||
          messageConversationId == _conversationId;
    }).toList();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || _sending) return;

    if (widget.onSendMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Messaging API is not connected yet.')),
      );
      return;
    }

    if (_conversationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation ID is missing.')),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      await widget.onSendMessage!(_conversationId, text);

      if (!mounted) return;

      setState(() {
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'senderId': 'doctor',
          'text': text,
          'time': TimeOfDay.now().format(context),
          'isRead': false,
        });
        _messageController.clear();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message could not be sent. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF16324F),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFDDF4F0),
              child: Text(
                _patientName.isNotEmpty ? _patientName[0].toUpperCase() : 'P',
                style: const TextStyle(
                  color: Color(0xFF087F8C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _patientName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet. Start the conversation.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final senderId = (message['senderId'] ?? '').toString();
    final isDoctor = senderId == 'doctor' || senderId == 'currentDoctor';
    final text = (message['text'] ?? '').toString();
    final time = (message['time'] ?? '').toString();

    return Align(
      alignment: isDoctor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isDoctor ? const Color(0xFF087F8C) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isDoctor ? 16 : 4),
            bottomRight: Radius.circular(isDoctor ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isDoctor ? Colors.white : const Color(0xFF16324F),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (time.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                time,
                style: TextStyle(
                  color: isDoctor ? Colors.white70 : Colors.black45,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE9EEF4))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: const Color(0xFFF5F8FC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: const Color(0xFF087F8C),
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: _sending ? null : _sendMessage,
              borderRadius: BorderRadius.circular(30),
              child: SizedBox(
                height: 48,
                width: 48,
                child: Center(
                  child: _sending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
