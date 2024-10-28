import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DemoFormScreen extends StatelessWidget {
  const DemoFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WFormBloc<dynamic>(),
        ),
      ],
      child: const _Render(),
    );
  }
}

class _Render extends StatefulWidget {
  const _Render();

  @override
  State<_Render> createState() => _RenderState();
}

class _RenderState extends State<_Render> {
  final formKey = useWForm();
  late final WFormBloc<dynamic> blocForm;
  late List<String> multiDynamicSelect;

  @override
  void initState() {
    super.initState();

    blocForm = context.read<WFormBloc<dynamic>>();
    multiDynamicSelect = [];
  }

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      color:CupertinoColors.systemGrey,
    );

    Color fillColor(WFormState? state) {
      return CupertinoColors.lightBackgroundGray;
    }

    List<BaseForm> formItems = [
      // Text field
      MFormItem(
        name: 'text',
        label: 'Text Field',
        value: '',
        fillColor: fillColor,
        labelStyle: labelStyle,
        validators: [
          MValidateFormItem(
            require: true,
            message: 'Please input!',
          ),
        ],
      ),
      MFormItem(
        name: 'phone',
        label: 'Phone',
        value: '',
        fillColor: fillColor,
        labelStyle: labelStyle,
        keyboardType: TextInputType.phone,
        validators: [
          MValidateFormItem(
            require: true,
            message: 'Please input!',
          ),
          MValidateFormItem(
            message: 'Wrong format!',
            customCheck: (value, formValue) {
              String format = r'(84|0[3|5|7|8|9])+([0-9]{3,18})\b';
              return !RegExp(format).hasMatch(value.toString());
            },
          ),
        ],
      ),
      MFormItem(
        name: 'email',
        label: 'Email',
        value: '',
        fillColor: fillColor,
        labelStyle: labelStyle,
        keyboardType: TextInputType.emailAddress,
        validators: [
          MValidateFormItem(
            require: true,
            message: 'Please input!',
          ),
          MValidateFormItem(
            message: 'Wrong format!',
            customCheck: (value, formValue) {
              String format = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
              return !RegExp(format).hasMatch(value.toString());
            },
          ),
        ],
      ),
      MFormItem(
        name: 'password',
        label: 'Password',
        value: '',
        isPassword: true,
        fillColor: fillColor,
        labelStyle: labelStyle,
        validators: [
          MValidateFormItem(
            require: true,
            message: 'Please input!',
          ),
          MValidateFormItem(
            min: 6,
            message: 'Minimum 3 characters!',
          ),
        ],
      ),
      MFormItem(
        name: 'multiselect',
        label: 'Multiselect',
        value: '',
        fillColor: fillColor,
        labelStyle: labelStyle,
        type: EFormItem.multiSelect,
        validators: [
          MValidateFormItem(
            require: true,
            message: 'Please input!',
          ),
        ],
        itemsMulti: selectItems.map((e) => MultiSelectItem(e.value, e.name)).toList(),
      ),
      MFormItem(
        name: 'birthday',
        label: 'birthday',
        value: '',
        fillColor: fillColor,
        labelStyle: labelStyle,
        type: EFormItem.birthday,
        validators: [
          MValidateFormItem(
            require: true,
            message: 'Please input!',
          ),
        ],
      ),
      MFormItem(
        name: 'multiDynamicSelect',
        label: 'Multi Dynamic Select',
        value: '',
        fillColor: fillColor,
        labelStyle: labelStyle,
        type: EFormItem.multiDynamicSelect,
        onChanged: (list) {
          multiDynamicSelect = list.map((e) => e.value as String).toList();
        },
        customDynamicBuilder: (onChanged) {
          final list = selectItems.map((e) => MultiSelectItem(e.value, e.name)).toList();

          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, void Function(void Function()) setState) => AlertDialog(
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        final data = {
                          "value": multiDynamicSelect.map((e) => list.firstWhere((element) => element.value == e)).toList(),
                        };

                        Navigator.pop(context, data);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                  title: const Text('Selected'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              return CheckboxListTile(
                                title: Text(list[index].label),
                                value: multiDynamicSelect.contains(list[index].value),
                                onChanged: (isChecked) {
                                  multiDynamicSelect.removeWhere((e) => e == list[index].value);

                                  if (isChecked == true) {
                                    multiDynamicSelect.add(list[index].value);
                                  }

                                  // multiDynamicSelect = test;
                                  setState(() {});
                                },
                              );
                            },
                            separatorBuilder: (context, index) => const SizedBox(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ).then((data) {
            if (data is Map && data.containsKey('value')) {
              onChanged.call(() => data['value']);
            }
          });
        },
        validators: [
          MValidateFormItem(
            require: true,
            message: 'Please input!',
          ),
        ],
      ),

      // Date picker
      MFormDateItem(
        name: 'date',
        label: 'Date',
        fillColor: fillColor,
        labelStyle: labelStyle,
        format: 'dd-MM-yyyy',
        validators: [
          MValidateFormItem(
            require: true,
            message: 'Please input!',
          ),
        ],
      ),
      MFormDynamicSelectItem(
        labelStyle: labelStyle,
        fillColor: fillColor,
        name: "date_range",
        label: 'Date Range',
        value: '',
        validators: [
          MValidateFormItem(
            require: true,
            message: 'Please input!',
          ),
        ],
        apiBuilder: (onchange, value) {
          showDialog(
            context: context,
            builder: (context) {
              return const RangeDateWidget();
            },
          ).then((value) {
            if (value is Map && value.containsKey('date')) {
              onchange.call(value['date']);
            }
          });
        },
        valueBuilder: (value) {
          String name = '';

          try {
            if (value is Map && (value["start"] as String).isNotEmpty && (value["end"] as String).isNotEmpty) {
              name = "${value["start"]}   ->   ${value["end"]}";
            }
          } catch (ex) {
            //
          }

          return name;
        },
      ),

      // Select
      MFormChoiceChipItem(
        name: 'choice_chip',
        label: 'Choice Chip',
        value: '',
        labelStyle: labelStyle,
        items: selectItems.map((e) {
          return MChoiceChipData(value: e.value, name: e.name);
        }).toList(),
        validators: [
          MValidateFormItem(
            require: true,
            message: 'Please input!',
          ),
        ],
      ),
      MFormSelectItem(
        name: 'select',
        label: 'Select',
        value: '',
        items: selectItems.map((e) {
          return MWSelect(value: e.value, name: e.name);
        }).toList(),
        labelStyle: labelStyle,
        fillColor: fillColor,
        validators: [
          MValidateFormItem(
            require: true,
            message: 'Please input!',
          ),
        ],
      ),
      MFormDynamicSelectItem(
        fillColor: fillColor,
        labelStyle: labelStyle,
        apiBuilder: (onChanged, value) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('MFormDynamicSelectItem'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          shrinkWrap: true,
                          itemCount: selectItems.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                final data = {
                                  "value": selectItems[index].value,
                                };

                                Navigator.pop(context, data);
                              },
                              child: Ink(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(selectItems[index].name),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ).then((data) {
            if (data is Map && data.containsKey('value')) {
              onChanged.call(data['value']);
            }
          });
        },
        valueBuilder: (value) {
          String label = '';
          try {
            label = selectItems.firstWhere((e) => e.value == value).name;
          } catch (err) {
            label = '';
          }
          return label;
        },
        name: 'dynamic_select',
        label: 'Dynamic Select',
        value: '',
        validators: [
          MValidateFormItem(
            require: true,
            message: 'Please input!',
          ),
        ],
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Demo Form Screen'),
        trailing: IconButton(
          onPressed: () {
            blocForm.onFinish(showDialog: true,ignoreApi: true);
            // blocForm.onSubmit();
            // blocForm.onReset();
            // blocForm.add(WFormFinish(showDialog: true, ignoreValidate: false));
          },
          icon: const Icon(CupertinoIcons.checkmark_alt),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              WForm<dynamic>(
                space: 30,
                items: formItems,
                builder: (items) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items.entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: e.value,
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final List<_SelectItem> selectItems = [
  _SelectItem('1', 'One One OneOnevOneOneOneOne OneOne'),
  _SelectItem('2', 'Two'),
  _SelectItem('3', 'Three'),
  _SelectItem('4', 'Four'),
  _SelectItem('5', 'Five'),
  _SelectItem('6', 'Six'),
  _SelectItem('7', 'Seven'),
  _SelectItem('8', 'Eight'),
  _SelectItem('9', 'Nine'),
  _SelectItem('10', 'Ten'),
  _SelectItem('11', 'Eleven'),
];

class _SelectItem {
  final String value;
  final String name;

  _SelectItem(this.value, this.name);
}
