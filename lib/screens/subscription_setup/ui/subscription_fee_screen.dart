import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:smallbiz/helper/alert_dialouge.dart';
import 'package:smallbiz/helper/bottom_bar.dart';
import 'package:smallbiz/helper/images_strings.dart';
import 'package:smallbiz/helper/text_style.dart';
import 'package:smallbiz/utils/colors.dart';
import 'package:smallbiz/widgets/dropdown_textfield.dart';
import 'package:smallbiz/widgets/gesture_container.dart';

class SubscriptionFee extends StatelessWidget {
  SubscriptionFee({Key? key}) : super(key: key);

  static const String routeName = '/subscription_fee';

  final TextEditingController cardController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: scaffoldColor,
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.only(top: 25, left: 16, right: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: primaryPinkColor,
                      )),
                ),
                const AppTextStyle(
                    textName: 'Add subscription Fee ',
                    textColor: Colors.black,
                    textSize: 24,
                    textWeight: FontWeight.w900),
                const SizedBox(
                  height: 5,
                ),
                const AppTextStyle(
                    textName: 'Became the member , Please enter your details.',
                    textColor: primaryTextColor,
                    textSize: 12,
                    textWeight: FontWeight.w400),
                Padding(
                  padding: const EdgeInsets.only(top: 55, bottom: 20),
                  child: Center(
                    child: SizedBox(
                      height: 124,
                      width: 202,
                      child: Image.asset(Images.masterCardImage),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: DropDownFieldText(
                          isRequired: true,
                          inputName: 'Card Type',
                          cnt: cardController,
                          keyboardType: TextInputType.text,
                          hintText: 'Master Card',
                          onTap: () {},
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: DropDownFieldText(
                          isRequired: false,
                          inputName: 'Expire',
                          inputLenth: 5,
                          cnt: dateController,
                          onTap: () {},
                          keyboardType: TextInputType.datetime,
                          hintText: 'MM/YY',
                        ),
                      ),
                    ),
                  ],
                ),
                DropDownFieldText(
                    onTap: () {},
                    hintText: 'Enter Cardholder name',
                    keyboardType: TextInputType.name,
                    cnt: userNameController,
                    inputName: 'Cardholder Name',
                    isRequired: false),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: DropDownFieldText(
                          isRequired: false,
                          inputName: 'Card Number',
                          cnt: cardController,
                          keyboardType: TextInputType.text,
                          hintText: '5023 **** **** 1234',
                          onTap: () {},
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: DropDownFieldText(
                          isRequired: false,
                          inputName: 'CVV(?)',
                          inputLenth: 3,
                          cnt: dateController,
                          onTap: () {},
                          keyboardType: TextInputType.datetime,
                          hintText: 'C90',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 170,
                  child: DropDownFieldText(
                    isRequired: false,
                    inputName: 'Subscription Fee for monthly',
                    textSize: 20,
                    inputLenth: 3,
                    cnt: priceController,
                    onTap: () {},
                    keyboardType: TextInputType.datetime,
                    hintText: '\$7.99',
                  ),
                ),
                GestureContainer(
                    containerName: 'Pay Fee',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialouge(
                            onPressed: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: const BottomBar(),
                                withNavBar: true,
                              );
                            },
                            buttonText: 'Done',
                            details:
                                'Congrats! You have successfully subscribed to Small Biz Social! Make your first post now!',
                            image: Images.alertEmoji,
                            message: 'Woo hoo!!'),
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
