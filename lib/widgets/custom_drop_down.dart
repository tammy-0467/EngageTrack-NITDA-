import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomDropDown extends StatelessWidget {
  final String? value;
  final double width;
  final bool isExpanded;
  final List<DropdownMenuItem<String>>? items;
  final void Function(String?)? onChanged;
  final Widget? hint;

  const CustomDropDown({super.key,
    required this.value,
    required this.width,
    required this.isExpanded,
    required this.items,
    required this.onChanged,
    required this.hint
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton2(
      items: items,
      isExpanded: isExpanded,
      value: value,
      onChanged: onChanged,
      hint: hint,
      dropdownStyleData: DropdownStyleData(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      iconStyleData: IconStyleData(
        iconEnabledColor: Theme.of(context).colorScheme.onPrimary,
        iconDisabledColor: Theme.of(context).colorScheme.onPrimary,
      ),
      style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary),
    );
  }
}
