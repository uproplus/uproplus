import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uproplus/core/viewmodels/base_model.dart';
import 'package:uproplus/ui/views/base_view.dart';

import '../../locator.dart';

class BaseViewNotifier<T extends BaseModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget child) builder;
  final Function(T) onModelReady;

  BaseViewNotifier({this.builder, this.onModelReady});

  @override
  _BaseViewNotifierState<T> createState() => _BaseViewNotifierState<T>();
}

class _BaseViewNotifierState<T extends BaseModel> extends State<BaseViewNotifier<T>> {
  T model = locator<T>();

  @override
  void initState() {
    if (widget.onModelReady != null) {
      widget.onModelReady(model);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      body: ChangeNotifierProvider<T>(
          builder: (context) => model,
          child: Consumer<T>(builder: widget.builder))
    );
  }
}
