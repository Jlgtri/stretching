import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod/riverpod.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/business_logic.dart';
import 'package:stretching/widgets/authorization_screen.dart';
import 'package:stretching/widgets/navigation/modals/payment_picker.dart';
import 'package:stretching/widgets/navigation/screens/activities_screen.dart';
import 'package:stretching/widgets/navigation/screens/home_screen.dart';
import 'package:stretching/widgets/navigation/screens/studios_screen.dart';
import 'package:translit/translit.dart';

/// The [FirebaseAnalytics] instance.
final FirebaseAnalytics analytics = FirebaseAnalytics();

/// The provider of the [FutureProvider].
final FutureProvider<FirebaseMessaging> messagingProvider =
    FutureProvider<FirebaseMessaging>((final ref) async {
  final messaging = FirebaseMessaging.instance;
  await messaging.setAutoInitEnabled(true);
  await messaging.requestPermission();
  return messaging;
});

final Translit _translit = Translit();

/// The translit function.
String translit(final String source) =>
    _translit.toTranslit(source: source).replaceAll(' ', '_');

/// The translit function.
String faTime(final DateTime source) =>
    source.toString().split('.').first.split(' ').join(', ');

/// The keys for pushing [FirebaseAnalytics] logs.
abstract class FAKeys {
  const FAKeys._();

  /// The key for [SMStretchingAPI.addUser] event.
  static const String login = 'login';

  /// The key for opening an [AuthorizationScreen].
  static const String loginButton = 'login_btn_click';

  /// The click on [StoryCardScreen].
  static const String stories = 'stories_click';

  /// The click on the [StudiosScreen] card on map.
  static const String studioOnMap = 'studio_select';

  /// The event on [StudioScreenCard].
  static const String studioScreen = 'studio_view';

  /// The click on [HomeScreen] sign up for training button.
  static const String homeGoToSchedule = 'sign_up_for_training';

  /// The click on [ActivityCard] when [ActivityCard.onMain] is true.
  static const String upcomingRecordClick = 'upcoming_class_banner_click';

  /// The click on [ActivityScreenCard].
  static const String activity = 'exercise_screen_view';

  /// The key for [BusinessLogic.book] event on [ActivityCard].
  static const String book = 'schedule_go_to_btn_click';

  /// The key for [BusinessLogic.cancelBook] event on [ActivityCard].
  static const String cancelBook = 'schedule_cancel_btn_click';

  /// The key for [SMStretchingAPI.createWishlist] on [ActivityCard].
  static const String wishlist = 'schedule_wait_list_btn_click';

  /// The key for [BusinessLogic.book] event on [ActivityScreenCard].
  static const String bookScreen = 'class_go_to_btn_click';

  /// The key for [BusinessLogic.cancelBook] event on [ActivityScreenCard].
  static const String cancelBookScreen = 'class_cancel_btn_click';

  /// The key for [SMStretchingAPI.createWishlist] on [ActivityScreenCard].
  static const String wishlistScreen = 'class_wait_list_btn_click';

  /// The event on [showPaymentPickerBottomSheet].
  static const String paymentPicker = 'class_checkout_option_select';

  /// The selection of abonement on [PaymentPickerScreen].
  static const String abonementSelect = 'checkout_pass_options_select';

  /// The click on [PaymentPickerScreen] payment button with abonement.
  static const String abonementPicked = 'checkout_pass_options_select';

  /// The event on [BusinessLogic.payTinkoff].
  static const String purchase = 'purchase';
}
