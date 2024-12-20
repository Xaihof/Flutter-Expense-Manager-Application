import 'package:f_expence_manager/page/navigation_expense_category_page.dart';
import 'package:f_expence_manager/page/navigation_income_category_page.dart';
import 'package:flutter/material.dart';

import '../ui/app_colors.dart';

class NavigationCategoryHostPage extends StatefulWidget {
  const NavigationCategoryHostPage({super.key});

  @override
  State<NavigationCategoryHostPage> createState() =>
      _NavigationCategoryHostPageState();
}

class _NavigationCategoryHostPageState
    extends State<NavigationCategoryHostPage> {
  bool showSecondScreen = false;
  double sliderPosition = 0.0;
  double innerSliderPosition = 0.0;
  String? appBarText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          showSecondScreen
              ? appBarText = "Expense Categories"
              : appBarText = "Income Categories",
          style: const TextStyle(color: AppColors.blue),
        ),
      ),
      body: Column(
        children: [
          InkWell(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  sliderPosition += details.delta.dx;
                  sliderPosition = sliderPosition.clamp(
                      0.0, MediaQuery.of(context).size.width - 100);
                  innerSliderPosition += details.delta.dx;
                  innerSliderPosition = innerSliderPosition.clamp(0.0, 50.0);
                });
              },
              child: AnimatedPositioned(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeInOut,
                left: sliderPosition,
                child: Container(
                  height: 35,
                  width: 210,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.5),
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: [
                      const Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "Income",
                              style: TextStyle(
                                color: AppColors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Expense",
                              style: TextStyle(
                                color: AppColors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 280),
                        alignment: showSecondScreen
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(3.5),
                          child: Container(
                            height: 35,
                            width: 91,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.5),
                              color: AppColors.blue,
                            ),
                            child: Center(
                              child: Text(
                                showSecondScreen ? 'Expense' : 'Income',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () {
              setState(() {
                showSecondScreen
                    ? showSecondScreen = false
                    : showSecondScreen = true;
              });
            },
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0) {
                  // Slide to the right, navigate to the previous screen
                  if (showSecondScreen) {
                    setState(() {
                      showSecondScreen = false;
                      sliderPosition = 0.0;
                      innerSliderPosition = 0.0;
                    });
                  }
                } else if (details.delta.dx < 0) {
                  // Slide to the left, navigate to the next screen
                  if (!showSecondScreen) {
                    setState(() {
                      showSecondScreen = true;
                      sliderPosition = MediaQuery.of(context).size.width - 100;
                      innerSliderPosition = 50.0;
                    });
                  }
                }
              },
              child: IndexedStack(
                index: showSecondScreen ? 1 : 0,
                children: const [
                  NavigationIncomeCategoryPage(),
                  NavigationExpenseCategoryPage(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
