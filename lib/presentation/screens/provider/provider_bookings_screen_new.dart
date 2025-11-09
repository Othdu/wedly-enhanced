import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/enums.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../../logic/blocs/booking/booking_bloc.dart';
import '../../../logic/blocs/booking/booking_event.dart';
import '../../../logic/blocs/booking/booking_state.dart';
import '../../widgets/booking_card_new.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _providerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _providerId = authState.user.id;
        _fetchBookingsByStatus(BookingStatus.pending);
      }
    });

    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && _providerId != null) {
      BookingStatus status;
      switch (_tabController.index) {
        case 0:
          status = BookingStatus.pending;
          break;
        case 1:
          status = BookingStatus.confirmed;
          break;
        case 2:
          status = BookingStatus.completed;
          break;
        default:
          status = BookingStatus.pending;
      }
      _fetchBookingsByStatus(status);
    }
  }

  void _fetchBookingsByStatus(BookingStatus status) {
    if (_providerId != null) {
      context.read<BookingBloc>().add(
            FetchBookingsByStatus(_providerId!, status),
          );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحجوزات'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'الحجوزات الجديدة'),
            Tab(text: 'الحجوزات المؤكدة'),
            Tab(text: 'الحجوزات المكتملة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList(BookingStatus.pending),
          _buildBookingsList(BookingStatus.confirmed),
          _buildBookingsList(BookingStatus.completed),
        ],
      ),
    );
  }

  Widget _buildBookingsList(BookingStatus status) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFD4AF37),
            ),
          );
        }

        if (state is BookingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _fetchBookingsByStatus(status),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is BookingsEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          );
        }

        if (state is BookingsLoaded) {
          final bookings = state.bookings;

          return RefreshIndicator(
            onRefresh: () async {
              _fetchBookingsByStatus(status);
            },
            color: const Color(0xFFD4AF37),
            child: ListView.builder(
              itemCount: bookings.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return BookingCard(
                  booking: booking,
                  showDiscount: index % 2 == 0, // Show discount on alternating cards for demo
                  onViewDetails: () {
                    // TODO: Navigate to booking details
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('قريباً: تفاصيل الحجز')),
                    );
                  },
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
