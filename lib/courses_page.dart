import 'package:flutter/material.dart';
import 'data_models.dart';

class CoursesPage extends StatelessWidget {
  final List<Course> courses;
  final Function(Course) addCourse;
  final Function(Course) removeCourse;
  final Function(Course) updateCourse;

  const CoursesPage
  (
    {
      super.key,
      required this.courses,
      required this.addCourse,
      required this.removeCourse,
      required this.updateCourse,
    }
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Courses',
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          
          // Add More Courses Button/Link
          Align(
            alignment: Alignment.centerRight,
            child: _buildAddCourseButton(context),
          ),
          const SizedBox(height: 20),

          // Dynamic Course Buttons
          ...courses.map((course) => _CourseButton(
            course: course,
            onRemove: removeCourse,
            onUpdate: updateCourse,
            )).toList(),
          
          const SizedBox(height: 40),
          
          // Removed < Back text
        ],
      ),
    );
  }

  // Widget for the 'Add More Courses' functionality
  Widget _buildAddCourseButton(BuildContext context) {
    return TextButton(
      onPressed: () => _showAddCourseDialog(context),
      child: Text(
        '+ Add More Courses',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // Dialog to capture new course details
  void _showAddCourseDialog(BuildContext context) {
    String title = '';
    int creditHours = 3;
    String instructor = '';
    String description = '';
    String schedule = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => title = value,
                  decoration: const InputDecoration(labelText: 'Course Title'),
                ),
                TextField(
                  onChanged: (value) => creditHours = int.tryParse(value) ?? 3,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Credit Hours (e.g., 3)'),
                ),
                TextField(
                  onChanged: (value) => instructor = value,
                  decoration: const InputDecoration(labelText: 'Instructor'),
                ),
                TextField(
                  onChanged: (value) => schedule = value,
                  decoration: const InputDecoration(labelText: 'Schedule'),
                ),
                TextField(
                  onChanged: (value) => description = value,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (title.isNotEmpty) {
                  addCourse(Course(
                    title, 
                    creditHours,
                    instructor: instructor,
                    description: description,
                    schedule: schedule,
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// Widget to add a new weightage entry
class _AddWeightageRow extends StatefulWidget {
  final Course course;
  final Function(Course) onUpdate;

  const _AddWeightageRow({required this.course, required this.onUpdate});

  @override
  State<_AddWeightageRow> createState() => _AddWeightageRowState();
}

class _AddWeightageRowState extends State<_AddWeightageRow> {
  final _typeController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _typeController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _typeController,
            decoration: const InputDecoration(hintText: 'Type (e.g. quiz)'),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: TextField(
            controller: _weightController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Weight %'),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            final type = _typeController.text.trim();
            final parsed = double.tryParse(_weightController.text) ?? 0.0;
            if (type.isNotEmpty && parsed > 0) {
              setState(() {
                widget.course.weightages[type] = (parsed/100).clamp(0.0, 1.0);
              });
              widget.onUpdate(widget.course);
              _typeController.clear();
              _weightController.clear();
            }
          },
        ),
      ],
    );
  }
}

// Widget to add a new score entry
class _AddScoreRow extends StatefulWidget {
  final Course course;
  final Function(Course) onUpdate;

  const _AddScoreRow({required this.course, required this.onUpdate});

  @override
  State<_AddScoreRow> createState() => _AddScoreRowState();
}

class _AddScoreRowState extends State<_AddScoreRow> {
  String? _selectedType;
  final _scoreController = TextEditingController();

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final types = widget.course.weightages.keys.toList();
    return Row(
      children: [
        Expanded(
          child: types.isEmpty
              ? TextField(
                  decoration: const InputDecoration(hintText: 'Type (e.g. quiz)'),
                  onChanged: (v) => _selectedType = v,
                )
              : DropdownButton<String>(
                  value: _selectedType ?? (types.isNotEmpty ? types.first : null),
                  items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _selectedType = v),
                ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: TextField(
            controller: _scoreController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Score'),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            final type = _selectedType;
            final parsed = double.tryParse(_scoreController.text) ?? -1;
            if ((type != null && type.isNotEmpty) && parsed >= 0) {
              widget.course.scores.add(AssessmentScore(type: type, value: parsed.clamp(0.0, 100.0)));
              widget.onUpdate(widget.course);
              _scoreController.clear();
            }
          },
        ),
      ],
    );
  }
}

// Course button widget (unchanged visually)

class _CourseButton extends StatelessWidget {
  final Course course;
  final Function(Course) onRemove;
  final Function(Course) onUpdate;

  const _CourseButton({
    required this.course,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Material(
        color: const Color(0xFFA2846A), 
        borderRadius: BorderRadius.circular(5.0),
        child: InkWell(
          onTap: () => _showCourseDetailsDialog(context),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Credit Hours: ${course.creditHours}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                  onPressed: () => _showDeleteConfirmation(context),
                  padding: const EdgeInsets.all(8.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCourseDetailsDialog(BuildContext context) {
    final titleController = TextEditingController(text: course.title);
    final creditHoursController = TextEditingController(text: course.creditHours.toString());
    final instructorController = TextEditingController(text: course.instructor);
    final descriptionController = TextEditingController(text: course.description);
    final scheduleController = TextEditingController(text: course.schedule);

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Course Details', style: theme.textTheme.titleLarge),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Divider(color: Colors.brown.shade200),
                const SizedBox(height: 8),

                // Basic info card
                Card(
                  color: Colors.brown.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Basic Info', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Course Title'),
                          onChanged: (value) {
                            course.title = value;
                            onUpdate(course);
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: creditHoursController,
                                decoration: const InputDecoration(labelText: 'Credit Hours'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  course.creditHours = int.tryParse(value) ?? course.creditHours;
                                  onUpdate(course);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: instructorController,
                                decoration: const InputDecoration(labelText: 'Instructor'),
                                onChanged: (value) {
                                  course.instructor = value;
                                  onUpdate(course);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: scheduleController,
                          decoration: const InputDecoration(labelText: 'Schedule'),
                          onChanged: (value) {
                            course.schedule = value;
                            onUpdate(course);
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          onChanged: (value) {
                            course.description = value;
                            onUpdate(course);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Priority and assessments
                Row(
                  children: [
                    Expanded(child: Text('Priority', style: theme.textTheme.titleMedium)),
                    ToggleButtons(
                      isSelected: [course.priority==0, course.priority==1, course.priority==2],
                      onPressed: (i) {
                        course.priority = i;
                        onUpdate(course);
                        (context as Element).markNeedsBuild();
                      },
                      children: const [Text('Low'), Text('Med'), Text('High')],
                      color: Colors.brown,
                      selectedColor: Colors.white,
                      fillColor: Colors.brown,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assessment Types & Weightages', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ...course.weightages.entries.map((entry) {
                          final type = entry.key;
                          final weightController = TextEditingController(text: (entry.value*100).toStringAsFixed(0));
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                Expanded(child: Text(type)),
                                SizedBox(
                                  width: 90,
                                  child: TextField(
                                    controller: weightController,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(suffixText: '%'),
                                    onSubmitted: (val) {
                                      final parsed = double.tryParse(val) ?? (entry.value*100);
                                      course.weightages[type] = (parsed/100).clamp(0.0, 1.0);
                                      onUpdate(course);
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20),
                                  onPressed: () {
                                    course.weightages.remove(type);
                                    onUpdate(course);
                                  },
                                )
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                        _AddWeightageRow(course: course, onUpdate: onUpdate),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Scores', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ...course.scores.asMap().entries.map((e) {
                          final idx = e.key;
                          final s = e.value;
                          final scoreController = TextEditingController(text: s.value.toString());
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                Expanded(child: Text(s.type)),
                                SizedBox(
                                  width: 90,
                                  child: TextField(
                                    controller: scoreController,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    onSubmitted: (val) {
                                      final parsed = double.tryParse(val) ?? s.value;
                                      s.value = parsed.clamp(0.0, 100.0);
                                      onUpdate(course);
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20),
                                  onPressed: () {
                                    course.scores.removeAt(idx);
                                    onUpdate(course);
                                  },
                                )
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                        _AddScoreRow(course: course, onUpdate: onUpdate),
                        const SizedBox(height: 8),
                        Builder(builder: (context) {
                          double computeFinal() {
                            if (course.weightages.isEmpty || course.scores.isEmpty) return 0.0;
                            final Map<String, List<double>> grouped = {};
                            for (final s in course.scores) {
                              grouped.putIfAbsent(s.type, () => []).add(s.value);
                            }
                            double total = 0.0;
                            for (final entry in grouped.entries) {
                              final type = entry.key;
                              final avg = entry.value.reduce((a,b) => a+b)/entry.value.length;
                              final weight = course.weightages[type] ?? 0.0;
                              total += avg * weight;
                            }
                            return total;
                          }

                          final finalPercent = computeFinal();
                          return Text('Estimated Final: ${finalPercent.toStringAsFixed(2)}%', style: theme.textTheme.titleMedium);
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Document upload feature coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Documents'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // Dispose controllers after dialog is closed
      titleController.dispose();
      creditHoursController.dispose();
      instructorController.dispose();
      descriptionController.dispose();
      scheduleController.dispose();
    });
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text('Are you sure you want to delete "${course.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onRemove(course);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course deleted.'))
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

/*
class _CourseButton extends StatelessWidget {
  final Course course;

  const _CourseButton({required this.course});

  @override
  Widget build(BuildContext context) {
    // ... (Container and InkWell code remains the same)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Material(
        color: const Color(0xFFA2846A), 
        borderRadius: BorderRadius.circular(5.0),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on ${course.title} (Detail Page)'))
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  'Credit Hours: ${course.creditHours}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/