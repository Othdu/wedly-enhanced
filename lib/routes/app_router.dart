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
import 'package:wedly/presentation/screens/auth/signup_otp_screen.dart';
import 'package:wedly/presentation/screens/auth/signup_success_screen.dart';
import 'package:wedly/presentation/screens/auth/provider_documents_screen.dart';
import 'package:wedly/presentation/screens/auth/role_selector_screen.dart';
import 'package:wedly/presentation/screens/provider/provider_navigation_wrapper.dart';
import 'package:wedly/presentation/screens/provider/provider_add_service_screen.dart';
import 'package:wedly/presentation/screens/provider/provider_edit_service_screen.dart';
import 'package:wedly/presentation/screens/provider/provider_edit_general_service_screen.dart';
import 'package:wedly/presentation/screens/provider/provider_edit_venue_service_screen.dart';
import 'package:wedly/presentation/screens/user/user_navigation_wrapper.dart';
import 'package:wedly/presentation/screens/user/user_cart_screen.dart';
import 'package:wedly/presentation/screens/user/user_edit_profile_screen.dart';
import 'package:wedly/presentation/screens/user/change_password_screen.dart';
import 'package:wedly/presentation/screens/user/user_address_screen.dart';
import 'package:wedly/presentation/screens/user/offers_list_screen.dart';
import 'package:wedly/presentation/screens/user/notifications_list_screen.dart';
import 'package:wedly/presentation/screens/user/terms_conditions_screen.dart';
import 'package:wedly/presentation/screens/user/help_and_support_screen.dart';
import 'package:wedly/presentation/screens/user/venues_list_screen.dart';
import 'package:wedly/presentation/screens/user/venue_booking_screen.dart';
import 'package:wedly/presentation/screens/user/category_services_list_screen.dart';
// OLD BOOKING SCREENS - Replaced with dynamic_service_booking_screen.dart
// import 'package:wedly/presentation/screens/user/photographer_booking_screen.dart';
// import 'package:wedly/presentation/screens/user/videographer_booking_screen.dart';
// import 'package:wedly/presentation/screens/user/makeupartist_booking_screen.dart';
// import 'package:wedly/presentation/screens/user/car_booking_screen.dart';
// import 'package:wedly/presentation/screens/user/wedding_dress_booking_screen.dart';
// import 'package:wedly/presentation/screens/user/decoration_booking_screen.dart';
// import 'package:wedly/presentation/screens/user/weddingplanner_booking_screen.dart';
import 'package:wedly/presentation/screens/user/dynamic_service_booking_screen.dart';
import 'package:wedly/logic/blocs/service/service_bloc.dart';
import 'package:wedly/logic/blocs/review/review_bloc.dart';
import 'package:wedly/logic/blocs/notification/notification_bloc.dart';
import 'package:wedly/presentation/screens/user/venue_details_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String signupOtp = '/signup-otp';
  static const String signupSuccess = '/signup-success';
  static const String providerDocuments = '/provider-documents';
  static const String roleSelector = '/role-selector';
  static const String userHome = '/user';
  static const String userCart = '/user-cart';
  static const String userEditProfile = '/user-edit-profile';
  static const String userChangePassword = '/user-change-password';
  static const String userAddress = '/user-address';
  static const String offersList = '/offers-list';
  static const String notificationsList = '/notifications-list';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String helpAndSupport = '/help-and-support';
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
  static const String dynamicServiceBooking = '/dynamic-service-booking';
  static const String providerHome = '/provider';
  static const String providerAddService = '/provider/add-service';
  static const String providerEditService = '/provider/edit-service';
  static const String providerEditGeneralService = '/provider/edit-general-service';
  static const String providerEditVenueService = '/provider/edit-venue-service';

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
      case signupOtp:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SignupOtpScreen(
            phoneOrEmail: args?['phoneOrEmail'] ?? '',
            userRole: args?['userRole'] ?? UserRole.user,
            name: args?['name'],
            password: args?['password'],
            phone: args?['phone'],
          ),
        );
      case signupSuccess:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              SignupSuccessScreen(userRole: args?['userRole'] ?? UserRole.user),
        );
      case providerDocuments:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProviderDocumentsScreen(
            name: args?['name'] ?? '',
            email: args?['email'] ?? '',
            password: args?['password'] ?? '',
            phone: args?['phone'] ?? '',
            city: args?['city'] ?? '',
          ),
        );
      case roleSelector:
        return MaterialPageRoute(builder: (_) => const RoleSelectorScreen());
      case userHome:
        return MaterialPageRoute(builder: (_) => const UserNavigationWrapper());
      case userCart:
        return MaterialPageRoute(builder: (_) => const UserCartScreen());
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
      case providerEditGeneralService:
        final args = settings.arguments as Map<String, dynamic>?;
        final service = args?['service'];
        if (service == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ProviderServiceBloc>(
            create: (_) => getIt<ProviderServiceBloc>(),
            child: ProviderEditGeneralServiceScreen(service: service),
          ),
        );
      case providerEditVenueService:
        final args = settings.arguments as Map<String, dynamic>?;
        final service = args?['service'];
        if (service == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ProviderServiceBloc>(
            create: (_) => getIt<ProviderServiceBloc>(),
            child: ProviderEditVenueServiceScreen(service: service),
          ),
        );
      case userEditProfile:
        return MaterialPageRoute(builder: (_) => const UserEditProfileScreen());
      case userChangePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case userAddress:
        return MaterialPageRoute(builder: (_) => const UserAddressScreen());
      case offersList:
        return MaterialPageRoute(builder: (_) => const OffersListScreen());
      case notificationsList:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<NotificationBloc>(
            create: (_) => getIt<NotificationBloc>(),
            child: const NotificationsListScreen(),
          ),
        );
      case termsAndConditions:
        return MaterialPageRoute(builder: (_) => const TermsConditionsScreen());
      case helpAndSupport:
        return MaterialPageRoute(builder: (_) => const HelpAndSupportScreen());
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
            child: VenueDetailsScreen(venue: venue),
          ),
        );
      case venueBooking:
        final args = settings.arguments as Map<String, dynamic>?;
        final venue = args?['venue'];
        final timeSlot = args?['timeSlot'] as String?;
        final decoration = args?['decoration'] as String?;
        if (venue == null || timeSlot == null || decoration == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) => VenueBookingScreen(
            venue: venue,
            timeSlot: timeSlot,
            decoration: decoration,
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
      // OLD BOOKING ROUTES - Now all use dynamicServiceBooking
      case photographerBooking:
      case videographerBooking:
      case makeupArtistBooking:
      case carBooking:
      case weddingDressBooking:
      case decorationBooking:
      case weddingPlannerBooking:
      case dynamicServiceBooking:
        final args = settings.arguments as Map<String, dynamic>?;
        final service = args?['service'];
        if (service == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (_) => DynamicServiceBookingScreen(service: service),
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
