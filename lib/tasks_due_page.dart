import 'package:flutter/material.dart';
import 'data_models.dart';

class TasksDuePage extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) addTask;
  final Function(Task) toggleTaskCompletion;

  const TasksDuePage({
    super.key,
    required this.tasks,
    required this.addTask,
    required this.toggleTaskCompletion,
  });

  @override
  Widget build(BuildContext context) {
    // Filtered lists
    final tasksToday = tasks.where((t) => t.period == 'Today').toList();
    final tasksThisWeek = tasks.where((t) => t.period == 'This Week').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasks Due',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              // Add Task Button
              _buildAddButton(context),
            ],
          ),
          const SizedBox(height: 30),

          // Today Section
          Text('Today', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ...tasksToday.map((task) => _buildTaskItem(context, task, toggleTaskCompletion)),
          
          const SizedBox(height: 40),

          // This Week Section
          Text('This Week', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ...tasksThisWeek.map((task) => _buildTaskItem(context, task, toggleTaskCompletion)),

          const SizedBox(height: 40),
          
          // Removed < Back text
        ],
      ),
    );
  }
  
  // Widget to display and allow checking off a task
  Widget _buildTaskItem(BuildContext context, Task task, Function(Task) onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => onToggle(task), // Tapping toggles completion
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              task.isCompleted ? Icons.check_circle_outline : Icons.circle_outlined,
              color: Colors.brown.shade800,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for the 'Add Task' functionality
  Widget _buildAddButton(BuildContext context) {
    return TextButton(
      onPressed: () => _showAddTaskDialog(context),
      child: Text(
        '+ Add Task',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // Dialog to capture new task details
  void _showAddTaskDialog(BuildContext context) {
    String description = '';
    String period = 'Today';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Use StatefulBuilder to manage dialog state (dropdown)
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) => description = value,
                    decoration: const InputDecoration(labelText: 'Task Description'),
                  ),
                  DropdownButton<String>(
                    value: period,
                    items: const ['Today', 'This Week']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => period = newValue);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (description.isNotEmpty) {
                      addTask(Task(description, period));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}