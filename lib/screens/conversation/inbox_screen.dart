import 'package:flutter/material.dart';
import 'package:jobportal/provider/chat_provider.dart';
import 'package:jobportal/screens/conversation/chatting_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final conversations = chatProvider.conversations;

    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),

      body:
          conversations.isEmpty
              ? const EmptyInboxState()
              : Column(
                children: [
                  const SizedBox(height: 40),

                  /// ------------------ HEADER ------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        const Text(
                          "Messages",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              onPressed: () {
                                Navigator.pushNamed(context, '/chat');
                              },
                            ),
                            const Icon(Icons.more_horiz, size: 26),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ---------------- SEARCH BAR ----------------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          hintText: "Search message",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: conversations.length,
                      padding: const EdgeInsets.only(top: 10),
                      itemBuilder: (context, index) {
                        final c = conversations[index];

                        return Dismissible(
                          key: Key(c.companyName),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            chatProvider.removeConversation(c);
                          },
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: const Color(0xffffe7e0),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.only(right: 25),
                            child: const Icon(
                              Icons.delete,
                              color: Color(0xffFF6B4A),
                              size: 28,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ChattingScreen(
                                          conversation: c,
                                          chatProvider: chatProvider,
                                        ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  /// Avatar
                                  CircleAvatar(
                                    radius: 27,
                                    backgroundImage:
                                        c.companyLogoUrl.startsWith("http")
                                            ? NetworkImage(c.companyLogoUrl)
                                            : AssetImage(c.companyLogoUrl)
                                                as ImageProvider,
                                  ),
                                  const SizedBox(width: 15),

                                  /// Name + last message
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.companyName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          c.lastMessage,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// Time
                                  Text(
                                    _formatDateTime(c.lastMessageTime),
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();

    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return DateFormat.jm().format(dateTime);
    } else if (dateTime.year == now.year) {
      return DateFormat.MMMd().format(dateTime);
    } else {
      return DateFormat.yMMMd().format(dateTime);
    }
  }
}

class EmptyInboxState extends StatelessWidget {
  const EmptyInboxState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/empty.png", height: 180),
          const SizedBox(height: 30),
          const Text(
            "No Message",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff0D0D26),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "You currently have no incoming messages\nthank you",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 50),
          SizedBox(
            width: 220,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1A1A60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {},
              child: const Text(
                "CREATE A MESSAGE",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
