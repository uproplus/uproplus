import 'package:flutter/material.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/widgets/media_type_selection_view.dart';

class MediaTypeSelectionDialog extends StatefulWidget {

  final List<AdType> adTypes;
  final ValueChanged<AdType> onSelected;

  MediaTypeSelectionDialog({this.adTypes, this.onSelected});

  @override
  _MediaTypeSelectionDialogState createState() => _MediaTypeSelectionDialogState();
}

class _MediaTypeSelectionDialogState extends State<MediaTypeSelectionDialog> {
  AdType _selectedAdType;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetAnimationDuration: const Duration(milliseconds: 100),
//            shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 298,
        width: 190.0 * widget.adTypes.length + 12.0,
        child: Column(
          children: [
            Container(
              height: 50,
              padding: EdgeInsets.all(6),
              alignment: Alignment.center,
              child: Text(
                '広告種類選択',
                style: TextStyle(
                    fontSize: 30
                ),
              ),
            ),
            Expanded(
              child: MediaTypeSelectionView(
                adTypes: widget.adTypes,
                onSelected: (adType) {
                  setState(() {
                    _selectedAdType = adType;
                  });
                },
              ),
            ),
            Row(
              children: [
                Spacer(),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                      'キャンセル',
                      style: TextStyle(
                        color: dialogButtonColor,
                      )
                  ),
                ),
                FlatButton(
                  onPressed: _selectedAdType == null ? null : () {
                    Navigator.of(context).pop();
                    widget.onSelected(_selectedAdType);
                  },
                  textColor: dialogButtonColor,
                  disabledTextColor: dialogButtonDisabledColor,
                  child: Text('次へ'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
