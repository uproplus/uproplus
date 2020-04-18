import 'package:flutter/material.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/widgets/adlist_item.dart';

class AddItem extends AdListItem {
  final Function onTap;

  AddItem({this.onTap}) : super(ad: Ad(), onTap: onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
//          margin: EdgeInsets.all(5.0),
          width: _viewWidth(context),
          height: _viewHeight(context),
          color: adMediaBackgroundColor,
          child: _getMediaWidget(context),
        ),
      ),
    );
  }

  Widget _getMediaWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: FittedBox(
              fit: BoxFit.contain,
              child: new IconTheme(
                data: new IconThemeData(
                    color: Colors.white54
                ),
                child: new Icon(Icons.add),
              ),
            )
        ),
      ],
    );
  }

  double _viewWidth(context) => MediaQuery.of(context).size.width / 2 - 10;
  double _viewHeight(context) => MediaQuery.of(context).size.height / 2 - 10;
}
