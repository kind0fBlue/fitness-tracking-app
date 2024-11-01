// on_boarding_view.dart
import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/on_boarding_page.dart';
import 'package:fitness/view/login/signup_view.dart';
import 'package:flutter/material.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  PageController controller = PageController();
  int pagenumber = 0;
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      pagenumber = controller.page?.round() ?? 0;

      setState(() {});
    });
  }

  List pageList = [
    {"title": "page1", "subtitle": "test code1"},
    {"title": "page2", "subtitle": "test code2"},
    {"title": "page3", "subtitle": "test code3"},
    {"title": "page4", "subtitle": "test code4"},
  ];
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Tcolor.White,
        body: Stack(
          alignment: Alignment.bottomRight,
          children: [
            PageView.builder(
              controller: controller,
              itemCount: pageList.length,
              itemBuilder: (context, index) {
                var pObj = pageList[index] as Map? ?? {};
                return OnBoardingPage(pObj: pObj);
              },
            ),
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: CircularProgressIndicator(
                      color: Tcolor.primaryColor1,
                      value: (pagenumber + 1) / pageList.length,
                      strokeWidth: 2,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 30),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: Tcolor.black,
                        borderRadius: BorderRadius.circular(35)),
                    child: IconButton(
                      icon: Icon(
                        Icons.navigate_next,
                        color: Tcolor.White,
                      ),
                      onPressed: () {
                        if (pagenumber < pageList.length - 1) {
                          pagenumber = pagenumber + 1;
                          controller.jumpToPage(pagenumber);
                          setState(() {});
                        } else {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupView()));
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
