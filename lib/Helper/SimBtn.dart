import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Color.dart';

class SimBtn extends StatelessWidget {
  final String? title;
  final VoidCallback? onBtnSelected;
  double? width;
  double? height;

  SimBtn({Key? key, this.title, this.onBtnSelected, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width * width!;
    // height=height;
    return _buildBtnAnimation(context);
  }

  Widget _buildBtnAnimation(BuildContext context) {
    return CupertinoButton(
        padding: EdgeInsets.zero,
        child: Container(
            width: width,
            height: height,
            alignment: FractionalOffset.center,
            decoration: new BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.grad1Color, colors.grad2Color],
                  stops: [0, 1]),
              borderRadius: new BorderRadius.all(const Radius.circular(5.0)),
            ),
            child: Text(title!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    color: colors.whiteTemp, fontWeight: FontWeight.normal))),
        onPressed: onBtnSelected);
  }
}
