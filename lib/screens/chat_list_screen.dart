import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jobportal/provider/chat_provider.dart';
import 'package:jobportal/services/socket_manager.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversations')),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          final convs = provider.conversations;
          if (provider.socketState == SocketConnectionState.connecting)
            return const Center(child: CircularProgressIndicator());
          if (convs.isEmpty)
            return const Center(child: Text('No conversations'));
          return ListView.builder(
            itemCount: convs.length,
            itemBuilder: (context, index) {
              final c = convs[index];
              final msgs = provider.messages[c.id];
              final last =
                  (msgs != null && msgs.isNotEmpty)
                      ? msgs.first.text ?? ''
                      : '';
              final title = c.company?.companyName ?? 'Company ${c.companyId}';
              return ListTile(
                title: Text(title),
                subtitle: Text(last),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(conversationId: c.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
