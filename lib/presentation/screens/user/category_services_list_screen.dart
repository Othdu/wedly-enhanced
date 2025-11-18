import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/logic/blocs/service/service_bloc.dart';
import 'package:wedly/logic/blocs/service/service_event.dart';
import 'package:wedly/logic/blocs/service/service_state.dart';
import 'package:wedly/presentation/widgets/category_service_card.dart';
import 'package:wedly/presentation/widgets/skeleton_loading.dart';

/// Generic screen for displaying services filtered by category
/// Used for all categories except venues (قاعات الأفراح)
/// Shows services with rating and price information
class CategoryServicesListScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryServicesListScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryServicesListScreen> createState() =>
      _CategoryServicesListScreenState();
}

class _CategoryServicesListScreenState
    extends State<CategoryServicesListScreen> {
  @override
  void initState() {
    super.initState();
    // Request services for this category when screen loads
    // TODO: API Integration - Replace with category-filtered API call
    context.read<ServiceBloc>().add(
      ServicesByCategoryRequested(widget.category.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Custom App Bar with golden background
          _buildAppBar(context),

          // Services List
          Expanded(
            child: BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                if (state is ServiceLoading) {
                  return _buildLoadingSkeleton();
                }

                if (state is ServiceError) {
                  return _buildErrorState(state.message);
                }

                if (state is ServicesByCategoryLoaded) {
                  if (state.services.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      // TODO: API Integration - Refresh category services
                      context.read<ServiceBloc>().add(
                        ServicesByCategoryRequested(widget.category.name),
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.services.length,
                      itemBuilder: (context, index) {
                        final service = state.services[index];
                        return CategoryServiceCard(
                          service: service,
                          onTap: () {
                            // TODO: Navigate to service details screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'عرض تفاصيل: ${service.name}',
                                  textDirection: TextDirection.rtl,
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Custom app bar with golden gradient background
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4AF37).withValues(alpha: 0.8),
            const Color(0xFFB8941E).withValues(alpha: 0.9),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          // Back button on the left (since Arabic is RTL)
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 24,
            ),
            padding: EdgeInsets.zero,
          ),

          const Spacer(),

          // Category name in center
          Text(
            widget.category.nameAr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),

          const Spacer(),

          // Empty space to balance the back button
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  /// Loading skeleton
  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SkeletonLoading.shimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image skeleton
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),
                // Content skeleton
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Error state
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ServiceBloc>().add(
                ServicesByCategoryRequested(widget.category.name),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'إعادة المحاولة',
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد خدمات في هذا القسم حالياً',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
