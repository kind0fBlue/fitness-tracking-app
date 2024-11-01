//started_view.dart
import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/round_button.dart';
// import 'package:fitness/view/on_boarding/on_boarding_view.dart';
import 'package:fitness/view/on_boarding/splash_view.dart';
import 'package:flutter/material.dart';

class StartedView extends StatefulWidget {
  const StartedView({super.key});

  @override
  State<StartedView> createState() => _StartedViewState();
}

class _StartedViewState extends State<StartedView> {
  //初始页面颜色
  bool changecolor = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Tcolor.White,
      body: Container(
        width: media.width,
        height: media.height,
        decoration: BoxDecoration(
            gradient: changecolor
                ? LinearGradient(
                    colors: Tcolor.primaryG,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : null),
        child: Stack(alignment: Alignment.center, children: [
          Column(
              // 字幕这一列的位置
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  "Fitness",
                  style: TextStyle(
                    color: Tcolor.black,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "fitness makes life better",
                  style: TextStyle(
                    color: Tcolor.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                SafeArea(
                  child: Padding(
                     // padding: const EdgeInsets.symmetric(horizontal: 15),
                      padding: const EdgeInsets.only(left: 60, right: 60, bottom: 35),
                      child: RoundButton(
                          title: "Start",
                          type: changecolor
                              ? RoundButtonType.textGradient
                              : RoundButtonType.bgGradient,
                    /*      onPressed: () {
                            if (changecolor) {
                              //跳页
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SplashView()));
                            } else {
                              setState(() {
                                changecolor = true;
                              });
                            }
                         }*/
                        onPressed: () {
                          setState(() {
                            changecolor = true; // 先将颜色状态改为 true
                          });

                          // 设置一个延迟，让颜色变化后再跳转
                          Future.delayed(const Duration(milliseconds: 300), () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SplashView()),
                            );
                          });
                        },
                          )
                    ),
                ),
              ]),
        ]),
      ),
    );
  }
}
