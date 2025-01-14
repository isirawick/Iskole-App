import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iskole/core/theme/app_palette.dart';

class DistrictDropdown extends StatefulWidget {

  DistrictDropdown({required this.onChange,this.validator,this.value});
  final Function(String?) onChange;
  final FormFieldValidator<String>? validator;
  String? value;
  @override
  _DistrictDropdownState createState() => _DistrictDropdownState();
}

class _DistrictDropdownState extends State<DistrictDropdown> {
  // List of districts in Sri Lanka
  final List<String> districts = [
    "Ampara", "Anuradhapura", "Badulla", "Batticaloa", "Colombo",
    "Galle", "Gampaha", "Hambantota", "Jaffna", "Kalutara","Kandy", "Kegalle", "Kilinochchi",
    "Kurunegala", "Mannar", "Matale", "Matara", "Monaragala", "Mullaitivu",
    "Nuwara Eliya", "Polonnaruwa", "Puttalam", "Ratnapura", "Trincomalee", "Vavuniya"
  ];


  // The selected district
  String? selectedDistrict;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      elevation: 1,
      menuMaxHeight: Get.height/1.5,
      value: selectedDistrict??widget.value,
      dropdownColor: Palette.backgroundSecondary,
      hint: Text(
        'Select District',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Palette.authInputColor,
        ),
      ),
      isExpanded: true,
      items: districts.map((district) {
        return DropdownMenuItem<String>(
          value: district,
          child: Text(
            district,
            style: TextStyle(fontSize: 16, color: Palette.authInputColor,),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        widget.onChange(newValue);
        setState(() {
          selectedDistrict = newValue;
        });
      },
      validator: widget.validator,
      decoration: InputDecoration(
        prefixIcon: SvgPicture.asset(
          'assets/svg/location.svg',
          height: 18,
          width: 18,
        ),
        prefixIconConstraints: BoxConstraints(maxHeight: 16, minWidth: 40),
        prefixIconColor: Palette.errorColor,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Palette.authInputColor,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Palette.gradient3,
          ),
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Palette.authInputColor,
        ),
        floatingLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Palette.gradient3,
        ),
      ),
      // underline: SizedBox(),
    );
  }
}
