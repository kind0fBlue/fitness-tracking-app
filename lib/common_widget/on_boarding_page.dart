import 'package:fitness/common/colo_extension.dart';
import 'package:flutter/material.dart';

class OnBoardingPage extends StatefulWidget {
  final Map pObj;
  const OnBoardingPage({super.key, required this.pObj});

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return SizedBox(
      width: media.width,
      height: media.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: media.width * 0.1),
          //title 部分
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              widget.pObj["title"].toString(),  // 使用 widget 来访问 pObj
              style: TextStyle(
                color: Tcolor.black,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          //subtitle 部分
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              widget.pObj["subtitle"].toString(),
              style: TextStyle(
                color: Tcolor.grey,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}