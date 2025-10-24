import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; 
import 'data_models.dart';

class WeeklyCalendarPage extends StatefulWidget {
  final List<Reminder> reminders;
  final Function(Reminder) addReminder;
  final Function(Reminder) removeReminder;

  const WeeklyCalendarPage
  ({
    super.key,
    required this.reminders, 
    required this.addReminder,
    required this.removeReminder,
    });

  @override
  State<WeeklyCalendarPage> createState() => _WeeklyCalendarPageState();
}

class _WeeklyCalendarPageState extends State<WeeklyCalendarPage> {
  // State for the calendar
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Function to get the list of reminders for a specific day
  List<Reminder> _getRemindersForDay(DateTime day) {
    return widget.reminders.where((r) => isSameDay(r.date, day)).toList();
  }

  // --- Add Reminder Dialog ---
  void _showAddReminderDialog(BuildContext context) {
    String description = '';
    DateTime selectedDate = _focusedDay;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Reminder'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) => description = value,
                    decoration: const InputDecoration(labelText: 'Reminder Description'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setState(() => selectedDate = pickedDate);
                      }
                    },
                    child: Text('Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}'),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    if (description.isNotEmpty) {
                      widget.addReminder(Reminder(description, selectedDate));
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
  // --- End Add Reminder Dialog ---

  @override
  Widget build(BuildContext context) {
    // Sort reminders by date for display
    widget.reminders.sort((a, b) => a.date.compareTo(b.date));
    
    // Get reminders for the currently focused day (or selected day if present)
    final remindersForSelectedDay = _getRemindersForDay(_selectedDay ?? _focusedDay);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            DateFormat('MMMM yyyy').format(_focusedDay), // Display current month
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 15),

          // REPLACED BLACK BLOCK with TableCalendar
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false, // We use our own header above
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            // Customize to match the brown theme
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.brown.shade300, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.brown.shade500, shape: BoxShape.circle),
              defaultTextStyle: TextStyle(color: Colors.brown.shade800),
              weekendTextStyle: TextStyle(color: Colors.brown.shade600),
              markerDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
            eventLoader: _getRemindersForDay,
            
          ),
          const SizedBox(height: 30),

          // Reminders Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reminders',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              // Add Reminders Button/Link
              TextButton(
                onPressed: () => _showAddReminderDialog(context),
                child: Text(
                  '+ Add Reminders',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Dynamic List of Reminders (for the selected/focused day)
          ...remindersForSelectedDay.map((reminder) => _ReminderItem(
            reminder: reminder,
            onRemove: (Reminder reminder) {
              final removedReminder = reminder;
              final removedIndex = widget.reminders.indexOf(reminder);
              widget.removeReminder(reminder);
    
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Reminder removed.'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                  widget.reminders.insert(removedIndex, removedReminder);
                  setState(() {}); // Force rebuild
                  },
                ),
                duration: const Duration(seconds: 3),
              )
            );
          },
          )).toList(),
          
          const SizedBox(height: 40),
          
          // Removed < Back text
        ],
      ),
    );
  }
}

class _ReminderItem extends StatelessWidget {
  final Reminder reminder;
  final Function(Reminder) onRemove;

  const _ReminderItem({
    required this.reminder,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
            child: Container(
              width: 8, 
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red, 
                borderRadius: BorderRadius.circular(4)
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${reminder.description} - ${DateFormat('h:mm a').format(reminder.date)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.brown.shade600, size: 20),
            onPressed: () => onRemove(reminder),
            padding: const EdgeInsets.all(8.0),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}