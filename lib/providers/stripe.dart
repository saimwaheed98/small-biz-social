import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:smallbiz/helper/alert_dialouge.dart';
import 'package:smallbiz/helper/bottom_bar.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/images_strings.dart';

class PaymentController extends ChangeNotifier {
  // set loading when the payment is processing
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Map<String, dynamic>? paymentIntentData;
  Future<void> makePayment({
    required String amount,
    required String currency,
    required BuildContext context,
  }) async {
    try {
      setLoading(true);
      paymentIntentData = await createPaymentIntent(amount, currency);
      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Small Biz Social',
          customerId: paymentIntentData!['customer'],
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
        ));
        displayPaymentSheet(context, amount);
      }
    } catch (e, s) {
      setLoading(false);
      debugPrint('exception:$e$s');
    }
  }

  displayPaymentSheet(context, String amount) async {
    try {
      setLoading(true);
      await Stripe.instance.presentPaymentSheet();
      await Apis.updateSubscriptionStatus(true);
      await Apis.setSubscription(int.parse(amount));
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialouge(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(BottomBar.routename);
            },
            buttonText: 'Done',
            details:
                'Congrats! You have successfully subscribed to Small Biz Social! Make your first post now!',
            image: Images.alertEmoji,
            message: 'Woo hoo!!'),
      );
    } on Exception catch (e) {
      setLoading(false);
      if (e is StripeException) {
        debugPrint("Error from Stripe: ${e.error.localizedMessage}");
      } else {
        debugPrint("Unforeseen error: ${e.toString()}");
      }
    } catch (e) {
      setLoading(false);
      debugPrint("exception:$e");
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
                'Bearer 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',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      return jsonDecode(response.body);
    } catch (err) {
      debugPrint('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount) * 100);
    return a.toString();
  }
}
