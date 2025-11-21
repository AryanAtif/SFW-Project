import 'package:flutter/services.dart';

// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_selector/file_selector.dart';
// Firebase Auth removed; using Supabase Auth
import 'package:url_launcher/url_launcher.dart';

import 'data_models.dart';

enum _UploadStatus { pending, uploading, done, error, cancelled }

class _UploadItem {
  final String name;
  final XFile file;
  double progress = 0.0; // 0.0 - 1.0; Supabase upload is a single call so we use indeterminate progress
  _UploadStatus status = _UploadStatus.pending;
  String? error;
  String? downloadUrl;

  _UploadItem({required this.name, required this.file});
}

class CourseDetailPage extends StatefulWidget {
  final Course course;
  final Function(Course) onUpdate;
  final Function(Course) onRemove;

  const CourseDetailPage({
    super.key,
    required this.course,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _creditHoursController;
  late final TextEditingController _instructorController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _scheduleController;

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _titleController = TextEditingController(text: c.title);
    _creditHoursController = TextEditingController(text: c.creditHours.toString());
    _instructorController = TextEditingController(text: c.instructor);
    _descriptionController = TextEditingController(text: c.description);
    _scheduleController = TextEditingController(text: c.schedule);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _creditHoursController.dispose();
    _instructorController.dispose();
    _descriptionController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _update() => widget.onUpdate(widget.course);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final course = widget.course;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title.isEmpty ? 'Course Details' : course.title),
        backgroundColor: Colors.brown.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Course'),
                  content: Text('Are you sure you want to delete "${course.title}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        widget.onRemove(course);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Course Title'),
                      onChanged: (value) {
                        course.title = value;
                        _update();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _creditHoursController,
                            decoration: const InputDecoration(labelText: 'Credit Hours'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              course.creditHours = int.tryParse(value) ?? course.creditHours;
                              _update();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _instructorController,
                            decoration: const InputDecoration(labelText: 'Instructor'),
                            onChanged: (value) {
                              course.instructor = value;
                              _update();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _scheduleController,
                      decoration: const InputDecoration(labelText: 'Schedule'),
                      onChanged: (value) {
                        course.schedule = value;
                        _update();
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      onChanged: (value) {
                        course.description = value;
                        _update();
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Priority
            Row(
              children: [
                Expanded(child: Text('Priority', style: theme.textTheme.titleMedium)),
                ToggleButtons(
                  isSelected: [course.priority==0, course.priority==1, course.priority==2],
                  onPressed: (i) {
                    course.priority = i;
                    _update();
                    setState(() {});
                  },
                  children: const [Text('Low'), Text('Med'), Text('High')],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Assessments
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
                                  _update();
                                  setState(() {});
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () {
                                course.weightages.remove(type);
                                _update();
                                setState(() {});
                              },
                            )
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                    AddWeightageRow(course: course, onUpdate: (c) { _update(); setState(() {}); }),
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
                                  _update();
                                  setState(() {});
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () {
                                course.scores.removeAt(idx);
                                _update();
                                setState(() {});
                              },
                            )
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                    AddScoreRow(course: course, onUpdate: (c) { _update(); setState(() {}); }),
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

            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickAndUploadFiles,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Documents'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Upload progress
            Builder(builder: (context) {
              if (_isUploading) {
                return Column(
                  children: [
                    LinearProgressIndicator(value: _progress),
                    const SizedBox(height: 8),
                    Text('${(_progress * 100).toStringAsFixed(0)}% uploaded', style: theme.textTheme.bodyMedium),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 12),
            // In-progress uploads (per-file)
            if (_fileProgress.isNotEmpty || _fileErrors.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Uploading', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ..._pickedFiles.keys.map((name) {
                        final progress = _fileProgress[name] ?? 0.0;
                        final error = _fileErrors[name];
                        final isUploading = _fileUploading[name] == true;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(value: progress),
                                    if (error != null) Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Text('Error: $error', style: theme.textTheme.bodyMedium!.copyWith(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isUploading) IconButton(icon: const Icon(Icons.cancel), onPressed: () => _cancelUpload(name)),
                              if (!isUploading && (_fileErrors[name] != null)) IconButton(icon: const Icon(Icons.refresh), onPressed: () => _retryUpload(name)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Uploaded documents list
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Documents', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (widget.course.documents.isEmpty) Text('No documents uploaded yet.', style: theme.textTheme.bodyMedium),
                    ...widget.course.documents.map((d) => ListTile(
                          title: Text(d.name),
                          subtitle: Text('by ${d.uploadedBy} • ${d.uploadedAt.toLocal().toString().split('.').first}'),
                          trailing: IconButton(icon: const Icon(Icons.open_in_new), onPressed: () => _openUrl(d.url)),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // File picking and upload
  bool _isUploading = false;
  double _progress = 0.0;
  // Per-file tracking
  final Map<String, XFile> _pickedFiles = {};
  // Using bool to indicate an active upload (Supabase upload cannot be cancelled via SDK)
  final Map<String, bool> _fileUploading = {};
  final Map<String, double> _fileProgress = {};
  final Map<String, String?> _fileErrors = {};

  Future<void> _pickAndUploadFiles() async {
    try {
      // Use file_selector to pick files across platforms
      final pickedFiles = await openFiles();
      if (pickedFiles.isEmpty) return;

      setState(() { _isUploading = true; _progress = 0.0; });

      int uploaded = 0;
      for (final picked in pickedFiles) {
        final filename = picked.name;
        _pickedFiles[filename] = picked;
        _fileProgress[filename] = 0.0;
        _fileErrors[filename] = null;
        _fileUploading[filename] = true;
        final safeCourseId = widget.course.title.isNotEmpty ? widget.course.title.replaceAll(' ', '_') : 'untitled_course';

        // Use Supabase storage. Default to 'public' bucket; change if you use
        // a different bucket name in your Supabase project.
        final supabase = Supabase.instance.client;
        final bucket = 'public';
        final path = 'courses/$safeCourseId/$filename';

        // Determine a conservative content type from file extension.
        String contentType = 'application/octet-stream';
        final lower = filename.toLowerCase();
        if (lower.endsWith('.pdf')) contentType = 'application/pdf';
        else if (lower.endsWith('.png')) contentType = 'image/png';
        else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) contentType = 'image/jpeg';
        else if (lower.endsWith('.txt')) contentType = 'text/plain';

        try {
          final bytes = await picked.readAsBytes();

          // Supabase storage upload (binary)
          await supabase.storage.from(bucket).uploadBinary(path, bytes, fileOptions: FileOptions(contentType: contentType));

          // Try to get a public URL. This returns a string when using the
          // current Supabase SDK.
          String publicUrl = supabase.storage.from(bucket).getPublicUrl(path);

          final uploaderId = Supabase.instance.client.auth.currentUser?.id ?? 'unknown';
          final doc = CourseDocument(name: filename, url: publicUrl, uploadedBy: uploaderId);
          widget.course.documents.add(doc);
          widget.onUpdate(widget.course);

          // mark done
          _fileUploading.remove(filename);
          _fileProgress.remove(filename);
          _pickedFiles.remove(filename);
          uploaded++;
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded $filename')));
        } catch (e, st) {
          debugPrint('Supabase upload error for $filename: $e\n$st');
          _fileErrors[filename] = e.toString();
          _fileUploading.remove(filename);
        }
      }

      setState(() { _isUploading = false; _progress = 0.0; });

      if (uploaded > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded $uploaded file(s)')));
      }
    } catch (e) {
      setState(() { _isUploading = false; _progress = 0.0; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  void _cancelUpload(String name) {
    // Supabase uploads are single-shot HTTP requests; we cannot reliably
    // cancel them via the client SDK. Mark the upload as cancelled locally.
    if (_fileUploading[name] == true) {
      _fileUploading.remove(name);
      _fileErrors[name] = 'Cancelled';
      setState(() {});
    }
  }

  Future<void> _retryUpload(String name) async {
    final picked = _pickedFiles[name];
    if (picked == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No file available to retry.')));
      return;
    }

    setState(() { _fileErrors[name] = null; _fileProgress[name] = 0.0; _isUploading = true; _fileUploading[name] = true; });

    final safeCourseId = widget.course.title.isNotEmpty ? widget.course.title.replaceAll(' ', '_') : 'untitled_course';
    final supabase = Supabase.instance.client;
    final bucket = 'public';
    final path = 'courses/$safeCourseId/$name';
    try {
      // Determine content type
      String contentType = 'application/octet-stream';
      final lower = name.toLowerCase();
      if (lower.endsWith('.pdf')) contentType = 'application/pdf';
      else if (lower.endsWith('.png')) contentType = 'image/png';
      else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) contentType = 'image/jpeg';
      else if (lower.endsWith('.txt')) contentType = 'text/plain';
      final bytes = await picked.readAsBytes();

      await supabase.storage.from(bucket).uploadBinary(path, bytes, fileOptions: FileOptions(contentType: contentType));

      // get public url
  final publicUrl = supabase.storage.from(bucket).getPublicUrl(path);

  final uploaderId = Supabase.instance.client.auth.currentUser?.id ?? 'unknown';
      final doc = CourseDocument(name: name, url: publicUrl, uploadedBy: uploaderId);
      widget.course.documents.add(doc);
      widget.onUpdate(widget.course);

      _fileUploading.remove(name);
      _fileProgress.remove(name);
      _pickedFiles.remove(name);
      if (!mounted) return;
      setState(() { _isUploading = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded $name')));
    } catch (e) {
      debugPrint('Retry upload error for $name: $e');
      if (!mounted) return;
      setState(() { _fileErrors[name] = e.toString(); _isUploading = false; _fileUploading.remove(name); });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }
}

// Local AddWeightageRow widget (copy of the helper used in courses_page)
class AddWeightageRow extends StatefulWidget {
  final Course course;
  final Function(Course) onUpdate;

  const AddWeightageRow({required this.course, required this.onUpdate});

  @override
  State<AddWeightageRow> createState() => _AddWeightageRowState();
}

class _AddWeightageRowState extends State<AddWeightageRow> {
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

// Local AddScoreRow widget
class AddScoreRow extends StatefulWidget {
  final Course course;
  final Function(Course) onUpdate;

  const AddScoreRow({required this.course, required this.onUpdate});

  @override
  State<AddScoreRow> createState() => _AddScoreRowState();
}

class _AddScoreRowState extends State<AddScoreRow> {
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

