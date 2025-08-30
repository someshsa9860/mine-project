import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

Color baseColor = Colors.black;
Color highlightColor = Colors.blue;
Color childColor = Colors.black;
String currency = "";
const String placeholder = 'assets/placeholder.png';

class MyCustomCard extends StatelessWidget {
  final Widget child;

  final double topLeft;
  final double margin;
  final double elevation;
  final double topRight;

  final double padding;
  final double bottomLeft;
  final Color color;
  final double bottomRight;
  final double? radius;

  const MyCustomCard({
    super.key,
    required this.child,
    this.topLeft = 8.0,
    this.topRight = 8.0,
    this.padding = 8.0,
    this.color = Colors.white,
    this.elevation = 1.0,
    this.bottomLeft = 8.0,
    this.margin = 4.0,
    this.bottomRight = 8.0,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: radius != null
            ? BorderRadius.circular(radius!)
            : BorderRadius.only(
                topLeft: Radius.circular(topLeft),
                topRight: Radius.circular(topRight),
                bottomLeft: Radius.circular(bottomLeft),
                bottomRight: Radius.circular(bottomRight),
              ),
      ),
      margin: EdgeInsets.symmetric(vertical: margin),
      elevation: elevation,
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
  }
}

class MyContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color? color;
  final Color? background;
  final Gradient? gradient;
  final double thickness;
  final double? width;
  final double? height;
  final double padding;
  final double innerPadding;
  final BorderStyle borderStyle;
  final double? topLeft, topRight, bottomRight, bottomLeft;

  const MyContainer({
    super.key,
    required this.child,
    this.radius = 8.0,
    this.padding = 0.0,
    this.innerPadding = 0.0,
    this.background,
    this.color,
    this.borderStyle = BorderStyle.solid,
    this.thickness = 0.50,
    this.width,
    this.topLeft,
    this.topRight,
    this.bottomRight,
    this.bottomLeft,
    this.height,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: background,
          gradient: gradient,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeft ?? radius),
            topRight: Radius.circular(topRight ?? radius),
            bottomRight: Radius.circular(bottomRight ?? radius),
            bottomLeft: Radius.circular(bottomLeft ?? radius),
          ),
          border: Border.all(
            color: color ?? Colors.indigo.withOpacity(0.2),
            width: thickness,
            style: borderStyle,
          ),
        ),
        child: Padding(padding: EdgeInsets.all(innerPadding), child: child),
      ),
    );
  }
}

///if there is no data in list
class Empty extends StatelessWidget {
  const Empty({Key? key, this.msg = 'Data is not available'}) : super(key: key);

  final String msg;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [AppLogo(), Text(msg)],
        ),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/icons/logo.png',
        width: size ?? 100,
        height: size ?? 100,
      ),
    );
  }
}

class TextInput extends StatelessWidget {
  final String keyName;
  final Map<dynamic, dynamic> initData;
  final String hint;
  final BuildContext context;
  final TextInputType inputType;
  final int minLines;
  final int? maxLines;
  final int? limit;
  final InputBorder? border;
  final bool obscureText;
  final dynamic autofillHints;
  final Widget? icon;
  final Widget? suffix;
  final Widget? suffixIcon;
  final EdgeInsets padding;
  final ValueChanged<String>? onChanged;
  final bool edit;
  final double radius;
  final Color? fillColor;
  final bool filled;
  final bool capitalized;
  final bool requiredField;

  const TextInput({
    super.key,
    required this.keyName,
    required this.initData,
    required this.hint,
    required this.context,
    this.inputType = TextInputType.text,
    this.minLines = 1,
    this.maxLines = 1,
    this.limit,
    this.border,
    this.obscureText = false,
    this.autofillHints,
    this.icon,
    this.suffix,
    this.suffixIcon,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    this.onChanged,
    required this.edit,
    this.radius = 8,
    this.fillColor,
    this.filled = false,
    this.capitalized = false,
    this.requiredField = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = icon == null
        ? border ??
              OutlineInputBorder(borderRadius: BorderRadius.circular(radius))
        : InputBorder.none;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hint.isNotEmpty)
          Text(
            "$hint ${requiredField ? "*" : ""}",
            style: Theme.of(context).textTheme.labelLarge,
          ).pOnly(bottom: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: '${initData[keyName] ?? ""}',
                keyboardType: inputType,
                enabled: edit,
                autofillHints: autofillHints,
                maxLength: limit,
                obscureText: obscureText,
                minLines: minLines,
                maxLines: maxLines,
                onChanged: onChanged,
                onSaved: (v) => initData[keyName] = v,
                onFieldSubmitted: (v) => initData[keyName] = v,
                textCapitalization: (keyName == "regno" || capitalized)
                    ? TextCapitalization.characters
                    : TextCapitalization.none,
                textInputAction: inputType == TextInputType.multiline
                    ? TextInputAction.newline
                    : TextInputAction.done,
                validator: (v) {
                  if (!requiredField) return null;
                  if (v == null || v.isEmpty) return hint;
                  return null;
                },
                decoration: InputDecoration(
                  hintText: hint,
                  suffix: suffix,
                  suffixIcon: suffixIcon,
                  filled: filled,
                  fillColor: fillColor,
                  contentPadding: padding,
                  border: effectiveBorder,
                ),
              ),
            ),
            if (icon != null) icon!,
          ],
        ),
      ],
    ).py8();
  }
}

