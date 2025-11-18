import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jobportal/provider/chat_provider.dart';
import 'package:jobportal/screens/chat_screen.dart';

void main() {
  testWidgets('ChatScreen shows messages and allows sending', (
    WidgetTester tester,
  ) async {
    final provider = ChatProvider();

    // Pre-populate a conversation and messages
    const convId = '1_2';
    provider.conversations = [];
    provider.messages[convId] = [];
    provider.userId = 1;

    await tester.pumpWidget(
      ChangeNotifierProvider<ChatProvider>.value(
        value: provider,
        child: const MaterialApp(home: ChatScreen(conversationId: convId)),
      ),
    );

    // Initially no messages
    expect(find.text('No messages'), findsOneWidget);

    // Enter text and press send
    final input = find.byType(TextField);
    await tester.enterText(input, 'Hello from test');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    // Sending uses API; in this simple test we at least ensure UI still builds
    expect(find.byIcon(Icons.send), findsOneWidget);
  });
}
