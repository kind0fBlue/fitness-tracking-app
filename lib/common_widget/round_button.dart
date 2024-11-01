import 'package:fitness/common/colo_extension.dart';
import 'package:flutter/material.dart';

enum RoundButtonType { bgGradient, textGradient}

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final RoundButtonType type;
 // final RoundButtonType size;
  const RoundButton(
      {super.key,
      required this.title,
      this.type = RoundButtonType.textGradient,
   //   this.size = RoundButtonType.textStyle,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: Tcolor.primaryG,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(25),
        boxShadow: type == RoundButtonType.bgGradient
            ? const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 2, offset: Offset(0, 2))
              ]
            : null,
      ),
      //started页面按钮
      child: MaterialButton(
        onPressed: onPressed,
        height: 50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textColor: Tcolor.primaryColor1,
        minWidth: double.maxFinite,
        elevation: type == RoundButtonType.bgGradient ? 0 : 1,
        color: type == RoundButtonType.bgGradient
            ? Colors.transparent
            : Tcolor.White,
        //渐变
        child: type == RoundButtonType.bgGradient
            //白页的started信息
            ? Text(
                title,
                style: TextStyle(
                  color: Tcolor.White,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              )
            : ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return LinearGradient(
                          colors: Tcolor.primaryG,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight)
                      .createShader(
                          Rect.fromLTRB(0, 0, bounds.width, bounds.height));
                },
                //蓝页的start信息
                child: Text(
                  title,
                  style: TextStyle(
                    color: Tcolor.primaryColor1,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
      ),
    );
  }
}
