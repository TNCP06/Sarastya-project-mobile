import 'package:flutter/material.dart';

import '../models/task.dart';

/// The accent colour used to represent each task status across the UI.
Color taskStatusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.todo:
      return const Color(0xFF757575); // grey
    case TaskStatus.inProgress:
      return const Color(0xFFF57C00); // orange
    case TaskStatus.done:
      return const Color(0xFF2E7D32); // green
  }
}

/// A small colour-coded badge showing a task's status.
class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({super.key, required this.status, this.onTap});

  final TaskStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = taskStatusColor(status);
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                status.label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 2),
                Icon(Icons.arrow_drop_down, size: 16, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
