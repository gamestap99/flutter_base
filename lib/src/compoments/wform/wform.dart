import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'index.dart';
import 'types/date_range.dart';
import 'widgets/w_date_range.dart';
import 'widgets/w_input_birthday.dart';

GlobalKey<_WFormState<T>> useWForm<T>() {
  return GlobalKey<_WFormState<T>>();
}

class WForm<T> extends StatefulWidget {
  final List<BaseForm> items;
  final Widget Function(Map<String, Widget> items)? builder;
  final EdgeInsetsGeometry? padding;
  final double space;

  const WForm({
    super.key,
    required this.items,
    this.builder,
    this.padding,
    this.space = 16,
  });

  @override
  State<WForm<T>> createState() => _WFormState<T>();
}

class _WFormState<T> extends State<WForm<T>> {
  late final WFormBloc<T> bloc;
  final Map<String, TextEditingController> listController = {};

  @override
  void initState() {
    bloc = context.read<WFormBloc<T>>();

    for (var item in widget.items) {
      listController[item.name] = TextEditingController();
    }
    super.initState();
  }

  bool getRequired(BaseForm item) {
    for (var validate in item.validators ?? <MValidateFormItem>[]) {
      if ((validate.require ?? false)) {
        return true;
      }
    }

    return false;
  }

  String? validator(String? txt, BaseForm item, Map<String, dynamic> values) {
    if (txt == null) {
      return null;
    } else {
      for (var validate in item.validators ?? <MValidateFormItem>[]) {
        if ((validate.require ?? false) && (txt.isEmpty)) {
          return validate.message;
        }

        if (validate.min != null && txt.length < validate.min!) {
          return validate.message;
        }

        if (validate.max != null && txt.length > validate.max!) {
          return validate.message;
        }

        if (validate.customCheck?.call(txt, values) ?? false) {
          return validate.message;
        }
      }
    }

    return null;
  }

