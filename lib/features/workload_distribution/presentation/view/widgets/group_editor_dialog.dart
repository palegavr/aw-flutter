import 'package:flutter/material.dart';

class GroupEditorDialog extends StatefulWidget {
  final List<String> initialGroups;
  final ValueChanged<List<String>> onSave;

  const GroupEditorDialog({
    super.key,
    required this.initialGroups,
    required this.onSave,
  });

  @override
  State<GroupEditorDialog> createState() => _GroupEditorDialogState();
}

class _GroupEditorDialogState extends State<GroupEditorDialog> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    for (final group in widget.initialGroups) {
      if (group.trim().isNotEmpty) {
        _addController(group);
      }
    }
    // Always start with one empty field at the end
    _addController('');
  }

  void _addController(String text) {
    final controller = TextEditingController(text: text);
    final focusNode = FocusNode();

    controller.addListener(() {
      _onControllerChange(controller);
    });

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        _onFocusLost(controller, focusNode);
      }
    });

    _controllers.add(controller);
    _focusNodes.add(focusNode);
  }

  void _onControllerChange(TextEditingController controller) {
    // If the changed controller is the last one and it has text, add a new empty one
    if (controller == _controllers.last && controller.text.isNotEmpty) {
      setState(() {
        _addController('');
      });
    } else {
      // Rebuild to update delete button visibility
      setState(() {});
    }
  }

  void _onFocusLost(TextEditingController controller, FocusNode focusNode) {
    // If text is empty and it's NOT the last one, remove it
    if (controller.text.isEmpty && controller != _controllers.last) {
      final index = _controllers.indexOf(controller);
      if (index != -1) {
        // Schedule removal for next frame to avoid disposing during notification
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _controllers.contains(controller)) {
            // Check index again as it might have changed
            final currentIndex = _controllers.indexOf(controller);
            if (currentIndex != -1) {
              _removeController(currentIndex);
            }
          }
        });
      }
    }
  }

  void _removeController(int index) {
    final controller = _controllers[index];
    final focusNode = _focusNodes[index];

    // Don't remove if it's the last one (safety check, though onFocusLost handles this logic too)
    // Actually, user might click delete button on the last one if it has text.
    // Logic for delete button:
    // If last one has text, we added a NEW empty one below it. So the one having text is NOT the last one anymore.
    // So usually we are deleting non-last items.
    // If we delete a middle item, just remove it.

    controller.dispose();
    focusNode.dispose();

    setState(() {
      _controllers.removeAt(index);
      _focusNodes.removeAt(index);
    });

    // Ensure we exist in a valid state (should be guaranteed by logic, but just in case)
    if (_controllers.isEmpty) {
      _addController('');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редагування груп'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Введіть назви груп. Порожні поля будуть автоматично видалені.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _controllers.length,
                  itemBuilder: (context, index) {
                    final controller = _controllers[index];
                    final focusNode = _focusNodes[index];
                    final showDelete = controller.text.isNotEmpty;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child:
                                showDelete
                                    ? IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.red[400],
                                      onPressed: () => _removeController(index),
                                    )
                                    : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        ElevatedButton(
          onPressed: () {
            final result =
                _controllers
                    .map((c) => c.text.trim())
                    .where((text) => text.isNotEmpty)
                    .toList();
            widget.onSave(result);
            Navigator.of(context).pop();
          },
          child: const Text('Зберегти'),
        ),
      ],
    );
  }
}
