
import 'package:flutter/material.dart';

import '../multi_select_dialog/index.dart';
import 'index.dart';

/// A customizable InkWell widget that opens the MultiSelectDialog
// ignore: must_be_immutable
class MultiDynamicSelectField<V> extends FormField<List<MultiSelectItem<V>>> {
  /// An enum that determines which type of list to render.
  final MultiSelectListType? listType;

  /// Style the Container that makes up the field.
  final BoxDecoration? decoration;

  /// Set text that is displayed on the button.
  final Text? buttonText;

  /// Specify the button icon.
  final Icon? buttonIcon;

  /// The text at the top of the dialog.
  final Widget? title;

  // /// List of items to select from.
  // final List<MultiSelectItem<V>> items;

  /// Fires when the an item is selected / unselected.
  final void Function(List<MultiSelectItem<V>>)? onSelectionChanged;

  /// Overrides the default MultiSelectChipDisplay attached to this field.
  /// If you want to remove it, use MultiSelectChipDisplay.none().
  final MultiSelectChipDisplay<V>? chipDisplay;

  /// The list of selected values before interaction.
  @override
  final List<MultiSelectItem<V>> initialValue;

  /// Fires when confirm is tapped.
  final void Function(List<MultiSelectItem<V>>) onConfirm;

  /// Toggles search functionality.
  final bool searchable;

  /// Text on the confirm button.
  final Text? confirmText;

  /// Text on the cancel button.
  final Text? cancelText;

  /// Set the color of the space outside the BottomSheet.
  final Color? barrierColor;

  /// Sets the color of the checkbox or chip when it's selected.
  final Color? selectedColor;

  /// Sets a fixed height on the dialog.
  final double? dialogHeight;

  /// Sets a fixed width on the dialog.
  final double? dialogWidth;

  /// Set the placeholder text of the search field.
  final String? searchHint;

  /// A function that sets the color of selected items based on their value.
  /// It will either set the chip color, or the checkbox color depending on the list type.
  final Color Function(V)? colorator;

  /// Set the background color of the dialog.
  final Color? backgroundColor;

  /// Color of the chip body or checkbox border while not selected.
  final Color? unselectedColor;

  /// Replaces the deafult search icon when searchable is true.
  final Icon? searchIcon;

  /// Replaces the default close search icon when searchable is true.
  final Icon? closeSearchIcon;

  /// Style the text on the chips or list tiles.
  final TextStyle? itemsTextStyle;

  /// Style the text on the selected chips or list tiles.
  final TextStyle? selectedItemsTextStyle;

  /// Style the text that is typed into the search field.
  final TextStyle? searchTextStyle;

  /// Style the search hint.
  final TextStyle? searchHintStyle;

  /// Moves the selected items to the top of the list.
  final bool separateSelectedItems;

  /// Set the color of the check in the checkbox
  final Color? checkColor;

  /// Whether the user can dismiss the widget by tapping outside
  final bool isDismissible;
  final bool loading;
  final void Function(void Function(List<MultiSelectItem<V>> Function() onChanged) callback) onCallbackBuilder;

  final AutovalidateMode autovalidateMode;
  final FormFieldValidator<List<MultiSelectItem<V>>>? validator;
  final FormFieldSetter<List<MultiSelectItem<V>>>? onSaved;
  final GlobalKey<FormFieldState>? key;
  FormFieldState<List<MultiSelectItem<V>>>? state;

  MultiDynamicSelectField({
    required this.onConfirm,
    required this.onCallbackBuilder,
    this.title,
    this.buttonText,
    this.buttonIcon,
    this.listType,
    this.decoration,
    this.onSelectionChanged,
    this.chipDisplay,
    this.searchable = false,
    this.loading = false,
    this.confirmText,
    this.cancelText,
    this.barrierColor,
    this.selectedColor,
    this.searchHint,
    this.dialogHeight,
    this.dialogWidth,
    this.colorator,
    this.backgroundColor,
    this.unselectedColor,
    this.searchIcon,
    this.closeSearchIcon,
    this.itemsTextStyle,
    this.searchTextStyle,
    this.searchHintStyle,
    this.selectedItemsTextStyle,
    this.separateSelectedItems = false,
    this.checkColor,
    this.isDismissible = true,
    this.onSaved,
    this.validator,
    this.initialValue = const [],
    this.autovalidateMode = AutovalidateMode.disabled,
    this.key,
  }) : super(
            key: key,
            onSaved: onSaved,
            validator: validator,
            autovalidateMode: autovalidateMode,
            initialValue: initialValue,
            builder: (FormFieldState<List<MultiSelectItem<V>>> state) {
              _MultiSelectDialogFieldView<V> field = _MultiSelectDialogFieldView<V>(
                title: title,
                onCallbackBuilder: onCallbackBuilder,
                buttonText: buttonText,
                buttonIcon: buttonIcon,
                chipDisplay: chipDisplay,
                decoration: decoration,
                listType: listType,
                onConfirm: onConfirm,
                onSelectionChanged: onSelectionChanged,
                initialValue: initialValue,
                searchable: searchable,
                confirmText: confirmText,
                cancelText: cancelText,
                barrierColor: barrierColor,
                selectedColor: selectedColor,
                searchHint: searchHint,
                dialogHeight: dialogHeight,
                dialogWidth: dialogWidth,
                colorator: colorator,
                backgroundColor: backgroundColor,
                unselectedColor: unselectedColor,
                searchIcon: searchIcon,
                closeSearchIcon: closeSearchIcon,
                itemsTextStyle: itemsTextStyle,
                searchTextStyle: searchTextStyle,
                searchHintStyle: searchHintStyle,
                selectedItemsTextStyle: selectedItemsTextStyle,
                separateSelectedItems: separateSelectedItems,
                checkColor: checkColor,
                isDismissible: isDismissible,
                loading: loading,
              );
              return _MultiSelectDialogFieldView<V>._withState(field, state);
            });
}

