import 'package:get/get.dart';

import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/edukasi/bindings/edukasi_binding.dart';
import '../modules/edukasi/views/edukasi_view.dart';
import '../modules/forgot/bindings/forgot_binding.dart';
import '../modules/forgot/views/forgot_view.dart';
import '../modules/history_quiz/bindings/history_quiz_binding.dart';
import '../modules/history_quiz/views/history_quiz_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/leaderboard/bindings/leaderboard_binding.dart';
import '../modules/leaderboard/views/leaderboard_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/login_history/bindings/login_history_binding.dart';
import '../modules/login_history/views/login_history_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/otp/bindings/otp_binding.dart';
import '../modules/otp/views/otp_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/quiz_level_detail/bindings/quiz_level_detail_binding.dart';
import '../modules/quiz_level_detail/views/quiz_level_detail_view.dart';
import '../modules/quizz_level/bindings/quizz_level_binding.dart';
import '../modules/quizz_level/views/quizz_level_view.dart';
import '../modules/quizz_timer/bindings/quizz_timer_binding.dart';
import '../modules/quizz_timer/views/quizz_timer_view.dart';
import '../modules/quizz_timer_detail/bindings/quizz_timer_detail_binding.dart';
import '../modules/quizz_timer_detail/views/quizz_timer_detail_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/transcribe/bindings/transcribe_binding.dart';
import '../modules/transcribe/views/transcribe_view.dart';
import '../modules/video_detail/bindings/video_detail_binding.dart';
import '../modules/video_detail/views/video_detail_view.dart';
import '../modules/webview/bindings/webview_binding.dart';
import '../modules/webview/views/webview_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.QUIZZ_LEVEL,
      page: () => const QuizzLevelView(),
      binding: QuizzLevelBinding(),
    ),
    GetPage(
      name: _Paths.QUIZZ_TIMER,
      page: () => const QuizzTimerView(),
      binding: QuizzTimerBinding(),
    ),
    GetPage(
      name: _Paths.LEADERBOARD,
      page: () => const LeaderboardView(),
      binding: LeaderboardBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT,
      page: () => const ForgotView(),
      binding: ForgotBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.EDUKASI,
      page: () => const EdukasiView(),
      binding: EdukasiBinding(),
    ),
    GetPage(
      name: _Paths.TRANSCRIBE,
      page: () => const TranscribeView(),
      binding: TranscribeBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.HISTORY_QUIZ,
      page: () => const HistoryQuizView(),
      binding: HistoryQuizBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_DETAIL,
      page: () => const VideoDetailView(),
      binding: VideoDetailBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: _Paths.WEBVIEW,
      page: () => const WebviewView(),
      binding: WebviewBinding(),
    ),
    GetPage(
      name: _Paths.QUIZ_LEVEL_DETAIL,
      page: () => const QuizLevelDetailView(),
      binding: QuizLevelDetailBinding(),
    ),
    GetPage(
      name: _Paths.QUIZZ_TIMER_DETAIL,
      page: () => const QuizzTimerDetailView(),
      binding: QuizzTimerDetailBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN_HISTORY,
      page: () => const LoginHistoryView(),
      binding: LoginHistoryBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
  ];
}
