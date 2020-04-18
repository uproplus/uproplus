import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:uproplus/ui/shared/text_styles.dart';

class AutoScrollText extends StatefulWidget {
  final double width;
  final String text;

  AutoScrollText({this.width, this.text});
  @override
  State<StatefulWidget> createState() => new _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController = new ScrollController();
  AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  initState() {
    double offset = -widget.width;
    double textWidth = _getTextWidth();
    super.initState();
    _animationController =
    new AnimationController(vsync: this, duration: Duration(seconds: 10))
      ..addListener(() {
        if (_animationController.isCompleted) {
          _animationController.repeat();
        }

        if (offset > textWidth) {
          offset = -widget.width;
        }
        offset += 1.0;
        setState(() {
          _scrollController.jumpTo(offset);
        });
      });
    _animationController.forward();
  }

  double _getTextWidth() {
    final constraints = BoxConstraints(
      maxWidth: widget.width,
      minHeight: 0.0,
      minWidth: 0.0,
    );

    final renderParagraph = RenderParagraph(
      TextSpan(
        text: widget.text,
        style: tickerStyle,
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    renderParagraph.layout(constraints);
    return renderParagraph.getMinIntrinsicWidth(tickerStyle.fontSize).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 4.0, right: 4.0, bottom: 4.0),
      child: Center(
        child: ListView(
          controller: _scrollController,
          children: [
            Center(child:  Text(widget.text, style: tickerStyle),)
          ],
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}