// ignore: must_be_immutable
class _MultiSelectDialogFieldView<V> extends StatefulWidget {
  final MultiSelectListType? listType;
  final BoxDecoration? decoration;
  final Text? buttonText;
  final Icon? buttonIcon;
  final Widget? title;

  // final List<MultiSelectItem<V>> items;
  final void Function(List<MultiSelectItem<V>>)? onSelectionChanged;
  final MultiSelectChipDisplay<V>? chipDisplay;
  final List<MultiSelectItem<V>> initialValue;
  final void Function(List<MultiSelectItem<V>>)? onConfirm;
  final bool? searchable;
  final Text? confirmText;
  final Text? cancelText;
  final Color? barrierColor;
  final Color? selectedColor;
  final double? dialogHeight;
  final double? dialogWidth;
  final String? searchHint;
  final Color Function(V)? colorator;
  final Color? backgroundColor;
  final Color? unselectedColor;
  final Icon? searchIcon;
  final Icon? closeSearchIcon;
  final TextStyle? itemsTextStyle;
  final TextStyle? selectedItemsTextStyle;
  final TextStyle? searchTextStyle;
  final TextStyle? searchHintStyle;
  final bool separateSelectedItems;
  final Color? checkColor;
  final bool isDismissible;
  FormFieldState<List<MultiSelectItem<V>>>? state;
  final void Function(void Function(List<MultiSelectItem<V>> Function() onChanged) callback) onCallbackBuilder;
  final bool loading;

  _MultiSelectDialogFieldView({
    this.title,
    this.buttonText,
    this.buttonIcon,
    this.listType,
    this.decoration,
    this.onSelectionChanged,
    this.onConfirm,
    this.chipDisplay,
    this.initialValue = const [],
    this.searchable,
    this.confirmText,
    this.cancelText,
    this.barrierColor,
    this.selectedColor,
    this.searchHint,
    this.dialogHeight,
    this.dialogWidth,
    this.colorator,
    this.backgroundColor,
    this.unselectedColor,
    this.searchIcon,
    this.closeSearchIcon,
    this.itemsTextStyle,
    this.searchTextStyle,
    this.searchHintStyle,
    this.selectedItemsTextStyle,
    this.separateSelectedItems = false,
    this.loading = false,
    this.checkColor,
    required this.isDismissible,
    required this.onCallbackBuilder,
  });

  /// This constructor allows a FormFieldState to be passed in. Called by MultiSelectDialogField.
  _MultiSelectDialogFieldView._withState(_MultiSelectDialogFieldView<V> field, FormFieldState<List<MultiSelectItem<V>>> this.state)
      : title = field.title,
        loading = field.loading,
        buttonText = field.buttonText,
        buttonIcon = field.buttonIcon,
        onCallbackBuilder = field.onCallbackBuilder,
        listType = field.listType,
        decoration = field.decoration,
        onSelectionChanged = field.onSelectionChanged,
        onConfirm = field.onConfirm,
        chipDisplay = field.chipDisplay,
        initialValue = field.initialValue,
        searchable = field.searchable,
        confirmText = field.confirmText,
        cancelText = field.cancelText,
        barrierColor = field.barrierColor,
        selectedColor = field.selectedColor,
        dialogHeight = field.dialogHeight,
        dialogWidth = field.dialogWidth,
        searchHint = field.searchHint,
        colorator = field.colorator,
        backgroundColor = field.backgroundColor,
        unselectedColor = field.unselectedColor,
        searchIcon = field.searchIcon,
        closeSearchIcon = field.closeSearchIcon,
        itemsTextStyle = field.itemsTextStyle,
        searchHintStyle = field.searchHintStyle,
        searchTextStyle = field.searchTextStyle,
        selectedItemsTextStyle = field.selectedItemsTextStyle,
        separateSelectedItems = field.separateSelectedItems,
        checkColor = field.checkColor,
        isDismissible = field.isDismissible;

