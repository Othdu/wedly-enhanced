import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/logic/blocs/provider_service/provider_service_bloc.dart';
import 'package:wedly/logic/blocs/venue/venue_bloc.dart';
import 'package:wedly/presentation/screens/auth/login_screen.dart';
import 'package:wedly/presentation/screens/auth/signup_screen.dart';
import 'package:wedly/presentation/screens/auth/forgot_password_screen.dart';
import 'package:wedly/presentation/screens/auth/reset_password_screen.dart';
import 'package:wedly/presentation/screens/auth/otp_verification_screen.dart';
import 'package:wedly/presentation/screens/auth/signup_otp_screen.dart';
import 'package:wedly/presentation/screens/auth/signup_success_screen.dart';
import 'package:wedly/presentation/screens/auth/provider_documents_screen.dart';
import 'package:wedly/presentation/screens/auth/role_selector_screen.dart';
import 'package:wedly/presentation/screens/provider/provider_navigation_wrapper.dart';
import 'package:wedly/presentation/screens/provider/provider_add_service_screen.dart';
import 'package:wedly/presentation/screens/provider/provider_edit_service_screen.dart';
import 'package:wedly/presentation/screens/user/user_navigation_wrapper.dart';
import 'package:wedly/presentation/screens/user/user_edit_profile_screen.dart';
import 'package:wedly/presentation/screens/user/offers_list_screen.dart';
import 'package:wedly/presentation/screens/user/notifications_list_screen.dart';
import 'package:wedly/presentation/screens/user/venues_list_screen.dart';
import 'package:wedly/presentation/screens/user/venue_booking_screen.dart';
import 'package:wedly/presentation/screens/user/category_services_list_screen.dart';
import 'package:wedly/presentation/screens/user/photographer_booking_screen.dart';
import 'package:wedly/presentation/screens/user/videographer_booking_screen.dart';
import 'package:wedly/presentation/screens/user/makeupartist_booking_screen.dart';
import 'package:wedly/presentation/screens/user/car_booking_screen.dart';
import 'package:wedly/presentation/screens/user/wedding_dress_booking_screen.dart';
import 'package:wedly/presentation/screens/user/decoration_booking_screen.dart';
import 'package:wedly/presentation/screens/user/weddingplanner_booking_screen.dart';
import 'package:wedly/logic/blocs/service/service_bloc.dart';
import 'package:wedly/logic/blocs/review/review_bloc.dart';
import 'package:wedly/logic/blocs/notification/notification_bloc.dart';

