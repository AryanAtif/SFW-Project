import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiChatPage extends StatefulWidget {
  const GeminiChatPage({super.key});

  @override
  State<GeminiChatPage> createState() => _GeminiChatPageState();
}

class _GeminiChatPageState extends State<GeminiChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  GenerativeModel? _model;
  ChatSession? _chat;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    try {
      // Gemini API key
      const apiKey = 'AIzaSyDCMJzHFr7t2C0jyFCV6EO6Q30sPr3-C9o';
      
      if (apiKey.isEmpty) {
        setState(() {
          _error = 'Please add your Gemini API key to initialize the chat.';
        });
        return;
      }

      _model = GenerativeModel(
        model: 'gemini-1.5-pro-002',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );

      _chat = _model!.startChat();
      setState(() {
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize chat: ${e.toString()}';
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _chat == null) return;

    final userMessage = text.trim();
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final response = await _chat!.sendMessage(Content.text(userMessage));
      final responseText = response.text ?? 'No response generated.';

      setState(() {
        _messages.add(ChatMessage(text: responseText, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Error: ${e.toString()}',
          isUser: false,
          isError: true,
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _buildWelcomeScreen()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(message: _messages[index]);
                  },
                ),
        ),
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.brown[600],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Thinking...',
                  style: TextStyle(
                    color: Colors.brown[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.brown[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Gemini Chat!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Ask me anything and I\'ll help you out!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip('Help me with homework'),
              _buildSuggestionChip('Explain a concept'),
              _buildSuggestionChip('Give me study tips'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _sendMessage(label),
      backgroundColor: Colors.brown[100],
      labelStyle: TextStyle(color: Colors.brown[900]),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide(color: Colors.brown[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide(color: Colors.brown[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide(color: Colors.brown[600]!, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                ),
                onSubmitted: _isLoading ? null : _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            MaterialButton(
              onPressed: _isLoading ? null : () => _sendMessage(_textController.text),
              shape: const CircleBorder(),
              color: Colors.brown[600],
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.send,
                color: _isLoading ? Colors.white54 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: message.isUser
              ? Colors.brown[600]
              : (message.isError ? Colors.red[100] : Colors.brown[100]),
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser
                ? Colors.white
                : (message.isError ? Colors.red[900] : Colors.brown[900]),
          ),
        ),
      ),
    );
  }
}