// Replace with your actual formatters
final DateFormat onlyDateFormat = DateFormat('yyyy-MM-dd');
final DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

class DateInputWidget extends StatelessWidget {
  final String fieldKey;
  final String hint;
  final Map initData;
  final bool isFullDate;
  final VoidCallback onUpdated;
  final bool edit;

  const DateInputWidget({
    super.key,
    required this.fieldKey,
    required this.hint,
    required this.initData,
    this.isFullDate = false,
    required this.onUpdated,
    required this.edit,
  });

  @override
  Widget build(BuildContext context) {
    final selectedDate = initData[fieldKey] != null
        ? (isFullDate ? dateTimeFormat : onlyDateFormat).format(
            DateTime.parse(initData[fieldKey]),
          )
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(hint, style: Theme.of(context).textTheme.titleSmall),
          ),
          TextButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(
              selectedDate ?? 'Choose',
              style: TextStyle(
                color: selectedDate == null ? Colors.grey : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: !edit
                ? null
                : () async {
                    DateTime? res;
                    if (isFullDate) {
                      res = await showBoardDateTimePickerForDateTime(
                        context: context,
                        initialDate: DateTime.now(),
                        minimumDate: DateTime(1950),
                        maximumDate: DateTime(2030),
                      );
                    } else {
                      res = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2030),
                      );
                    }

                    if (res != null) {
                      initData[fieldKey] = isFullDate
                          ? res.toIso8601String()
                          : onlyDateFormat.format(res);
                      onUpdated();
                    }
                  },
          ),
        ],
      ),
    );
  }
}

DateFormat get timeFormat => DateFormat('HH:mm:ss');

class DropDownInputWidget extends StatelessWidget {
  final List<Map<String, dynamic>> list;
  final Map<dynamic, dynamic> initData;
  final dynamic fieldKey;
  final TextEditingController? searchController;
  final VoidCallback setStateCallback;
  final Widget? suffixIcon;
  final String hint;

  const DropDownInputWidget({
    super.key,
    required this.list,
    required this.initData,
    required this.fieldKey,
    this.searchController,
    required this.setStateCallback,
    this.suffixIcon,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$hint :",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 40,
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField2<dynamic>(
                  isExpanded: true,
                  hint: Text(
                    'choose',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  items: list
                      .map(
                        (e) => DropdownMenuItem(
                          value: e['value'],
                          child: Text("${e['label']}"),
                        ),
                      )
                      .toList(),
                  value: initData[fieldKey],
                  onChanged: (v) {
                    initData[fieldKey] = v;
                    setStateCallback();
                  },
                  dropdownSearchData: searchController == null
                      ? null
                      : DropdownSearchData(
                          searchInnerWidgetHeight: 50,
                          searchController: searchController,
                          searchInnerWidget: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: TextFormField(
                              expands: true,
                              controller: searchController,
                              maxLines: null,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                hintText: 'Search for an item...',
                                hintStyle: const TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          searchMatchFn: (item, searchValue) {
                            return item.value.toString().toLowerCase().contains(
                              searchValue.toLowerCase(),
                            );
                          },
                        ),
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    height: 40,
                    width: 140,
                    elevation: 8,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  iconStyleData: const IconStyleData(iconSize: 0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    suffixIcon: suffixIcon,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RadioInput extends StatelessWidget {
  final List<String> list;
  final Map<dynamic, dynamic> initData;
  final String keyName;
  final VoidCallback onChanged;
  final String hint;
  final Widget? suffixIcon;

  const RadioInput({
    super.key,
    required this.list,
    required this.initData,
    required this.keyName,
    required this.onChanged,
    required this.hint,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    var value = initData[keyName];
    if (!list.contains(value)) {
      value = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text("$hint : ", style: Theme.of(context).textTheme.titleMedium),
          if (suffixIcon != null) suffixIcon!,
          Expanded(
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: list.map((e) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: e,
                        groupValue: value,
                        onChanged: (v) {
                          initData[keyName] = v;
                          onChanged();
                        },
                      ),
                      Text(
                        _capitalize(e),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;
}

class Label extends StatelessWidget {
  final dynamic text;

  final double? fontSize;
  final Color? color;

  const Label({Key? key, required this.text, this.fontSize, this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '$text',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
          color: color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

showSnackBar(message) {
  Get.showSnackbar(
    GetSnackBar(message: "$message", duration: Duration(seconds: 3)),
  );
}

enum SettingKeys { bluetooth, paper, bluetoothFont }
