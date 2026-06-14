import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/project_detail_provider.dart';
import '../widgets/task_form_sheet.dart';
import '../widgets/task_status_chip.dart';
import '../widgets/task_tile.dart';

/// Shows a single project with its tasks: add / edit / delete tasks and
/// change a task's status (todo → in_progress → done).
class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectDetailProvider>().load(widget.projectId);
    });
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _addTask() async {
    final provider = context.read<ProjectDetailProvider>();
    await showTaskFormSheet(
      context,
      onSubmit: (title, description, status, dueDate) async {
        await provider.addTask(
          title: title,
          description: description,
          status: status,
          dueDate: dueDate,
        );
        _showSnack('Task added');
      },
    );
  }

  Future<void> _editTask(Task task) async {
    final provider = context.read<ProjectDetailProvider>();
    await showTaskFormSheet(
      context,
      task: task,
      onSubmit: (title, description, status, dueDate) async {
        await provider.updateTask(
          taskId: task.id,
          title: title,
          description: description,
          status: status,
          dueDate: dueDate,
        );
        _showSnack('Task updated');
      },
    );
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<ProjectDetailProvider>().deleteTask(task.id);
      _showSnack('Task deleted');
    } catch (e) {
      _showSnack('Failed to delete task', error: true);
    }
  }

  Future<void> _changeStatus(Task task) async {
    final selected = await showModalBottomSheet<TaskStatus>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Set status',
                    style: Theme.of(ctx).textTheme.titleMedium),
              ),
            ),
            for (final status in TaskStatus.values)
              ListTile(
                leading: Icon(Icons.circle,
                    size: 14, color: taskStatusColor(status)),
                title: Text(status.label),
                trailing: task.status == status
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(ctx, status),
              ),
          ],
        ),
      ),
    );
    if (selected == null || selected == task.status || !mounted) return;
    try {
      await context.read<ProjectDetailProvider>().changeStatus(task, selected);
      _showSnack('Status updated');
    } catch (e) {
      _showSnack('Failed to update status', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ProjectDetailProvider>(
          builder: (context, provider, _) =>
              Text(provider.project?.name ?? 'Project'),
        ),
      ),
      floatingActionButton: Consumer<ProjectDetailProvider>(
        builder: (context, provider, _) {
          if (provider.status != DetailStatus.loaded) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: _addTask,
            icon: const Icon(Icons.add),
            label: const Text('New task'),
          );
        },
      ),
      body: Consumer<ProjectDetailProvider>(
        builder: (context, provider, _) {
          switch (provider.status) {
            case DetailStatus.initial:
            case DetailStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case DetailStatus.error:
              return _ErrorState(
                message: provider.error ?? 'Something went wrong',
                onRetry: () => provider.load(widget.projectId),
              );

            case DetailStatus.loaded:
              final project = provider.project!;
              return RefreshIndicator(
                onRefresh: () => provider.load(widget.projectId),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 96),
                  children: [
                    _ProjectHeader(
                      description: project.description,
                      total: project.tasks.length,
                      done: project.doneCount,
                    ),
                    if (project.tasks.isEmpty)
                      const _EmptyTasks()
                    else
                      ...project.tasks.map(
                        (task) => TaskTile(
                          task: task,
                          onStatusTap: () => _changeStatus(task),
                          onEdit: () => _editTask(task),
                          onDelete: () => _deleteTask(task),
                        ),
                      ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  const _ProjectHeader({
    required this.description,
    required this.total,
    required this.done,
  });

  final String description;
  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description.isNotEmpty) ...[
            Text(description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(Icons.checklist_rounded,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                total == 0 ? 'No tasks yet' : '$done of $total done',
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: done / total,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      child: Column(
        children: [
          Icon(Icons.task_alt,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('No tasks yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Add your first task with the button below.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
