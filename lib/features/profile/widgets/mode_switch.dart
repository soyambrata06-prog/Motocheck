import 'package:flutter/material.dart';
import '../../../core/constants/enums.dart';

class ModeSwitch extends StatelessWidget {
  final UserRole currentRole;
  final Function(UserRole) onRoleChanged;

  const ModeSwitch({
    super.key,
    required this.currentRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<UserRole>(
      segments: const [
        ButtonSegment(value: UserRole.rider, label: Text('Rider'), icon: Icon(Icons.motorcycle)),
        ButtonSegment(value: UserRole.police, label: Text('Police'), icon: Icon(Icons.local_police)),
      ],
      selected: {currentRole},
      onSelectionChanged: (Set<UserRole> newSelection) {
        onRoleChanged(newSelection.first);
      },
    );
  }
}

