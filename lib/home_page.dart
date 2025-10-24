import 'package:flutter/material.dart';
import 'data_models.dart'; 
class HomePage extends StatelessWidget {
  final List<String> pinnedMessages;
  final List<Task> tasks; // Must be List<Task>
  final Function(String) addPinnedMessage;
  final Function(String) removePinnedMessage;
  final Function(int, String) insertPinnedMessageAt;
    const HomePage({
        super.key, 
        required this.pinnedMessages, 
        required this.tasks,
        required this.addPinnedMessage,
        required this.removePinnedMessage,
        required this.insertPinnedMessageAt,
        
    });

  @override
  Widget build(BuildContext context) {
    final tasksToday = tasks
        .where((t) => t.period == 'Today' && !t.isCompleted)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Pinned Messages Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pinned Messages',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              // Button to add new pinned message
              TextButton.icon(
                onPressed: () => _showAddMessageDialog(context),
                icon: const Icon(Icons.add, size: 20, color: Colors.brown),
                label: Text(
                  'Add',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // REPLACED BLACK BLOCK with Pinned Messages List
            Container(
              height: 200, 
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.brown.shade300),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: pinnedMessages.isEmpty
                ? const Center(child: Text('Tap "Add" to save a note for later.'))
                : ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: pinnedMessages.length,
                  itemBuilder: (context, index) {
                    final message = pinnedMessages[index];
                  return Dismissible(
                    key: Key(message + index.toString()), // Make key more unique
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                        final removedMessage = message;
                        final removedIndex = index;
                        removePinnedMessage(message);
            
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Pinned message removed.'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                              insertPinnedMessageAt(removedIndex, removedMessage);
                              
                            },
                            ),
                         )
                          );
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                          color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                        ),
                    child: _PinnedMessageItem(
                        message: message,
                        onDelete: () {
                          final removedMessage = message;
                          final removedIndex = pinnedMessages.indexOf(message);
                          removePinnedMessage(message);
              
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Pinned message removed.'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  pinnedMessages.insert(removedIndex, removedMessage);
                                  // Force rebuild
                                  (context as Element).markNeedsBuild();
                                },
                              ),
                              duration: const Duration(seconds: 3),
                            )
                          );
                        },
                      ),
                    );
                },
                ),
            ),

/*          Container(
            height: 200, 
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.brown.shade300),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: pinnedMessages.isEmpty
              ? const Center(child: Text('Tap "Add" to save a note for later.'))
              : ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: pinnedMessages.length,
                itemBuilder: (context, index) {
                  final message = pinnedMessages[index];
                  return Dismissible( // Allows swiping to remove
                    key: Key(message),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      removePinnedMessage(message);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pinned message removed.'))
                      );
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        '📌 ${message}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
          ),
*/
          
          const SizedBox(height: 30),

          // Title: Tasks To do Today
          Text(
            'Tasks To do Today',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),

          // Dynamic List of Tasks (SYCNED)
          if (tasksToday.isEmpty)
            Text(
              'No tasks due today. You\'re all caught up! 🎉',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            // We only show the description, as per the mockup
            ...tasksToday.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '• ${task.description}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )).toList(),
          
          const SizedBox(height: 50),
          
          // Removed the (HOME) text
        ],
      ),
    );
  }

  // Dialog to capture a new pinned message
  void _showAddMessageDialog(BuildContext context) {
    String message = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pin a Message'),
          content: TextField(
            onChanged: (value) => message = value,
            decoration: const InputDecoration(labelText: 'Message / Note'),
            maxLines: 3,
            minLines: 1,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (message.trim().isNotEmpty) {
                  addPinnedMessage(message);
                  Navigator.pop(context);
                }
              },
              child: const Text('Pin'),
            ),
          ],
        );
      },
    );
  }
  
}
// Add this new widget class at the bottom of home_page.dart
class _PinnedMessageItem extends StatefulWidget {
  final String message;
  final VoidCallback onDelete;

  const _PinnedMessageItem({
    required this.message,
    required this.onDelete,
  });

  @override
  State<_PinnedMessageItem> createState() => _PinnedMessageItemState();
}

class _PinnedMessageItemState extends State<_PinnedMessageItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '📌 ${widget.message}',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_isHovered)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.brown.shade600, size: 20),
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}