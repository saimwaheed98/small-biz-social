import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:smallbiz/helper/bottom_bar.dart';
import 'package:smallbiz/helper/image_picker.dart';
import 'package:smallbiz/providers/bool_function_proider.dart';
import 'package:smallbiz/providers/bottom_bar_provider.dart';
import 'package:smallbiz/providers/stripe.dart';
import 'package:smallbiz/referal_link/create_link.dart';
import 'package:smallbiz/screens/chat_room/provider/chat_room_provider.dart';
import 'package:smallbiz/screens/chat_room/ui/chat_room_screen.dart';
import 'package:smallbiz/screens/create_account/provider/create_account_providers.dart';
import 'package:smallbiz/screens/create_account/provider/profile_picture_provider.dart';
import 'package:smallbiz/screens/create_account/ui/create_account_screen.dart';
import 'package:smallbiz/screens/create_account/ui/profile_picture_screen.dart';
import 'package:smallbiz/screens/home/provider/create_post_screen_provider.dart';
import 'package:smallbiz/screens/home/provider/home_screen_provider.dart';
import 'package:smallbiz/screens/home/provider/post_screen_provider.dart';
import 'package:smallbiz/screens/home/ui/home_screen.dart';
import 'package:smallbiz/screens/home/ui/post_screen.dart';
import 'package:smallbiz/screens/profile_percent_indicater/profile_percent_indicater.dart';
import 'package:smallbiz/screens/sign_in/provider/sign_in_screen_provider.dart';
import 'package:smallbiz/screens/splash_screen/providers/splash_screen_provider.dart';
import 'package:smallbiz/screens/splash_screen/splash_screen.dart';
import 'package:smallbiz/screens/subscription_setup/provider/subscription_setup.dart';
import 'package:smallbiz/screens/subscription_setup/ui/subscription_fee_screen.dart';
import 'package:smallbiz/screens/subscription_setup/ui/subscription_setup_screen.dart';
import 'package:smallbiz/screens/user_profile/provider/profile_setting_provider.dart';
import 'package:smallbiz/screens/user_profile/ui/user_profile_screen.dart';
import 'package:smallbiz/screens/users_chat/provider/chat_screen_provider.dart';
import 'firebase_options.dart';
import '.env';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = StripePublishableKey;
  await Stripe.instance.applySettings();
  _createNotificationChannel();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => HomeScreenProvider()),
    ChangeNotifierProvider(
      create: (context) => CreateAccountProviders(),
    ),
    ChangeNotifierProvider(
      create: (context) => SigninProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => ProfilePictureProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => BoolFunctionProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => ImagePickerProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => ChatScreenProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => CreatePostScreenProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => PostScreenProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => InternetConnectionProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => BottomBarProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => ChatRoomProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => ProfileSettingProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => PaymentController(),
    ),
    ChangeNotifierProvider(
      create: (context) => SubscriptionSetupProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => DeepLinkService(),
    )
  ], child: const MyApp()));
}

_createNotificationChannel() async {
  await FlutterNotificationChannel.registerNotificationChannel(
    description: 'This channel is used for important notifications',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
    visibility: NotificationVisibility.VISIBILITY_PUBLIC,
    allowBubbles: true,
    enableVibration: true,
    enableSound: true,
    showBadge: true,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Small Biz Social',
      themeMode: ThemeMode.system,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        BottomBar.routename: (context) => const BottomBar(),
        HomeScreen.routeName: (context) => HomeScreen(),
        UserProfile.routename: (context) => UserProfile(),
        ChatRoomScreen.routename: (context) => const ChatRoomScreen(),
        PostScreen.routeName: (context) => PostScreen(),
        CreateAccount.routeName: (context) => CreateAccount(),
        ProfilePicture.routeName: (context) => const ProfilePicture(),
        SubscriptionSetup.routename: (context) => SubscriptionSetup(),
        SubscriptionFee.routeName: (context) => SubscriptionFee(),
        ProfilePercentage.routeName: (context) => const ProfilePercentage(),
      },
    );
  }
}
