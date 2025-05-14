import 'package:flutter/material.dart';

class EntryDatePicker extends StatefulWidget {
  final DateTime selectedDate; // Required selected date from parent
  final Function(DateTime) onDateChanged; // Callback to update parent's state

  const EntryDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<EntryDatePicker> createState() => _EntryDatePickerState();
}

class _EntryDatePickerState extends State<EntryDatePicker> {
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate, // Use parent's selectedDate as initial
      firstDate: DateTime(2000), // Expanded range (adjust as needed)
      lastDate: DateTime(2100), // Expanded range (adjust as needed)
    );

    if (pickedDate != null && pickedDate != widget.selectedDate) {
      widget.onDateChanged(pickedDate); // Notify parent of the change
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.withAlpha((0.5 * 255).toInt()), // Faint outline
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0), // Optional: rounded corners
          ),
          child: InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(8.0), // Match container’s radius for ripple
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Padding inside the box
              child: Text(
                '${widget.selectedDate.month}/${widget.selectedDate.day}/${widget.selectedDate.year}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}