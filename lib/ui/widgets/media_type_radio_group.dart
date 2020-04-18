import 'package:flutter/material.dart';

class MediaTypeRadioGroup extends StatefulWidget {
  MediaTypeRadioGroup(this.mediaTypes, this.onSelectedListener);

  final List<int> mediaTypes;
  final Function onSelectedListener;

  @override
  _MediaTypeRadioGroupState createState() => _MediaTypeRadioGroupState();
}

class _MediaTypeRadioGroupState extends State<MediaTypeRadioGroup> {
  int _selectedMediaType;

  @override
  Widget build(BuildContext context) {
    return ListBody(
      children: new List<RadioListTile<int>>.generate(
          widget.mediaTypes.length,
          (index) {
            return RadioListTile(
              title: _getTitle(index),
              value: widget.mediaTypes[index],
              groupValue: _selectedMediaType,
              onChanged: (selected) {
                setState(() {
                  _selectedMediaType = selected;
                  widget.onSelectedListener(selected);
                });
              },
            );
          }
      ),
    );
  }

  Widget _getTitle(int index) {
    switch (widget.mediaTypes[index]) {
      case 101:
        return const Text("Local Image");
      case 102:
        return const Text("Image Url");
      case 201:
        return const Text("Local Video");
      case 202:
        return const Text("Video Url");
      default:
        return const Text("");
    }
  }
}