  void reset() {
    listController.forEach((key, value) {
      value.value = const TextEditingValue();
    });
    bloc.onReset();
    // AppConsole.dump("reset foprm");
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Widget> items = {};

    for (var element in widget.items) {
      late Widget child;
      if (element is MFormItem) {
        switch (element.type) {
          case EFormItem.birthday:
            {
              child = BlocBuilder<WFormBloc<T>, WFormState>(
                buildWhen: (previous, current) {
                  return (previous.values[element.name] != current.values[element.name]) || (previous.errors[element.name] != current.errors[element.name]);
                },
                builder: (context, state) {
                  String value = '';

                  if (state.values[element.name] != null) {
                    value = state.values[element.name];
                  } else if (element.value != null) {
                    value = element.value;
                  }
                  return WInputBirthday(
                    label: element.label,
                    space: false,
                    enabled: true,
                    stackedLabel: true,
                    controller: listController[element.name] ?? TextEditingController(),
                    name: element.name,
                    value: value,
                    labelStyle: element.labelStyle,
                    required: getRequired(element),
                    onChanged: (value) {
                      context.read<WFormBloc<T>>().add(
                            WFormChangeValue(
                              name: element.name,
                              value: value,
                            ),
                          );
                    },
                    enabledBorder: element.options?.enabledBorder,
                    errorBorder: element.options?.errorBorder,
                    focusedBorder: element.options?.focusedBorder,
                    disabledBorder: element.options?.disabledBorder,
                    fillColor: element.fillColor,
                    iconColor: element.options?.iconColor,
                    requiredColor: element.options?.requiredColor,
                    style: element.options?.style,
                    hintStyle: element.options?.hintStyle,
                    validator: (txt) => validator(txt, element, state.values),
                    textInputAction: element.textInputAction,
                  );
                },
              );

              break;
            }
          case EFormItem.multiDynamicSelect:
            {
              child = BlocBuilder<WFormBloc<T>, WFormState>(
                buildWhen: (previous, current) {
                  return previous.values[element.name] != current.values[element.name];
                },
                builder: (context, state) {
                  return WMultiDynamicSelect(
                    stackedLabel: true,
                    label: element.label,
                    onCallbackBuilder: element.customDynamicBuilder!,
                    onChanged: (items) {
                      List<dynamic> values = items.map((e) => e.value).toList();
                      element.onChanged?.call(items);

                      context.read<WFormBloc<T>>().add(
                            WFormChangeValue(
                              name: element.name,
                              value: values,
                            ),
                          );
                    },
                  );
                },
              );

              break;
            }

          case EFormItem.multiSelect:
            {
              child = BlocBuilder<WFormBloc<T>, WFormState>(
                buildWhen: (previous, current) {
                  return previous.values[element.name] != current.values[element.name];
                },
                builder: (context, state) {
                  return WMultiSelect<dynamic>(
                    items: element.itemsMulti,
                    validator: (value) {
                      return null;
                    },
                    customBuilder: element.customBuilder,
                    onChanged: (values) {
                      context.read<WFormBloc<T>>().add(
                            WFormChangeValue(
                              name: element.name,
                              value: values,
                            ),
                          );
                    },
                  );
                },
              );

              break;
            }

          default:
            {
              child = BlocBuilder<WFormBloc<T>, WFormState>(
                buildWhen: (previous, current) {
                  return (previous.values[element.name] != current.values[element.name]) || (previous.errors[element.name] != current.errors[element.name]);
                },
                builder: (context, state) {
                  String value = '';

                  if (state.values[element.name] != null) {
                    value = state.values[element.name];
                  } else if (element.value != null) {
                    value = element.value;
                  }

                  return WInput(
                    controller: listController[element.name] ?? TextEditingController(),
                    name: element.name,
                    label: element.label,
                    value: value,
                    hintText: element.hint,
                    password: element.isPassword,
                    labelStyle: element.labelStyle,
                    required: getRequired(element),
                    errorText: state.errors[element.name],
                    minLines: element.minLines,
                    maxLines: element.isPassword ? 1 : (element.maxLines ?? 1),
                    icon: element.icon,
                    onChanged: (value) {
                      context.read<WFormBloc<T>>().add(
                            WFormChangeValue(
                              name: element.name,
                              value: value,
                            ),
                          );
                    },
                    enabledBorder: element.options?.enabledBorder,
                    errorBorder: element.options?.errorBorder,
                    focusedBorder: element.options?.focusedBorder,
                    disabledBorder: element.options?.disabledBorder,
                    fillColor: element.fillColor,
                    iconColor: element.options?.iconColor,
                    requiredColor: element.options?.requiredColor,
                    style: element.options?.style,
                    hintStyle: element.options?.hintStyle,
                    validator: (txt) => validator(txt, element, state.values),
                    stackedLabel: element.stackedLabel,
                    textInputAction: element.textInputAction,
                  );
                },
              );

              break;
            }
        }
      } else if (element is MFormDateItem) {
        child = BlocBuilder<WFormBloc<T>, WFormState>(
          buildWhen: (previous, current) {
            return (previous.values[element.name] != current.values[element.name]) || (previous.errors[element.name] != current.errors[element.name]);
          },
          builder: (context, state) {
            String value = '';

            if (state.values[element.name] != null) {
              value = state.values[element.name];
            } else if (element.value != null) {
              value = element.value;
            }

            return WDate(
              controller: listController[element.name] ?? TextEditingController(),
              // name: element.name,
              label: element.label,
              value: value,
              // required: getRequired(element),
              // errorText: state.errors[element.name],
              maxLines: 3,
              onChanged: (value) {
                context.read<WFormBloc<T>>().add(
                      WFormChangeValue(
                        name: element.name,
                        value: value,
                      ),
                    );
              },
              // validator: (txt) => validator(txt, element),
              stackedLabel: true,
            );
          },
        );
      } else if (element is MFormSelectItem) {
        assert(element.items != null);
        child = BlocBuilder<WFormBloc<T>, WFormState>(
          buildWhen: (previous, current) {
            return previous.values[element.name] != current.values[element.name];
          },
          builder: (context, state) {
            String value = '';
            final index = element.items!.indexWhere((el) => el.value == state.values[element.name]);

            if (index >= 0 && index < element.items!.length) {
              value = element.items![index].name;
            } else {
              final index = element.items!.indexWhere((el) => el.value == element.value);

              if (index >= 0) {
                value = element.items![index].name;
              }
            }

            return WSelect(
              name: element.name,
              label: element.label,
              onChanged: (value) {
                context.read<WFormBloc<T>>().add(
                      WFormChangeValue(
                        name: element.name,
                        value: value,
                      ),
                    );
              },
              value: value,
              hintText: element.hint,
              // validator: (txt) => validator(txt,element),
              controller: listController[element.name] ?? TextEditingController(),
              items: element.items!,
              itemSelect: (content, int index) {},
              selectLabel: () {},
              selectValue: () {},
              // stackedLabel: true,
            );
          },
        );
      } else if (element is MFormDateRangeItem) {
        child = BlocBuilder<WFormBloc<T>, WFormState>(
          buildWhen: (previous, current) {
            return (previous.values[element.name] != current.values[element.name]) || (previous.errors[element.name] != current.errors[element.name]);
          },
          builder: (context, state) {
            String value = '';

            // if (state.values[element.name] != null) {
            //   value = state.values[element.name];
            // } else if (element.value != null) {
            //   value = element.value;
            // }
            DateTime? start;
            DateTime? end;
            final values = state.values[element.name];

            if (values is Map) {
              if (values.containsKey("from") && values["from"] != null) {
                start = DateFormat(element.formatDate).parse(values["from"]);
              }

              if (values.containsKey("to") && values["to"] != null) {
                end = DateFormat(element.formatDate).parse(values["to"]);
              }
            }

            return WDateRange(
              controller: listController[element.name] ?? TextEditingController(),
              // name: element.name,
              label: element.label,
              value: value,
              start: start,
              end: end,
              // required: getRequired(element),
              // errorText: state.errors[element.name],
              onChanged: (value) {
                context.read<WFormBloc<T>>().add(
                      WFormChangeValue(
                        name: element.name,
                        value: value.map(
                          (key, value) => MapEntry(
                            key.name,
                            value != null ? DateFormat(element.formatDate).format(value) : null,
                          ),
                        ),
                      ),
                    );
              },
              // validator: (txt) => validator(txt, element),
              stackedLabel: true,
            );
          },
        );
      }

      if (element is MFormDynamicSelectItem) {
        child = BlocBuilder<WFormBloc<T>, WFormState>(
          buildWhen: (previous, current) {
            return previous.values[element.name] != current.values[element.name];
          },
          builder: (context, state) {
            return WApiSelect(
              fillColor: element.fillColor,
              name: element.name,
              label: element.label,
              labelStyle: element.labelStyle,
              enabled: element.enabled?.call(state) ?? true,
              required: getRequired(element),
              disabledBorder: element.disabledBorder,
              onChanged: (value) {
                context.read<WFormBloc<T>>().add(
                      WFormChangeValue(
                        name: element.name,
                        value: value,
                      ),
                    );
              },
              value: element.valueBuilder.call(state.values[element.name]),
              controller: listController[element.name] ?? TextEditingController(),
              itemSelect: (content, int index) {},
              onTap: (void Function(dynamic) onChanged) {
                element.apiBuilder.call(onChanged, state.values[element.name]);
              },
              validator: (txt) => validator(txt, element, state.values),
              // stackedLabel: true,
            );
          },
        );
      }

      items[element.name] = child;
    }

    return Form(
      key: bloc.formKey,
      child: widget.builder?.call(items) ??
          SingleChildScrollView(
            padding: widget.padding,
            child: Column(
              children: <Widget>[
                ...items.entries.map((e) => Padding(
                      padding: EdgeInsets.only(top: widget.space),
                      child: e.value,
                    )),
              ],
            ),
          ),
    );
  }
}