  @override
  __MultiSelectDialogFieldViewState createState() => __MultiSelectDialogFieldViewState<V>();
}

class __MultiSelectDialogFieldViewState<V> extends State<_MultiSelectDialogFieldView<V>> {
  List<MultiSelectItem<V>> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItems.addAll(widget.initialValue);
  }

  @override
  void didUpdateWidget(_MultiSelectDialogFieldView<V> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue) {
      _selectedItems = [];
      _selectedItems.addAll(widget.initialValue);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.state!.didChange(_selectedItems);
      });
    }
  }

  Widget _buildInheritedChipDisplay() {
    List<MultiSelectItem<V>> chipDisplayItems = [..._selectedItems];
    chipDisplayItems.removeWhere((element) => element.value == null);

    if (widget.chipDisplay != null) {
      // if user has specified a chipDisplay, use its params
      if (widget.chipDisplay!.disabled!) {
        return Container();
      } else {
        return MultiSelectDynamicChipDisplay<V>(
          items: _selectedItems,
          colorator: widget.chipDisplay!.colorator ?? widget.colorator,
          onTap: (item) {
            List<MultiSelectItem<V>> newValues = List.from(_selectedItems);
            // if (widget.chipDisplay!.onTap != null) {
            //   dynamic result = widget.chipDisplay!.onTap!(item);
            //   if (result is List<V>) newValues = result;
            // }
            newValues.remove(item);

            _selectedItems = newValues;
            if (widget.state != null) {
              widget.state!.didChange(_selectedItems);
            }
            if (widget.onConfirm != null) widget.onConfirm!(_selectedItems);
          },
          decoration: widget.chipDisplay!.decoration,
          chipColor: widget.chipDisplay!.chipColor ?? ((widget.selectedColor != null && widget.selectedColor != Colors.transparent) ? widget.selectedColor!.withOpacity(0.35) : null),
          alignment: widget.chipDisplay!.alignment,
          textStyle: widget.chipDisplay!.textStyle,
          icon: null,
          shape: widget.chipDisplay!.shape,
          scroll: widget.chipDisplay!.scroll,
          scrollBar: widget.chipDisplay!.scrollBar,
          height: widget.chipDisplay!.height,
          chipWidth: widget.chipDisplay!.chipWidth,
        );
      }
    } else {
      // user didn't specify a chipDisplay, build the default
      return MultiSelectChipDisplay<V>(
        items: chipDisplayItems,
        colorator: widget.colorator,
        chipColor: (widget.selectedColor != null && widget.selectedColor != Colors.transparent) ? widget.selectedColor!.withOpacity(0.35) : null,
      );
    }
  }

  void onChanged(List<MultiSelectItem<V>> selected) {
    _selectedItems = selected;
    if (widget.state != null) {
      widget.state!.didChange(_selectedItems);
    }
    if (widget.onConfirm != null) widget.onConfirm!(_selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () {
            widget.onCallbackBuilder((item) => onChanged(item.call()));
          },
          child: Container(
            decoration: widget.state != null
                ? widget.decoration ??
                    BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      border: Border.all(
                        color: widget.state != null && widget.state!.hasError
                            ? Colors.red.shade800.withOpacity(0.6)
                            : _selectedItems.isNotEmpty
                                ? (widget.selectedColor != null && widget.selectedColor != Colors.transparent)
                                    ? widget.selectedColor!
                                    : Theme.of(context).primaryColor
                                : Colors.black45,
                        width: _selectedItems.isNotEmpty
                            ? (widget.state != null && widget.state!.hasError)
                                ? 1.4
                                : 1.8
                            : 1.2,
                      ),
                    )
                : widget.decoration,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _selectedItems.isNotEmpty ? Expanded(child: _buildInheritedChipDisplay()) : widget.buttonText ?? const Text("Select"),
                _selectedItems.isNotEmpty ? const SizedBox.shrink() : (widget.buttonIcon ?? const Icon(Icons.arrow_downward)),
              ],
            ),
          ),
        ),
        widget.state != null && widget.state!.hasError ? const SizedBox(height: 5) : Container(),
        widget.state != null && widget.state!.hasError
            ? Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      widget.state!.errorText!,
                      style: TextStyle(
                        color: Colors.red[800],
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
      ],
    );
  }
}