class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String otpVerification = '/otp-verification';
  static const String signupOtp = '/signup-otp';
  static const String signupSuccess = '/signup-success';
  static const String providerDocuments = '/provider-documents';
  static const String roleSelector = '/role-selector';
  static const String userHome = '/user';
  static const String userEditProfile = '/user-edit-profile';
  static const String offersList = '/offers-list';
  static const String notificationsList = '/notifications-list';
  static const String venuesList = '/venues-list';
  static const String venueDetails = '/venue-details';
  static const String venueBooking = '/venue-booking';
  static const String categoryServices = '/category-services';
  static const String photographerBooking = '/photographer-booking';
  static const String videographerBooking = '/videographer-booking';
  static const String makeupArtistBooking = '/makeup-artist-booking';
  static const String carBooking = '/car-booking';
  static const String weddingDressBooking = '/wedding-dress-booking';
  static const String decorationBooking = '/decoration-booking';
  static const String weddingPlannerBooking = '/wedding-planner-booking';
  static const String providerHome = '/provider';
  static const String providerAddService = '/provider/add-service';
  static const String providerEditService = '/provider/edit-service';

  static void goToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  static void goToRoleSelector(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectorScreen()),
    );
  }

  static void goToUserHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const UserNavigationWrapper()),
      (route) => false,
    );
  }

  static void goToProviderHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProviderNavigationWrapper()),
      (route) => false,
    );
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneOrEmail: args?['phoneOrEmail'] ?? '',
            isForPasswordReset: args?['isForPasswordReset'] ?? false,
          ),
        );
      case signupOtp:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SignupOtpScreen(
            phoneOrEmail: args?['phoneOrEmail'] ?? '',
            userRole: args?['userRole'] ?? UserRole.user,
          ),
        );
      case signupSuccess:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              SignupSuccessScreen(userRole: args?['userRole'] ?? UserRole.user),
        );
      case providerDocuments:
        return MaterialPageRoute(
          builder: (_) => const ProviderDocumentsScreen(),
        );
      case roleSelector:
        return MaterialPageRoute(builder: (_) => const RoleSelectorScreen());
      case userHome:
        return MaterialPageRoute(builder: (_) => const UserNavigationWrapper());
      case providerHome:
        return MaterialPageRoute(
          builder: (_) => const ProviderNavigationWrapper(),
        );
      case providerAddService:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ProviderServiceBloc>(
            create: (_) => getIt<ProviderServiceBloc>(),
            child: const ProviderAddServiceScreen(),
          ),
        );
      case providerEditService:
        final args = settings.arguments as Map<String, dynamic>?;
        final service = args?['service'];
        if (service == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ProviderServiceBloc>(
            create: (_) => getIt<ProviderServiceBloc>(),
            child: ProviderEditServiceScreen(service: service),
          ),
        );
      case userEditProfile:
        return MaterialPageRoute(builder: (_) => const UserEditProfileScreen());
      case offersList:
        return MaterialPageRoute(builder: (_) => const OffersListScreen());
      case notificationsList:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<NotificationBloc>(
            create: (_) => getIt<NotificationBloc>(),
            child: const NotificationsListScreen(),
          ),
        );
      case venuesList:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<VenueBloc>(
            create: (_) => getIt<VenueBloc>(),
            child: const VenuesListScreen(),
          ),
        );
      case venueDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final venue = args?['venue'];
        if (venue == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ReviewBloc>(
            create: (_) => getIt<ReviewBloc>(),
            child: VenueBookingScreen(venue: venue),
          ),
        );
      case venueBooking:
        final args = settings.arguments as Map<String, dynamic>?;
        final venue = args?['venue'];
        if (venue == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) => VenueBookingScreen(
            venue: venue,
          ),
        );
      case categoryServices:
        final args = settings.arguments as Map<String, dynamic>?;
        final category = args?['category'];
        if (category == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ServiceBloc>(
            create: (_) => getIt<ServiceBloc>(),
            child: CategoryServicesListScreen(category: category),
          ),
        );
      case photographerBooking:
        final args = settings.arguments as Map<String, dynamic>?;
        final service = args?['service'];
        final offer = args?['offer'];
        if (service == null && offer == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) =>
              PhotographerBookingScreen(service: service, offer: offer),
        );
      case videographerBooking:
        final args = settings.arguments as Map<String, dynamic>?;
        final service = args?['service'];
        final offer = args?['offer'];
        // Convert offer to service if needed (temporary solution)
        if (service == null && offer == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) =>
              VideographerBookingScreen(service: service ?? offer?.toService()),
        );
      case makeupArtistBooking:
        final args = settings.arguments as Map<String, dynamic>?;
        final service = args?['service'];
        final offer = args?['offer'];
        // Convert offer to service if needed (temporary solution)
        if (service == null && offer == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) =>
              MakeupArtistBookingScreen(service: service ?? offer?.toService()),
        );
      case carBooking:
        final args = settings.arguments as Map<String, dynamic>?;
        final service = args?['service'];
        final offer = args?['offer'];
        // Convert offer to service if needed (temporary solution)
        if (service == null && offer == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) =>
              CarBookingScreen(service: service ?? offer?.toService()),
        );
      case weddingDressBooking:
        final args = settings.arguments as Map<String, dynamic>?;
        final service = args?['service'];
        final offer = args?['offer'];
        if (service == null && offer == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) =>
              WeddingDressBookingScreen(service: service, offer: offer),
        );
      case decorationBooking:
        final args = settings.arguments as Map<String, dynamic>?;
        final service = args?['service'];
        final offer = args?['offer'];
        if (service == null && offer == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) =>
              DecorationBookingScreen(service: service, offer: offer),
        );
      case weddingPlannerBooking:
        final args = settings.arguments as Map<String, dynamic>?;
        final service = args?['service'];
        final offer = args?['offer'];
        if (service == null && offer == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) =>
              WeddingPlannerBookingScreen(service: service, offer: offer),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }

  static Widget getInitialRoute(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // Check role and navigate accordingly
          // For now, show role selector
          return const RoleSelectorScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
