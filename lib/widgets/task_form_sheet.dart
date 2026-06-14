import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../utils/api_error.dart';

/// Shows the add/edit task form as a modal bottom sheet.
///
/// [task] is null when creating, or the existing task when editing.
/// [onSubmit] performs the API call; the sheet owns the submitting spinner,
/// closes on success, and shows a SnackBar on failure.
Future<void> showTaskFormSheet(
  BuildContext context, {
  Task? task,
  required Future<void> Function(
    String title,
    String description,
    TaskStatus status,
    DateTime? dueDate,
  ) onSubmit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TaskFormSheet(task: task, onSubmit: onSubmit),
  );
}

class _TaskFormSheet extends StatefulWidget {
  const _TaskFormSheet({required this.task, required this.onSubmit});

  final Task? task;
  final Future<void> Function(
    String title,
    String description,
    TaskStatus status,
    DateTime? dueDate,
  ) onSubmit;

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskStatus _status;
  DateTime? _dueDate;
  bool _submitting = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _status = widget.task?.status ?? TaskStatus.todo;
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        _status,
        _dueDate,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(describeApiError(e)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Edit task' : 'New task',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                enabled: !_submitting,
                maxLength: 150,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Title is required';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                enabled: !_submitting,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Status',
                    style: Theme.of(context).textTheme.labelLarge),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TaskStatus>(
                segments: const [
                  ButtonSegment(
                      value: TaskStatus.todo, label: Text('To do')),
                  ButtonSegment(
                      value: TaskStatus.inProgress, label: Text('In progress')),
                  ButtonSegment(
                      value: TaskStatus.done, label: Text('Done')),
                ],
                selected: {_status},
                onSelectionChanged: _submitting
                    ? null
                    : (selection) =>
                        setState(() => _status = selection.first),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _submitting ? null : _pickDueDate,
                icon: const Icon(Icons.event),
                label: Text(
                  _dueDate == null
                      ? 'Set due date (optional)'
                      : 'Due ${DateFormat('d MMM yyyy').format(_dueDate!)}',
                ),
              ),
              if (_dueDate != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _submitting
                        ? null
                        : () => setState(() => _dueDate = null),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear date'),
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Save changes' : 'Create task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
