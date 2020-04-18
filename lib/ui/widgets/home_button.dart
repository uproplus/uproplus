import 'package:flutter/material.dart';
import 'package:uproplus/ui/shared/text_styles.dart';

class HomeButtonView extends StatefulWidget {

  final Widget icon;
  final String japaneseText;
  final String englishText;
  final Function onPressedListener;

  HomeButtonView({
    @required this.icon,
    @required this.japaneseText,
    @required this.englishText,
    this.onPressedListener
  });

  @override
  _HomeButtonViewState createState() => _HomeButtonViewState();
}

class _HomeButtonViewState extends State<HomeButtonView> {

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: widget.onPressedListener,
        child: Container(
          padding: EdgeInsets.all(26),
          child: Column(
            children: [
              Expanded(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: widget.icon,
                  )
              ),
              Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.center,
                child: Text(
                  widget.japaneseText,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(40))
                ),
                child: Center(
                  child: Text(widget.englishText, style: mainButtonStyle,),
                ),
                width: 140,
                padding: EdgeInsets.all(5),
              )
            ],
          ),
        ),
      ),
    );
  }

}
