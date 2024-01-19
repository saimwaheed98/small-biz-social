import 'package:flutter/widgets.dart';
import 'package:smallbiz/helper/firebase_helper.dart';
import 'package:smallbiz/helper/warning_helper.dart';
import 'package:smallbiz/models/user_bussiness_details_model.dart';

class SubscriptionSetupProvider extends ChangeNotifier {
  // check if the checkbox is checked or not
  bool _isChecked = false;
  bool get isChecked => _isChecked;

  void changeIsChecked(bool value) {
    _isChecked = value;
    notifyListeners();
  }

  // check if the proccess is loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  final GlobalKey<FormState> formState = GlobalKey<FormState>();

  // controllers
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController bussinessNameController = TextEditingController();
  TextEditingController businessLinkController = TextEditingController();
  TextEditingController einNumberController = TextEditingController();

  // clear controllers
  void clearControllers() {
    firstNameController.text = '';
    lastNameController.text = '';
    bussinessNameController.text = '';
    businessLinkController.text = '';
    einNumberController.text = '';
  }

  Future<void> createBussiness(
      {required String firstName,
      required String lastName,
      required String uid,
      required String bussinessName,
      required String businessLink,
      required String einNumber,
      required BuildContext context}) async {
    try {
      setLoading(true);
      var time = DateTime.now().millisecondsSinceEpoch.toString();
      var ref =
          Apis.firestore.collection('users').doc(Apis.auth.currentUser!.uid);
      BussinessModel bussinessDetails = BussinessModel(
          firstName: firstName,
          uid: uid,
          lastName: lastName,
          createdAt: time,
          bussinessName: bussinessName,
          businessLink: businessLink,
          einNumber: einNumber);
      await ref
          .collection('business')
          .doc('details')
          .set(bussinessDetails.toJson())
          .onError((error, stackTrace) {
        WarningHelper.showWarningDialog(context, 'Error', error.toString());
        debugPrint(error.toString());
      });
    } catch (e) {
      setLoading(false);
      debugPrint(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
